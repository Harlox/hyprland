#!/usr/bin/env bash
set -euo pipefail

if ! command -v pacman >/dev/null 2>&1; then
  echo "Erreur: ce script est prevu pour Arch/EndeavourOS avec pacman." >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "==> Mise a jour du systeme"
$SUDO pacman -Syu --noconfirm

echo "==> Installation du core Hyprland"
$SUDO pacman -S --needed --noconfirm \
  linux-zen linux-headers base base-devel \
  mesa libdrm libglvnd \
  nvidia-open-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver \
  wayland wayland-protocols qt6-wayland \
  hyprland polkit \
  xdg-desktop-portal xdg-desktop-portal-hyprland \
  mako grim slurp \
  quickshell \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils \
  networkmanager upower brightnessctl \
  kitty thunar \
  noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols \
  git curl cmake ninja python rustup nodejs npm go

echo "==> Installation des extras"
$SUDO pacman -S --needed --noconfirm \
  matugen \
  gamemode lib32-gamemode \
  mangohud lib32-mangohud \
  gamescope \
  bluez bluez-utils

echo "==> Activation des services systeme"
$SUDO systemctl enable --now NetworkManager
$SUDO systemctl enable --now bluetooth

echo "==> Activation des services audio utilisateur"
if ! systemctl --user enable --now pipewire pipewire-pulse wireplumber; then
  echo "Avertissement: impossible d'activer les services audio utilisateur maintenant."
  echo "Relance la session puis execute :"
  echo "  systemctl --user enable --now pipewire pipewire-pulse wireplumber"
fi

HYPR_CONF="${HOME}/.config/hypr/hyprland.conf"
QUICKSHELL_DIR="${HOME}/.config/quickshell"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
HYPRLAND_CONF_RAW_URL="https://raw.githubusercontent.com/Harlox/hyprland/main/hyprland.conf"
QUICKSHELL_RAW_URL="https://raw.githubusercontent.com/Harlox/hyprland/main/quickshell"

echo "==> Installation de la configuration Quickshell"
mkdir -p "${QUICKSHELL_DIR}"

if [[ -d "${SCRIPT_DIR}/quickshell" ]]; then
  cp -R "${SCRIPT_DIR}/quickshell/." "${QUICKSHELL_DIR}/"
elif [[ -f "${SCRIPT_DIR}/shell.qml" ]]; then
  cp "${SCRIPT_DIR}/shell.qml" "${QUICKSHELL_DIR}/shell.qml"
else
  echo "Configuration Quickshell locale introuvable, telechargement depuis GitHub."
  if ! command -v curl >/dev/null 2>&1; then
    echo "Erreur: curl est requis pour telecharger la configuration Quickshell." >&2
    exit 1
  fi
  mkdir -p "${QUICKSHELL_DIR}/components"
  curl -fsSL "${QUICKSHELL_RAW_URL}/shell.qml" \
    -o "${QUICKSHELL_DIR}/shell.qml"
  curl -fsSL "${QUICKSHELL_RAW_URL}/components/ClockWidget.qml" \
    -o "${QUICKSHELL_DIR}/components/ClockWidget.qml"
  curl -fsSL "${QUICKSHELL_RAW_URL}/components/TopBar.qml" \
    -o "${QUICKSHELL_DIR}/components/TopBar.qml"
  curl -fsSL "${QUICKSHELL_RAW_URL}/components/VolumeMenu.qml" \
    -o "${QUICKSHELL_DIR}/components/VolumeMenu.qml"
  curl -fsSL "${QUICKSHELL_RAW_URL}/components/WorkspacesStrip.qml" \
    -o "${QUICKSHELL_DIR}/components/WorkspacesStrip.qml"
fi

echo "==> Installation de la configuration Hyprland dans ${HYPR_CONF}"
mkdir -p "$(dirname "${HYPR_CONF}")"
if [[ -f "${SCRIPT_DIR}/hyprland.conf" ]]; then
  cp "${SCRIPT_DIR}/hyprland.conf" "${HYPR_CONF}"
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "Erreur: curl est requis pour telecharger la configuration Hyprland." >&2
    exit 1
  fi
  curl -fsSL "${HYPRLAND_CONF_RAW_URL}" -o "${HYPR_CONF}"
fi

echo "==> Installation terminee"
echo "Si tu es en Wi-Fi, lance nmtui pour te connecter."
echo "Redemarre ensuite pour charger le noyau, les modules NVIDIA et la session Hyprland."
