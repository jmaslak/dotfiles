#!/usr/bin/env python3

#
# Copyright (C) 2026 Joelle Maslak
# All Rights Reserved - See License
#

import json
import os

SETTINGS_PATH = os.path.expanduser("~/.claude/settings.json")
HOOK_COMMAND = f"for i in 1 2 3; do say ready; sleep 0.5; done"


def add_hook(hook_type, hook_desc, hook_command):
    with open(SETTINGS_PATH) as f:
        settings = json.load(f)

    hooks = settings.get("hooks", {}).get(hook_type, [])
    flag = False
    for group in hooks:
        for hook in group.get("hooks", []):
            if f"# {hook_desc}" in hook.get("command", ""):
                flag = True
                if hook_command != hook["command"]:
                    hook["command"] = hook_command
                else:
                    return

    if not flag:
        settings.setdefault("hooks", {}).setdefault(hook_type, []).append(
            {"hooks": [{"type": "command", "command": hook_command}]}
        )

    with open(SETTINGS_PATH, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")

    print(f"Hook '{hook_type}-{hook_desc}' added.")


def main():
    add_hook("Stop", "talker", HOOK_COMMAND + " # talker")
    add_hook("Notification", "notifier", HOOK_COMMAND + " # notifier")


if __name__ == "__main__":
    main()
