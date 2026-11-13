"""pack the theme into a .vsix. no vsce needed: a vsix is a zip with two manifests."""
import json
import sys
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parent
pkg = json.loads((root / "package.json").read_text(encoding="utf-8"))
theme = root / "themes" / "glacier-oled.json"
json.loads(theme.read_text(encoding="utf-8"))  # fail loudly on a broken theme

manifest = f"""<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="{pkg['name']}" Version="{pkg['version']}" Publisher="{pkg['publisher']}"/>
    <DisplayName>{pkg['displayName']}</DisplayName>
    <Description xml:space="preserve">{pkg['description']}</Description>
    <Categories>Themes</Categories>
    <Properties><Property Id="Microsoft.VisualStudio.Code.Engine" Value="{pkg['engines']['vscode']}"/></Properties>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Dependencies/>
  <Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>"""
types = """<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension=".json" ContentType="application/json"/><Default Extension=".vsixmanifest" ContentType="text/xml"/></Types>"""

out = Path(sys.argv[1]) if len(sys.argv) > 1 else root / f"{pkg['name']}-{pkg['version']}.vsix"
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", types)
    z.writestr("extension.vsixmanifest", manifest)
    z.write(root / "package.json", "extension/package.json")
    z.write(theme, "extension/themes/glacier-oled.json")
print(out)
