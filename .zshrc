# For more info see $ZSH/templates/zshrc.zsh-template

# This .zshrc also nominally works as .bashrc
# .bashrc should only contain:  source ~/.zshrc
# I don't try to make bash work well, just to not be broken.

if [[ "$1" == "install" ]]; then
    set -xeu
    zsh --version
    if ! [[ -d ~/.oh-my-zsh ]]; then
        grep -sq "^$USER:.*zsh" /etc/passwd || sudo sed -i "s|^($USER):.*:)[^:]*\$|\\1$(command -v zsh)|" /etc/passwd
        ( set +x; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; )

        if [[ -f ~/.bashrc ]] && ! [[ -f ~/.config/.bashrc.orig ]]; then
            mv ~/.bashrc ~/.config/.bashrc.orig
        fi
        echo 'source ~/.zshrc' > ~/.bashrc
    else
        echo 'oh-my-zsh already installed'
    fi
    exit
elif [[ "$1" == "shellcheck" ]]; then
    set -xeu
    cd ~
    shellcheck -x -e SC2154,SC1090,SC2139,SC2090,SC2089 -s bash "$0"
    exit $?
fi

if [[ "$(ps -p "$$" -o comm -h)" == "zsh" ]]; then
    alias iszsh=true
    function has() {
        (( $+commands[$1] ))
    }
else
    alias iszsh=false

    # If not running interactively, don't do anything
    case $- in
        *i*) ;;
          *) return;;
    esac

    export PS1='[\h \W]$ '

    function has() {
        command -v "$1" &>/dev/null
    }

    # Ignore .zsh stuff
    setopt() { :; }
    unsetopt() { :; }
fi

addpath() {
    if [[ -d "$1" ]]; then
        pathmunge "$@"
    fi
}
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}
pathmunge "node_modules/.bin"
addpath "$HOME/bin"
addpath "$HOME/.local/bin"

alias is_fedora='grep -sq fedora /etc/os-release'

if has podman && ! has docker; then
    docker() { podman "$@"; }
fi
if has podman-compose && ! has docker-compose; then
    docker-compose() { podman-compose "$@"; }
fi

if iszsh; then
    export ZSH="$HOME/.oh-my-zsh"

    ZSH_THEME="avit"
    ZSH_THEME="ys"
    ZSH_THEME="powerlevel10k/powerlevel10k"
    ZSH_THEME="agnoster"

    if [[ "$ZSH_THEME" == "powerlevel10k/powerlevel10k" ]]; then
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
            source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
        fi
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        if [[ -f ~/.p10k.zsh ]]; then
            source ~/.p10k.zsh
        fi
    fi

    plugins=(
        git
        gradle
        npm
    )
    if is_fedora; then
        plugins+=('dnf')
    fi
    if has brew; then
        plugins+=('brew')
    fi
    if has docker || has podman; then
        if ! has docker; then
            docker() { podman "$@"; }
            docker-compose() { podman-compose "$@"; }
        fi
        plugins+=('docker' 'docker-compose')
    fi

    #TODO: z fzf git* mvn fasd vi-mode vim-interaction pass gnu-utils
    #tig, systemd, tmux* vault
    #jira
    #colorize colored-man-pages compleat dirhistory dnf fbterm man
    #terminalapp themes ufw
    source "$ZSH/oh-my-zsh.sh"
else
    HISTCONTROL=ignoreboth
fi

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
PROMPT="${PROMPT/$/%h$}"
export CDPATH=".:$HOME/src:$HOME"
export LESS=-iRj3
setopt cdablevars

if [[ -d /usr/lib/jvm/default-java ]] && [[ -z "$JAVA_HOME" ]]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
fi

# If an ssh connection, connect X back to the client
[ -z "$SSH_CLIENT" ] || export DISPLAY="${SSH_CLIENT/ */}:0"

if [[ "$(uname -r)" == *-Microsoft ]]; then
    # WSL

    unsetopt BG_NICE # https://github.com/Microsoft/WSL/issues/1887
    nice() {
        if [[ "$1" == "-n" ]]; then shift; shift; fi
        "$@"
    }
    export nice
    renice() { :; }
    export renice

    if has docker; then
        export DOCKER_HOST=tcp://0.0.0.0:2375
    fi
    export DISPLAY=:0

    alias powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    alias cmd=/mnt/c/Windows/System32/cmd.exe
    alias clip=/mnt/c/Windows/System32/clip.exe
    alias permissions='cmd /c whoami /all /FO LIST'
    alias notify-send="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -file 'C:/Users/$USER/bin/notify-send.ps1'"

    # Remove Windows from path
    export PATH="$(sed -r 's|:?(/mnt)?/c/[^:]*||g;' <<<"$PATH")"
    export USERPROFILE="/c/Users/$USER"

    sudo mount -a
fi


cheat() { curl -s "cheat.sh/$(echo -n "$*" | jq -sRr @uri)"; }
nocolor() { sed -r 's:\x1B\[[0-9;]*[mKB]::g; s:^.*\x0D::g;'; }
alias weather='curl -sL4 http://wttr.in/Indianapolis'

c() { awk -v "n=$1" '{print $n}'; }
alias c1='c 1'
alias c2='c 2'
alias c3='c 3'
alias nogrep='rg -v " rg | grep "'
# Pipe to this to make something immediately executable
# usage: curl .../ec | xble ~/bin/ec
xble() { set -eu; cat > "$1"; chmod u+x "$1"; }
if ! iszsh; then
    command_not_found_handler() {
        if grep -sq "^Host $1\$" ~/.ssh/config; then
            ssh "$@"
        elif [[ -x /usr/lib/command-not-found ]]; then
            # Copied from /etc/zsh_command_not_found
            /usr/lib/command-not-found --no-failure-msg -- ${1+"$1"} && :
        else
            echo "Command not found: $1"
            return 127
        fi
    }
fi

alias lzsh='source $HOME/.zshrc'

if has docker; then
    alias dk='docker'
    alias dkr='docker run -it --rm'
    alias dka='docker run -it --rm --name alpine alpine'
    alias dkh='docker run -it --rm --name host -v /:/host --privileged alpine /bin/sh'
    alias dkas='docker run -it --rm --name alpine alpine sh'
    alias dkps='docker ps'
    function dkb() {
        # Output to tty.  Send image id to stdout.
        docker build . "$@" | tee /dev/tty | sed -nr 's/Successfully built (.*)$/\1/p'
    }
    alias dkbr='docker run -it --rm $(dkb)'
    alias dkbs='docker run -it --rm $(dkb) sh'
    alias dcpu='docker-compose push'
    alias dc='docker-compose'
    alias dkcl='docker ps -a | grep -Ev "CONTAINER|jenkinsfile|wsl" | c1 | xargs -r docker rm -f'
    #useful: dco, dcb, dcup, dcupd, dcps, dcdn

    alias dkme='docker  run -it --rm -v "$PWD:$PWD" -w "$PWD" -e HOME="$HOME" -v "$HOME:$HOME:ro" -v /var/run/docker.sock:/var/run/docker.sock -u $(id -u):$(id -g)'
    alias dkmea='docker run -it --rm -v "$PWD:$PWD" -w "$PWD" -e HOME="$HOME" -v "$HOME:$HOME:ro" -v /var/run/docker.sock:/var/run/docker.sock -u $(id -u):$(id -g) alpine'

    #TODO: docker package manager
fi

unalias rg gcd &>/dev/null || true
alias rgf='rg --files'
alias rgj="rg -g'*.java' -g'*.kt' -g'*.groovy' -g'build.gradle' --heading"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgreprc"
export FZF_DEFAULT_COMMAND='fd --hidden --exclude ".git" --exclude "package-lock.json" .'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

unalias ls &>/dev/null || true
if has exa; then
    ls() { exa "$@"; }
    alias l='exa -la --git -I .git'
    alias la='exa -la --git -I .git'
    alias ll='exa -l --git -I .git'
    alias lsa='exa -laa --git -I .git'
fi

alias u='urxvt -e tmux &'

if iszsh; then
    alias -g -- --cless='--color=always | less -R'
    alias -g --  --ccat='--color=always | cat'
    alias -g --  --java='**/main/java/**/*.java'
    alias -g -- --fdall='--hidden --no-ignore -E .git'
fi
r() { sed -r -n "${1}p"; }
x() { xargs -d"\n" -r "$@"; }
xy() {
  x="$1"; shift
  y="$1"; shift
  sed -r -n "${y}p" | awk -v "n=$x" '{print $n}' | xargs -d$'\n' -r "$@"
}

unalias gss &>/dev/null || true
unalias gs &>/dev/null || true
gss() { git --no-pager -c color.ui=always status -s "$@" -uno | cat -n; }
gs()  { git --no-pager -c color.ui=always status -s "$@" -b | cat -n; }
alias gr='./gradlew'
alias gt='clear; ./gradlew test'
#gcd() { cd "$1" || exit 1; git status | sed -n '/use/ !{ /^$/ !p };'; }
# fetch and checkout a single branch
gfco() {
    git fetch origin "$1"
    git checkout "$1"
}
# merge develop
gmd() {
    git fetch origin develop:develop
    git merge develop --no-edit
}
alias g='git --no-pager'
alias gpage='unset GIT_PAGER'
alias gnpage='export GIT_PAGER=cat'
# fuzzy git add untracked files
alias gafo='git ls-files -o --exclude-standard | sort | fzf -m --preview "bat --color=always -r :99 {}" | xargs -tr git add; git status'
# fuzzy git add modified files
alias gafm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}" | xargs -tr git add; git status'
# fuzzy git checkout modified files
alias grfm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}" | xargs -tr git checkout; git status'
# fuzzy remove git untracked files
alias grfo='git ls-files -o --exclude-standard | sort | fzf -m --preview "bat --color=always -r :99 {}" | xargs -tr rm; git status'
# fuzzy git diff
alias gdfm='git ls-files -m --exclude-standard | sort | fzf -m --preview "git diff -w {}"'
alias gp1='git push --set-upstream origin $(git_current_branch)'
alias gdd='git --no-pager diff'
alias gdh='git diff HEAD'
alias gd='git diff -w'
alias gcb='git checkout -b --track'
alias gpf='git push origin HEAD --force-with-lease'
alias 'gpf!'='git push origin HEAD --force'
unalias glo &>/dev/null || true
glo() {
    git --no-pager log --oneline --decorate -9 --color=always "$@" | nl -v0 | sed -r 's/^ +/HEAD~/; s/\t/ /'
}
gloi() {
    glo --color=never "$@" | fzf --preview "git show --name-only {2}"
}

# network graph with parent merges removed
ggraph() {
    git log --oneline --graph --decorate --invert-grep -P --grep "Merge (remote-tracking )?branch(es)? (.*and )?'(origin/)?(master|develop)'" "$@"
}

#shellcheck disable=SC2142
alias ts="awk '{ print strftime(\"%H:%M:%S\"), \$0; fflush();}'"

#useful: ggsup, gp, gpf!, gau, gss, gst, gc -m, gcb, gco, gcm

lsource() { if [[ -f "$1" ]]; then source "$1"; fi; }
if iszsh; then
    lsource /usr/share/fzf/shell/key-bindings.zsh
    lsource /usr/share/doc/fzf/examples/key-bindings.zsh
    lsource /usr/share/zsh/vendor-completions/_fzf

    # this will soon be default
    # see https://github.com/ohmyzsh/ohmyzsh/issues/7609
    bindkey '^H' backward-kill-word
else
    lsource /usr/share/fzf/shell/key-bindings.bash
    lsource /usr/share/doc/fzf/examples/key-bindings.bash
    #. /usr/share/powerline/bash/powerline.sh
fi

#TODO: fasd, z, oh-my-zsh, powerline

umask 027

export ANDROID_SDK_ROOT=$HOME/Android/Sdk
#export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#export PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
#export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

export EDITOR="$(which vim)"

# Container package manager
contize() {
    podman run -it --rm \
        --privileged --userns=keep-id \
        -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
        -v "$HOME:$HOME" -v /tmp:/tmp \
        -w "$PWD" \
        "$@"

#        -v "/tmp/empty:$HOME/.mozilla" -v "/tmp/empty:$HOME/.ssh" -v "/tmp/empty:$HOME/.gnupg" -v "/tmp/empty:$HOME/.cache/mozilla" \
}

sudo-contize() {
    podman exec -it -u 0:0 -w /root --privileged "$@"
}


# Packages
groovy()   { contize groovy groovy   "$@"; }
groovysh() { contize groovy groovysh "$@"; }
gradle9()  { contize openjdk:9-jdk-slim ./gradlew --no-daemon "$@"; }
java9()    { contize openjdk:9-jdk-slim /bin/bash "$@"; }

browse() { xdg-open "file://$(readlink -f "$1")"; }

alias 'cpd=/home/mslattery/Downloads/pmd-bin-6.22.0/bin/run.sh cpd'
todo() { ( set -x; "$@"; ) 2>&1 | tee -a todo.txt; }

if iszsh; then
  bindkey '^U' backward-kill-line
fi

git-foresta() { ~/src/git-foresta/git-foresta --style=10 "$@" | less -RSX; }

# Make shell script
mksh() {
echo '#!/bin/bash
     
set -euo pipefail
' > "$1"
chmod +x "$1"
}

# user JDK switching

export JAVA_HOME="$HOME/javahome"
if [[ ! -d ~/javahome ]]; then
  ln -snf /usr/lib/jvm/jre "$JAVA_HOME"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
alias chjvm='readlink -f /usr/lib/jvm/* | sort -u | fzf | xargs -I{} ln -snf {} ~/javahome'
alias chjvm='readlink -f /usr/lib/jvm/* | sort -u | fzf --preview "{}/bin/java -version; ls -l {} {}/bin" | xargs -I{} ln -snf {} ~/javahome'

# Android

export ANDROID_SDK_ROOT=$HOME/Android/Sdk
addpath "$ANDROID_SDK_ROOT/platform-tools" after

lui() {
  ( nohup "$@" &>/dev/null & ) &>/dev/null
}

# Convert docx to pdf
doc2pdf() {
  soffice --headless --invisible --nodefault --nolockcheck --nologo --norestore --nofirststartwizard --convert-to pdf "$@"
}

rgb() {
  pattern="$1"; shift
  rg "$pattern" "$@" -l | xargs -r -d"\n" bat --pager="less -iR '$pattern'"
}

faketty() {
  script --return --quiet --command "$(printf "%q " "$@")" /dev/null
}

# bash and vim without logging
incognito() {
  bash -c '
    vim() { command vim -i NONE +"set noswapfile" +"set nobackup" "$@"; }
    export -f vim
    exec bash +o history
  '
}

# copy clipboard in markdown to text/html
rt-clip() {
    {
        echo $'---\ntitle:\nheader-includes: <meta http-equiv="content-type" content="text/html; charset=utf-8"/>\n---'
        /usr/bin/xclip -o -selection clipboard
    } | \
        pandoc -f markdown -s -t html --quiet | \
        sed '/<title>/d' | \
        /usr/bin/xclip -i -selection clipboard -t text/html
}

# copy html clipboard to markdown
md-clip() {
    /usr/bin/xclip -o -selection clipboard -t text/html | \
        pandoc -f html -t markdown | \
        sed -r 's/^-   /\* /; s/^    -   /  - /;' | \
        /usr/bin/xclip -i -selection clipboard
}

# Convert clipboard to raw html, without header
html-clip() {
  /usr/bin/xclip -o -selection clipoard -t text/html | \
    sed '/^<!DOCTYPE/,/<\/head/ d; s/<body [^>]*>//; /^<\/body/,$ d;' | \
    /usr/bin/xclip -i -selection clipboard
}

#TODO: single clip command.  -f|-t html|md|text -i -|clip|file -o -|clip|file

# Speak clipboard from phone
tts-clip() {
  /usr/bin/xclip -o -selection clipoard | ssh phone termux-tts-speak
}

# Phone dialog input, possibly from mic, to clipboard
stt-clip() {
  ssh phone termux-dialog -m | jq '.text' -r | /usr/bin/xclip -i -selection clipboard
}

alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# cleanup
unset -f pathmunge
unset -f addpath
