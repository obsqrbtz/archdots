# Archdots

![preview](https://raw.githubusercontent.com/obsqrbtz/archdots/master/scrot.png)

## Dependencies

- [Stow](https://www.gnu.org/software/stow)
- **zsh**
- [Oh My Zsh](https://ohmyz.sh)
- [thefuck](https://github.com/nvbn/thefuck)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- **playerctl**
- **inotify-tools**
- [Hyprland](https://wiki.hyprland.org/Getting-Started/Installation)
- **polkit-gnome**
- [wofi](https://hg.sr.ht/~scoopta/wofi)
- [swww](https://github.com/LGFae/swww)
- [udiskie](https://github.com/coldfix/udiskie)
- [Waybar](https://github.com/Alexays/Waybar)
- [mako](https://github.com/emersion/mako)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [Mononoki Nerd Font](https://www.nerdfonts.com/font-downloads)
- [Fluent-Dark GTK theme](https://github.com/vinceliuice/Fluent-gtk-theme)
- [Bibata-Modern-Ice cursors](https://github.com/ful1e5/Bibata_Cursor)

> **Fastfetch**, **mpv**, **ranger** and **spicetify** are not actually configured, so you might ignore them, change to your configs or just remove these directories.

> **Fluent-Dark** GTK theme is set in **hyprland.conf**.

## Install

> If there are existing configs in home directory, rename or remove it first. Otherwise `stow` will fail to create the symlinks.

```bash
git clone https://github.com/obsqrbtz/archdots.git ~/.dotfiles
git submodule init
git submodule update --recursive
rm .gitconfig #(alternatively, put your git configuratiuon in this file)
stow -R -v -t ~ .
```

Then tweak default display, programs, autostart and environment variables in **hyprland.conf** if needed.

## Unlink

```bash
stow -D -v -t ~ .
```

**Neovim config is in another [repo](https://github.com/obsqrbtz/nvim-config)**

## Troubleshooting

If any dependency is missing in readme or configuration does not apply correctly on your machine, feel free to create an [issue](https://github.com/obsqrbtz/archdots/issues)
