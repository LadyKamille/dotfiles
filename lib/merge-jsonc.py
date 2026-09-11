#!/usr/bin/env python3
"""Add a baseline's top-level settings to a target JSONC file without replacing it.

Keys already present in the target are left alone, whatever their value, so a
local choice always wins. The target's own text -- comments, ordering, grouping
-- is preserved; new keys are appended in a marked block before the final brace.
"""
import json
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

MARKER = "// --- added from dotfiles baseline ---"


def strip_comments(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'(^|\s)//.*$', '', text, flags=re.M)


def top_level_keys(text):
    return set(json.loads(strip_comments(text) or '{}').keys())


def render(source_text, keys):
    """Pull each key's literal text out of the baseline, so formatting survives.

    Returns one entry per key, trailing comma stripped; the caller joins them.
    """
    lines = source_text.splitlines()
    entries = []
    for key in keys:
        start = next(i for i, l in enumerate(lines) if l.lstrip().startswith(f'"{key}"'))
        depth = lines[start].count('{') + lines[start].count('[')
        depth -= lines[start].count('}') + lines[start].count(']')
        block = [lines[start]]
        i = start
        while depth > 0:
            i += 1
            depth += lines[i].count('{') + lines[i].count('[')
            depth -= lines[i].count('}') + lines[i].count(']')
            block.append(lines[i])
        entries.append('\n'.join(block).rstrip().rstrip(','))
    return entries


def main():
    baseline, target, dry_run = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3] == '1'
    baseline_text = baseline.read_text()

    if not target.exists():
        if dry_run:
            print(f"would create {target} from baseline")
            return 0
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(baseline, target)
        print(f"create {target} from baseline")
        return 0

    target_text = target.read_text()
    missing = [k for k in top_level_keys(baseline_text) - top_level_keys(target_text)]
    missing.sort()
    if not missing:
        print(f"ok    {target} (baseline already covered)")
        return 0

    if dry_run:
        print(f"would add {len(missing)} setting(s) to {target}: {', '.join(missing)}")
        return 0

    backup = target.with_suffix(target.suffix + '.bak-' + datetime.now().strftime('%Y%m%d%H%M%S'))
    shutil.copy(target, backup)

    close = target_text.rstrip().rfind('}')
    head, tail = target_text[:close].rstrip(), target_text[close:]
    if not head.endswith((',', '{')):
        head += ','
    entries = render(baseline_text, missing)
    block = '\n\n  ' + MARKER + '\n' + ',\n'.join(entries) + '\n'
    target.write_text(head + block + tail)
    print(f"merge {target}: added {len(missing)} setting(s) ({', '.join(missing)})")
    print(f"      previous file kept at {backup}")
    return 0


if __name__ == '__main__':
    sys.exit(main())
