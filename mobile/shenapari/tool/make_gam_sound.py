"""Makes «гам», the order push sound, from Vlad's own recording.

The take is 4.53–5.05 s of the recording (the third «гам»): cut, a high-
pass at 90 Hz against rumble, the room noise between sounds gated to
silence, 5 ms / 40 ms fades, peak at −1 dBFS. Python standard library only.

  afconvert -f WAVE -d LEI16@44100 -c 1 "<recording>.m4a" /tmp/rec.wav
  python3 tool/make_gam_sound.py /tmp/rec.wav android/app/src/main/res/raw/gam.wav
"""
import math
import struct
import sys
import wave

RATE = 44100
TAKE = (4.53, 5.05)


def load(path):
    with wave.open(path) as w:
        if w.getframerate() != RATE or w.getnchannels() != 1 or w.getsampwidth() != 2:
            sys.exit('expects 44.1 kHz mono 16-bit (see afconvert above)')
        n = w.getnframes()
        return [v / 32768 for v in struct.unpack('<%dh' % n, w.readframes(n))]


def save(path, x):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, v)) * 32767)) for v in x))


def highpass(x, hz):
    rc = 1 / (2 * math.pi * hz)
    k = rc / (rc + 1 / RATE)
    y, px, py = [], 0.0, 0.0
    for v in x:
        py = k * (py + v - px)
        px = v
        y.append(py)
    return y


def gate(x, floor_db=-48, window=0.01):
    """Room noise below [floor_db] becomes silence, with soft edges."""
    n = int(window * RATE)
    threshold = 10 ** (floor_db / 20)
    open_ = []
    for i in range(0, len(x), n):
        block = x[i:i + n]
        rms = math.sqrt(sum(v * v for v in block) / max(1, len(block)))
        open_.append(1.0 if rms > threshold else 0.0)
    smooth, level = [], 0.0
    for target in open_:
        level += (target - level) * (0.6 if target > level else 0.25)
        smooth.append(level)
    return [v * smooth[min(i // n, len(smooth) - 1)] for i, v in enumerate(x)]


def fades(x, fade_in=0.005, fade_out=0.04):
    y = list(x)
    a, b = int(fade_in * RATE), int(fade_out * RATE)
    for i in range(a):
        y[i] *= i / a
    for i in range(b):
        y[-1 - i] *= i / b
    return y


def normalise(x, peak_db=-1.0):
    peak = max(abs(v) for v in x) or 1
    gain = 10 ** (peak_db / 20) / peak
    return [v * gain for v in x]


def main(src, dst):
    x = load(src)[int(TAKE[0] * RATE):int(TAKE[1] * RATE)]
    save(dst, fades(normalise(gate(highpass(x, 90)))))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
