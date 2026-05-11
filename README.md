# Hyprland Setup

Script d'installation pour preparer un environnement Hyprland sur Arch Linux ou EndeavourOS.

Le projet installe les paquets essentiels, configure les services systeme, met en place PipeWire, ajoute les variables NVIDIA utiles pour Wayland, et installe la configuration Quickshell fournie avec le depot.

## Contenu

```text
.
- install.sh        # Script d'installation
- quickshell/       # Configuration Quickshell
  - shell.qml       # Point d'entree Quickshell
  - components/     # Composants de la barre
- README.md         # Documentation du projet
```

## Prerequis

- Arch Linux ou EndeavourOS.
- `pacman`.
- Un utilisateur avec acces `sudo`.
- Une connexion internet active.

Le script est pense pour une machine avec GPU NVIDIA et le pilote `nvidia-open-dkms`. Si tu utilises AMD, Intel ou un autre pilote NVIDIA, adapte la section des paquets dans `install.sh` avant execution.

## Installation

Clone le depot, puis lance :

```bash
git clone https://github.com/Harlox/hyprland.git
cd hyprland
chmod +x install.sh
./install.sh
```

Depuis un TTY, connecte-toi d'abord au reseau si necessaire :

```bash
nmtui
```

## Installation en une ligne

Le script peut aussi etre lance directement depuis GitHub :

```bash
curl -fsSL https://raw.githubusercontent.com/Harlox/hyprland/main/install.sh | bash
```

Dans ce mode, si le dossier local `quickshell/` n'est pas present, le script telecharge automatiquement `shell.qml` et ses composants depuis GitHub.

## Ce que le script fait

### Mise a jour

Le systeme est mis a jour avec :

```bash
sudo pacman -Syu
```

### Installation Hyprland

Le script installe Hyprland et les composants necessaires pour une session Wayland utilisable :

- Hyprland
- Wayland et `wayland-protocols`
- `qt6-wayland`
- portals XDG pour Hyprland
- `polkit`
- `mako`
- `grim`
- `slurp`

### Support NVIDIA

Les paquets NVIDIA installes sont :

- `nvidia-open-dkms`
- `nvidia-utils`
- `lib32-nvidia-utils`
- `egl-wayland`
- `libva-nvidia-driver`

Le script ajoute ensuite ces variables dans `~/.config/hypr/hyprland.conf` :

```ini
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
```

### Quickshell

Le dossier `quickshell/` est copie vers :

```text
~/.config/quickshell/
```

Si le script est lance seul via l'URL raw GitHub, les memes fichiers sont telecharges directement depuis le depot.

Puis Hyprland est configure pour lancer Quickshell automatiquement :

```ini
exec-once = quickshell
```

La configuration incluse fournit une barre simple avec workspaces Hyprland, horloge et controle du volume PipeWire.

### Audio

La stack audio installee est basee sur PipeWire :

- `pipewire`
- `pipewire-alsa`
- `pipewire-pulse`
- `pipewire-jack`
- `wireplumber`
- `alsa-utils`

Les services utilisateur sont actives avec `systemctl --user`.

### Reseau et Bluetooth

Le script installe et active :

- `NetworkManager`
- `bluez`
- `bluez-utils`

### Outils inclus

Le script installe aussi quelques outils courants :

- terminal : `kitty`
- launcher : `fuzzel`
- fichiers : `nautilus`
- luminosite et batterie : `brightnessctl`, `upower`
- developpement : `git`, `cmake`, `ninja`, `python`, `rustup`, `nodejs`, `npm`, `go`
- gaming : `gamemode`, `mangohud`, `gamescope`
- theming : `matugen`

## Apres installation

Redemarre la machine :

```bash
sudo reboot
```

Puis lance Hyprland depuis ton display manager ou depuis un TTY.

## Personnalisation

Pour utiliser le noyau standard au lieu de `linux-zen`, remplace dans `install.sh` :

```text
linux-zen
```

par :

```text
linux
```

Pour utiliser le pilote NVIDIA DKMS classique, remplace :

```text
nvidia-open-dkms
```

par :

```text
nvidia-dkms
```

## Idempotence

Le script peut etre relance sans dupliquer les lignes ajoutees dans `hyprland.conf`. Les paquets sont installes avec `pacman --needed`, ce qui evite de reinstaller ce qui est deja present.
