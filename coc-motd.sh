#!/bin/sh
# XYBERSEAN Code of Conduct — interactive shell hook.
#
# Sourced from /etc/zshrc (macOS) or /etc/bash.bashrc (Linux) so that
# operators who bypass the SSH pre-auth banner (paired tmux, ttyd, local
# shell, reused sessions) still see the principles once per shell.
#
# Safe for non-interactive shells: returns immediately if not a TTY,
# so it never breaks scp, rsync, git, ansible, or pipelines.

# Bail on non-interactive shells (no TTY on stdin or stdout).
[ -t 0 ] && [ -t 1 ] || return 0

# Show only once per shell.
[ -n "${XYBERSEAN_COC_SHOWN:-}" ] && return 0
XYBERSEAN_COC_SHOWN=1
export XYBERSEAN_COC_SHOWN

# Render the banner in bold red if the terminal supports color.
if [ -r /etc/xybersean/coc-banner.txt ]; then
    if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
        printf '\033[1;31m'
        cat /etc/xybersean/coc-banner.txt
        printf '\033[0m\n'
    else
        cat /etc/xybersean/coc-banner.txt
    fi
fi
