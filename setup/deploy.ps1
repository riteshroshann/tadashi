<#
  Tadashi / deploy
  Puts the kit in place: Claude standing orders and skills, the folio Typst package,
  the prompt, the PowerShell profile, the Windows Terminal theme and the Nerd Font.
  Anything it replaces is backed up to ~/.tadashi-backup/<timestamp> first. Idempotent.
  Usage:  powershell -ExecutionPolicy Bypass -File setup\deploy.ps1
#>
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
$kit    = Split-Path $PSScriptRoot -Parent
$backup = Join-Path $env:USERPROFILE (".tadashi-backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$utf8   = New-Object System.Text.UTF8Encoding $false

function Backup([string]$path) {
  if (Test-Path $path) {
    $dest = Join-Path $backup ($path -replace '^[A-Za-z]:\\', '')
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item $path $dest -Recurse -Force
  }
}

function Place([string]$src, [string]$dst) {
  if ((Test-Path $dst) -and (Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
    Write-Host ("  ok     {0}" -f $dst); return
  }
  Backup $dst
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item $src $dst -Force
  Write-Host ("  set    {0}" -f $dst)
}

Write-Host "`n[1/7] Claude: standing orders and skills"
$claude = Join-Path $env:USERPROFILE '.claude'
Place (Join-Path $kit 'claude\CLAUDE.md') (Join-Path $claude 'CLAUDE.md')
Get-ChildItem (Join-Path $kit 'claude\skills') -Directory | ForEach-Object {
  robocopy $_.FullName (Join-Path $claude "skills\$($_.Name)") /MIR /NJH /NJS /NFL /NDL /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed for skill $($_.Name)" }
  Write-Host ("  set    skill {0}" -f $_.Name)
}

Write-Host "`n[2/7] folio Typst package"
python (Join-Path $claude 'skills\folio\scripts\folio.py') setup | ForEach-Object { "  $_" }

Write-Host "`n[3/7] Prompt and PowerShell profile"
Place (Join-Path $kit 'config\starship.toml') (Join-Path $env:USERPROFILE '.config\starship.toml')
$block = "# >>> tadashi >>>`r`n" + (Get-Content (Join-Path $kit 'config\profile.ps1') -Raw).TrimEnd() + "`r`n# <<< tadashi <<<"
$docs  = [Environment]::GetFolderPath('MyDocuments')
foreach ($p in @("$docs\WindowsPowerShell\profile.ps1", "$docs\PowerShell\profile.ps1")) {
  $old = if (Test-Path $p) { Get-Content $p -Raw } else { '' }
  if ($old -match '(?s)# >>> tadashi >>>.*?# <<< tadashi <<<') {
    $new = [regex]::Replace($old, '(?s)# >>> tadashi >>>.*?# <<< tadashi <<<', { param($m) $block })
  } else {
    $new = $old.TrimEnd() + $(if ($old.Trim()) { "`r`n`r`n" } else { '' }) + $block + "`r`n"
  }
  if ($new -ne $old) {
    Backup $p
    New-Item -ItemType Directory -Force (Split-Path $p) | Out-Null
    [IO.File]::WriteAllText($p, $new, $utf8)
    Write-Host ("  set    {0}" -f $p)
  } else { Write-Host ("  ok     {0}" -f $p) }
}

Write-Host "`n[4/7] JetBrainsMono Nerd Font (per-user, no elevation)"
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$reg     = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$weights = 'Regular', 'Italic', 'Medium', 'MediumItalic', 'Bold', 'BoldItalic'
if (Test-Path (Join-Path $fontDir 'JetBrainsMonoNerdFont-Regular.ttf')) {
  Write-Host "  ok     JetBrainsMono Nerd Font"
} else {
  $tmp = Join-Path $env:TEMP ("tadashi-font-" + [guid]::NewGuid())
  New-Item -ItemType Directory -Force $tmp, $fontDir | Out-Null
  Invoke-WebRequest -UseBasicParsing 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz' -OutFile "$tmp\jbm.tar.xz"
  $files = $weights | ForEach-Object { "JetBrainsMonoNerdFont-$_.ttf" }
  & "$env:SystemRoot\System32\tar.exe" -xf "$tmp\jbm.tar.xz" -C $tmp @files
  Add-Type -Namespace Tadashi -Name Gdi -MemberDefinition '[DllImport("gdi32.dll", CharSet = CharSet.Unicode)] public static extern int AddFontResource(string file);'
  foreach ($w in $weights) {
    $f = "JetBrainsMonoNerdFont-$w.ttf"
    Copy-Item "$tmp\$f" (Join-Path $fontDir $f) -Force
    New-ItemProperty $reg -Name "JetBrainsMono Nerd Font $w (TrueType)" -Value (Join-Path $fontDir $f) -PropertyType String -Force | Out-Null
    [Tadashi.Gdi]::AddFontResource((Join-Path $fontDir $f)) | Out-Null
  }
  Remove-Item $tmp -Recurse -Force
  Write-Host "  set    JetBrainsMono Nerd Font"
}

Write-Host "`n[5/7] Windows Terminal theme"
$wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (Test-Path $wt) {
  Backup $wt
  $merge = @'
import json, sys
wt, theme = sys.argv[1], sys.argv[2]
try:
    settings = json.load(open(wt, encoding="utf-8-sig"))
except ValueError:
    sys.exit("  skip   settings.json has comments; merge config/terminal.json by hand")
t = json.load(open(theme, encoding="utf-8"))
schemes = [s for s in settings.get("schemes", []) if s.get("name") != t["scheme"]["name"]]
settings["schemes"] = schemes + [t["scheme"]]
settings.setdefault("profiles", {}).setdefault("defaults", {}).update(t["defaults"])
settings.update(t.get("root", {}))
json.dump(settings, open(wt, "w", encoding="utf-8"), indent=4, ensure_ascii=False)
print("  set    " + wt)
'@
  $merge | python - $wt (Join-Path $kit 'config\terminal.json')
} else { Write-Host "  skip   Windows Terminal not found" }

Write-Host "`n[6/7] Claude Code status line"
Place (Join-Path $kit 'claude\statusline.py') (Join-Path $claude 'statusline.py')
$cc = Join-Path $claude 'settings.json'
Backup $cc
$statusMerge = @'
import json, os, sys
path, script = sys.argv[1], sys.argv[2].replace(os.sep, "/")
settings = json.load(open(path, encoding="utf-8-sig")) if os.path.exists(path) else {}
settings["statusLine"] = {"type": "command", "command": "python -I " + script, "padding": 0}
settings["attribution"] = {"commit": "", "pr": "", "sessionUrl": False}
json.dump(settings, open(path, "w", encoding="utf-8"), indent=2)
print("  set    " + path)
'@
$statusMerge | python - $cc (Join-Path $claude 'statusline.py')

Write-Host "`n[7/7] Editor settings (VS Code family)"
$editorMerge = @'
import json, sys
path, wanted = sys.argv[1], sys.argv[2]
try:
    settings = json.load(open(path, encoding="utf-8-sig"))
except ValueError:
    sys.exit("  skip   " + path + " has comments; merge config/editor.json by hand")
settings.update(json.load(open(wanted, encoding="utf-8")))
json.dump(settings, open(path, "w", encoding="utf-8"), indent=4)
print("  set    " + path)
'@
foreach ($app in 'Antigravity IDE', 'Code', 'Cursor') {
  $user = Join-Path $env:APPDATA "$app\User"
  if (Test-Path $user) {
    $file = Join-Path $user 'settings.json'
    if (-not (Test-Path $file)) { [IO.File]::WriteAllText($file, '{}', $utf8) }
    Backup $file
    $editorMerge | python - $file (Join-Path $kit 'config\editor.json')
  }
}

Write-Host "`nDone. Backups (if any): $backup"
Write-Host "Open a new Windows Terminal window to see the prompt and theme."
