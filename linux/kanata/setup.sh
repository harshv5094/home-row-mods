#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

function have() {
  command -v "$1" &>/dev/null
}

function cmdCheck() {
  if [ $? -eq 0 ]; then
    printf "%b" "${GREEN}$1${RESET}"
  else
    printf "%b" "${RED}Fail!!${RESET}"
  fi
}

function main() {
  printf "%b\n" "${CYAN}***Welcome to Home Mod Row Keybinding setup***${RESET}"

  # NOTE: Installing Kanata Package
  if have paru; then
    printf "%b\n" "${YELLOW}**Installing kanata-bin from paru**${RESET}"
    paru -S kanata-bin
  else
    printf "%b" "${RED}**Please install paru aur helper first**${RESET}"
    return 1
  fi

  # NOTE: Creating `uinput` and `input` group
  printf "%b\n" "${YELLOW}Creating group ${CYAN} uinput ${RESET} and ${CYAN} input ${RESET}${RESET}"
  sudo groupadd uinput
  cmdCheck "Created uinput group"
  sudo groupadd input
  cmdCheck "Created input group"

  # NOTE: Adding $USER to `uinput` and `input`
  printf "%b\n" "${YELLOW}Adding group ${CYAN} uinput ${RESET} and ${CYAN} input ${RESET} to user ${CYAN} $USER ${RESET}${RESET}"
  sudo usermod -aG uinput "$USER"
  cmdCheck "Added uinput to $USER"
  sudo usermod -aG input "$USER"
  cmdCheck "Added input to $USER"

  printf "%b\n" "${YELLOW}Copying rules file${RESET}"
  sudo cp -r ./99-input.rules /etc/udev/rules.d/
  cmdCheck "Success"

  printf "%b\n" "${YELLOW}Reloading Rules${RESET}"
  sudo udevadm control --reload-rules && sudo udevadm trigger
  cmdCheck "Success"

  printf "%b\n" "${YELLOW}Verifying uinput file${RESET}"
  ls -l /dev/uinput
  cmdCheck "Success"

  printf "%b\n" "${YELLOW}Loading uinput drivers${RESET}"
  sudo modprobe uinput
  cmdCheck "Success"

  if [ -d "$HOME/.config/systemd/user/" ]; then
    printf "%b\n" "${YELLOW}Copying Service file${RESET}"
    cp -rf ./kanata.service ~/.config/systemd/user/
    cmdCheck "Success"
  else
    mkdir -p "$HOME/.config/systemd/user/"
    printf "%b\n" "${YELLOW}Copying Service file${RESET}"
    cp -rf ./kanata.service ~/.config/systemd/user/
    cmdCheck "Success"
  fi

  if [ -d "$HOME/.config/kanata/" ]; then
    printf "%b\n" "${YELLOW}Copying kanata file${RESET}"
    cp -rf ./config.kbd ~/.config/kanata/
    cmdCheck "Success"
  else
    mkdir -p "$HOME/.config/systemd/user/"
    printf "%b\n" "${YELLOW}Copying kanata file${RESET}"
    cp -rf ./config.kbd ~/.config/kanata/
    cmdCheck "Success"
  fi

  printf "%b\n" "${YELLOW} Enabling Services ${RESET}"
  systemctl --user daemon-reload
  systemctl --user enable kanata.service
  systemctl --user start kanata.service
  systemctl --user status kanata.service # check whether the service is running
  cmdCheck "Success"

  printf "%b\n" "${YELLOW} Rebooting system in 60 seconds ${RESET}"
  sleep 60
  reboot
}

main
