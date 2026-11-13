# give every folder under a root the sky folder icon via desktop.ini; no admin needed
param([string]$Root = [Environment]::GetFolderPath('Desktop'),
      [string]$Icon = "$HOME\.icons\folder-sky.ico")
foreach ($dir in Get-ChildItem $Root -Directory -Force | Where-Object { -not $_.Name.StartsWith('.') }) {
  $ini = Join-Path $dir.FullName 'desktop.ini'
  $lines = if (Test-Path $ini) { (Get-Content $ini -Force) | Where-Object { $_ -notmatch '^(IconResource|IconFile|IconIndex)=' } } else { @() }
  if (-not ($lines -match '^\[\.ShellClassInfo\]')) { $lines = @('[.ShellClassInfo]') + $lines }
  $out = foreach ($l in $lines) { $l; if ($l -match '^\[\.ShellClassInfo\]') { "IconResource=$Icon,0" } }
  if (Test-Path $ini) { attrib -h -s $ini }
  Set-Content $ini $out -Encoding Unicode
  attrib +h +s $ini
  attrib +r $dir.FullName
  "  sky  $($dir.Name)"
}
ie4uinit.exe -show
