# node via fnm, once per shell (the 5.1 profile may have beaten us to it)
if ((Get-Command fnm -ErrorAction SilentlyContinue) -and -not $env:FNM_MULTISHELL_PATH) {
  fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

# interactive shells only; scripts and agents get stock powershell
$tadashiArgs = [Environment]::GetCommandLineArgs()
$tadashiInteractive = [Environment]::UserInteractive -and -not ($tadashiArgs -match '^-noni') -and
  (($tadashiArgs -match '^-noe') -or -not ($tadashiArgs -match '^-(c|com|command|f|file|e|ec|encodedcommand)$'))

if ($tadashiInteractive) {
  if (Get-Command starship -ErrorAction SilentlyContinue) { Invoke-Expression (& starship init powershell) }
  if (Get-Command zoxide -ErrorAction SilentlyContinue) { Invoke-Expression (& { (zoxide init powershell | Out-String) }) }

  if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --group-directories-first --icons=auto @args }
    function ll { eza -la --group-directories-first --git --icons=auto @args }
    function lt { eza --tree --level=2 --group-directories-first --icons=auto @args }
  }
  if (Get-Command bat -ErrorAction SilentlyContinue) { function b { bat --style=plain @args } }
  if (Get-Command lazygit -ErrorAction SilentlyContinue) { Set-Alias lg lazygit }
  if (Get-Command docker -ErrorAction SilentlyContinue) {
    # spiderfoot in a container, bound to localhost
    function spiderfoot {
      docker start spiderfoot *> $null
      if ($LASTEXITCODE -ne 0) { docker run -d --name spiderfoot -p 127.0.0.1:5001:5001 spiderfoot | Out-Null }
      Start-Process 'http://127.0.0.1:5001'
    }
  }

  try {
    Set-PSReadLineOption -ErrorAction Stop -Colors @{
      Command = '#05d9e8'; Parameter = '#b967ff'; String = '#3df5a7'; Number = '#ffd166'
      Operator = '#ff2a6d'; Variable = '#d6dbe5'; Comment = '#4a4f63'
    }
  } catch { }
  # psreadline 2.1+ only; windows powershell ships 2.0
  try { Set-PSReadLineOption -ErrorAction Stop -Colors @{ InlinePrediction = '#4a4f63' } } catch { }
}
Remove-Variable tadashiArgs, tadashiInteractive
