# Dotfiles project

This is my personal dotfiles and dotfiles manager project on github.

## Getting started

### To install

```sh
curl -L https://raw.githubusercontent.com/mikeslattery/dotfiles/master/.local/bin/dotfiles | \
  /bin/sh -s install
```

or

```sh
wget https://raw.githubusercontent.com/mikeslattery/dotfiles/master/.local/bin/dotfiles -O - | \
  /bin/sh -s install
```

### What install does

- Create a bare git repo at `$GIT_DIR`
- Checkout files to `~`
- Backup original files to a `backup-$branch-$HOSTNAME` branch
- Configure to not show untracked files
- if git user.email isn't set up, downloads `.gitconfig`
- if ssh isn't set up or installed, falls back to https
- if git isn't installed, falls back to download files
- if curl isn't installed, falls back to wget

for information see the [.local/bin/dotfiles](.local/bin/dotfiles) script.

### Requirements:

- for install:  `git` or `unzip`, `curl` or `wget`
- for pushes:   `git`, `openssh`, and keys registered with github
- In [.zshrc](.zshrc):    `alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"`
- In .zshrc:    `export "PATH=$HOME/.local/bin"`

## Managing the dot files

After installation, the `config` command will act like `git`
but only for your dot files in `$HOME`.

### Usage:  (after install)

```
config   ...        - git subcommand.  Requires alias in .zshrc
dotfiles etc        - Copy ~/.config/dotfiles/etc to /etc
dotfiles ssh <host> - Install to ssh host
dotfiles tar <host> - Copy to host w/o github access
dotfiles docker <id>- Install into a running docker container
dotfiles uninstall  - Revert to config as before install.
dotfiles ...        - git subcommand. (in case `config` alias not set)
```

### Advice

- Never run: `config add <directory>`, or `config commit -a -m <message>`
     Instead use: `config add -u [<path>...]`
- `config` works best if run from home directory.

### To make your own

To make your own new empty dotfiles project, based on this script.

  1. Match the requirements section.
  2. Create an empty github dotfiles repo.
  3. Run: `export DOTFILES_NAME=<github-username>/dotfiles`
  4. Run the install command from the top of this readme.

### Environmental override variables

```
DOTFILES_NAME   - github owner/project.
DOTFILES_BRANCH - default is master
DOTFILES_DIR    - default is ~/.dotfiles
```

### More Information

* Other files in [.config/dotfiles](.config/dotfiles)
* <https://www.atlassian.com/git/tutorials/dotfiles>

## Supported Environment

### Software

* Vim, NeoVim
* Zsh
* Tmux
* Jetbrains IDEAVim
* npm, yarn
* i3, sway
* Alacritty

### Operating Environments

These are environments I've successfully used
these dot files with at some point.

* Linux.  Fedora, Ubuntu, Alpine, Arch.
* WSL 1  (WSL 2 not tested)
* Cygwin, Msys2
* Git for Windows (striped down Msys2)
* Docker container
* RHEL over ssh

## FAQ

Q: Why not use one of the other dotfiles managers or `stow`?

A: I wanted something as simple as plain `git`, but no simpler.

Q: But isn't your script also complicated?

A: The core of what it does is simple.
But it handles several special cases.

I could have just written this:

```sh
git clone --bare https://github.com/mikeslattery/dotfiles/ ~/.dotfiles
config config --local status.showUntrackedFiles no
config reset --hard
```

Q: Why not use symlinks to all the files?

A: I used to, but they don't track with file deletions or moves, 
and adds required 2 steps (`git add` + `ln -s`)

