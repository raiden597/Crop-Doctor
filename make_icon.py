from PIL import Image, ImageDraw, ImageFilter
import math

SIZE = 1024

def make_icon():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))

    # --- Background ---
    bg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bg)
    bd.rounded_rectangle([0, 0, SIZE, SIZE], radius=220, fill=(20, 55, 38))
    img = Image.alpha_composite(img, bg)

    # --- Radial glow in upper-center ---
    glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([180, 60, 840, 680], fill=(64, 145, 108, 70))
    glow = glow.filter(ImageFilter.GaussianBlur(110))
    img = Image.alpha_composite(img, glow)

    # --- Leaf shape ---
    def leaf_points(cx, cy, w, h, n=200):
        pts = []
        for i in range(n):
            t = 2 * math.pi * i / n
            # Basic ellipse
            x = cx + (w / 2) * math.sin(t)
            y = cy - (h / 2) * math.cos(t)
            # Pinch sides to make it a pointed oval leaf
            squeeze = 1 - 0.35 * (math.sin(t) ** 2)
            x = cx + (x - cx) * squeeze
            pts.append((int(x), int(y)))
        return pts

    leaf_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    ld = ImageDraw.Draw(leaf_layer)

    # Main leaf body
    main_pts = leaf_points(490, 430, 360, 560)
    ld.polygon(main_pts, fill=(82, 183, 136, 235))

    # Highlight on left — lighter inner zone
    hi_pts = leaf_points(460, 390, 180, 340)
    ld.polygon(hi_pts, fill=(183, 228, 199, 90))

    img = Image.alpha_composite(img, leaf_layer)
    draw = ImageDraw.Draw(img)

    # --- Leaf veins ---
    vc = (210, 240, 220, 130)
    # Center vein
    draw.line([(494, 160), (478, 700)], fill=vc, width=9)
    # Side veins (left & right pairs)
    for i, by in enumerate([280, 370, 460, 540]):
        bx = 492 - i * 4
        draw.line([(bx, by), (bx - 90, by + 50)], fill=vc, width=6)
        draw.line([(bx, by), (bx + 90, by + 50)], fill=vc, width=6)

    # --- Stem ---
    draw.line([(480, 700), (462, 820)], fill=(82, 183, 136, 210), width=22)

    # Small soil mound under stem
    draw.ellipse([400, 810, 530, 855], fill=(45, 90, 60, 160))

    # --- Medical cross badge (bottom-right) ---
    bcx, bcy, br = 715, 715, 148

    # Drop shadow
    shadow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([bcx - br + 12, bcy - br + 12, bcx + br + 12, bcy + br + 12],
               fill=(0, 0, 0, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img)

    # Badge dark ring
    draw.ellipse([bcx - br, bcy - br, bcx + br, bcy + br], fill=(14, 40, 26))

    # Red circle
    ir = 128
    draw.ellipse([bcx - ir, bcy - ir, bcx + ir, bcy + ir], fill=(240, 90, 90))

    # White cross arms
    aw, ah = 48, 136
    draw.rounded_rectangle(
        [bcx - aw // 2, bcy - ah // 2, bcx + aw // 2, bcy + ah // 2],
        radius=10, fill='white')
    draw.rounded_rectangle(
        [bcx - ah // 2, bcy - aw // 2, bcx + ah // 2, bcy + aw // 2],
        radius=10, fill='white')

    # --- Decorative sparkle dots (AI feel) ---
    sparkles = [(165, 195, 14), (835, 172, 10), (148, 670, 8),
                (875, 610, 11), (210, 840, 7), (800, 840, 9)]
    for sx, sy, sr in sparkles:
        draw.ellipse([sx - sr, sy - sr, sx + sr, sy + sr],
                     fill=(183, 228, 199, 140))

    # --- Save ---
    out = img.convert('RGBA')
    out.save('assets/images/app_icon.png', 'PNG')
    print(f"Saved: assets/images/app_icon.png  ({SIZE}x{SIZE})")

make_icon()
