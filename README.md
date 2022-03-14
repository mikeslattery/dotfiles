# Dotfiles project

[This](https://github.com/mikeslattery/dotfiles) is my personal dotfiles
and dotfiles installer project on github.

The first section is about the dot files themselves.
See ["Getting Started"](#getting-started) to read about the install script.

## Supported Environment

This describes the configuration dotfiles and the environments supported.

Some of the following may not be fully supported at any time as I change tools.

### Software

* NeoVim, Vim, IDEAVim
* Zsh, Oh-My-Zsh
* Tmux, Alacritty
* npm, yarn, node
* i3, sway
* `fzf`, `rg`, `fd`, `bat`, `exa`
* Podman

### Operating Environments

Environments I've successfully used with these dot files.

* Linux distros.  Fedora, Ubuntu, Alpine, Arch.
* Docker containers: alpine, ubuntu, fedora, debian
* Termux Android app
* Remote RHEL servers over ssh (w/o git installed)
* WSL 1  (WSL 2 not tested)
* Cygwin, Msys2
* Git for Windows (stripped down Msys2)

### Notable Features of my configuration

* Auto-install of plugin managers for NeoVim, Tmux, Zsh, on first use
* Dracula theme for NeoVim, Tmux, Alacritty, i3/sway, Gtk, Slack, but with darker background
* [True color](https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6) support across alacritty, tmux, NeoVim 
* `.zshrc` also serves as a `.bashrc`
* `init.vim` also serves as a `.vimrc`
* Powerline fonts across alacritty, tmux, neovim
* Mouseless usage as a goal, with vi keybindings when possible
* Similar keybindings for tmux, i3, neovim
* Global git pre-commit hook to run editorconfig checker
* Integration between Jetbrains IDEs and NeoVim
* Supplies files for `/etc`

### Notable individual files and directories

* [.vimrc](.vimrc) implements NeoVim defaults and then sources [.config/nvim/init.vim](.config/nvim/init.vim)
* [.config/dotfiles](.config/dotfiles) location for support files for this dotfiles project.

### Various high level To-Dos

* Git submodules for OMZ, tmux tpm, qt.
* GSConnect
* Configure firefox with sync
* Install script for packages, including Google Drive and Keepass
* Better integrate i3, Neovim, tmux, firefox, zathura
* Switch to NeoVim native LSP.  Fallback to Ale and/or tags
* git-crypt for `.gitconfig`, `.ssh`, netlify, stripe, keypassxc.ini
* dconf as a text file
* Support for in-container development.  `c-b c` starts in same container.  Shared clipboard.

## Getting started

This describes how to install the dotfiles from this project.
The script will backup your existing files to a branch.

### To install

```sh
sh -c "$(curl https://git.io/msdot -L)"
```

or, if you don't have `curl`, and don't want a prompt

```sh
sh -c "$(wget https://git.io/msdot -O -)" -- i
```

or, if you don't want to use the install script, you can install manually:

```sh
cd ~
git clone --bare https://github.com/mikeslattery/dotfiles .dotfiles
alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"
config config --local status.showUntrackedFiles no
config config --local core.excludesFile ~/.config/dotfiles/gitignore
config config --local submodule.recurse true
config reset --hard
config pull
```

### Requirements

- for install:  `git` or `unzip`, `curl` or `wget`
- for pushes:   `git`, `openssh`, and keys registered with github
- In [.zshrc](.zshrc):    `alias config="git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME"`
- In .zshrc:    `export "PATH=$PATH:$HOME/.local/bin:$HOME/bin"`

### What install does

- Create a bare git repo at `~/.dotfiles`
- Checkout files to `$HOME`.
- Git is configured to not show untracked files
- Backup original files to a branch, `backup-master-$HOSTNAME`. (requires `git` be installed beforehand)
- if git user.email isn't set, download `.gitconfig` or input interactively.
- if git+ssh isn't set up or installed, fall back to https
- if `git` isn't installed, fall back to download files
- if `curl` isn't installed, fall back to `wget`

So, basically `$HOME` is a Git repo, but `.git` is renamed `.dotfiles` to avoid conflicts with other tools.
The script handles a lot of use cases to ensure success in all environments.

For more information see the [.local/bin/dotfiles](.local/bin/dotfiles) script.

### Managing the dot files

After installation, the `config` alias will act like `git`
but only for your dot files in `$HOME`.

### Advice and pitfalls

- Never run: `config add <directory>`, `config add -A`, or `config commit -a -m <message>`.
  Instead use: `config add -u` or `config add <file>`
- Dot files will not be backed up if you don't have `git` installed at time of install.
- If you installed without `git` and then decide to install `git` later,
  you can then run `dotfiles install` to create the `~/.dotfiles` bare repo.
- `config` works best if run from home directory.
- `uninstall` may remove some git submodule directories
  which may break original functionality (e.g. OMZ, tpm, .themes)

## Install Script Details

This is additional information about the install script.
It is located at [.local/bin/dotfiles](.local/bin/dotfiles).

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

### To make your own

To incorporate a customized copy of the `dotfiles` script into your dotfiles repo:

1. Match the requirements section.
2. Create an empty dotfiles repo on <https://github.com>
3. Run: `DOTFILES_NAME=<github-username>/dotfiles sh -c "$(curl https://git.io/msdot -L)"`

The only file from this repo you'll inherit is `dotfiles`,
but it will be modified with your defaults.

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

## FAQ

Q: Why not use one of the other dotfiles managers or `stow`?

A: I wanted something as simple as plain `git`, but no simpler.

Q: But isn't your script also complicated?

A: The script is optional and only for initial install.
The core of what it does is simple,
but it handles several special cases.

Q: Why not use symlinks to all the files, instead of a bare repo?

A: I used to, but they don't track with file deletions or moves, 
adding a file required more steps,
and uninstalling or moving the repo was a mess.

Q: How did you create the shortened vanity URL?  Is it safe?

A: [git.io](https://git.io) is [run by github](https://github.blog/2011-11-10-git-io-github-url-shortener/).

This command allocated the URL:

```sh
url="https://raw.githubusercontent.com/mikeslattery/dotfiles/master/.local/bin/dotfiles"
curl https://git.io/ -i -F "url=$url" -F "code=msdot"
```

