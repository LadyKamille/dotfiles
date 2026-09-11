# worktrunk adapter

Two settings only: the worktree path layout, and a `post-switch` hook that lists
any worktree logs it finds.

The `post-start` and `post-remove` hooks on an existing machine stay local and
untracked — they call repo-specific Make targets and a `frontend/` yarn install,
which belong with the repo they serve rather than in a personal config.

`install.sh` links this file only when `~/.config/worktrunk/config.toml` does not
already exist, so it seeds a new machine without overwriting local hooks. Adding
machine- or employer-specific hooks later means editing them into the linked
file — put those in the repo's own `.config/wt.toml` instead, where worktrunk
appends them to these hooks rather than replacing them.
