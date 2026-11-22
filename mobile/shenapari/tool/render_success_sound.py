"""Renders «Дзинь на видачу», the success sound (Оплачено, Дякуємо!), to
assets/sounds/success.wav: two strikes of a counter bell, like a kitchen
calling «order up». The same synthesis as the sound board artifact: struck
bells (inharmonic partials, instant attack, exponential ring-out), the
second strike 170 ms later and a little softer. Python standard library
only.

  python3 tool/render_success_sound.py
"""
import math
import struct
import wave

RATE = 44100
LENGTH = 1.6  # seconds
PARTIALS = [(1, 1), (2.76, 0.45), (5.4, 0.22), (8.93, 0.1), (0.5, 0.18)]


def bell(buffer, start, freq, gain, decay):
    for ratio, weight in PARTIALS:
        f = freq * ratio
        d = decay / math.sqrt(ratio)
        amp = gain * weight
        first = int(start * RATE)
        for i in range(int(d * RATE)):
            n = first + i
            if n >= len(buffer):
                break
            t = i / RATE
            attack = min(1.0, t / 0.004)
            # from amp down to 1e-4 of it over d, like exponentialRampToValue
            envelope = attack * amp * (1e-4) ** (t / d)
            buffer[n] += envelope * math.sin(2 * math.pi * f * t)


def main():
    buffer = [0.0] * int(LENGTH * RATE)
    bell(buffer, 0.0, 1760, 0.55, 1.5)
    bell(buffer, 0.17, 1760, 0.42, 1.3)
    peak = max(abs(x) for x in buffer)
    scale = 0.7 / peak  # about -3 dB
    fade = int(0.03 * RATE)
    for i in range(fade):  # no click at the very end
        buffer[-1 - i] *= i / fade
    with wave.open('assets/sounds/success.wav', 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, x * scale)) * 32767))
            for x in buffer))


if __name__ == '__main__':
    main()
