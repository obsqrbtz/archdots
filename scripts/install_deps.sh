#!/bin/bash

sudo ()
{
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}



sudo pacman -Sy &&
sudo pacman -S stow \
	zsh \
	thefuck \
	zoxide \
	playerctl \
	inotify-tools \
	hyprland xdg-desktop-portal-hyprland \
	polkit-gnome \
	wofi \
	udiskie \
	waybar \
	mako \
	kitty \
  git-delta \
	ttf-mononoki-nerd --noconfirm &&

git clone https://aur.archlinux.org/swww.git ~/swww &&
cd ~/swww &&
makepkg -si --noconfirm &&
cd ../ &&
rm -rf ~/swww &&

git clone https://aur.archlinux.org/fluent-gtk-theme.git ~/fluent-gtk-theme &&
cd ~/fluent-gtk-theme &&
makepkg -si --noconfirm &&
cd ../ &&
rm -rf ~/fluent-gtk-theme &&

git clone https://aur.archlinux.org/bibata-cursor-theme-bin.git ~/bibata-cursor-theme &&
cd ~/bibata-cursor-theme &&
makepkg -si --noconfirm &&
cd ../ &&
rm -rf ~/bibata-cursor-theme &&

if [ "$(whoami)" != "build" ]; then
	chsh -s $(which zsh) $(whoami)
fi &&
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&

mv ~/.zshrc ~/.zshrc_old



