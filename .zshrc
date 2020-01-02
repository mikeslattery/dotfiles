# For more info see $ZSH/templates/zshrc.zsh-template

export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:${GROOVY_HOME}/bin"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"
ZSH_THEME="avit"
ZSH_THEME="ys"

plugins=(
    git
    docker
    docker-compose
    gradle
)
#TODO: z fzf git* mvn fasd vi-mode vim-interaction pass gnu-utils
#tig, systemd, tmux* vault
#jira
#colorize colored-man-pages compleat dirhistory dnf fbterm man
#terminalapp themes ufw

source $ZSH/oh-my-zsh.sh

# User configuration

# export LANG=en_US.UTF-8

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export HISTSIZE=999000
export HISTFILESIZE=$HISTSIZE
setopt hist_ignore_space
export JAVA_HOME=/usr/lib/jvm/default-java
nhistory() { history "${1:-50}" | tac | cat -n | tac; }

export SDKMAN_DIR="/home/v64162/.sdkman"
export GROOVY_HOME=/usr/local/lib/groovy-2.5.7
[[ -s "/home/v64162/.sdkman/bin/sdkman-init.sh" ]] && source "/home/v64162/.sdkman/bin/sdkman-init.sh"

PROMPT="${PROMPT/$/ %h$}"
export CDPATH=".:$HOME/src2:$HOME"
setopt cdablevars
jf=$HOME/src2/jenkinsfile

# If an ssh connection, connect X back to the client
[ -z "$SSH_CLIENT" ] || export DISPLAY="${SSH_CLIENT/ */}:0"

if [[ "$(uname -r)" == *-Microsoft ]]; then
    unsetopt BG_NICE # https://github.com/Microsoft/WSL/issues/1887
    nice() {
        if [[ "$1" == "-n" ]]; then shift; shift; fi
        "$@"
    }
    export nice
    renice() { :; }
    export renice

    export DOCKER_HOST=tcp://0.0.0.0:2375
    export DISPLAY=:0

    alias powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    alias cmd=/mnt/c/Windows/System32/cmd.exe
    alias clip=/mnt/c/Windows/System32/clip.exe
    alias permissions='cmd /c whoami /all /FO LIST'

    export PATH="$(sed -r 's|:?/mnt/c/[^:]*||g' <<<"$PATH")"
    export USERPROFILE="/c/Users/$USER"

    sudo mount -a
fi

cheat() { curl -s "cheat.sh/$(echo -n "$*" | jq -sRr @uri)"; }
nocolor() { sed -r 's:\x1B\[[0-9;]*[mKB]::g; s:^.*\x0D::g;'; }
alias weather='curl -sL4 http://wttr.in/Indianapolis'

if command -v vimx &>/dev/null; then
    alias vim=vimx
fi
c() { awk -v "n=$1" '{print $n}'; }
alias c1='c 1'
alias c2='c 2'
alias c3='c 3'
alias nogrep='grep -v grep'
# Pipe to this to make something immediately executable
xble() { set -eu; cat > "$1"; chmod u+x "$1"; }

alias lzsh='source $HOME/.zshrc'

alias dk='docker'
alias dkr='docker run -it --rm'
alias dka='docker run -it --rm --name alpine alpine'
alias dkas='docker run -it --rm --name alpine alpine sh'
alias dkps='docker ps'
function dkb() {
    # Output to tty.  Send image id to stdout.
    docker build . "$@" | tee /dev/tty | sed -nr 's/Successfully built (.*)$/\1/p'
}
alias dkbr='docker run -it --rm $(dkb)'
alias dkbs='docker run -it --rm $(dkb) sh'
alias dcpu='docker-compose push'
alias dkcl='docker ps -a | grep -Ev "CONTAINER|jenkinsfile|wsl" | c1 | xargs -r docker rm -f'
#useful: dco, dcb, dcup, dcupd, dcps, dcdn

unalias rg gcd 2>/dev/null || true
alias rgf='rg --files'
export FZF_DEFAULT_COMMAND='fd --hidden --exclude ".git" .'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if command -v exa &>/dev/null; then
    unalias ls 2>/dev/null || true
    ls() { exa "$@"; }
    alias l='exa -la --git'
    alias la='exa -la --git'
    alias ll='exa -l --git'
    alias lsa='exa -laa --git'
fi

alias u='urxvt -e tmux &'

alias gs='git status -s'
alias gt='clear; ./gradlew test'
#gcd() { cd "$1" || exit 1; git status | sed -n '/use/ !{ /^$/ !p };'; }
alias g='git --no-pager'
alias gpage='unset GIT_PAGER'
alias gnpage='export GIT_PAGER=cat'
alias gafo='git ls-files -o --exclude-standard | sort | fzf -m --preview "bat --color=always -r :99 {}" | xargs -tr git add; git status'
alias gafm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}" | xargs -tr git add; git status'
alias grfm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}" | xargs -tr git checkout; git status'
alias grfo='git ls-files -o --exclude-standard | sort | fzf -m --preview "bat --color=always -r :99 {}" | xargs -tr rm; git status'
alias gdfm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}"'
alias glo='git --no-pager log --oneline --decorate -9'
alias gp1='git push --set-upstream origin $(git_current_branch)'
alias gdd='git --no-pager diff'
alias gdh='git diff HEAD'
alias gcb='git checkout -b --track'
#useful: ggsup, gp, gpf!, gau, gss, gst, gc -m, gcb, gco, gcm

if [[ -f /usr/share/fzf/shell/key-bindings.bash ]]; then
    . /usr/share/fzf/shell/key-bindings.zsh
fi
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    . /usr/share/doc/fzf/examples/key-bindings.zsh
fi
. /usr/share/zsh/vendor-completions/_fzf
#. /usr/share/powerline/bash/powerline.sh

#TODO: fasd, z, oh-my-zsh, powerline
#TODO: docker package manager

umask 022

