# Dotfiles project

This is my personal dotfiles and dotfiles installer project on github.

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

- Create a bare git repo at `~/.dotfiles`
- Checkout files to `~`
- Configure to not show untracked files
- Backup original files to a branch, `backup-master-$HOSTNAME`. (requires `git` be installed beforehand)
- if git user.email isn't set, download `.gitconfig` or input interactively.
- if git+ssh isn't set up or installed, fall back to https
- if git isn't installed, fall back to download files
- if curl isn't installed, fall back to wget

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

### Advice and pitfalls

- Never run: `config add <directory>`, `config add -A`, or `config commit -a -m <message>`
     Instead use: `config add -u` or `config add <file>`
- `config` works best if run from home directory.
- Dot files will not be backed up if you don't have `git` installed.
- If you installed without `git` and then decide to install it,
  you can later run `dotfiles install` to create the `~/.dotfile` repo.

### To make your own

To make your own new empty dotfiles project, based on this script.

1. Match the requirements section.
2. Create an empty dotfiles repo on <https://github.com>
3. Run: `export DOTFILES_NAME=<github-username>/dotfiles`
4. Run: `sh -c "$(curl https://git.io/msdot -L)"`

The only file from this repo you'll inherit is `dotfiles`.

### Environmental override variables

```
DOTFILES_NAME   - github owner/project.
DOTFILES_BRANCH - default is master
DOTFILES_DIR    - default is ~/.dotfiles
```

### More Information

* <https://www.atlassian.com/git/tutorials/dotfiles>
* Read the [.local/bin/dotfiles](.local/bin/dotfiles) script
* Other files in [.config/dotfiles](.config/dotfiles)

## Supported Environment

Some of the following may not be fully supported at any time as I change tools.

### Software

* Vim, NeoVim, IDEAVim
* Zsh, Oh-My-Zsh with Agnoster theme
* Tmux
* npm, yarn
* i3, sway
* Alacritty

### Operating Environments

Environments I've successfully used with these dot files.

* Linux.  Fedora, Ubuntu, Alpine, Arch.
* WSL 1  (WSL 2 not tested)
* Cygwin, Msys2
* Git for Windows (striped down Msys2)
* Docker containers: alpine, ubuntu, fedora, debian
* RHEL over ssh (w/o git installed)

### Notable Features of my configuration

These aren't features of the install, but of my configuration dot files.

* Auto-install of plugin managers for Vim, Tmux, Zsh, on first use
* `.zshrc` also serves as a `.bashrc`
* `init.vim` also serves as a `.vimrc`
* Dracula theme for Vim, Tmux, Alacritty (but not Zsh)
* Mouseless usage is a goal
* [True color](https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6) support across alacritty, tmux, (n)vim
* Similar keybindings for tmux, i3, neovim
* Supplies files for `/etc`
* Integration of Jetbrains IDEs and gVim

### Various high level To-Dos

* Configure firefox with sync
* Install script for packages, including Google Drive and Keepass
* Better integrate i3, vim, tmux, firefox
* Switch to Vim Coc, with fallback to tags
* git-crypt for `.gitconfig`, `.ssh`

## FAQ

Q: Why not use one of the other dotfiles managers or `stow`?

A: I wanted something as simple as plain `git`, but no simpler.

Q: But isn't your script also complicated?

A: The script is optional and only for initial install.
The core of what it does is simple,
but it handles several special cases.

Q: Why not use symlinks to all the files?

A: I used to, but they don't track with file deletions or moves, 
adding a file required 2 steps (`git add` + `ln -s`,
and uninstalling or moving the repo was a mess.

Q: How did you create the shortened vanity URL?  Is it safe?

A: `git.io` is [run by github](https://github.blog/2011-11-10-git-io-github-url-shortener/).
This command allocated the URL:

```sh
url="https://raw.githubusercontent.com/mikeslattery/dotfiles/master/.local/bin/dotfiles"
curl https://git.io/ -i -F "url=$url" -F "code=msdot"
```

