export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="nicoulaj"

source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(git)

source $ZSH/oh-my-zsh.sh

eval $(thefuck --alias)

eval "$(zoxide init zsh)"

export PATH=$PATH:/home/dan/.spicetify
export CMAKE_GENERATOR=Ninja

alias cd="z"
alias force-upgrade="sudo pacman -Syu --overwrite '*'"
alias yay-clean="yay -Scc"
