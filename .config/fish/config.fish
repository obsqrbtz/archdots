if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt
    set -l time_str (date "+%H:%M")
    echo -n (set_color 999999)"$time_str "(set_color green)"$USER "(set_color red)"> "(set_color normal)
end

function fish_right_prompt
    set -l tty_short (tty | string replace "/dev/" "")
    echo -n (set_color red)"< "(set_color cyan)"$hostname"(set_color normal)":"(set_color yellow)"$tty_short"(set_color normal)""
end

set -x CMAKE_GENERATOR Ninja
set -x GITLAB_HOME /srv/gitlab
#set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
set -x SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock

alias disable-tv="hyprctl keyword monitor HDMI-A-2, disable"

alias get-ip="curl https://ipecho.net/plain; echo"

# ls
alias ls="eza --icons --sort type --all"
alias git-ls="eza --all -l --icons --color=always --git --group-directories-first"
alias ls-tree="eza --icons --sort type --all --tree --git-ignore"
alias dotfiles='find . -maxdepth 1 -mindepth 1 -name ".*" \
  -not -name "." -not -name ".." -print0 \
  | xargs -0r eza -al -d --icons --color=always --git --group-directories-first --'

# archiving
alias untar="tar -zxvf"
alias mktar="tar -cvzf"

# Download audio from youtube
alias ytdl-mp3="yt-dlp -x --audio-format mp3 --audio-quality 0 -o '/home/synchronous/music/%(title)s.%(ext)s' "

# Disk usage
alias ncdu="ncdu -rx"
# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[ -f /home/dan/src/ink-goose/node_modules/tabtab/.completions/electron-forge.fish ]; and . /home/dan/src/ink-goose/node_modules/tabtab/.completions/electron-forge.fish

# Packages search
alias yas="yay -Slq | fzf --multi --preview 'yay -Si {1}' --preview-window=right:60% | xargs -ro yay -S"
alias yaq="yay -Qq | fzf --multi --preview 'yay -Qi {1}' --preview-window=right:60%"
# AUR only
alias yaqm="yay -Qm | awk '{print $1}' | fzf --multi --preview 'yay -Qi {1}' --preview-window=right:60%"

# opencode
fish_add_path /home/dan/.opencode/bin
fish_add_path /home/dan/.dotnet/tools
export PATH="$HOME/.local/bin:$PATH"
