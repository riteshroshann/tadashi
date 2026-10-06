<#
  Tadashi / privacy
  Default:   per-user hardening, no elevation. Every key it touches is exported first,
             so `reg import` on the backup undoes it.
  -Machine:  system-wide hardening; run from an elevated PowerShell.
  -Dns:      with -Machine, also route DNS through Quad9 over HTTPS.
  Usage:     powershell -ExecutionPolicy Bypass -File setup\privacy.ps1 [-Machine [-Dns]]
#>
param([switch]$Machine, [switch]$Dns)
$ErrorActionPreference = 'Stop'
$backup = Join-Path $env:USERPROFILE (".tadashi-backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss') + "\registry")

function Set-Values([string]$key, [hashtable]$values) {
  New-Item -ItemType Directory -Force $backup | Out-Null
  $native = $key -replace '^HKCU:\\', 'HKCU\' -replace '^HKLM:\\', 'HKLM\'
  $file = Join-Path $backup (($native -replace '[\\: ]', '_') + '.reg')
  if (Test-Path $key) {
    reg export $native $file /y | Out-Null
  } else {
    Add-Content (Join-Path $backup 'created-keys.txt') $native   # undo: delete these keys
    New-Item -Path $key -Force | Out-Null
  }
  foreach ($name in $values.Keys) {
    New-ItemProperty -Path $key -Name $name -Value $values[$name] -PropertyType DWord -Force | Out-Null
  }
  Write-Host ("  set    {0}" -f $key)
}

if (-not $Machine) {
  Write-Host "`n[user] Advertising, tracking and suggestions"
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' @{ Enabled = 0 }
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' @{ TailoredExperiencesWithDiagnosticDataEnabled = 0 }
  Set-Values 'HKCU:\Control Panel\International\User Profile' @{ HttpAcceptLanguageOptOut = 1 }
  Set-Values 'HKCU:\Software\Microsoft\Siuf\Rules' @{ NumberOfSIUFInPeriod = 0 }
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' @{
    SilentInstalledAppsEnabled = 0; SystemPaneSuggestionsEnabled = 0; SoftLandingEnabled = 0
    'SubscribedContent-338388Enabled' = 0; 'SubscribedContent-338389Enabled' = 0
    'SubscribedContent-338393Enabled' = 0; 'SubscribedContent-353694Enabled' = 0
    'SubscribedContent-353696Enabled' = 0
  }

  Write-Host "`n[user] Speech, typing and inking stay on the device"
  Set-Values 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' @{ HasAccepted = 0 }
  Set-Values 'HKCU:\Software\Microsoft\InputPersonalization' @{ RestrictImplicitTextCollection = 1; RestrictImplicitInkCollection = 1 }
  Set-Values 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' @{ HarvestContacts = 0 }
  Set-Values 'HKCU:\Software\Microsoft\Personalization\Settings' @{ AcceptedPrivacyPolicy = 0 }

  Write-Host "`n[user] Explorer and Start: show the truth, keep history private"
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' @{
    HideFileExt = 0; Hidden = 1; Start_TrackProgs = 0; Start_IrisRecommendations = 0; ShowCopilotButton = 0
  }
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' @{ ShowRecent = 0; ShowFrequent = 0 }
  Set-Values 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' @{ BingSearchEnabled = 0; CortanaConsent = 0 }

  Write-Host "`nDone. Sign out and back in (or restart Explorer) for Explorer and Start changes."
  Write-Host "Undo: reg import each file in $backup"
  return
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { throw "-Machine needs an elevated PowerShell (Run as administrator)." }

Write-Host "`n[machine] Disk encryption"
$ErrorActionPreference = 'Continue'   # manage-bde writes to stderr on editions without BitLocker
$status = manage-bde -status C: 2>&1 | Out-String
$ErrorActionPreference = 'Stop'
if ($status -match 'Protection On') { Write-Host "  ok     C: is encrypted" }
else {
  Write-Host "  WARN   C: is NOT encrypted. Turn on Settings > Privacy & security > Device encryption."
  Write-Host "         If that page is missing, Windows 11 Pro adds BitLocker, Windows Sandbox and Hyper-V."
}

Write-Host "`n[machine] Diagnostics and activity history"
Set-Values 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' @{ AllowTelemetry = 1; DoNotShowFeedbackNotifications = 1 }
Set-Values 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' @{ PublishUserActivities = 0; UploadUserActivities = 0; EnableActivityFeed = 0 }
Set-Values 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' @{ DisabledByGroupPolicy = 1 }
Set-Values 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' @{ TurnOffWindowsCopilot = 1 }
Set-Values 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' @{ fAllowToGetHelp = 0 }
# user policy, so it lands in whoever elevated. on a one-person laptop that's you
Set-Values 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' @{ DisableSearchBoxSuggestions = 1 }

Write-Host "`n[machine] Defender and firewall"
try {
  Set-MpPreference -PUAProtection Enabled -EnableNetworkProtection Enabled
  Write-Host "  set    Defender: block potentially unwanted apps and malicious domains"
} catch { Write-Host "  skip   Defender settings (another antivirus may be in charge)" }
Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True -DefaultInboundAction Block
Write-Host "  set    Firewall on for every profile, inbound blocked by default"

Write-Host "`n[machine] Trusted privacy apps (free, open source, audited)"
foreach ($id in 'Proton.ProtonVPN', 'IDRIX.VeraCrypt') {
  winget install --id $id -e --scope machine --silent --disable-interactivity `
    --accept-source-agreements --accept-package-agreements | Out-Null
  if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) { Write-Host ("  done   {0}" -f $id) }
  else { Write-Host ("  FAIL   {0} (exit {1})" -f $id, $LASTEXITCODE) }
}

if ($Dns) {
  Write-Host "`n[machine] Encrypted DNS (Quad9, DNS over HTTPS)"
  $servers = '9.9.9.9', '149.112.112.112'
  $doh = @{ DohTemplate = 'https://dns.quad9.net/dns-query'; AllowFallbackToUdp = $false; AutoUpgrade = $true }
  foreach ($s in $servers) {
    # windows already lists quad9, with auto-upgrade off. fix it in place
    if (Get-DnsClientDohServerAddress -ServerAddress $s -ErrorAction SilentlyContinue) {
      Set-DnsClientDohServerAddress -ServerAddress $s @doh
    } else {
      Add-DnsClientDohServerAddress -ServerAddress $s @doh
    }
  }
  # physical adapters only; leave the wsl and docker switches alone
  Get-NetAdapter -Physical | Where-Object Status -eq 'Up' | ForEach-Object {
    Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses $servers
    Write-Host ("  set    {0} -> Quad9 over HTTPS" -f $_.Name)
    Write-Host ("  note   Hotel or airport login page not loading? Set-DnsClientServerAddress -InterfaceAlias '{0}' -ResetServerAddresses" -f $_.Name)
  }
  if (Get-Service CloudflareWARP -ErrorAction SilentlyContinue | Where-Object Status -eq 'Running') {
    Write-Host "  note   Cloudflare WARP is running and takes over DNS while connected (encrypted to Cloudflare)."
    Write-Host "         Quad9 applies whenever WARP is off. Run one VPN at a time."
  }
  Clear-DnsClientCache
  try {
    $check = (Invoke-WebRequest -UseBasicParsing 'https://on.quad9.net' -TimeoutSec 15).Content
    if ($check -match 'YES') { Write-Host "  ok     on.quad9.net confirms Quad9 is answering" }
    else { Write-Host "  WARN   on.quad9.net says Quad9 is not in use yet" }
  } catch { Write-Host "  WARN   could not reach on.quad9.net to confirm" }
}

Write-Host "`nDone. Backups in $backup"
