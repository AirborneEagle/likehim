"""
Generate the Like Him app icon family from a single procedural source.

Output:
  assets/icon/icon_master.png        — 1024x1024, full-bleed (rounded square baked in)
  assets/icon/icon_foreground.png    — 1024x1024, transparent background, foreground only
                                        (used by Android adaptive icons)
  assets/icon/icon_circle.png        — 1024x1024, with a circular crop (for in-app brand mark)
  web/favicon.png                    — 64x64, generated alongside

The mark itself: a 10-pointed gentle star in warm cream on deep midnight blue.
Ten points subtly echo the ten Christlike attributes; the star is a quiet
reference to the morning-star imagery without being denominationally narrow.

Run:  python tools/make_icon.py
"""

from __future__ import annotations

import math
import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


REPO = Path(__file__).resolve().parent.parent
ASSETS = REPO / "assets" / "icon"
ASSETS.mkdir(parents=True, exist_ok=True)


# Like Him palette — keyed to lib/theme/theme.dart
NAVY_DEEP = (27, 42, 64)        # midnight blue
NAVY_RIM = (16, 26, 42)         # darker rim for vignette
CREAM = (250, 240, 220)         # warm parchment
CREAM_GLOW = (255, 248, 230)    # subtle highlight
GOLD = (201, 166, 107)          # warm accent (theme tertiary)


def ten_pointed_star(cx: float, cy: float, outer_r: float, inner_r: float):
    """Return 20 vertices of a 10-pointed star (alternating outer/inner)."""
    pts = []
    for i in range(20):
        angle = i * math.pi / 10 - math.pi / 2
        r = outer_r if i % 2 == 0 else inner_r
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    return pts


def smooth_rosette(
    cx: float,
    cy: float,
    base_r: float,
    petal_amp: float,
    n_petals: int = 10,
    samples: int = 720,
):
    """
    Smooth N-petal rosette via the polar curve r(θ) = base_r + amp·cos(N·θ).
    Returns a dense polygon approximation — Pillow has no native bezier, so we
    sample finely and rely on antialiasing.
    """
    pts = []
    for i in range(samples):
        theta = i * 2 * math.pi / samples - math.pi / 2
        r = base_r + petal_amp * math.cos(n_petals * theta)
        pts.append((cx + r * math.cos(theta), cy + r * math.sin(theta)))
    return pts


def draw_star_mark(canvas_size: int, *, with_background: bool, rounded: bool) -> Image.Image:
    """
    Render the brand mark.

    Layers (bottom → top):
      1. Optional rounded-square background, with a soft radial vignette
      2. The 10-pointed cream star
      3. A small bright cream center dot
      4. A thin gold ring around the star (subtle, warm accent)
    """
    W = canvas_size
    if with_background:
        img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    else:
        img = Image.new("RGBA", (W, W), (0, 0, 0, 0))

    draw = ImageDraw.Draw(img, "RGBA")

    # 1. Background
    if with_background:
        # Soft radial vignette: deep navy in the center, slightly darker on the
        # edges. We achieve this by drawing concentric rounded rectangles with
        # decreasing alpha contribution.
        radius = int(W * 0.225) if rounded else 0  # iOS-ish corner radius
        if rounded:
            draw.rounded_rectangle(
                [(0, 0), (W - 1, W - 1)],
                radius=radius,
                fill=NAVY_DEEP + (255,),
            )
        else:
            draw.rectangle([(0, 0), (W - 1, W - 1)], fill=NAVY_DEEP + (255,))

        # Vignette: an inverse radial fade from rim color outward.
        vignette = Image.new("RGBA", (W, W), (0, 0, 0, 0))
        vd = ImageDraw.Draw(vignette, "RGBA")
        n_steps = 22
        for s in range(n_steps):
            t = s / n_steps  # 0 .. 1
            # alpha highest at the corners, zero at center
            alpha = int(64 * (t ** 1.6))
            shrink = int(W * 0.5 * (1 - t))
            x0, y0 = shrink, shrink
            x1, y1 = W - 1 - shrink, W - 1 - shrink
            if x1 <= x0 or y1 <= y0:
                continue
            box = [(x0, y0), (x1, y1)]
            if rounded:
                # Match the corner radius proportionally.
                r = max(0, radius - shrink // 2)
                vd.rounded_rectangle(
                    box, radius=r, outline=NAVY_RIM + (alpha,), width=2
                )
            else:
                vd.rectangle(box, outline=NAVY_RIM + (alpha,), width=2)
        # Blur the vignette so it's a smooth gradient.
        vignette = vignette.filter(ImageFilter.GaussianBlur(radius=W * 0.04))
        img = Image.alpha_composite(img, vignette)
        draw = ImageDraw.Draw(img, "RGBA")

    # 2. The 10-petal rosette
    cx, cy = W / 2, W / 2

    # Smooth polar curve r(θ) = base_r + amp·cos(10θ): true rounded petals,
    # no cog-teeth. Petal "depth" is 2·amp.
    base_r = W * 0.31
    petal_amp = W * 0.038
    star_pts = smooth_rosette(cx, cy, base_r, petal_amp, n_petals=10)
    outer_r = base_r + petal_amp  # used by the highlight + shadow

    # Subtle shadow under the rosette for tactile feel
    shadow = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow, "RGBA")
    sd.polygon(
        [(p[0], p[1] + W * 0.015) for p in star_pts],
        fill=(0, 0, 0, 90),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=W * 0.018))
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img, "RGBA")

    # The rosette itself, drawn in cream
    rosette = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rosette, "RGBA")
    rd.polygon(star_pts, fill=CREAM + (255,))

    # Soft inner highlight: a subtle radial gradient on the rosette so it
    # doesn't read as flat. We achieve this by overlaying a faint highlight
    # disc near the upper-left of the rosette.
    hl = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hl, "RGBA")
    hl_r = outer_r * 0.55
    hl_cx = cx - outer_r * 0.18
    hl_cy = cy - outer_r * 0.22
    hd.ellipse(
        [
            (hl_cx - hl_r, hl_cy - hl_r),
            (hl_cx + hl_r, hl_cy + hl_r),
        ],
        fill=CREAM_GLOW + (90,),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(radius=W * 0.06))
    rosette = Image.alpha_composite(rosette, hl)

    # Mask the highlight so it never spills outside the petals.
    mask = Image.new("L", (W, W), 0)
    md = ImageDraw.Draw(mask)
    md.polygon(star_pts, fill=255)
    masked = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    masked.paste(rosette, (0, 0), mask)
    img = Image.alpha_composite(img, masked)
    draw = ImageDraw.Draw(img, "RGBA")

    # No ornament in the center — the rosette silhouette is the whole mark.

    return img


def crop_to_circle(src: Image.Image) -> Image.Image:
    """Crop an image to a circular alpha mask."""
    W, H = src.size
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse([(0, 0), (W - 1, H - 1)], fill=255)
    out = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    out.paste(src, (0, 0), mask)
    return out


def feature_graphic(width: int = 1024, height: int = 500) -> Image.Image:
    """
    Play Store feature graphic — 1024×500. Rosette on the left, wordmark
    + tagline on the right, deep midnight background with a soft vignette.
    """
    img = Image.new("RGB", (width, height), NAVY_DEEP)
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    # Soft vignette
    vd = ImageDraw.Draw(overlay, "RGBA")
    for s in range(18):
        t = s / 18
        alpha = int(64 * (t ** 1.6))
        shrink_x = int(width * 0.5 * (1 - t))
        shrink_y = int(height * 0.5 * (1 - t))
        x0, y0 = shrink_x, shrink_y
        x1, y1 = width - 1 - shrink_x, height - 1 - shrink_y
        if x1 <= x0 or y1 <= y0:
            continue
        vd.rectangle(
            [(x0, y0), (x1, y1)],
            outline=NAVY_RIM + (alpha,),
            width=2,
        )
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=24))
    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(img, "RGBA")

    # Rosette on the left, vertically centered. Reuse the same mark.
    mark_size = int(height * 0.74)
    mark = draw_star_mark(mark_size, with_background=False, rounded=False)
    mark_x = int(height * 0.18)
    mark_y = (height - mark_size) // 2
    img.paste(mark, (mark_x, mark_y), mark)

    # Wordmark + tagline on the right.
    # Pillow's default font is small; we draw a stylized wordmark using
    # large text with the system's serif fallback. (Best effort without
    # bundling a font file.)
    try:
        from PIL import ImageFont
        font_dir = "C:/Windows/Fonts"
        title_font = None
        for candidate in [
            f"{font_dir}/georgia.ttf",
            f"{font_dir}/cambria.ttc",
            f"{font_dir}/times.ttf",
            f"{font_dir}/segoeui.ttf",
        ]:
            if os.path.exists(candidate):
                try:
                    title_font = ImageFont.truetype(candidate, 110)
                    body_font = ImageFont.truetype(candidate, 30)
                    break
                except OSError:
                    continue
        if title_font is None:
            title_font = ImageFont.load_default()
            body_font = title_font
    except Exception:
        title_font = ImageFont.load_default()
        body_font = title_font

    text_x = mark_x + mark_size + int(width * 0.04)
    text_y_title = int(height * 0.34)
    text_y_body = int(height * 0.56)

    draw.text(
        (text_x, text_y_title),
        "Like Him",
        font=title_font,
        fill=CREAM + (255,),
    )
    draw.text(
        (text_x, text_y_body),
        "a quiet companion",
        font=body_font,
        fill=GOLD + (255,),
    )
    draw.text(
        (text_x, text_y_body + 40),
        "for becoming",
        font=body_font,
        fill=GOLD + (255,),
    )
    return img


def main() -> int:
    W = 1024

    # Master: rounded-square background + star (used by flutter_launcher_icons
    # for iOS/Android legacy/web)
    master = draw_star_mark(W, with_background=True, rounded=True)
    master.save(ASSETS / "icon_master.png")

    # Play Store feature graphic — 1024x500
    fg_graphic = feature_graphic(1024, 500)
    fg_graphic.save(ASSETS / "play_feature_graphic_1024x500.png")

    # Foreground only — Android adaptive icon foreground layer. Google
    # guidance: keep critical content within the inner 66% of the canvas so
    # circular/rounded launcher masks don't crop it. We render the mark at
    # full size, then paste it centered into a 1.5× canvas so the rosette
    # ends up at ~66% of the foreground PNG.
    inner = draw_star_mark(W, with_background=False, rounded=False)
    fg_size = int(W * 1.5)
    fg = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
    offset = (fg_size - W) // 2
    fg.paste(inner, (offset, offset), inner)
    fg = fg.resize((W, W), Image.LANCZOS)
    fg.save(ASSETS / "icon_foreground.png")

    # Circle-cropped variant for the in-app brand mark on the auth screen.
    circle = crop_to_circle(master)
    circle.save(ASSETS / "icon_circle.png")

    # Web favicon
    favicon = master.resize((64, 64), Image.LANCZOS)
    favicon.save(REPO / "web" / "favicon.png")

    print("[ok] wrote", ASSETS / "icon_master.png")
    print("[ok] wrote", ASSETS / "icon_foreground.png")
    print("[ok] wrote", ASSETS / "icon_circle.png")
    print("[ok] wrote", ASSETS / "play_feature_graphic_1024x500.png")
    print("[ok] wrote", REPO / "web" / "favicon.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
