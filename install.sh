#!/usr/bin/env bash
# XYBERSEAN Code of Conduct — fleet installer.
#
# Idempotent. Safe to re-run. Detects macOS vs Linux and wires the banner
# into the right places. Does NOT touch existing sshd hardening files.
#
# Usage:
#   sudo ./install.sh                  # install
#   sudo ./install.sh --uninstall      # remove
#   sudo ./install.sh --check          # report current state without changing
#
# Files written:
#   /etc/xybersean/CODE_OF_CONDUCT.md
#   /etc/xybersean/coc-banner.txt
#   /etc/xybersean/coc-motd.sh
#
# SSH wiring:
#   macOS:   /etc/ssh/sshd_config.d/400-xybersean-coc.conf  (Banner directive)
#   Linux:   /etc/ssh/sshd_config.d/400-xybersean-coc.conf  (Banner directive)
#
# Shell wiring (one source line, no overwrite):
#   macOS:   /etc/zshrc      (default macOS interactive shell)
#   Linux:   /etc/bash.bashrc
#            /etc/zsh/zshrc  (if zsh is installed system-wide)
#
# Exit codes:
#   0   success
#   1   wrong privileges or unsupported OS
#   2   sshd config validation failed (changes rolled back)

set -euo pipefail

ACTION="${1:-install}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/etc/xybersean"
SSHD_DROPIN="/etc/ssh/sshd_config.d/400-xybersean-coc.conf"
SHELL_HOOK_LINE='[ -r /etc/xybersean/coc-motd.sh ] && . /etc/xybersean/coc-motd.sh   # XYBERSEAN COC'
HOOK_MARKER='# XYBERSEAN COC'

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: must be run as root (use sudo)" >&2
        exit 1
    fi
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *) echo "unsupported" ;;
    esac
}

install_files() {
    install -d -m 0755 "$TARGET_DIR"
    install -m 0644 "$SCRIPT_DIR/CODE_OF_CONDUCT.md" "$TARGET_DIR/CODE_OF_CONDUCT.md"
    install -m 0644 "$SCRIPT_DIR/coc-banner.txt"     "$TARGET_DIR/coc-banner.txt"
    install -m 0755 "$SCRIPT_DIR/coc-motd.sh"        "$TARGET_DIR/coc-motd.sh"
    echo "  ✓ files installed in $TARGET_DIR"
}

install_sshd_dropin() {
    local tmp
    tmp="$(mktemp)"
    cat > "$tmp" <<'EOF'
# XYBERSEAN Code of Conduct — pre-auth SSH banner.
# Installed by https://github.com/Xybersean/code-of-conduct
# Safe to remove this single file to disable the banner without touching
# any other sshd configuration.

Banner /etc/xybersean/coc-banner.txt
EOF
    install -m 0644 "$tmp" "$SSHD_DROPIN"
    rm -f "$tmp"
    echo "  ✓ sshd drop-in: $SSHD_DROPIN"
}

validate_sshd() {
    if command -v sshd >/dev/null 2>&1; then
        if ! sshd -t 2>/tmp/sshd-validate.err; then
            echo "ERROR: sshd config validation failed:" >&2
            cat /tmp/sshd-validate.err >&2
            return 2
        fi
        echo "  ✓ sshd -t passed"
    elif [ -x /usr/sbin/sshd ]; then
        if ! /usr/sbin/sshd -t 2>/tmp/sshd-validate.err; then
            echo "ERROR: sshd config validation failed:" >&2
            cat /tmp/sshd-validate.err >&2
            return 2
        fi
        echo "  ✓ sshd -t passed"
    else
        echo "  ! sshd binary not found; skipping validation (banner will still apply)"
    fi
}

reload_sshd_macos() {
    # macOS launches sshd per-connection via launchd. Banner picks up on the
    # next new connection automatically; no reload needed.
    echo "  ✓ macOS launchd sshd: new connections will pick up the banner (no reload required)"
}

reload_sshd_linux() {
    if command -v systemctl >/dev/null 2>&1; then
        local unit=""
        for u in sshd ssh; do
            if systemctl list-unit-files "${u}.service" >/dev/null 2>&1 \
               && systemctl status "${u}.service" >/dev/null 2>&1; then
                unit="$u"; break
            fi
        done
        if [ -n "$unit" ]; then
            systemctl reload "${unit}.service" 2>/dev/null || systemctl restart "${unit}.service"
            echo "  ✓ reloaded ${unit}.service"
        else
            echo "  ! no sshd/ssh systemd unit detected; banner applies on next sshd restart"
        fi
    else
        echo "  ! systemctl not found; reload sshd manually"
    fi
}

add_shell_hook() {
    local file="$1"
    [ -f "$file" ] || return 0
    if grep -qF "$HOOK_MARKER" "$file"; then
        echo "  · shell hook already present in $file"
        return 0
    fi
    {
        echo ""
        echo "$SHELL_HOOK_LINE"
    } >> "$file"
    echo "  ✓ shell hook added to $file"
}

remove_shell_hook() {
    local file="$1"
    [ -f "$file" ] || return 0
    if grep -qF "$HOOK_MARKER" "$file"; then
        local tmp
        tmp="$(mktemp)"
        grep -vF "$HOOK_MARKER" "$file" > "$tmp"
        install -m 0644 "$tmp" "$file"
        rm -f "$tmp"
        echo "  ✓ shell hook removed from $file"
    fi
}

do_install() {
    local os="$(detect_os)"
    require_root
    echo "[install] OS=$os host=$(hostname)"

    install_files
    install_sshd_dropin

    if ! validate_sshd; then
        rm -f "$SSHD_DROPIN"
        echo "ERROR: rolled back $SSHD_DROPIN due to validation failure" >&2
        exit 2
    fi

    case "$os" in
        macos)
            add_shell_hook /etc/zshrc
            reload_sshd_macos
            ;;
        linux)
            add_shell_hook /etc/bash.bashrc
            add_shell_hook /etc/zsh/zshrc
            reload_sshd_linux
            ;;
        *)
            echo "ERROR: unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    echo "[install] complete on $(hostname)"
}

do_uninstall() {
    local os="$(detect_os)"
    require_root
    echo "[uninstall] OS=$os host=$(hostname)"

    rm -f "$SSHD_DROPIN" && echo "  ✓ removed $SSHD_DROPIN" || true
    rm -rf "$TARGET_DIR" && echo "  ✓ removed $TARGET_DIR" || true

    case "$os" in
        macos) remove_shell_hook /etc/zshrc ;;
        linux)
            remove_shell_hook /etc/bash.bashrc
            remove_shell_hook /etc/zsh/zshrc
            ;;
    esac

    case "$os" in
        macos) reload_sshd_macos ;;
        linux) reload_sshd_linux ;;
    esac

    echo "[uninstall] complete on $(hostname)"
}

do_check() {
    local os="$(detect_os)"
    echo "[check] OS=$os host=$(hostname)"
    echo "  files:"
    for f in CODE_OF_CONDUCT.md coc-banner.txt coc-motd.sh; do
        if [ -r "$TARGET_DIR/$f" ]; then echo "    ✓ $TARGET_DIR/$f"
        else echo "    ✗ MISSING $TARGET_DIR/$f"; fi
    done
    echo "  sshd drop-in:"
    if [ -r "$SSHD_DROPIN" ]; then echo "    ✓ $SSHD_DROPIN"
    else echo "    ✗ MISSING $SSHD_DROPIN"; fi
    echo "  shell hook:"
    case "$os" in
        macos)
            grep -qF "$HOOK_MARKER" /etc/zshrc 2>/dev/null \
                && echo "    ✓ /etc/zshrc" || echo "    ✗ /etc/zshrc"
            ;;
        linux)
            grep -qF "$HOOK_MARKER" /etc/bash.bashrc 2>/dev/null \
                && echo "    ✓ /etc/bash.bashrc" || echo "    ✗ /etc/bash.bashrc"
            [ -f /etc/zsh/zshrc ] && {
                grep -qF "$HOOK_MARKER" /etc/zsh/zshrc 2>/dev/null \
                    && echo "    ✓ /etc/zsh/zshrc" || echo "    ✗ /etc/zsh/zshrc"
            }
            ;;
    esac
}

case "$ACTION" in
    install)   do_install ;;
    --install) do_install ;;
    uninstall) do_uninstall ;;
    --uninstall) do_uninstall ;;
    check)     do_check ;;
    --check)   do_check ;;
    *) echo "Usage: $0 [install|uninstall|check]"; exit 1 ;;
esac
