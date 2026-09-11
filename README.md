# dotfiles

Personal shell and AI-agent configuration.

| Path | What it is |
| --- | --- |
| `.zshrc` | oh-my-zsh config: `agnoster` theme, plugins, and aliases — hook-free git wrappers (`pbgco`, `pbgpull`, `pbgmerge`, `pbgrbi`), `socat` port forwards, `gbd`. |
| `Brewfile` | Personal macOS toolchain, installed by `bootstrap.sh` via `brew bundle`. Work-only tools stay off it. |
| `bootstrap.sh` | First-run shell setup for macOS (Homebrew) or Debian/Ubuntu (apt): installs zsh, oh-my-zsh, the two zsh plugins, a powerline font, and gitleaks, then links `.zshrc`. |
| `ai/` | Agent-agnostic instructions, skills, and per-agent settings. See [ai/README.md](ai/README.md). |
| `vscode/` | VS Code user settings, including the Copilot chat keys. |
| `worktrunk/` | Worktree path layout and the post-switch log hook; seeded only where no worktrunk config exists. |
| `git/` | Global git identity and the global gitignore (`~/.gitconfig`, `~/.config/git/ignore`). |
| `hooks/` | `pre-commit`, which blocks a commit whose staged changes look like a credential. Needs `gitleaks`. |
| `lib/` | Symlink helpers shared by the two installers. |

## Setup

```bash
git clone --recurse-submodules git@github.com:LadyKamille/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh   # zsh, oh-my-zsh, plugins, fonts, gitleaks; links .zshrc
./install.sh     # git config, the pre-commit hook, and all agent config
```

Both scripts are idempotent, and `DRY_RUN=1` makes either one print what it
would change without touching anything.

`install.sh` links the git config and this repo's pre-commit hook, then runs
`ai/install.sh`; run that one alone for agent config only. `bootstrap.sh` is
separate and touches neither.

The hook is installed into this repo's `.git/hooks` only — `core.hooksPath`
stays untouched so other repos keep their own hooks. Without `gitleaks` on
PATH the hook passes everything and says so.

## Machine-specific shell settings

`bootstrap.sh` links `~/.zshrc` to the tracked one, and the tracked one sources
`~/.zshrc.local` when it exists. PATH entries, tokens, and per-host tweaks go in
that untracked file — never in `.zshrc`, which is public.

Migrating a machine whose `~/.zshrc` predates this: the link step backs the old
file up under `~/.agent-config-backups/`, so move anything machine-specific out
of that backup into `~/.zshrc.local`.

Already-cloned checkout missing `ai/vendor/`? Run
`git submodule update --init --recursive`.
