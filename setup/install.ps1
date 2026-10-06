<#
  Tadashi / install
  The CLI arsenal and Claude Code. Idempotent: re-run any time, on any machine.
  Usage:  powershell -ExecutionPolicy Bypass -File setup\install.ps1
#>
$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

function Have([string]$cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
              "$env:LOCALAPPDATA\Microsoft\WinGet\Links;$env:USERPROFILE\.local\bin;$env:APPDATA\npm"
}

function Get-Pkg([string]$id, [string]$cmd) {
  if ($cmd -and (Have $cmd)) { Write-Host ("  ok     {0}" -f $id); return }
  Write-Host ("  get    {0}" -f $id)
  winget install --id $id -e --silent --disable-interactivity `
    --accept-source-agreements --accept-package-agreements | Out-Null
  $code = $LASTEXITCODE
  # 0x8A15002B = already installed, nothing to upgrade
  if ($code -eq 0 -or $code -eq -1978335189) { Write-Host ("  done   {0}" -f $id) }
  else { Write-Host ("  FAIL   {0}  (exit {1})" -f $id, $code) }
}

# uv tools and claude live in ~/.local/bin; make sure new shells see it
$localBin = Join-Path $env:USERPROFILE '.local\bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $localBin) {
  [Environment]::SetEnvironmentVariable('Path', $userPath.TrimEnd(';') + ';' + $localBin, 'User')
}
Refresh-Path

Write-Host "`n[1/4] Search, read, navigate"
Get-Pkg 'BurntSushi.ripgrep.MSVC'   'rg'
Get-Pkg 'sharkdp.fd'                'fd'
Get-Pkg 'junegunn.fzf'              'fzf'
Get-Pkg 'sharkdp.bat'               'bat'
Get-Pkg 'eza-community.eza'         'eza'
Get-Pkg 'ajeetdsouza.zoxide'        'zoxide'
Get-Pkg 'jqlang.jq'                 'jq'
Get-Pkg 'MikeFarah.yq'              'yq'
Get-Pkg 'chmln.sd'                  'sd'
Get-Pkg 'bootandy.dust'             'dust'
Get-Pkg 'charmbracelet.glow'        'glow'

Write-Host "`n[2/4] Build, measure, ship"
Get-Pkg 'Casey.Just'                'just'
Get-Pkg 'sharkdp.hyperfine'         'hyperfine'
Get-Pkg 'XAMPPRocky.Tokei'          'tokei'
Get-Pkg 'dandavison.delta'          'delta'
Get-Pkg 'JesseDuffield.lazygit'     'lazygit'
Get-Pkg 'GitHub.cli'                'gh'
Get-Pkg 'Gitleaks.Gitleaks'         'gitleaks'
Get-Pkg 'aristocratos.btop4win'     'btop4win'
Get-Pkg 'Starship.Starship'         'starship'
Get-Pkg 'astral-sh.uv'              'uv'
Get-Pkg 'Oven-sh.Bun'               'bun'
Get-Pkg 'BiomeJS.Biome'             'biome'

Write-Host "`n[3/4] Documents"
Get-Pkg 'Typst.Typst'               'typst'
Get-Pkg 'JohnMacFarlane.Pandoc'     'pandoc'
Get-Pkg 'oschwartz10612.Poppler'    'pdftoppm'

Write-Host "`n[+] Privacy (free, open source, independently audited)"
Get-Pkg 'Bitwarden.CLI'             'bw'
Get-Pkg 'Microsoft.Sysinternals.Suite' 'autoruns'
$bitwarden = Join-Path $env:LOCALAPPDATA 'Programs\Bitwarden\Bitwarden.exe'
if (Test-Path $bitwarden) { Write-Host '  ok     Bitwarden.Bitwarden' } else { Get-Pkg 'Bitwarden.Bitwarden' '' }
$mullvad = Join-Path $env:LOCALAPPDATA 'Mullvad\MullvadBrowser\Release\mullvadbrowser.exe'
if (Test-Path $mullvad) { Write-Host '  ok     MullvadVPN.MullvadBrowser' } else { Get-Pkg 'MullvadVPN.MullvadBrowser' '' }

Write-Host "`n[4/4] Runtimes (per-user, no elevation)"
Get-Pkg 'Schniz.fnm'                'fnm'
Refresh-Path
if (-not (Have 'pwsh')) {
  Write-Host "  get    PowerShell 7 (Microsoft Store build)"
  winget install --id 9MZ1SNWT0N5D --source msstore --silent --disable-interactivity `
    --accept-source-agreements --accept-package-agreements | Out-Null
} else { Write-Host "  ok     pwsh" }

# node comes from fnm, never a system-wide msi
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
if (-not (Have 'node')) { fnm install --lts | Out-Null; fnm default lts-latest | Out-Null }
Write-Host ("  ok     node {0} (fnm)" -f (node --version))

Write-Host "`n[+] Python-side tools (isolated via uv)"
foreach ($t in @(
  @{ pkg = 'ruff';          cmd = 'ruff'     },
  @{ pkg = 'ast-grep-cli';  cmd = 'ast-grep' }
)) {
  if (Have $t.cmd) { Write-Host ("  ok     {0}" -f $t.pkg) }
  else { Write-Host ("  get    {0}" -f $t.pkg); uv tool install --quiet $t.pkg 2>&1 | Out-Null }
}

Write-Host "`n[+] Web verification: lighthouse, svgo, font subsetting, playwright"
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
if (-not (Have 'lighthouse')) { npm install -g --silent lighthouse svgo 2>&1 | Out-Null }
if (-not (Have 'pyftsubset')) { uv tool install --quiet fonttools --with brotli 2>&1 | Out-Null }
python -c "import playwright" 2>$null
if ($LASTEXITCODE -ne 0) {
  python -m pip install --user --quiet --disable-pip-version-check playwright 2>&1 | Out-Null
  python -m playwright install chromium 2>&1 | Out-Null
}
Write-Host "  ok     lighthouse, svgo, pyftsubset, playwright"

# one agent only. no codex, gemini cli or aider
Write-Host "`n[+] Agent"
if (-not (Have 'claude')) {
  Write-Host "  get    claude (native installer)"
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
} else { Write-Host "  ok     claude" }

Write-Host "`nDone. Open a new terminal so PATH changes apply."
