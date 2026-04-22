





# Claude 1

## Command

wget -O bootstrap.sh https://raw.githubusercontent.com/Korplin/LinuxDevPlatformBootstrap/main/bootstrap.sh && sudo bash bootstrap.sh

## Postinstall

After reboot, set JetBrainsMono Nerd Font in Konsole settings — otherwise the prompt icons render as squares.

# Claude 2

## Command

wget -O devplatformbootstrap.sh https://raw.githubusercontent.com/Korplin/LinuxDevPlatformBootstrap/main/devplatformbootstrap.sh && bash devplatformbootstrap.sh

## Postinstall

Manual steps required after the playbook finishes

sudo reboot — required for GPU drivers, kernel modules, nouveau blacklist, sddm startup, and all group membership changes (docker, libvirt, kvm) to take effect
Log in via KDE Plasma — sddm starts automatically after reboot
Set your git identity (per-user, not system-wide):

bash   git config --global user.name  "Your Name"
   git config --global user.email "you@example.com"

Authenticate GitHub CLI: gh auth login
Konsole Powerline font — in Konsole → Settings → Edit Current Profile → Appearance → Font — pick a Powerline font (e.g. DejaVu Sans Mono for Powerline) so the agnoster theme renders arrow separators correctly

# GPT 2

## Command

wget -O devplatformbootstrap.sh https://raw.githubusercontent.com/Korplin/LinuxDevPlatformBootstrap/main/devplatformbootstrap.sh && bash devplatformbootstrap.sh

## Postinstall

Manual steps after the playbook finishes
Reboot the machine.
sudo reboot
Log in again.

This is needed so these changes actually take effect:

KDE Plasma / SDDM starts cleanly
docker, libvirt, and kvm group membership activates
zsh becomes the user’s default shell
NVIDIA / AMD / Intel / VM guest drivers load properly
Cursor appears in the KDE application menu

Tiny caveat goblin 🛠️: the Cursor AppImage URL installs whatever Cursor currently publishes as “latest,” so future Cursor changes could affect that one part. Everything else is pinned to apt repositories or Debian packages.

# Claude 2

Manual steps required after the playbook finishes

sudo reboot — required for GPU drivers, kernel modules, nouveau blacklist, sddm startup, and all group membership changes (docker, libvirt, kvm) to take effect
Log in via KDE Plasma — sddm starts automatically after reboot
Set your git identity (per-user, not system-wide):

bash   git config --global user.name  "Your Name"
   git config --global user.email "you@example.com"

Authenticate GitHub CLI: gh auth login
Konsole Powerline font — in Konsole → Settings → Edit Current Profile → Appearance → Font — pick a Powerline font (e.g. DejaVu Sans Mono for Powerline) so the agnoster theme renders arrow separators correctly
