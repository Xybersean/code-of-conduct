#!/usr/bin/env bash
# Re-runnable fleet deployer. Probes every host, installs (or re-installs)
# the Code of Conduct on any that respond, skips any that are offline.
# Idempotent — safe to run repeatedly. Curtis's machines intentionally
# excluded; he opts in personally.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTS=(z a x y nina)
TIMEOUT=4

probe() { ssh -o ConnectTimeout="$TIMEOUT" -o BatchMode=yes -o ControlPath=none "$1" 'uname -s' 2>/dev/null; }

deploy_local() {
    sudo bash "$SCRIPT_DIR/install.sh" install
}

deploy_remote() {
    local h="$1"
    rsync -az --delete --exclude=.git "$SCRIPT_DIR/" "$h:xybersean-coc-stage/" >/dev/null
    ssh -o ControlPath=none "$h" "sudo bash ~/xybersean-coc-stage/install.sh install"
}

for h in "${HOSTS[@]}"; do
    if [ "$h" = "z" ]; then
        echo "=== z (local) ==="
        deploy_local && echo "  RESULT: ok" || echo "  RESULT: FAILED"
        continue
    fi
    echo "=== $h ==="
    if probe "$h" >/dev/null; then
        deploy_remote "$h" && echo "  RESULT: ok" || echo "  RESULT: FAILED"
    else
        echo "  SKIP: offline"
    fi
done

echo "Done."
