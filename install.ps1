# XYBERSEAN Code of Conduct — Windows installer.
#
# Mirrors install.sh for Windows boxes (nina). Requires an elevated
# PowerShell session (Run as Administrator) because it writes to
# ProgramData and the OpenSSH server config.
#
# Usage (from elevated PowerShell):
#   .\install.ps1                  # install
#   .\install.ps1 -Action uninstall
#   .\install.ps1 -Action check
#
# Files written:
#   C:\ProgramData\xybersean\CODE_OF_CONDUCT.md
#   C:\ProgramData\xybersean\coc-banner.txt
#   C:\ProgramData\ssh\sshd_config.d\400-xybersean-coc.conf
#
# OpenSSH on Windows: C:\ProgramData\ssh\sshd_config typically already
# has `Include sshd_config.d\*.conf` on recent OpenSSH installs. If it
# does not, this script appends an Include directive (idempotent).

param(
    [ValidateSet("install","uninstall","check")]
    [string]$Action = "install"
)

$ErrorActionPreference = "Stop"

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TargetDir   = "C:\ProgramData\xybersean"
$SshDropinDir = "C:\ProgramData\ssh\sshd_config.d"
$SshDropin   = Join-Path $SshDropinDir "400-xybersean-coc.conf"
$SshdConfig  = "C:\ProgramData\ssh\sshd_config"
$BannerDest  = Join-Path $TargetDir "coc-banner.txt"

function Assert-Admin {
    $current = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Must run from an elevated PowerShell (Run as Administrator)."
        exit 1
    }
}

function Install-Files {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $ScriptDir "CODE_OF_CONDUCT.md") -Destination $TargetDir -Force
    Copy-Item -Path (Join-Path $ScriptDir "coc-banner.txt")     -Destination $TargetDir -Force
    Write-Host "  [+] files installed in $TargetDir"
}

function Install-SshdDropin {
    if (-not (Test-Path $SshDropinDir)) {
        New-Item -ItemType Directory -Path $SshDropinDir -Force | Out-Null
    }
    $content = @"
# XYBERSEAN Code of Conduct — pre-auth SSH banner.
# Installed by https://github.com/Xybersean/code-of-conduct
# Safe to remove this single file to disable the banner without touching
# any other sshd configuration.

Banner $BannerDest
"@
    Set-Content -Path $SshDropin -Value $content -Encoding ASCII
    Write-Host "  [+] sshd drop-in: $SshDropin"

    # Ensure main sshd_config includes the drop-in directory (older
    # OpenSSH for Windows builds did not include this by default).
    if (Test-Path $SshdConfig) {
        $sshdContent = Get-Content $SshdConfig -Raw
        if ($sshdContent -notmatch "Include\s+sshd_config\.d") {
            Add-Content -Path $SshdConfig -Value "`r`n# Added by XYBERSEAN Code of Conduct installer`r`nInclude sshd_config.d\*.conf"
            Write-Host "  [+] added Include directive to $SshdConfig"
        } else {
            Write-Host "  [.] sshd_config already includes drop-in directory"
        }
    } else {
        Write-Warning "sshd_config not found at $SshdConfig — install OpenSSH server first."
    }
}

function Restart-Sshd {
    $svc = Get-Service -Name sshd -ErrorAction SilentlyContinue
    if ($svc) {
        Restart-Service -Name sshd
        Write-Host "  [+] restarted sshd service"
    } else {
        Write-Warning "sshd service not found — banner will apply once OpenSSH server is running."
    }
}

function Do-Install {
    Assert-Admin
    Write-Host "[install] OS=Windows host=$env:COMPUTERNAME"
    Install-Files
    Install-SshdDropin
    Restart-Sshd
    Write-Host "[install] complete on $env:COMPUTERNAME"
}

function Do-Uninstall {
    Assert-Admin
    Write-Host "[uninstall] OS=Windows host=$env:COMPUTERNAME"
    if (Test-Path $SshDropin) { Remove-Item $SshDropin -Force; Write-Host "  [+] removed $SshDropin" }
    if (Test-Path $TargetDir) { Remove-Item $TargetDir -Recurse -Force; Write-Host "  [+] removed $TargetDir" }
    Restart-Sshd
    Write-Host "[uninstall] complete on $env:COMPUTERNAME"
}

function Do-Check {
    Write-Host "[check] OS=Windows host=$env:COMPUTERNAME"
    Write-Host "  files:"
    foreach ($f in @("CODE_OF_CONDUCT.md","coc-banner.txt")) {
        $p = Join-Path $TargetDir $f
        if (Test-Path $p) { Write-Host "    [OK]  $p" } else { Write-Host "    [MISS] $p" }
    }
    Write-Host "  sshd drop-in:"
    if (Test-Path $SshDropin) { Write-Host "    [OK]  $SshDropin" } else { Write-Host "    [MISS] $SshDropin" }
}

switch ($Action) {
    "install"   { Do-Install }
    "uninstall" { Do-Uninstall }
    "check"     { Do-Check }
}
