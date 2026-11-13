# make sky the default for every folder (machine-wide, needs admin) and every zip (per-user)
param([string]$Icons = "$HOME\.icons")
$folder = "$Icons\folder-sky.ico"; $zip = "$Icons\zip-sky.ico"

New-Item 'HKCU:\Software\Classes\CompressedFolder\DefaultIcon' -Force | Out-Null
Set-ItemProperty 'HKCU:\Software\Classes\CompressedFolder\DefaultIcon' '(default)' "$zip,0"
"  sky  zip files"

$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
$set = "New-Item '$key' -Force | Out-Null; Set-ItemProperty '$key' '3' '$folder,0'; Set-ItemProperty '$key' '4' '$folder,0'"
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')
if ($admin) { Invoke-Expression $set }
else { Start-Process pwsh -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', $set }
if ((Get-ItemProperty $key -ErrorAction SilentlyContinue).'3') { "  sky  every folder" } else { "  skip every folder (elevation declined)" }

ie4uinit.exe -show
