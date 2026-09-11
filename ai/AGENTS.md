- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

# Coding Standards
- Prefer descriptive variable and method names to comments. Comments should only be used for doc blocks, describing business logic, or explaining complex logic.

# Plans
- At the end of each plan, give me a list of unresolved questions if any. Make the questions extremely concise.

# Worktrees
- Always use `wt` (worktrunk) for worktree operations — never raw `git worktree add/remove/list`.
- Run git/gh and other commands directly from the worktree working directory — do not cd into the main project directory first.
- As soon as a worktree is the target for implementation, switch the session context into that worktree directory (e.g. EnterWorktree) before reading, editing, or running commands.
