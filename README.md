# Archdots

Arch config backup

![screenshot](scrot.png?raw=true)

## Packages

- stow
- inotify-tools
- playerctl
- Hyprland
- rofi
- kitty
- dolphin
- pavucontrol
- noctalia:
    - quickshell
    - ttf-roboto
    - inter-font
    - gpu-screen-recorder
    - brightnessctl
    - ddcutil
    - cliphist
    - matugen
    - cava
    - wlsunset
    - xdg-desktop-portal-hyprland
- kvantum
- qt5ct
- qt6ct
- adw-gtk3

## Install

> If there are existing configs in home directory, rename or remove it first. Otherwise `stow` will fail to create the symlinks.

```bash
git clone https://github.com/obsqrbtz/archdots.git ~/.dotfiles
cd ~/.dotfiles
rm .gitconfig #(alternatively, put your git configuratiuon in this file)
stow -R -v -t ~ .
```

## Unlink

```bash
stow -D -v -t ~ .
```
