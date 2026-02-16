if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -x CMAKE_GENERATOR Ninja
set -x GITLAB_HOME /srv/gitlab

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
