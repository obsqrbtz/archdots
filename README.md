# Archdots

Arch config backup

## Install

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
