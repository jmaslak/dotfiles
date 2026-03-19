#!/usr/bin/env python3

#
# Copyright (C) 2026 Joelle Maslak
# All Rights Reserved - See License
#

import json
import os

SETTINGS_PATH = os.path.expanduser("~/.claude/settings.json")
HOOK_NAME = "talker"
HOOK_COMMAND = f"for i in 1 2 3; do say ready; sleep 0.5; done # {HOOK_NAME}"


def main():
    with open(SETTINGS_PATH) as f:
        settings = json.load(f)

    stop_hooks = settings.get("hooks", {}).get("Stop", [])
    flag = False
    for group in stop_hooks:
        for hook in group.get("hooks", []):
            if f"# {HOOK_NAME}" in hook.get("command", ""):
                flag = True
                if HOOK_COMMAND != hook["command"]:
                    hook["command"] = HOOK_COMMAND
                else:
                    return

    if not flag:
        settings.setdefault("hooks", {}).setdefault("Stop", []).append(
            {"hooks": [{"type": "command", "command": HOOK_COMMAND}]}
        )

    with open(SETTINGS_PATH, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")

    print(f"Hook '{HOOK_NAME}' added.")


if __name__ == "__main__":
    main()
