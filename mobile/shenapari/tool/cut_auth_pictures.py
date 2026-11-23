"""Cut the sign-in illustrations out of their near-white page.

Sources: the original images in Figma (file WlnYntPxtDOEUhWhka1hH6, layers
425:750 «phone» and 425:755 «code»), 1448×1086 and 1581×995, flat RGB.
Needs numpy, scipy and Pillow. Writes PNG; the app ships them as WebP
(quality 92, lossless alpha):

    python tool/cut_auth_pictures.py phone_raw.png phone_auth.png phone_auth_dark.png 438,759
    python tool/cut_auth_pictures.py code_raw.png otp_code.png otp_code_dark.png 760,674

The trailing x,y are gaps of page colour shut in by the drawing (see holes).

The AI-made originals are flat RGB: a near-white page, a light beige blob and
the drawing on it. The page goes transparent with soft edges (no white fringe):
- page–blob edges unmix along the page→blob line (alpha = how much blob);
- drawing–page edges use colour-to-alpha against the page colour.
The dark variant repaints the blob dark and unmixes the drawing's edges from
the blob, so no light seam stays around hair and outlines.
"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

def c2a(rgb, ref):
    """GIMP colour-to-alpha: the most transparent fg that, over ref, gives rgb."""
    ref = np.asarray(ref, float)
    up = np.where(rgb > ref, (rgb - ref) / np.maximum(255 - ref, 1e-6), 0)
    down = np.where(rgb < ref, (ref - rgb) / np.maximum(ref, 1e-6), 0)
    alpha = np.clip(np.maximum(up, down).max(axis=-1), 0, 1)
    fg = (rgb - ref * (1 - alpha[..., None])) / np.maximum(alpha[..., None], 1e-6)
    return np.clip(fg, 0, 255), alpha

def line_mix(rgb, a_col, b_col):
    """Position t along a→b of rgb's projection, and its distance from the line."""
    a_col, b_col = np.asarray(a_col, float), np.asarray(b_col, float)
    v = b_col - a_col
    t = ((rgb - a_col) @ v) / (v @ v)
    resid = np.linalg.norm(rgb - (a_col + t[..., None] * v), axis=-1)
    return t, resid

def cut(src, page, blob, dark_blob, out_light, out_dark, holes=(), pad=12):
    rgb = np.asarray(Image.open(src).convert('RGB')).astype(float)
    page, blob = np.asarray(page, float), np.asarray(blob, float)
    near_page = np.abs(rgb - page).max(axis=-1) <= 4
    labels, _ = ndimage.label(near_page)
    edge_labels = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    outside = np.isin(labels, edge_labels[edge_labels > 0])
    band = ndimage.binary_dilation(outside, iterations=3) & ~outside

    alpha = np.where(outside, 0.0, 1.0)
    color = rgb.copy()
    t, resid = line_mix(rgb, page, blob)
    on_blob_line = band & (resid < 3.5)
    alpha[on_blob_line] = np.clip(t[on_blob_line], 0, 1)
    color[on_blob_line] = blob
    rest = band & ~on_blob_line
    fg, a2 = c2a(rgb[rest], page)
    alpha[rest], color[rest] = a2, fg

    def save(col, path):
        img = np.dstack([np.clip(col, 0, 255), alpha * 255]).round().astype(np.uint8)
        ys, xs = np.nonzero(alpha > 0.02)
        y0, y1 = max(ys.min() - pad, 0), min(ys.max() + pad + 1, img.shape[0])
        x0, x1 = max(xs.min() - pad, 0), min(xs.max() + pad + 1, img.shape[1])
        Image.fromarray(img[y0:y1, x0:x1], 'RGBA').save(path, optimize=True)

    save(color, out_light)

    # Dark: the blob (and its soft outer edge) becomes dark_blob.
    t2, resid2 = line_mix(color, page, blob)
    is_blob = (alpha > 0) & (resid2 < 3.5) & (t2 > 0.5)
    is_blob = ndimage.binary_opening(is_blob, iterations=1)
    # Only the big blob itself, not blob-coloured specks in the digits.
    lab, n = ndimage.label(is_blob)
    sizes = ndimage.sum(is_blob, lab, range(1, n + 1))
    is_blob = np.isin(lab, 1 + np.nonzero(sizes >= is_blob.size * 0.002)[0]) | on_blob_line
    # Gaps of page colour shut in by the drawing (between an arm and the
    # body) are background too: they go dark with the blob.
    # They are painted over afterwards and kept out of the seam, which would
    # darken the skin next to them.
    hole = np.zeros_like(is_blob)
    light_ish = np.abs(rgb - page).max(axis=-1) <= 12
    hole_labels, _ = ndimage.label(light_ish)
    for x, y in holes:
        hole |= hole_labels == hole_labels[y, x]
    hole = ndimage.binary_dilation(hole, iterations=1) & (rgb.min(axis=-1) >= 200)
    dark = color.copy()
    dark[is_blob] = dark_blob
    # The originals outline the drawing with a thin light line over the blob.
    # Near the blob, light pixels (that line and its soft mix with the
    # drawing) are unmixed from white and laid over the dark blob; darker and
    # saturated pixels (hair, shirt) stay as they are.
    # The light line is grey (not skin- or shirt-coloured) and up to ~6 px
    # wide; the white speech bubble is kept out of it.
    sizes = ndimage.sum(near_page, labels, range(1, labels.max() + 1))
    big_white = np.isin(labels, 1 + np.nonzero(sizes > 5000)[0]) & ~outside
    neutral_light = (color.min(axis=-1) >= 110) & (np.ptp(color, axis=-1) <= 40)
    seam = (ndimage.binary_dilation(is_blob, iterations=6) & ~is_blob & ~outside & ~band
            & ~ndimage.binary_dilation(hole, iterations=3)
            & ~ndimage.binary_dilation(big_white, iterations=8) & neutral_light)
    fg, f = c2a(color[seam], (255, 255, 255))
    dark[seam] = fg * f[:, None] + np.asarray(dark_blob, float) * (1 - f[:, None])
    dark[hole] = dark_blob
    save(dark, out_dark)

if __name__ == '__main__':
    src, light, dark = sys.argv[1:4]
    holes = [tuple(map(int, p.split(','))) for p in sys.argv[4:]]
    cut(src, page=(254, 254, 254), blob=(250, 245, 243), dark_blob=(38, 38, 38),
        out_light=light, out_dark=dark, holes=holes)
