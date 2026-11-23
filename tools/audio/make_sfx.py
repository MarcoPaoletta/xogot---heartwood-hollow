"""Heartwood Hollow: original sound effects and stingers.

Every file this script writes is synthesized offline from code: noise, filters,
plucked strings (Karplus-Strong), modal resonators and sine partials. No samples,
no recordings, no sample libraries, no downloads. Every random stream has a
fixed seed, so a rebuild gives the same sounds.

Usage (from the project root):
    py -3 tools/audio/make_sfx.py            build everything, then print a report
    py -3 tools/audio/make_sfx.py --verify   only measure the files that exist

Needs Python 3 with numpy, scipy and soundfile (libsndfile with Vorbis).
Writes mono 44.1 kHz OGG Vorbis files to assets/audio/sfx/ and assets/audio/stingers/.
The loudness targets follow the levels the game mix was balanced with
(RMS per role, peaks kept under -1 dBFS), so audio.gd needs no volume changes.
"""

from __future__ import annotations

import os
import sys

import numpy as np
import soundfile as sf
from scipy import signal

SR = 44100
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SFX_DIR = os.path.join(ROOT, "assets", "audio", "sfx")
STING_DIR = os.path.join(ROOT, "assets", "audio", "stingers")


# --------------------------------------------------------------------------- helpers

def rng(seed: int) -> np.random.Generator:
    return np.random.default_rng(seed)


def t_axis(dur: float) -> np.ndarray:
    return np.arange(int(dur * SR)) / SR


def sos_band(lo: float, hi: float, order: int = 2):
    return signal.butter(order, [lo, hi], btype="bandpass", fs=SR, output="sos")


def sos_low(fc: float, order: int = 2):
    return signal.butter(order, fc, btype="lowpass", fs=SR, output="sos")


def sos_high(fc: float, order: int = 2):
    return signal.butter(order, fc, btype="highpass", fs=SR, output="sos")


def filt(sos, x: np.ndarray) -> np.ndarray:
    return signal.sosfilt(sos, x)


def env_exp(n: int, tau: float, attack: float = 0.002) -> np.ndarray:
    t = np.arange(n) / SR
    a = np.clip(t / max(attack, 1e-5), 0.0, 1.0)
    return a * np.exp(-t / tau)


def env_bell(n: int, peak_at: float) -> np.ndarray:
    """Smooth rise and fall, peak at a fraction of the length."""
    x = np.linspace(0.0, 1.0, n)
    up = np.clip(x / peak_at, 0, 1)
    down = np.clip((1 - x) / (1 - peak_at), 0, 1)
    return np.sin(up * np.pi / 2) ** 2 * np.sin(down * np.pi / 2) ** 2


def fade_out(x: np.ndarray, sec: float = 0.01) -> np.ndarray:
    n = min(len(x), int(sec * SR))
    if n > 0:
        x[-n:] *= np.linspace(1.0, 0.0, n) ** 2
    return x


def place(dst: np.ndarray, src: np.ndarray, at: float, gain: float = 1.0) -> None:
    i = int(at * SR)
    if i >= len(dst):
        return
    n = min(len(src), len(dst) - i)
    chunk = src[:n] * gain
    if n < len(src):
        chunk = fade_out(chunk.copy(), 0.02)
    dst[i:i + n] += chunk


def modal(freqs, decays, gains, dur: float, excite: np.ndarray | None = None) -> np.ndarray:
    """Sum of decaying sine modes, optionally convolved with a short excitation."""
    t = t_axis(dur)
    out = np.zeros_like(t)
    for f, d, g in zip(freqs, decays, gains):
        out += g * np.sin(2 * np.pi * f * t) * np.exp(-t / d)
    if excite is not None:
        out = signal.fftconvolve(out, excite)[: len(t)]
    return fade_out(out, 0.03)


def pluck(freq: float, dur: float, seed: int, bright: float = 0.5, damp: float = 0.996) -> np.ndarray:
    """Karplus-Strong plucked string, pizzicato style (short, warm)."""
    r = rng(seed)
    n = int(dur * SR)
    period = SR / freq
    p = int(period)
    frac = period - p
    burst = r.uniform(-1, 1, p)
    burst = filt(sos_low(2000 + 6000 * bright, 1), burst)
    buf = np.zeros(n + p + 2)
    buf[:p] = burst
    for i in range(p, n + p):
        a = buf[i - p]
        b = buf[i - p - 1] if i - p - 1 >= 0 else 0.0
        c = buf[i - p + 1] if frac > 0 else a
        prev = (1 - frac) * a + frac * c
        buf[i] = damp * 0.5 * (prev + b)
    out = buf[p:p + n]
    out *= env_exp(n, 0.35 + 0.3 * (440 / freq), 0.001)
    # body resonance, like a small wooden instrument
    body = filt(sos_band(180, 2600, 1), out)
    return fade_out(0.6 * out + 0.7 * body, 0.03)


def bell(freq: float, dur: float, tau: float = 0.6) -> np.ndarray:
    ratios = [1.0, 2.0, 2.76, 5.4, 8.93]
    gains = [1.0, 0.45, 0.32, 0.12, 0.05]
    decays = [tau, tau * 0.6, tau * 0.45, tau * 0.25, tau * 0.12]
    return modal([freq * k for k in ratios], decays, gains, dur)


def steelpan(freq: float, dur: float) -> np.ndarray:
    t = t_axis(dur)
    out = np.zeros_like(t)
    for k, g, d in [(1.0, 1.0, 0.55), (2.0, 0.6, 0.35), (3.0, 0.25, 0.22), (4.02, 0.12, 0.15)]:
        out += g * np.sin(2 * np.pi * freq * k * t + 0.3 * np.sin(2 * np.pi * 5 * t)) * np.exp(-t / d)
    out *= np.clip(t / 0.004, 0, 1)
    return fade_out(out, 0.03)


def note(name: str) -> float:
    names = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}
    pitch, octave = name[:-1], int(name[-1])
    midi = 12 * (octave + 1) + names[pitch]
    return 440.0 * 2 ** ((midi - 69) / 12)


def room(x: np.ndarray, seed: int, length: float = 0.35, wet: float = 0.18) -> np.ndarray:
    """Small synthetic room: decaying filtered noise impulse."""
    r = rng(seed)
    n = int(length * SR)
    ir = r.normal(0, 1, n) * np.exp(-np.arange(n) / (0.12 * SR))
    ir = filt(sos_low(5000, 1), ir)
    ir /= np.sqrt((ir ** 2).sum()) + 1e-9
    tail = signal.fftconvolve(x, ir)
    out = np.zeros(len(tail))
    out[: len(x)] += x
    return out + wet * tail


def master(x: np.ndarray, rms_db: float, peak_db: float = -2.5) -> np.ndarray:
    """Hit a target RMS (measured over the audible part), soft limit the peak."""
    x = np.asarray(x, dtype=np.float64)
    x = x - np.mean(x)
    x = fade_out(x, 0.008)
    # trim leading silence (keep 3 ms) and trailing silence below -70 dB, so a sound starts on its trigger
    lead = np.nonzero(np.abs(x) > np.abs(x).max() * 10 ** (-40 / 20))[0]
    if len(lead):
        x = x[max(0, lead[0] - int(0.003 * SR)):]
    thr = np.abs(x).max() * 10 ** (-70 / 20)
    idx = np.nonzero(np.abs(x) > thr)[0]
    if len(idx):
        x = x[: idx[-1] + 1]
    rms = np.sqrt(np.mean(x ** 2)) + 1e-12
    x = x * (10 ** (rms_db / 20) / rms)
    lim = 10 ** (peak_db / 20)
    over = np.abs(x) > lim * 0.7
    if over.any():
        knee = lim * 0.7
        y = x.copy()
        s = np.sign(x[over])
        a = np.abs(x[over]) - knee
        y[over] = s * (knee + (lim - knee) * np.tanh(a / (lim - knee)))
        x = y
    return np.clip(x, -lim, lim)


# --------------------------------------------------------------------------- sound recipes

def step_dirt(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.34
    out = np.zeros(int(dur * SR))
    # soft heel thump in the dirt
    t = t_axis(0.09)
    thump = np.sin(2 * np.pi * (95 - 260 * t) * t) * np.exp(-t / 0.025)
    place(out, thump, 0.0, 0.5)
    # crunch: dense grains of filtered noise (grass blades and soil)
    for i in range(int(r.integers(26, 38))):
        at = abs(r.normal(0.03, 0.035))
        g = r.normal(0, 1, int(r.uniform(0.002, 0.008) * SR))
        g *= np.hanning(len(g))
        lo = r.uniform(900, 1800)
        g = filt(sos_band(lo, lo * r.uniform(2.0, 3.2)), g)
        place(out, g, at, r.uniform(0.25, 0.9))
    hiss = r.normal(0, 1, len(out)) * env_exp(len(out), 0.05, 0.004)
    out += 0.25 * filt(sos_band(1200, 5000), hiss)
    return master(out, -29.5)


def step_wood(seed: int) -> np.ndarray:
    r = rng(seed)
    k = r.uniform(0.94, 1.06)
    click = r.normal(0, 1, int(0.004 * SR)) * np.hanning(int(0.004 * SR))
    body = modal([170 * k, 410 * k, 880 * k, 1630 * k], [0.06, 0.04, 0.025, 0.012], [1.0, 0.55, 0.3, 0.15], 0.25, click)
    t = t_axis(0.25)
    knock = np.sin(2 * np.pi * 120 * k * t) * np.exp(-t / 0.03)
    out = body + 0.6 * knock
    return master(room(out, seed + 1, 0.2, 0.12), -20.5)


def step_stone(seed: int) -> np.ndarray:
    r = rng(seed)
    n = int(0.12 * SR)
    tap = r.normal(0, 1, n) * env_exp(n, 0.012, 0.0005)
    tap = filt(sos_high(1400), tap)
    ring = modal([2200 * r.uniform(0.95, 1.05), 3400, 5100], [0.02, 0.012, 0.008], [0.4, 0.25, 0.15], 0.12)
    grit = r.normal(0, 1, n) * env_exp(n, 0.03, 0.006)
    grit = filt(sos_band(2500, 7000), grit)
    t = t_axis(0.12)
    low = np.sin(2 * np.pi * 150 * t) * np.exp(-t / 0.015)
    return master(tap + ring + 0.35 * grit + 0.4 * low, -22.0)


def cloth(seed: int, dur: float) -> np.ndarray:
    r = rng(seed)
    n = int(dur * SR)
    x = r.normal(0, 1, n)
    x = filt(sos_band(900, 6500), x)
    # a few overlapping swishes of fabric
    e = np.zeros(n)
    for i in range(3):
        c = r.uniform(0.15, 0.7)
        w = r.uniform(0.06, 0.16)
        tt = np.arange(n) / n
        e += r.uniform(0.5, 1.0) * np.exp(-((tt - c) / w) ** 2)
    flutter = 1 + 0.35 * filt(sos_low(30, 1), r.normal(0, 1, n)) * 8
    out = x * e * np.clip(flutter, 0.2, 2.0)
    return master(out, -28.5)


def sword_swish(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.5
    n = int(dur * SR)
    x = r.normal(0, 1, n)
    out = np.zeros(n)
    # sweep a band pass up then down (blade passing the ear)
    blocks = 64
    edges = np.linspace(0, n, blocks + 1).astype(int)
    centre = 700 + 2100 * np.sin(np.linspace(0, np.pi, blocks)) ** 1.5
    centre *= r.uniform(0.9, 1.1)
    zi = None
    for b in range(blocks):
        sos = sos_band(centre[b] * 0.6, centre[b] * 1.5)
        if zi is None:
            zi = np.zeros((sos.shape[0], 2))
        seg = x[edges[b]:edges[b + 1]]
        y, zi = signal.sosfilt(sos, seg, zi=zi)
        out[edges[b]:edges[b + 1]] = y
    out *= env_bell(n, 0.42) ** 1.2
    return master(out, -21.0)


def wood_bonk(seed: int) -> np.ndarray:
    r = rng(seed)
    k = r.uniform(0.92, 1.08)
    click = r.normal(0, 1, int(0.003 * SR)) * np.hanning(int(0.003 * SR))
    body = modal([215 * k, 520 * k, 1130 * k, 2050 * k], [0.09, 0.06, 0.03, 0.015], [1.0, 0.7, 0.35, 0.15], 0.33, click)
    t = t_axis(0.33)
    thump = np.sin(2 * np.pi * (140 * k - 120 * t) * t) * np.exp(-t / 0.05)
    return master(room(body + 0.8 * thump, seed + 3, 0.25, 0.14), -22.5)


def sparkle_poof(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.55
    out = np.zeros(int(dur * SR))
    # soft puff of air
    n = int(0.25 * SR)
    puff = filt(sos_band(400, 2200), r.normal(0, 1, n)) * env_exp(n, 0.06, 0.01)
    place(out, puff, 0.0, 0.7)
    # rising glitter: tiny bell pings climbing a pentatonic scale
    scale = [note(x) for x in ["G5", "A5", "C6", "D6", "E6", "G6", "A6", "C7"]]
    for i in range(10):
        f = scale[min(len(scale) - 1, int(i * 0.8 + r.integers(0, 2)))]
        ping = bell(f, 0.25, 0.08)
        place(out, ping, 0.02 + i * 0.032 + r.uniform(0, 0.01), 0.35 + 0.05 * i / 10)
    return master(room(out, seed + 5, 0.4, 0.2), -15.0)


def monster_happy(seed: int, rise: float) -> np.ndarray:
    r = rng(seed)
    dur = 0.34
    t = t_axis(dur)
    out = np.zeros_like(t)
    # two cute syllables, "bip-bee", gliding up
    for s, (start, length, f0) in enumerate([(0.0, 0.12, 520), (0.13, 0.2, 640)]):
        tt = t_axis(length)
        f = f0 * rise * (1 + 0.55 * tt / length) * (1 + 0.03 * np.sin(2 * np.pi * 22 * tt))
        ph = 2 * np.pi * np.cumsum(f) / SR
        v = np.sin(ph) + 0.3 * np.sin(2 * ph) + 0.1 * np.sin(3 * ph)
        v *= env_bell(len(tt), 0.25)
        place(out, v, start)
    out = filt(sos_low(4500), out)
    return master(out, -13.5)


def monster_grumpy(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.52
    t = t_axis(dur)
    f = 118 * r.uniform(0.9, 1.1) * (1 - 0.3 * t / dur)
    ph = 2 * np.pi * np.cumsum(f) / SR
    v = sum(np.sin(k * ph) / k for k in range(1, 8))
    v *= 1 + 0.4 * np.sin(2 * np.pi * 17 * t)
    v = filt(sos_low(900), v) * env_bell(len(t), 0.15)
    thump = np.sin(2 * np.pi * (85 - 50 * t) * t) * np.exp(-t / 0.06)
    return master(v + 1.1 * thump, -17.3)


def player_hurt(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.17
    t = t_axis(dur)
    f = 170 * r.uniform(0.95, 1.05) * np.exp(-t / 0.05) + 55
    ph = 2 * np.pi * np.cumsum(f) / SR
    body = np.sin(ph) * np.exp(-t / 0.06)
    n = len(t)
    slap = filt(sos_band(300, 2500), r.normal(0, 1, n)) * env_exp(n, 0.015, 0.001)
    return master(body + 0.5 * slap, -14.5)


def honey_pour(seed: int, count: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.85
    out = np.zeros(int(dur * SR))
    at = 0.02
    for i in range(count):
        length = r.uniform(0.05, 0.09)
        tt = t_axis(length)
        f0 = r.uniform(260, 420)
        f = f0 * (1 + 1.4 * (tt / length) ** 1.5)
        ph = 2 * np.pi * np.cumsum(f) / SR
        blob = np.sin(ph) * env_bell(len(tt), 0.2)
        place(out, blob, at, r.uniform(0.6, 1.0))
        at += r.uniform(0.08, 0.15)
    n = len(out)
    liquid = filt(sos_band(200, 900), r.normal(0, 1, n)) * env_bell(n, 0.3) * 0.15
    out = filt(sos_low(2200), out + liquid)
    return master(room(out, seed + 9, 0.3, 0.15), -30.0)


def dialogue_blip(seed: int, f: float) -> np.ndarray:
    t = t_axis(0.035)
    v = np.sin(2 * np.pi * f * t) + 0.25 * np.sin(2 * np.pi * 2 * f * t)
    v *= env_exp(len(t), 0.009, 0.0008)
    return master(v, -18.0)


def ui_hover() -> np.ndarray:
    t = t_axis(0.13)
    f = 980 * np.exp(-t / 0.05) + 420
    ph = 2 * np.pi * np.cumsum(f) / SR
    v = np.sin(ph) * env_exp(len(t), 0.03, 0.002)
    return master(v, -20.0)


def ui_click(seed: int, f: float) -> np.ndarray:
    r = rng(seed)
    n = int(0.03 * SR)
    t = np.arange(n) / SR
    v = np.sin(2 * np.pi * f * t) * np.exp(-t / 0.004)
    v += 0.4 * filt(sos_high(3000), r.normal(0, 1, n)) * np.exp(-t / 0.002)
    return master(v, -16.0)


def ui_reject() -> np.ndarray:
    out = np.zeros(int(0.5 * SR))
    for i, nm in enumerate(["E4", "C4"]):
        tt = t_axis(0.2)
        f = note(nm)
        v = np.sin(2 * np.pi * f * tt) + 0.33 * np.sin(2 * np.pi * 3 * f * tt) + 0.12 * np.sin(2 * np.pi * 5 * f * tt)
        v = filt(sos_low(1800), v) * env_bell(len(tt), 0.1)
        place(out, v, i * 0.17)
    return master(out, -20.0)


def shield_equip(seed: int) -> np.ndarray:
    r = rng(seed)
    click = r.normal(0, 1, int(0.003 * SR)) * np.hanning(int(0.003 * SR))
    ring = modal([510, 1235, 2040, 3110, 4370], [0.35, 0.22, 0.15, 0.09, 0.05], [1.0, 0.6, 0.45, 0.25, 0.12], 0.62, click)
    t = t_axis(0.62)
    thud = np.sin(2 * np.pi * (120 - 60 * t) * t) * np.exp(-t / 0.05)
    strap = filt(sos_band(1500, 5000), r.normal(0, 1, len(t))) * env_exp(len(t), 0.05, 0.02)
    return master(room(ring + 0.9 * thud + 0.2 * strap, seed + 2, 0.3, 0.15), -25.5)


def brazier_light(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.7
    n = int(dur * SR)
    whoomph = filt(sos_low(700), r.normal(0, 1, n)) * env_bell(n, 0.18)
    roar = filt(sos_band(500, 2500), r.normal(0, 1, n)) * env_bell(n, 0.3) * 0.35
    out = whoomph + roar
    for i in range(14):
        at = r.uniform(0.1, 0.65)
        c = r.normal(0, 1, int(0.003 * SR))
        c = filt(sos_high(2500), c)
        place(out, c, at, r.uniform(0.3, 0.9))
    return master(out, -26.5)


def calm_chime(seed: int, notes_: list[str]) -> np.ndarray:
    out = np.zeros(int(0.9 * SR))
    for i, nm in enumerate(notes_):
        place(out, pluck(note(nm), 0.6, seed + i, 0.6), i * 0.09)
        place(out, bell(note(nm) * 2, 0.6, 0.25), i * 0.09, 0.12)
    return master(room(out, seed + 7, 0.5, 0.22), -15.2)


# --------------------------------------------------------------------------- stingers

def phrase_pizz(seed: int, seq: list[tuple[str, float]], chord: list[str] | None, chord_at: float,
                dur: float, rms: float) -> np.ndarray:
    out = np.zeros(int(dur * SR))
    for i, (nm, at) in enumerate(seq):
        place(out, pluck(note(nm), min(0.9, dur - at + 0.05), seed + i, 0.55), at)
    if chord:
        for j, nm in enumerate(chord):
            place(out, pluck(note(nm), dur - chord_at, seed + 50 + j, 0.45), chord_at + j * 0.012, 0.7)
            place(out, bell(note(nm) * 2, dur - chord_at, 0.4), chord_at, 0.05)
    return master(room(out, seed + 100, 0.6, 0.25), rms)


def phrase_steel(seed: int, seq: list[tuple[str, float]], dur: float, rms: float) -> np.ndarray:
    out = np.zeros(int(dur * SR))
    for nm, at in seq:
        place(out, steelpan(note(nm), dur - at), at)
    return master(room(out, seed + 100, 0.6, 0.25), rms)


def stinger_hit(seed: int) -> np.ndarray:
    r = rng(seed)
    dur = 0.34
    out = np.zeros(int(dur * SR))
    t = t_axis(dur)
    drum = np.sin(2 * np.pi * (110 - 140 * t) * t) * np.exp(-t / 0.07)
    snap = filt(sos_band(800, 5000), r.normal(0, 1, len(t))) * env_exp(len(t), 0.03, 0.001)
    out += drum + 0.5 * snap
    for j, nm in enumerate(["A3", "C4", "D#4"]):
        place(out, pluck(note(nm), dur, seed + j, 0.8, 0.99), 0.0, 0.6)
    return master(out, -16.5)


# --------------------------------------------------------------------------- build list

def build() -> dict[str, np.ndarray]:
    s: dict[str, np.ndarray] = {}
    for i in range(4):
        s[f"sfx/step_dirt_{i + 1}.ogg"] = step_dirt(100 + i)
        s[f"sfx/step_wood_{i + 1}.ogg"] = step_wood(200 + i)
    for i in range(3):
        s[f"sfx/step_stone_{i + 1}.ogg"] = step_stone(300 + i)
        s[f"sfx/cloth_{i + 1}.ogg"] = cloth(400 + i, [0.62, 0.45, 0.5][i])
    for i in range(2):
        s[f"sfx/sword_swish_{i + 1}.ogg"] = sword_swish(500 + i)
        s[f"sfx/sparkle_poof_{i + 1}.ogg"] = sparkle_poof(700 + i)
        s[f"sfx/monster_happy_{i + 1}.ogg"] = monster_happy(800 + i, [1.0, 1.18][i])
        s[f"sfx/monster_grumpy_{i + 1}.ogg"] = monster_grumpy(900 + i)
        s[f"sfx/player_hurt_{i + 1}.ogg"] = player_hurt(1000 + i)
        s[f"sfx/honey_pour_{i + 1}.ogg"] = honey_pour(1100 + i, [6, 4][i])
        s[f"sfx/dialogue_blip_{i + 1}.ogg"] = dialogue_blip(1200 + i, [1750.0, 1960.0][i])
        s[f"sfx/ui_click_{i + 1}.ogg"] = ui_click(1300 + i, [2400.0, 2650.0][i])
    for i in range(4):
        s[f"sfx/wood_bonk_{i + 1}.ogg"] = wood_bonk(600 + i)
    s["sfx/ui_hover.ogg"] = ui_hover()
    s["sfx/ui_reject.ogg"] = ui_reject()
    s["sfx/shield_equip.ogg"] = shield_equip(1400)
    s["sfx/brazier_light.ogg"] = brazier_light(1500)
    s["sfx/calm_chime_1.ogg"] = calm_chime(1600, ["G5", "D6"])
    s["sfx/calm_chime_2.ogg"] = calm_chime(1610, ["A5", "E6"])

    s["stingers/seed_awaken.ogg"] = phrase_pizz(2000, [("C5", 0.0), ("E5", 0.11), ("G5", 0.22), ("C6", 0.33)],
                                                ["C5", "E5", "G5"], 0.45, 1.25, -15.0)
    s["stingers/ending_forest.ogg"] = phrase_pizz(2100, [("G4", 0.0), ("B4", 0.12), ("D5", 0.24), ("G5", 0.36)],
                                                  ["G4", "B4", "D5"], 0.5, 1.3, -15.0)
    s["stingers/ending_home.ogg"] = phrase_steel(2200, [("C5", 0.0), ("E5", 0.14), ("G5", 0.28), ("E5", 0.42), ("C6", 0.56)],
                                                 1.3, -15.4)
    s["stingers/ending_share.ogg"] = phrase_pizz(2300, [("F5", 0.0), ("A5", 0.1), ("C6", 0.2), ("F6", 0.32)],
                                                 ["F5", "A5", "C6"], 0.42, 1.1, -15.1)
    s["stingers/choice_honey.ogg"] = phrase_pizz(2400, [("E5", 0.0), ("G5", 0.16), ("A5", 0.32), ("G5", 0.48), ("C6", 0.66)],
                                                 None, 0.0, 1.45, -17.3)
    s["stingers/choice_fight.ogg"] = stinger_hit(2500)
    s["stingers/calm_burst.ogg"] = phrase_pizz(2600, [("G5", 0.0), ("D6", 0.1)], None, 0.0, 0.6, -17.3)
    return s


def report(paths: list[str]) -> int:
    bad = 0
    for p in paths:
        d, sr = sf.read(p, always_2d=True)
        m = d.mean(axis=1)
        pk = 20 * np.log10(np.abs(m).max() + 1e-12)
        rms = 20 * np.log10(np.sqrt(np.mean(m ** 2)) + 1e-12)
        ok = sr == SR and pk <= -0.5 and len(m) > 0 and np.isfinite(m).all()
        bad += 0 if ok else 1
        print(f"{'OK ' if ok else 'BAD'} {len(m) / sr:5.2f}s peak {pk:6.1f} dB rms {rms:6.1f} dB  {os.path.relpath(p, ROOT)}")
    return bad


def main() -> int:
    out_paths: list[str] = []
    if "--verify" not in sys.argv:
        for rel, x in build().items():
            path = os.path.join(ROOT, "assets", "audio", rel.replace("/", os.sep))
            os.makedirs(os.path.dirname(path), exist_ok=True)
            sf.write(path, x.astype(np.float32), SR, format="OGG", subtype="VORBIS")
            out_paths.append(path)
    else:
        for d in (SFX_DIR, STING_DIR):
            for f in sorted(os.listdir(d)):
                if f.endswith(".ogg"):
                    out_paths.append(os.path.join(d, f))
    bad = report(sorted(out_paths))
    print(f"{len(out_paths)} files, {bad} failed checks")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
