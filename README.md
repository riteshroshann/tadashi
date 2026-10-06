<div align="center">

<img src="assets/baymax.svg" alt="Baymax holding a warm mug" width="560">

# tadashi

**Hello. I am Tadashi, your personal engineering companion.**

My whole computer in one folder. Two commands, and a fresh laptop becomes mine.

<img src="assets/vitals.svg" alt="scan complete: 60 tools in one pass, 15 skills on demand, privacy locked down, vibes immaculate" width="560">

</div>

## Activate

```powershell
winget install -e --id Git.Git; winget install -e --id GitHub.cli
gh auth login; gh repo clone riteshroshann/tadashi; cd tadashi
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
.\setup\install.ps1; .\setup\deploy.ps1
```

New terminal after the first line. Safe to rerun, always. Tweaked something? Run `.\setup\deploy.ps1` again. The full tour lives in [the manual](Tadashi.pdf).

<br>

<div align="center">

<img src="assets/armor.svg" alt="armor, optional upgrades: Library, 300 more skills (setup\library.ps1); Recon, public-source investigation (setup\osint.ps1); Stealth, tracking off and firewall up (setup\privacy.ps1); Ink, every kind of document (setup\documents.ps1)" width="560">

<br>

<sub><i>I will not deactivate until you are satisfied with your setup.</i></sub>

<a href="https://github.com/riteshroshann"><img src="assets/signature.svg" alt="Engineered by Ritesh Roshan" height="34"></a>

</div>
