The Exact Command
On your fresh Debian 13 VM (SSH in as your user, then):

wget -O bootstrap.sh https://raw.githubusercontent.com/Korplin/LinuxDevPlatformBootstrap/main/bootstrap.sh && sudo bash bootstrap.sh

After reboot, set JetBrainsMono Nerd Font in Konsole settings — otherwise the prompt icons render as squares.

# Delete later

sudo rm -f /etc/apt/keyrings/kubernetes.gpg
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update


