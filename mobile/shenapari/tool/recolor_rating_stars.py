"""Recolours JcToon's «Rating animation» (Rive, CC BY 4.0) for ШеНаПарі.

The original is white stars on a dark square, made to be remixed. CC BY
allows changes if they are stated; these are the changes:
transparent background, brand-yellow filled stars, pale-yellow empty ones,
light-yellow glow. Shapes and motion are untouched.

Colours sit in a .riv as property 37 (colorValue) followed by 4 bytes,
ARGB stored little-endian (B, G, R, A).

  curl -sL -o /tmp/rating.riv \\
    https://public.rive.app/community/runtime-files/405-6776-rating-animation.riv
  python3 tool/recolor_rating_stars.py /tmp/rating.riv assets/rive/rating_stars.riv
"""
import sys


def le(argb):
    """0xAARRGGBB as stored in the file."""
    return argb.to_bytes(4, 'little')


SWAP = {
    le(0xFF1C1C1C): le(0x001C1C1C),  # artboard background -> transparent
    le(0xFFFFFAFA): le(0xFFFEBC2F),  # filled star -> brand yellow
    le(0xFF111111): le(0xFFFFF4D6),  # empty star fill -> pale yellow
    le(0xFF2F2F2F): le(0xFFF5D88C),  # empty star outline (the rim of a filled one) -> soft yellow
    le(0xFFFFFFFF): le(0xFFFFD25A),  # glow and sparks -> light yellow
}


def main(src, dst):
    data = bytearray(open(src, 'rb').read())
    if data[:4] != b'RIVE':
        sys.exit(f'{src} is not a Rive file')
    count = {key: 0 for key in SWAP}
    for i in range(len(data) - 5):
        if data[i] == 0x25:
            chunk = bytes(data[i + 1:i + 5])
            if chunk in SWAP:
                data[i + 1:i + 5] = SWAP[chunk]
                count[chunk] += 1
    open(dst, 'wb').write(data)
    print({key.hex(): n for key, n in count.items()})


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
