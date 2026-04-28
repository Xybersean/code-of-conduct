#!/usr/bin/env bash
# Re-runnable fleet deployer for the XYBERSEAN Code of Conduct.
#
# Probes every host, deploys the installer to any host that:
#   1. is reachable via SSH right now, AND
#   2. either has no banner installed yet, or has a stale banner
#      (checksum differs from the local source).
#
# Idempotent — safe to run on a cron / launchd schedule. Skips hosts
# that are offline, skips hosts already current, skips Windows nina
# (manual install via install.ps1 only), and by default skips Curtis's
# machines (his hardware, his consent gates each update).
#
# Usage:
#   deploy-fleet.sh                # default: skips Curtis's boxes
#   deploy-fleet.sh --include-curtis  # also push to curtis-imac/MBA
#                                     # requires curtis-sudo entry in keychain
#                                     # (security add-generic-password -s curtis-sudo
#                                     #   -a curtisbeaverford -w "...")
#
# Exit codes:
#   0   one or more deploys succeeded, or everyone is already current
#   1   transient SSH/rsync failure on a host (others may have succeeded)
#
# Logs to stdout. When run from launchd, redirect to a file.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMEOUT=5

INCLUDE_CURTIS=0
for arg in "$@"; do
    case "$arg" in
        --include-curtis) INCLUDE_CURTIS=1 ;;
        --help|-h)
            sed -n '2,30p' "$0" | grep -E '^# ' | sed 's/^# //; s/^#$//'
            exit 0
            ;;
    esac
done

# Sean-owned hosts (passwordless sudo via Sean's z account).
SEAN_HOSTS=(z a x y)
# Windows host (manual install via install.ps1; we just probe and report).
WINDOWS_HOSTS=(nina)
# Curtis-owned hosts (sudo password gated; opt-in via --include-curtis).
CURTIS_HOSTS=(curtis-imac curtis-macbookair)

# Local source banner checksum — single source of truth.
LOCAL_MD5="$(md5 -q "$SCRIPT_DIR/coc-banner.txt" 2>/dev/null \
             || md5sum "$SCRIPT_DIR/coc-banner.txt" 2>/dev/null | awk '{print $1}')"

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '[%s] %s\n' "$(ts)" "$*"; }

probe_unix() {
    ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes -o ControlPath=none "$1" \
        'uname -s' 2>/dev/null
}

remote_md5() {
    # Returns the remote banner MD5 or empty string if missing.
    ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes -o ControlPath=none "$1" '
        if [ -r /etc/xybersean/coc-banner.txt ]; then
            if command -v md5sum >/dev/null 2>&1; then
                md5sum /etc/xybersean/coc-banner.txt | awk "{print \$1}"
            elif command -v md5 >/dev/null 2>&1; then
                md5 -q /etc/xybersean/coc-banner.txt
            fi
        fi
    ' 2>/dev/null
}

deploy_local() {
    sudo bash "$SCRIPT_DIR/install.sh" install
}

deploy_remote() {
    local h="$1"
    rsync -az --delete --exclude=.git -e "ssh -o ControlPath=none" \
        "$SCRIPT_DIR/" "$h:xybersean-coc-stage/" >/dev/null
    ssh -o ControlPath=none "$h" "sudo bash ~/xybersean-coc-stage/install.sh install"
}

deploy_curtis() {
    local h="$1"
    local pw
    pw="$(security find-generic-password -s curtis-sudo -a curtisbeaverford -w 2>/dev/null)"
    if [ -z "$pw" ]; then
        log "  SKIP $h: no curtis-sudo entry in keychain (run security add-generic-password)"
        return 1
    fi
    rsync -az --delete --exclude=.git -e "ssh -o ControlPath=none" \
        "$SCRIPT_DIR/" "$h:xybersean-coc-stage/" >/dev/null
    printf '%s\n' "$pw" | ssh -o ControlPath=none "$h" \
        "sudo -S bash ~/xybersean-coc-stage/install.sh install" 2>&1 \
        | grep -v '^Password:'
}

handle_unix_host() {
    local h="$1"
    local deploy_fn="$2"

    if [ "$h" = "z" ]; then
        # Local: just install. Always cheap, bash will skip if already current.
        log "=== z (local) ==="
        deploy_local && log "  ok" || { log "  FAILED"; return 1; }
        return 0
    fi

    if ! probe_unix "$h" >/dev/null; then
        log "=== $h: offline, skip"
        return 0
    fi

    local rmd5
    rmd5="$(remote_md5 "$h")"
    if [ "$rmd5" = "$LOCAL_MD5" ] && [ -n "$rmd5" ]; then
        log "=== $h: already current ($rmd5)"
        return 0
    fi

    log "=== $h: ${rmd5:-missing} -> $LOCAL_MD5, deploying"
    "$deploy_fn" "$h" && log "  ok" || { log "  FAILED on $h"; return 1; }
}

probe_windows() {
    # Windows OpenSSH server: probe via SSH, but install is manual via install.ps1.
    local h="$1"
    if ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes -o ControlPath=none "$h" \
       'powershell -Command "Test-Path C:\ProgramData\xybersean\coc-banner.txt"' \
       2>/dev/null | grep -q True; then
        log "=== $h: Windows, banner present (manual updates required via install.ps1)"
    else
        if ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes -o ControlPath=none "$h" \
           true 2>/dev/null; then
            log "=== $h: Windows, banner MISSING — manual install needed (run install.ps1 from elevated PowerShell)"
        else
            log "=== $h: Windows, offline"
        fi
    fi
}

log "deploy-fleet.sh starting (local md5: $LOCAL_MD5)"

EXIT=0

for h in "${SEAN_HOSTS[@]}"; do
    handle_unix_host "$h" deploy_remote || EXIT=1
done

for h in "${WINDOWS_HOSTS[@]}"; do
    probe_windows "$h"
done

if [ "$INCLUDE_CURTIS" = "1" ]; then
    for h in "${CURTIS_HOSTS[@]}"; do
        handle_unix_host "$h" deploy_curtis || EXIT=1
    done
else
    for h in "${CURTIS_HOSTS[@]}"; do
        log "=== $h: Curtis-owned, skipped (re-run with --include-curtis to push)"
    done
fi

log "deploy-fleet.sh done (exit $EXIT)"
exit "$EXIT"
