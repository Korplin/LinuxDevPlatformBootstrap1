#!/usr/bin/env bash
# =============================================================================
# devplatform — Bootstrap Entry Point
# =============================================================================
# This script does ONE job: prepare the system for Ansible, then hand off.
# All real system configuration lives in devplatform.yml — NOT here.
#
# Philosophy: bash is the ignition key. Ansible is the engine.
#
# Repository: https://github.com/Korplin/LinuxDevPlatformBootstrap
# =============================================================================

set -euo pipefail

# ── Colour helpers ─────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}  →${RESET}  $*"; }
success() { echo -e "${GREEN}  ✓${RESET}  $*"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET}  $*"; }
die()     { echo -e "${RED}  ✗  ERROR:${RESET} $*" >&2; exit 1; }

# ── Header ─────────────────────────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
cat <<'EOF'
  ██████╗ ███████╗██╗   ██╗██████╗ ██╗      █████╗ ████████╗███████╗ ██████╗ ██████╗ ███╗   ███╗
  ██╔══██╗██╔════╝██║   ██║██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗████╗ ████║
  ██║  ██║█████╗  ██║   ██║██████╔╝██║     ███████║   ██║   █████╗  ██║   ██║██████╔╝██╔████╔██║
  ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║
  ██████╔╝███████╗ ╚████╔╝ ██║     ███████╗██║  ██║   ██║   ██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║
  ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
EOF
echo -e "${RESET}"
echo -e "  ${BOLD}Linux Developer Platform — Bootstrap${RESET}"
echo -e "  ${CYAN}https://github.com/Korplin/LinuxDevPlatformBootstrap${RESET}"
echo ""

# ── Guard: must run as root ────────────────────────────────────────────────────
# We require root so Ansible can install packages and configure the system
# without repeated sudo prompts breaking the automated flow.
# Correct usage: sudo bash bootstrap.sh
if [[ "$EUID" -ne 0 ]]; then
    die "This script must run as root.\n\n  Run:  sudo bash bootstrap.sh"
fi

# ── Guard: must be Debian ──────────────────────────────────────────────────────
if [[ ! -f /etc/os-release ]]; then
    die "/etc/os-release not found. Is this actually Debian?"
fi
# shellcheck source=/dev/null
source /etc/os-release
if [[ "$ID" != "debian" ]]; then
    die "This script targets Debian. Detected: ${PRETTY_NAME:-unknown}"
fi
info "Detected OS: ${PRETTY_NAME}"

# ── Derive the real user (the one who will log into the desktop) ───────────────
# SUDO_USER is set when the script is invoked via sudo.
# If run directly as root (e.g. in a VM console), we prompt.
if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    DEV_USER="$SUDO_USER"
    info "Configuring desktop for user: ${BOLD}${DEV_USER}${RESET}"
else
    warn "SUDO_USER is not set. Who is the primary desktop user?"
    read -rp "  Enter username: " DEV_USER
    if ! id "$DEV_USER" &>/dev/null; then
        die "User '${DEV_USER}' does not exist. Create the user first, then re-run."
    fi
fi
export DEV_USER

# ── Step 1: Refresh apt and install bootstrap prerequisites ────────────────────
echo ""
info "Updating apt package index..."
apt-get update -qq

info "Installing bootstrap prerequisites..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    curl \
    wget \
    gnupg \
    ca-certificates \
    lsb-release \
    python3 \
    python3-pip \
    python3-apt \
    jq

success "Prerequisites installed."

# ── Step 2: Install Ansible ────────────────────────────────────────────────────
if command -v ansible-playbook &>/dev/null; then
    ANSIBLE_VER=$(ansible --version 2>/dev/null | head -1)
    success "Ansible already present: ${ANSIBLE_VER}"
else
    info "Installing Ansible..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ansible
    success "Ansible installed: $(ansible --version | head -1)"
fi

# ── Step 3: Fetch Ansible playbook from GitHub ─────────────────────────────────
REPO_RAW="https://raw.githubusercontent.com/Korplin/LinuxDevPlatformBootstrap/main"
PLAYBOOK_NAME="devplatform.yml"
PLAYBOOK_DEST="/root/${PLAYBOOK_NAME}"

info "Fetching playbook from GitHub..."
wget -q --show-progress -O "${PLAYBOOK_DEST}" "${REPO_RAW}/${PLAYBOOK_NAME}" \
    || die "Failed to download playbook.\n  URL: ${REPO_RAW}/${PLAYBOOK_NAME}\n  Check your internet connection."

success "Playbook saved to ${PLAYBOOK_DEST}"

# ── Step 4: Hand off to Ansible ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  Handing control to Ansible.${RESET}"
echo -e "  Every task below is a declared state being enforced."
echo -e "  Running again later will only change what has drifted."
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# -i "localhost,"   — single host inventory (the comma is intentional, it denotes a list)
# -c local          — no SSH, run directly on this machine
# --diff            — show what changed in config files (educational output)
# -e dev_user       — pass the real user into the playbook
ansible-playbook "${PLAYBOOK_DEST}" \
    -i "localhost," \
    -c local \
    --diff \
    -e "dev_user=${DEV_USER}"

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}  Bootstrap complete.${RESET}"
echo -e ""
echo -e "  KDE Plasma, drivers, and all tools are now provisioned."
echo -e "  ${BOLD}Reboot to start your desktop environment:${RESET}"
echo -e ""
echo -e "    ${BOLD}sudo reboot${RESET}"
echo -e ""
echo -e "  Running this script again is safe — Ansible is idempotent."
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
