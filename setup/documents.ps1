<#
  Tadashi / documents
  Everything the document skills need, so no session installs anything mid-task:
  LaTeX (Tectonic), LibreOffice, QPDF, Tesseract OCR, and the Python and Node libraries
  behind the pdf, docx, pptx and xlsx skills. Typst, Pandoc and Poppler come from install.ps1.
  Run once from an elevated PowerShell (LibreOffice and Tesseract install machine-wide). Idempotent.
  Usage:  powershell -ExecutionPolicy Bypass -File setup\documents.ps1
#>
$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'
$bin = Join-Path $env:USERPROFILE '.local\bin'
New-Item -ItemType Directory -Force $bin | Out-Null

function Have([string]$cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Add-UserPath([string]$dir) {
  if (-not $dir -or -not (Test-Path $dir)) { return }
  $p = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (($p -split ';') -notcontains $dir) { [Environment]::SetEnvironmentVariable('Path', $p.TrimEnd(';') + ';' + $dir, 'User') }
  if (($env:Path -split ';') -notcontains $dir) { $env:Path += ";$dir" }
}
function Get-Pkg([string]$id, [string]$probe) {
  if (Test-Path $probe) { Write-Host ("  ok     {0}" -f $id); return }
  Write-Host ("  get    {0}" -f $id)
  winget install --id $id -e --silent --disable-interactivity --accept-source-agreements --accept-package-agreements | Out-Null
  if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) { Write-Host ("  done   {0}" -f $id) }
  else { Write-Host ("  FAIL   {0} (exit {1})" -f $id, $LASTEXITCODE) }
}
# gh when signed in, since anonymous api calls get rate limited
function Get-LatestRelease([string]$repo) {
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    $json = gh api "repos/$repo/releases/latest" 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $json) { return $json | ConvertFrom-Json }
  }
  Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
}
function Check([string]$name, [scriptblock]$test) {
  $ok = $false
  try { $ok = [bool](& $test) } catch { $ok = $false }
  Write-Host ("  {0} {1}" -f $(if ($ok) { 'pass  ' } else { 'FAIL  ' }), $name)
}

$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ";$bin"
$work = Join-Path $env:TEMP ("tadashi-docs-" + [guid]::NewGuid())
New-Item -ItemType Directory $work | Out-Null

Write-Host "`n[1/5] LaTeX: Tectonic (fetches packages itself and never prompts)"
if (Have 'tectonic') { Write-Host "  ok     tectonic" } else {
  $rel   = Get-LatestRelease 'tectonic-typesetting/tectonic'
  $asset = $rel.assets | Where-Object { $_.name -like '*x86_64-pc-windows-msvc.zip' } | Select-Object -First 1
  $zip   = Join-Path $work $asset.name
  Invoke-WebRequest -UseBasicParsing $asset.browser_download_url -OutFile $zip
  $want = ($asset.digest -replace '^sha256:', '').ToUpper()
  if ($want -and (Get-FileHash $zip -Algorithm SHA256).Hash -eq $want) {
    Expand-Archive $zip -DestinationPath $work -Force
    Copy-Item (Join-Path $work 'tectonic.exe') (Join-Path $bin 'tectonic.exe') -Force
    Write-Host ("  done   tectonic {0} (sha256 verified)" -f $rel.tag_name)
  } else { Write-Host "  FAIL   tectonic (checksum missing or wrong, not installed)" }
}

Write-Host "`n[2/5] LibreOffice, QPDF, Tesseract OCR"
Get-Pkg 'TheDocumentFoundation.LibreOffice' 'C:\Program Files\LibreOffice\program\soffice.exe'
Add-UserPath 'C:\Program Files\LibreOffice\program'
Get-Pkg 'UB-Mannheim.TesseractOCR' 'C:\Program Files\Tesseract-OCR\tesseract.exe'
Add-UserPath 'C:\Program Files\Tesseract-OCR'
$qpdf = Get-ChildItem 'C:\Program Files\qpdf*\bin\qpdf.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $qpdf) {
  Get-Pkg 'QPDF.QPDF' 'C:\nonexistent'
  $qpdf = Get-ChildItem 'C:\Program Files\qpdf*\bin\qpdf.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
} else { Write-Host "  ok     QPDF.QPDF" }
if ($qpdf) { Add-UserPath $qpdf.DirectoryName }

Write-Host "`n[3/5] Python libraries for the pdf, docx, pptx and xlsx skills"
python -m pip install --user --quiet --disable-pip-version-check pypdf pdfplumber reportlab pytesseract pdf2image `
  python-docx python-pptx openpyxl pandas pillow pymupdf 'markitdown[docx,pptx,xlsx,pdf]' 2>&1 | Out-Null
Add-UserPath (Join-Path $env:APPDATA 'Python\Python312\Scripts')
Write-Host "  done   python libraries"

Write-Host "`n[4/5] Node libraries for the docx and pptx skills"
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
npm install -g --silent docx pptxgenjs react react-dom react-icons sharp 2>&1 | Out-Null
# fnm's default alias; npm root -g points at a per-shell link that vanishes
$fnmDir = if ($env:FNM_DIR) { $env:FNM_DIR } else { Join-Path $env:APPDATA 'fnm' }
$root = Join-Path $fnmDir 'aliases\default\node_modules'
[Environment]::SetEnvironmentVariable('NODE_PATH', $root, 'User')
$env:NODE_PATH = $root
Write-Host "  done   node libraries (NODE_PATH -> $root)"

Write-Host "`n[5/5] Prove every piece works"
$tex = Join-Path $work 'probe.tex'
Set-Content $tex -Encoding ascii -Value '\documentclass{article}\usepackage{amsmath,booktabs,graphicx,hyperref}\begin{document}Ready: $E = mc^2$\end{document}'
Check 'LaTeX: tectonic compiles a document (and caches its packages)' {
  tectonic -X compile $tex --outdir $work 2>&1 | Out-Null; Test-Path (Join-Path $work 'probe.pdf') }
Check 'Python: pdf, docx, pptx, xlsx and OCR libraries import' {
  python -c "import pypdf, pdfplumber, reportlab, pytesseract, pdf2image, docx, pptx, openpyxl, pandas, PIL, fitz, markitdown" 2>$null; $LASTEXITCODE -eq 0 }
Check 'LibreOffice: converts a Word file to PDF' {
  python -c "import docx, sys; d = docx.Document(); d.add_paragraph('probe'); d.save(sys.argv[1])" (Join-Path $work 'office.docx')
  soffice --headless --convert-to pdf --outdir $work (Join-Path $work 'office.docx') 2>&1 | Out-Null
  Test-Path (Join-Path $work 'office.pdf') }
Check 'QPDF: validates a PDF' { qpdf --check (Join-Path $work 'office.pdf') 2>&1 | Out-Null; $LASTEXITCODE -eq 0 }
Check 'Tesseract: OCR engine answers' { (tesseract --version 2>&1 | Out-String) -match 'tesseract' }
Check 'markitdown: reads a Word file' { (python -m markitdown (Join-Path $work 'office.docx') 2>$null | Out-String) -match 'probe' }
Check 'Node: docx and pptxgenjs load' { node -e "require('docx'); require('pptxgenjs')" 2>$null; $LASTEXITCODE -eq 0 }
Check 'Typst, Pandoc, Poppler present' { (Have 'typst') -and (Have 'pandoc') -and (Have 'pdftoppm') }

Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`nDone. Open a new terminal so PATH and NODE_PATH apply."
