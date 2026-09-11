# dotfiles

Personal shell and AI-agent configuration.

| Path | What it is |
| --- | --- |
| `.zshrc` | oh-my-zsh config: `agnoster` theme, plugins, and aliases — hook-free git wrappers (`pbgco`, `pbgpull`, `pbgmerge`, `pbgrbi`), `socat` port forwards, `gbd`. |
| `bootstrap.sh` | First-run shell setup: installs zsh, oh-my-zsh, the autosuggestions and syntax-highlighting plugins, and powerline fonts, then appends `.zshrc` to `~/.zshrc`. |
| `ai/` | Agent-agnostic instructions, skills, and per-agent settings. See [ai/README.md](ai/README.md). |

## Setup

```bash
git clone --recurse-submodules git@github.com:LadyKamille/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh    # shell; apt-based, so Linux only
./ai/install.sh   # agent config; macOS and Linux
```

The two halves are independent — `bootstrap.sh` does not touch `ai/`, and
`ai/install.sh` does not touch the shell.

`bootstrap.sh` appends to `~/.zshrc` rather than linking it, so shell changes
have to be copied back here by hand. `ai/install.sh` symlinks instead, so agent
config edits are already staged in git.

Already-cloned checkout missing `ai/vendor/`? Run
`git submodule update --init --recursive`.
