# XYBERSEAN Code of Conduct

The safety, privacy, and ethics protocol for everyone — humans and AI —
operating on XYBERSEAN infrastructure.

> Access on any XYBERSEAN host is superuser-equivalent across the entire
> fleet. That is a lot of power. It comes with a duty you do not get to
> opt out of.

## Read it

- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — the full document.
- [`coc-banner.txt`](coc-banner.txt) — the short banner shown at SSH login.

## Install on a fleet host

### macOS / Linux

```sh
git clone https://github.com/Xybersean/code-of-conduct.git
cd code-of-conduct
sudo ./install.sh
```

### Windows

From an **elevated PowerShell** (Run as Administrator):

```powershell
git clone https://github.com/Xybersean/code-of-conduct.git
cd code-of-conduct
.\install.ps1
```

The installer is **idempotent** and safe to re-run. It will:

1. Place the document, banner, and shell hook in `/etc/xybersean/`.
2. Add a drop-in to `/etc/ssh/sshd_config.d/400-xybersean-coc.conf` that
   sets the `Banner` directive — without touching any existing sshd config.
3. Validate the new sshd config with `sshd -t` and roll back if it fails.
4. Wire the same banner into the system-wide interactive shell rc
   (`/etc/zshrc` on macOS, `/etc/bash.bashrc` and `/etc/zsh/zshrc` on
   Linux) so operators who bypass SSH (paired tmux, ttyd, local shell,
   reused sessions) still see the principles.
5. Reload sshd on Linux. On macOS, no reload is needed — the per-connection
   launchd sshd picks up the new banner on the next connection.

### Other modes

```sh
sudo ./install.sh check       # report current state, change nothing
sudo ./install.sh uninstall   # remove everything cleanly
```

PowerShell equivalents:

```powershell
.\install.ps1 -Action check
.\install.ps1 -Action uninstall
```

### Fleet auto-deploy

`deploy-fleet.sh` probes every host, MD5-checks the installed banner
against the local source, and re-deploys only on missing or stale
hosts. Safe to run on a cron / launchd schedule.

```sh
bash deploy-fleet.sh                 # default — Sean-owned boxes
bash deploy-fleet.sh --include-curtis  # also Curtis's macOS boxes
                                       # (sudo password read from
                                       # macOS keychain entry curtis-sudo)
```

Reference launchd plist (`com.xybersean.coc-fleet-sync`, every 30
min) lives in the project memory; copy and adapt for your fleet.

## What gets installed

| Path                                                | Purpose                              |
|-----------------------------------------------------|--------------------------------------|
| `/etc/xybersean/CODE_OF_CONDUCT.md`                 | The full document.                   |
| `/etc/xybersean/coc-banner.txt`                     | The short pre-auth banner.           |
| `/etc/xybersean/coc-motd.sh`                        | Shell-startup hook (interactive only). |
| `/etc/ssh/sshd_config.d/400-xybersean-coc.conf`     | sshd `Banner` directive.             |
| (line in) `/etc/zshrc` or `/etc/bash.bashrc`        | Sources the shell hook.              |

The shell hook is **safe for non-interactive shells**: it returns
immediately if stdout is not a TTY, so it never breaks `scp`, `rsync`,
`git`, ansible, or pipelines.

## Scope

Applies to every operator — human or AI — connecting to or executing on
any XYBERSEAN device. Connecting is acceptance. The full document
([`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)) covers privacy, honesty,
integrity, transparency, due diligence, AI agent specific duties, the
hacker ethics canon, legal compliance, and incident response.

## License

[`CC0 1.0 Universal`](LICENSE). Fork it, adapt it, ship it for your own
team. If you do, we'd love a pointer back to the original — but you owe
us nothing.

## Maintainer

seanito@xybersean.com
