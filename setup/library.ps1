<#
  Tadashi / library
  Mirrors the best public Claude skill repos into ~/.claude/skill-library (not auto-loaded).
  Usage:  powershell -ExecutionPolicy Bypass -File setup\library.ps1
#>
$ErrorActionPreference = 'Continue'

$repos = @(
  'anthropics/skills',                    # official Anthropic skills
  'obra/superpowers',                     # dev methodology: TDD, debugging, planning, verification
  'addyosmani/agent-skills',              # production engineering lifecycle
  'mattpocock/skills',                    # engineering workflows: tdd, diagnosis, design, specs
  'anthropics/claude-plugins-official',   # official plugin directory: MCP dev, plugin dev
  'trailofbits/skills',                   # security research and audit workflows
  'getsentry/skills',                     # Sentry eng team: review, bug finding, PR hygiene
  'vercel-labs/agent-skills',             # React / Next.js performance and web design rules
  'cloudflare/security-audit-skill',      # multi-phase, verified security audit
  'garrytan/gstack'                       # plan / review / QA / ship workflow
)

$lib  = Join-Path $env:USERPROFILE '.claude\skill-library'
# untrusted data: no hooks, no submodules, no lfs, no credential prompts
$safe = @('-c', 'core.hooksPath=/dev/null', '-c', 'core.longpaths=true', '-c', 'advice.diverging=false')
$env:GIT_LFS_SKIP_SMUDGE = '1'
$env:GIT_TERMINAL_PROMPT = '0'
New-Item -ItemType Directory -Force $lib | Out-Null

Write-Host "`n[1/2] Sync $($repos.Count) repos into $lib"
foreach ($r in $repos) {
  $dir = Join-Path $lib ($r -replace '/', '__')
  if (-not (Test-Path (Join-Path $dir '.git'))) {
    git @safe clone -q --depth 1 --no-recurse-submodules -c core.hooksPath=/dev/null "https://github.com/$r.git" $dir
    if ($LASTEXITCODE -eq 0) { Write-Host ("  new    {0}" -f $r) } else { Write-Host ("  FAIL   {0}  (clone exit {1})" -f $r, $LASTEXITCODE) }
    continue
  }
  $before = git -C $dir rev-parse --short HEAD
  git @safe -C $dir pull -q --ff-only --depth 1 2>$null
  if ($LASTEXITCODE -ne 0) {
    # shallow clones can't fast-forward once upstream moves. mirrors are read-only, so just jump
    git @safe -C $dir fetch -q --depth 1 origin
    if ($LASTEXITCODE -ne 0) { Write-Host ("  FAIL   {0}  (fetch exit {1})" -f $r, $LASTEXITCODE); continue }
    git @safe -C $dir reset -q --hard '@{u}'
  }
  $after = git -C $dir rev-parse --short HEAD
  if ($before -eq $after) { Write-Host ("  ok     {0}" -f $r) } else { Write-Host ("  pull   {0}  {1}..{2}" -f $r, $before, $after) }
}

# name and description from yaml frontmatter, good enough for how skills write it
function Get-Front([string]$file) {
  $meta  = @{ name = ''; description = '' }
  $lines = [IO.File]::ReadAllLines($file)
  if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') { return $meta }
  $key = $null
  for ($i = 1; $i -lt $lines.Count; $i++) {
    $l = $lines[$i]
    if ($l.Trim() -eq '---') { break }
    if ($l -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
      $key = $Matches[1]
      if ($meta.ContainsKey($key)) { $meta[$key] = $Matches[2].Trim() } else { $key = $null }
    } elseif ($key -and $l -match '^\s+\S') {
      $meta[$key] = $meta[$key] + ' ' + $l.Trim()
    }
  }
  foreach ($k in @('name', 'description')) {
    $v = ($meta[$k] -replace '^[>|][-+]?\s*', '').Trim()
    if ($v.Length -ge 2 -and $v[0] -eq '"' -and $v[-1] -eq '"') { $v = $v.Substring(1, $v.Length - 2) -replace '\\"', '"' }
    if ($v.Length -ge 2 -and $v[0] -eq "'" -and $v[-1] -eq "'") { $v = $v.Substring(1, $v.Length - 2) -replace "''", "'" }
    $meta[$k] = $v
  }
  return $meta
}

function Shorten([string]$text, [int]$words = 20) {
  $w = @($text -split '\s+' | Where-Object { $_ })
  $s = ($w | Select-Object -First $words) -join ' '
  if ($w.Count -gt $words) { $s = $s.TrimEnd('.', ',', ';', ':') + ' ...' }
  return ($s -replace '\|', '\|' -replace '<', '&lt;' -replace '>', '&gt;')
}

Write-Host "`n[2/2] Regenerate INDEX.md"
$useFd = [bool](Get-Command fd -ErrorAction SilentlyContinue)
$body  = New-Object System.Collections.Generic.List[string]
$toc   = New-Object System.Collections.Generic.List[string]
$total = 0
foreach ($r in $repos) {
  $slug = $r -replace '/', '__'
  $dir  = Join-Path $lib $slug
  if (-not (Test-Path $dir)) { continue }
  if ($useFd) {
    $found = @(fd -H -I -t f -E .git -g SKILL.md --path-separator / --base-directory $dir)
  } else {
    $found = @(Get-ChildItem -LiteralPath $dir -Recurse -Force -File -Filter SKILL.md |
      Where-Object { $_.FullName -notmatch '\\\.git\\' } |
      ForEach-Object { $_.FullName.Substring($dir.Length + 1) -replace '\\', '/' })
  }
  $found = @($found | Sort-Object)
  $total += $found.Count
  $toc.Add(("- [{0}](#{1}) - {2} skills" -f $r, ($r -replace '[^A-Za-z0-9 _-]', '').ToLower(), $found.Count))
  $body.Add(''); $body.Add("## $r"); $body.Add('')
  $body.Add('| Skill | Description | Path |'); $body.Add('|---|---|---|')
  foreach ($rel in $found) {
    $m    = Get-Front (Join-Path $dir $rel)
    $name = $m.name
    if (-not $name) { $name = Split-Path (Split-Path $rel -Parent) -Leaf }
    $link = ("$slug/$rel" -replace ' ', '%20')
    $body.Add(("| {0} | {1} | [{2}]({3}) |" -f (Shorten $name 8), (Shorten $m.description), $rel, $link))
  }
}

$head = @(
  '# Skill library index', '',
  ("{0} skills across {1} repos. Generated {2} by library.ps1." -f $total, $repos.Count, (Get-Date -Format 'yyyy-MM-dd HH:mm')),
  'Mirrors only: nothing here is auto-loaded. Copy a skill folder into ~/.claude/skills to activate it.', ''
)
$text = (($head + $toc + $body) -join "`n") + "`n"
[IO.File]::WriteAllText((Join-Path $lib 'INDEX.md'), $text, (New-Object System.Text.UTF8Encoding $false))
Write-Host ("  wrote  {0}  ({1} skills)" -f (Join-Path $lib 'INDEX.md'), $total)
Write-Host "`nDone."
