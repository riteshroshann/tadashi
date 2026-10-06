"""status line: folder, branch, model, context, cost.

reads the session json on stdin, prints one line. reads .git/HEAD directly so it stays fast.
"""
import json
import sys
from pathlib import Path

PINK, CYAN, VIOLET, AMBER, DIM, RESET = (
    "\033[38;2;255;42;109m", "\033[38;2;5;217;232m", "\033[38;2;185;103;255m",
    "\033[38;2;255;209;102m", "\033[38;2;74;79;99m", "\033[0m",
)


def branch(start):
    for d in [start, *start.parents]:
        head = d / ".git" / "HEAD"
        if head.is_file():
            ref = head.read_text(encoding="utf-8").strip()
            return ref.removeprefix("ref: refs/heads/") if ref.startswith("ref:") else ref[:7]
        if (d / ".git").is_file():  # worktree or submodule: .git is a pointer file
            return "worktree"
    return None


def main():
    try:
        s = json.loads(sys.stdin.buffer.read().decode("utf-8") or "{}")
    except ValueError:
        s = {}
    cwd = Path((s.get("workspace") or {}).get("current_dir") or s.get("cwd") or ".")
    parts = [f"{CYAN}{cwd.name or cwd}{RESET}"]

    b = branch(cwd)
    if b:
        parts.append(f"{PINK} {b}{RESET}")

    model = (s.get("model") or {}).get("display_name")
    if model:
        parts.append(f"{VIOLET}{model}{RESET}")

    ctx = s.get("context_window") or {}
    used = ctx.get("used_percentage")
    if isinstance(used, (int, float)):
        colour = AMBER if used >= 70 else DIM
        parts.append(f"{colour}ctx {used:.0f}%{RESET}")

    cost = s.get("cost") or {}
    usd = cost.get("total_cost_usd")
    if isinstance(usd, (int, float)) and usd > 0:
        parts.append(f"{DIM}${usd:.2f}{RESET}")
    added, removed = cost.get("total_lines_added"), cost.get("total_lines_removed")
    if added or removed:
        parts.append(f"{DIM}+{added or 0} -{removed or 0}{RESET}")

    sys.stdout.buffer.write(("  ".join(parts)).encode("utf-8"))


if __name__ == "__main__":
    main()
