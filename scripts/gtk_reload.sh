theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme ''
sleep 1
gsettings set org.gnome.desktop.interface gtk-theme $theme
