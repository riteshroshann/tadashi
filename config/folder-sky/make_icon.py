"""draw sky blue folder and zip icons in the windows 11 shape, all sizes in one .ico each."""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

BACK = (14, 132, 190, 255)   # tab and back sheet, darker sky
FRONT = (56, 189, 248, 255)  # front sheet, #38bdf8
LIP = (125, 211, 252, 255)   # top edge highlight on the front sheet
ZIP = (12, 74, 110, 255)     # zipper teeth, deep sky
S = 1024                     # draw large, downsample for clean edges
SIZES = [16, 20, 24, 32, 40, 48, 64, 96, 128, 256]


def folder() -> Image.Image:
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    r = 70
    # back sheet with the tab on the left
    d.rounded_rectangle((64, 150, 420, 330), r, fill=BACK)
    d.polygon([(380, 150), (470, 240), (470, 330), (380, 330)], fill=BACK)
    d.rounded_rectangle((64, 230, 960, 860), r, fill=BACK)
    # front sheet, slightly lower, with a light lip
    d.rounded_rectangle((64, 330, 960, 880), r, fill=LIP)
    d.rounded_rectangle((64, 346, 960, 880), r, fill=FRONT)
    return im


def zipped() -> Image.Image:
    im = folder()
    d = ImageDraw.Draw(im)
    x = 600  # zipper runs down the front sheet, right of centre
    for i, y in enumerate(range(346, 760, 46)):
        dx = 0 if i % 2 == 0 else 40
        d.rectangle((x + dx - 40, y, x + dx, y + 30), fill=ZIP)
    d.rounded_rectangle((x - 60, 740, x + 60, 860), 24, fill=ZIP)  # pull tab
    return im


def save(im: Image.Image, out: Path) -> None:
    im.resize((256, 256), Image.LANCZOS).save(out, sizes=[(s, s) for s in SIZES])
    print(out)


if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".icons"
    out.mkdir(parents=True, exist_ok=True)
    save(folder(), out / "folder-sky.ico")
    save(zipped(), out / "zip-sky.ico")
