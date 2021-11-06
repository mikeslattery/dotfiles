# Dotfiles project

This is my personal dotfiles and dotfiles manager project on github.

## Getting started

### To install

```sh
sh -c "$(curl https://git.io/msdot -L)"
```

or, if you don't have `curl`, and don't want a prompt

```sh
sh -c "$(wget https://git.io/msdot -O -)" -- i
```

or, if you don't want to use the `dotfiles` script.

```sh
git clone --bare https://github.com/mikeslattery/dotfiles .dotfiles
alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"
config config --local status.showUntrackedFiles no
config reset --hard
```

### Requirements:

- for install:  `git` or `unzip`, `curl` or `wget`
- for pushes:   `git`, `openssh`, and keys registered with github
- In [.zshrc](.zshrc):    `alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"`
- In .zshrc:    `export "PATH=$HOME/.local/bin"`

### What install does

- Create a bare git repo at `$GIT_DIR`
- Checkout files to `~`
- Backup original files to a branch, `backup-$branch-$HOSTNAME`
- Configure to not show untracked files
- if git user.email isn't set up, downloads `.gitconfig`
- if git+ssh isn't set up or installed, falls back to https
- if git isn't installed, falls back to download files
- if curl isn't installed, falls back to wget

for information see the [.local/bin/dotfiles](.local/bin/dotfiles) script.

## Managing the dot files

After installation, the `config` command will act like `git`
but only for your dot files in `$HOME`.

### Usage:  (after install)

```
config   ...        - git subcommand.  Requires alias in .zshrc
dotfiles help       - Usage.
dotfiles etc        - Copy ~/.config/dotfiles/etc to /etc
dotfiles ssh <host> - Install to ssh host
dotfiles tar <host> - Copy to ssh host w/o github access
dotfiles docker <id>- Install into a running docker container
dotfiles uninstall  - Revert to config as before install.
dotfiles docker <id>- Install into a running docker container
dotfiles curl|wget  - Print out install command, for copy-paste purposes.
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
  4. Run: `sh -c "$(curl https://git.io/msdot -L)"`

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

Some of the above may not be fully supported at any time as I change tools.

### Operating Environments

These are environments I've successfully used
these dot files with, at some point.

* Linux.  Fedora, Ubuntu, Alpine, Arch.
* WSL 1  (WSL 2 not tested)
* Cygwin, Msys2
* Git for Windows (striped down Msys2)
* Docker containers: alpine, ubuntu, fedora, debian
* RHEL over ssh (w/o git installed)

## FAQ

Q: Why not use one of the other dotfiles managers or `stow`?

A: I wanted something as simple as plain `git`, but no simpler.

Q: But isn't your script also complicated?

A: The script is optional and only for initial install.
The core of what it does is simple,
but it handles several special cases.

Q: Why not use symlinks to all the files?

A: I used to, but they don't track with file deletions or moves, 
and adding a file required 2 steps (`git add` + `ln -s`)

Q: How did you create the shortened vanity URL?
A: `curl https://git.io/ -i -F "url=<url>" -F "code=<name>"`

