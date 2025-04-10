export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dieter"

source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(git)

source $ZSH/oh-my-zsh.sh

eval $(thefuck --alias)

eval "$(zoxide init zsh)"

export PATH=$PATH:/home/dan/.spicetify:/home/dan/.dotnet/tools
export CMAKE_GENERATOR=Ninja
export ROC_ENABLE_PRE_VEGA=1

alias cd="z"
alias force-upgrade="sudo pacman -Syu --overwrite '*'"
alias yay-clean="yay -Scc"

function rgdelta() {
    rg --json -C 2 "$1" | delta
}

function notify_test() {
    notify-send "Test Notification" "Some text to test out the notification daemon" \
        --urgency=critical \
        --expire-time=10000 \
        --icon=dialog-information \
        --hint=string:x-canonical-private-synchronous:anything \
        --hint=int:transient:1 \
        --category=im.received \
        --action=default="OK",cancel="Dismiss"
}

# Created by `pipx` on 2025-03-31 22:12:33
export PATH="$PATH:/home/dan/.local/bin"
