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
- kvantum
- qt5ct
- qt6ct
- adw-gtk3

## Install

> If there are existing configs in home directory, rename or remove it first. Otherwise `stow` will fail to create the symlinks.

```bash
git clone https://github.com/obsqrbtz/archdots.git --recurse-submodules ~/.dotfiles
cd ~/.dotfiles
rm .gitconfig #(alternatively, put your git configuratiuon in this file)
stow -R -v -t ~ .
```

## Unlink

```bash
stow -D -v -t ~ .
```
