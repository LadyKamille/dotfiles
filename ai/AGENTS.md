- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

# Coding Standards
- Prefer descriptive variable and method names to comments. Comments should only be used for doc blocks, describing business logic, or explaining complex logic.
- Comments (including doc blocks) are written for a future reviewer reading the code cold — keep them additive and about the code itself. Don't narrate the change, the conversation that produced it, or which existing pattern it mirrors; that history belongs in the PR or an ADR.

# Safety
- Only make GET requests against external APIs unless I ask otherwise. If a task seems to need a write, ask first.
- Never force-push (`--force-with-lease` included), and never rebase beyond a `reword`, without explicit permission. Reordering, squashing, dropping, and amending already-pushed commits all need asking first. Normal fast-forward pushes are fine.
- When a committed script fails because of a gap in the local environment, fix the invocation for that run — don't edit shared code to route around a local quirk.

# Plans
- At the end of each plan, give me a list of unresolved questions if any. Make the questions extremely concise.

# Worktrees
- Always use `wt` (worktrunk) for worktree operations — never raw `git worktree add/remove/list`.
- Run git/gh and other commands directly from the worktree working directory — do not cd into the main project directory first.
- As soon as a worktree is the target for implementation, switch the session context into that worktree directory (e.g. EnterWorktree) before reading, editing, or running commands.
