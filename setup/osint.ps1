<#
  Tadashi / osint
  Open-source intelligence tooling, kept isolated: Python tools in their own uv environments,
  Go binaries from official releases with checksums verified, SpiderFoot in a local container.
  Idempotent. Usage:  powershell -ExecutionPolicy Bypass -File setup\osint.ps1
#>
$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'
$bin = Join-Path $env:USERPROFILE '.local\bin'
New-Item -ItemType Directory -Force $bin | Out-Null

function Have([string]$cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path', 'User') + ";$bin"
}

function Get-UvTool([string]$pkg, [string]$cmd, [string[]]$extra = @()) {
  if (Have $cmd) { Write-Host ("  ok     {0}" -f $pkg); return }
  Write-Host ("  get    {0}" -f $pkg)
  uv tool install --quiet @extra $pkg 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { Write-Host ("  FAIL   {0}" -f $pkg) }
}

function Get-Pkg([string]$id, [string]$cmd) {
  if (Have $cmd) { Write-Host ("  ok     {0}" -f $id); return }
  Write-Host ("  get    {0}" -f $id)
  winget install --id $id -e --silent --disable-interactivity `
    --accept-source-agreements --accept-package-agreements | Out-Null
  if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { Write-Host ("  FAIL   {0}" -f $id) }
}

# gh when signed in, since anonymous api calls get rate limited
function Get-LatestRelease([string]$repo) {
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    $json = gh api "repos/$repo/releases/latest" 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $json) { return $json | ConvertFrom-Json }
  }
  Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
}
# latest windows build from a release, installed only if its checksum matches
function Get-Release([string]$repo, [string]$exe, [string]$as = $exe) {
  if (Have $as) { Write-Host ("  ok     {0}" -f $repo); return }
  Write-Host ("  get    {0}" -f $repo)
  $rel   = Get-LatestRelease $repo
  $zip   = $rel.assets | Where-Object { $_.name -like '*windows_amd64.zip' } | Select-Object -First 1
  $sums  = $rel.assets | Where-Object { $_.name -like '*checksums.txt' } | Select-Object -First 1
  $tmp   = Join-Path $env:TEMP ("tadashi-" + [guid]::NewGuid())
  New-Item -ItemType Directory $tmp | Out-Null
  Invoke-WebRequest -UseBasicParsing $zip.browser_download_url -OutFile "$tmp\$($zip.name)"
  $expected = ((Invoke-RestMethod $sums.browser_download_url) -split "`n" |
    Where-Object { $_ -match [regex]::Escape($zip.name) }) -split '\s+' | Select-Object -First 1
  $actual = (Get-FileHash "$tmp\$($zip.name)" -Algorithm SHA256).Hash
  if (-not $expected -or $actual -ne $expected.ToUpper()) {
    Write-Host ("  FAIL   {0}  (checksum mismatch, not installed)" -f $repo)
  } else {
    Expand-Archive "$tmp\$($zip.name)" -DestinationPath $tmp -Force
    Copy-Item "$tmp\$exe.exe" (Join-Path $bin "$as.exe") -Force
    Write-Host ("  done   {0} {1}  (sha256 verified)" -f $repo, $rel.tag_name)
  }
  Remove-Item $tmp -Recurse -Force
}

Refresh-Path

Write-Host "`n[1/4] People and accounts"
Get-UvTool 'sherlock-project' 'sherlock'
Get-UvTool 'maigret'          'maigret'
Get-UvTool 'holehe'           'holehe'
Get-UvTool 'socialscan'       'socialscan'

Write-Host "`n[2/4] Domains and infrastructure"
Get-UvTool 'git+https://github.com/laramies/theHarvester' 'theHarvester' @('--python', '3.14')
Get-UvTool 'dnstwist' 'dnstwist'
Get-UvTool 'censys'   'censys'
Get-UvTool 'shodan'   'shodan'
Get-Pkg 'OWASP.Amass' 'amass'
Get-Release 'projectdiscovery/subfinder' 'subfinder'
Get-Release 'projectdiscovery/dnsx'      'dnsx'
# kali's name for it; python's httpx already owns httpx
Get-Release 'projectdiscovery/httpx'     'httpx' 'httpx-toolkit'

Write-Host "`n[3/4] Media and metadata"
Get-Pkg 'OliverBetz.ExifTool' 'exiftool'
Get-Pkg 'Gyan.FFmpeg'         'ffmpeg'
Get-UvTool 'yt-dlp'           'yt-dlp'
Get-UvTool 'gallery-dl'       'gallery-dl'

Write-Host "`n[4/4] SpiderFoot (local container, bound to 127.0.0.1)"
$imageReady = $false
if (Have 'docker') { docker image inspect spiderfoot *> $null; $imageReady = ($LASTEXITCODE -eq 0) }
if (-not (Have 'docker')) {
  Write-Host "  skip   Docker not found"
} elseif ($imageReady) {
  Write-Host "  ok     spiderfoot image"
} else {
  Write-Host "  build  spiderfoot from github.com/smicallef/spiderfoot (a few minutes)"
  docker build -q -t spiderfoot https://github.com/smicallef/spiderfoot.git 2>&1 | Out-Null
  if ($LASTEXITCODE -eq 0) { Write-Host "  done   spiderfoot image" } else { Write-Host "  FAIL   spiderfoot build" }
}

Write-Host "`nDone. Start SpiderFoot with 'spiderfoot' in a new terminal (http://127.0.0.1:5001)."
