# dotfiles

Personal shell and AI-agent configuration.

| Path | What it is |
| --- | --- |
| `.zshrc` | oh-my-zsh config: `agnoster` theme, plugins, and aliases — hook-free git wrappers (`pbgco`, `pbgpull`, `pbgmerge`, `pbgrbi`), `socat` port forwards, `gbd`. |
| `bootstrap.sh` | First-run shell setup: installs zsh, oh-my-zsh, the autosuggestions and syntax-highlighting plugins, and powerline fonts, then appends `.zshrc` to `~/.zshrc`. |
| `ai/` | Agent-agnostic instructions, skills, and per-agent settings. See [ai/README.md](ai/README.md). |
| `git/` | Global git identity and the global gitignore (`~/.gitconfig`, `~/.config/git/ignore`). |
| `hooks/` | `pre-commit`, which blocks a commit whose staged changes look like a credential. Needs `gitleaks`. |
| `lib/` | Symlink helpers shared by the two installers. |

## Setup

```bash
brew install gitleaks   # or your platform's package manager
git clone --recurse-submodules git@github.com:LadyKamille/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh   # shell; apt-based, so Linux only
./install.sh     # git config, the pre-commit hook, and all agent config
```

`install.sh` links the git config and this repo's pre-commit hook, then runs
`ai/install.sh`; run that one alone for agent config only. `bootstrap.sh` is
separate and touches neither.

The hook is installed into this repo's `.git/hooks` only — `core.hooksPath`
stays untouched so other repos keep their own hooks. Without `gitleaks` on
PATH the hook passes everything and says so.

`bootstrap.sh` appends to `~/.zshrc` rather than linking it, so shell changes
have to be copied back here by hand. `ai/install.sh` symlinks instead, so agent
config edits are already staged in git.

Already-cloned checkout missing `ai/vendor/`? Run
`git submodule update --init --recursive`.
