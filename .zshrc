# For more info see ~/.oh-my-zsh/templates/zshrc.zsh-template and ~/.bashrc

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/zsh/custom"

if [[ "$1" == "install" ]]; then
    set -eu
    dl() { wget "$1" -O /dev/stdout -q 2>/dev/null || curl -sLf "$1"; }
    sh -c "RUNZSH=no; $(dl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --keep-zshrc
    mkdir -p "$ZSH"/completions "$ZSH"/custom "$ZSH"/functions
    exit $?
elif [[ "$1" == "shellcheck" ]]; then
    cd ~
    set -x
    shellcheck -x -e SC2154,SC1090,SC2139,SC2090,SC2089 -s bash "$0"
    zsh -i -c ''
    exit $?
elif [[ "$1" == "upgrade" ]]; then
    "$ZSH"/tools/upgrade.sh
    exit $?
fi

if [[ -n "$ZSH_VERSION" ]]; then
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

# Install oh-my-zsh
if ! [[ -d "$ZSH" ]]; then
    if has zsh && has git; then
        sh "$0" install
    else
        echo 'W: oh-my-zsh requires: zsh, git, chsh'
    fi
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
addpath "$HOME/go/bin"
addpath "$HOME/src/my/ai"

alias is_fedora='grep -sq fedora /etc/os-release'

if has podman && ! has docker; then
    docker() { podman "$@"; }
    docker-compose() { podman-compose "$@"; }
fi

if iszsh; then
    ZSH_THEME="darkblood" # set by `omz`
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

    completions=( fd vagrant yarn )

    plugins=( git gradle npm )

    if is_fedora; then
        plugins+=('dnf')
    fi
    if has brew; then
        plugins+=('brew')
    fi
    if has mosh; then
        plugins+=('mosh')
    fi
    if has docker || has podman; then
        if ! has docker; then
            docker() { podman "$@"; }
            docker-compose() { podman-compose "$@"; }
        fi
        plugins+=('docker' 'docker-compose')
    fi

    for plugin in "${completions[@]}"; do
        fpath=("$ZSH/plugins/$plugin" $fpath)
    done

    fpath=("$HOME/.local/completions" $fpath)

    #TODO: completions bundler, cpan, gem, pip, hub, gradle
    #TODO: z fzf git* mvn fasd vi-mode vim-interaction pass gnu-utils
    #tig, systemd, tmux* vault
    #yarn
    #gh, github, git-flow
    #jira
    #colorize colored-man-pages compleat dirhistory dnf fbterm man
    #terminalapp themes ufw
    source ~/.oh-my-zsh/oh-my-zsh.sh
else
    HISTCONTROL=ignoreboth
fi

# User configuration

# export LANG=en_US.UTF-8

export HISTSIZE=999000
export HISTFILESIZE=$HISTSIZE
export SAVEHIST=$HISTSIZE
setopt hist_ignore_space
export PROMPT="!%h$PROMPT"
export CDPATH="$HOME/src"
export LESS=-iRj3
setopt cdablevars
unsetopt autocd

export TUIR_BROWSER=w3m
export TUIR_EDITOR=nvim
export NCDU_SHELL='vifm .'
alias ddgr='BROWSER=w3m ddgr'

if [[ -d /usr/lib/jvm/default-java ]] && [[ -z "$JAVA_HOME" ]]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
fi

# If an ssh connection, connect X back to the client
[ -z "$SSH_CLIENT" ] || export DISPLAY="${SSH_CLIENT/ */}:0"

cheat() { curl -s "cheat.sh/$(echo -n "$*" | jq -sRr @uri)"; }
nocolor() { sed -r 's:\x1B\[[0-9;]*[mKB]::g; s:^.*\x0D::g;'; }
alias weather='curl -sL4 http://wttr.in/Indianapolis'

fin() {
  local r="$?"
  local msg="${1:-Done}"
  notify-send "$msg ($r) $(date +%T)"
  echo "$msg ($r) $(date +%T)"
}

c() { awk -v "n=$1" '{print $n}'; }
alias c1='c 1'
alias c2='c 2'
alias c3='c 3'
alias nogrep='rg -v " rg | grep "'
alias fd='fd --hidden --exclude=.git'
# Pipe to this to make something immediately executable
# usage: curl .../ec | xble ~/bin/ec
xble() { set -eu; cat > "$1"; chmod u+x "$1"; }
unalias md &>/dev/null || true
md() { set -eu; mkdir -p "$1"; cd "$1"; }
command_not_found_handler() {
    _log() {
      echo "$*" >&2
      "$@"
    }
    if grep -sq "^Host $1\$" ~/.ssh/config; then
        _log ssh "$@"
    elif [[ -f yarn.lock ]] &&        has yarn && grep -sq "\"$1\":" package.json; then
        _log yarn run "$@"
    elif [[ -f package-lock.json ]] && has npm && grep -sq "\"$1\":" package.json; then
        _log npm run "$@"
    elif [[ -x node_modules/.bin/"$1" ]] && [[ -f package.json ]] && [[ -d .git ]]; then
        PATH="node_modules/.bin:$PATH"
        "$@"
    elif git --help | grep -Esq "^   $1 .*$"; then
        _log git "$@"
    # handle failure
    elif command -v command_not_found_handle &>/dev/null; then
        command_not_found_handle "$@"
    elif [[ -x /usr/lib/command-not-found ]]; then
        # Copied from /etc/zsh_command_not_found
        /usr/lib/command-not-found --no-failure-msg -- ${1+"$1"} && :
    else
        echo "Command not found: $*" >&2
        return 127
    fi
}

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
alias fzp='fzf -m --preview="[ -f {} ] && bat -r :100 --color=always {} || tree -C {}"'

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
    alias -g -- --bat=' | xargs -d"\n" -r bat'
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
alias gdno='git --no-pager diff -w --name-only --diff-filter=AM'
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
alias gl='git pull --ff --no-edit'
alias gp1='git push --set-upstream origin $(git_current_branch)'
alias gpf='git push origin HEAD --force-with-lease'
alias 'gpf!'='git push origin HEAD --force'
unalias gp &>/dev/null || true
gp() {
  # check for conflicts before pull
  git pull --no-ff --no-commit && \
    git pull --ff --no-edit && \
    git push
}
alias gdd='git --no-pager diff'
alias gdh='git diff HEAD'
alias gd='git diff -w'
alias gcb='git checkout -b --track'
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
    bindkey '^U' backward-kill-line

else
    lsource /usr/share/fzf/shell/key-bindings.bash
    lsource /usr/share/doc/fzf/examples/key-bindings.bash
    #. /usr/share/powerline/bash/powerline.sh

    # does not work with gnome-terminal + tmux
    bind "\C-h":backward-kill-word
fi

#TODO: fasd, z, oh-my-zsh, powerline

umask 027

export ANDROID_SDK_ROOT=$HOME/Android/Sdk

EDITOR="$(command -v nvim || command -v vi)"
# if [[ -n "$TMUX" ]]; then
#   EDITOR="tmux popup -E $EDITOR"
# fi
export EDITOR

# Run program within a container with my identity
# Usage: contize [options] [--name <name>] <image> [<cmd> [<args...>]]
contize() {
    podman run -it --rm \
        --security-opt label=disable \
        --userns=keep-id \
        -v "$HOME:$HOME" -v /tmp:/tmp \
        -w "$PWD" \
        "$@"

#        -v "/tmp/empty:$HOME/.mozilla" -v "/tmp/empty:$HOME/.ssh" -v "/tmp/empty:$HOME/.gnupg" -v "/tmp/empty:$HOME/.cache/mozilla" \
}

# Run as root in a running container
# Usage: sudo-contize [options] <name> [<cmd> [<args...>]]
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
  addpath "$JAVA_HOME/bin" after
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
    nvim() { command nvim -i NONE +"set noswapfile" +"set nobackup" "$@"; }
    vim() { nvim "$@"; }
    export -f nvim
    export -f vim
    exec bash +o history "$@"
  ' -- "$@"
}

# Converts a zshrc function to a script in ~/bin
fun2script() {
  {
    echo -n "#!/bin/bash\n# $1\n"
    which "$1" | sed '1d; $d; s/^\t//;'
  } > "$HOME/bin/$1";
  chmod u+x "$HOME/bin/$1"

  sed -ri "/^${1}\(\) \{/, /^\}/ d;" ~/.zshrc

  dotfiles add "bin/$1"
  dotfiles add -u ~/.zshrc
  unset -f "$1"
  hash -r
}

# Convert clipboard to raw html, without header
html-clip() {
  /usr/bin/xclip -o -selection clipoard -t text/html | \
    sed '/^<!DOCTYPE/,/<\/head/ d; s/<body [^>]*>//; /^<\/body/,$ d;' | \
    /usr/bin/xclip -i -selection clipboard
}

#TODO: single clip command.  -f|-t html|md|text -i -|clip|file -o -|clip|file

# Speak clipboard from phone
# tts() {
#   ssh phone termux-tts-speak
# }

tts-clip() {
  /usr/bin/xclip -o -selection clipoard | tts
}

# Phone dialog input, possibly from mic, to clipboard
stt() {
  ssh phone termux-dialog -m | jq '.text' -r
}

stt-clip() {
  sst | /usr/bin/xclip -i -selection clipboard
}

# move directory to /tmp
# example: lntmp .nuxt
lntmp() {
  set -eu
  dest="/tmp$(readlink -f "$1")"
  src="$1"

  [[ ! -L "$src" ]] || { echo "Already a symlink"; return 1; }
  [[ -d "$src" ]] || mkdir "$src"

  mkdir -p "$(dirname "$dest")"
  mv "$src" "$dest"
  ln -s "$dest" "$src"
  echo "$(readlink -f "$src")" > /var/tmp/symlinks.txt
}
#TODO: move to systemd user script
## during boot, remove all symlinks created by lntmp
#if [[ -f /var/tmp/symlinks.txt ]]; then
#  for link in $(cat /var/tmp/symlinks.txt); do
#    if [[ -L "$link" ]] && [[ ! -d "/tmp/$link" ]]; then
#      rm "$link"
#    fi
#  done
#  rm /var/tmp/symlinks.txt
#fi

# to undo run lzsh
shortprompt() {
  omz theme use bira
  export PROMPT="${PROMPT/\%n@\%m/!%h}"
}

alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# cleanup
unset -f pathmunge
unset -f addpath

# https://unix.stackexchange.com/questions/41274/having-tmux-load-by-default-when-a-zsh-terminal-is-launched
#if iszsh && [[ -z "$TMUX" ]] && [[ -z "$SSH_CLIENT" ]] && !ps -C tmux &>/dev/null; then
#   exec tmux
#fi

# Not sure why this was automatically added here, but it breaks perl

# export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
# export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
# export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
# export PERL_MB_OPT="--install_base \"$HOME/perl5\""
# export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
