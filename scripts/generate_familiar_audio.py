#!/usr/bin/env python3
"""Generate original ShakeCheer Pro effects before the Xcode project is built.

These sounds are created from code (and, for Game Over on macOS, the built-in
system speech synthesizer). No third-party audio recording is embedded by this
script.
"""

from __future__ import annotations

import math
import os
import random
import shutil
import struct
import subprocess
import tempfile
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "Resources"


def envelope(index: int, total: int, attack: float = 0.01, release: float = 0.18) -> float:
    attack_n = max(1, int(attack * SAMPLE_RATE))
    release_n = max(1, int(release * SAMPLE_RATE))
    if index < attack_n:
        return index / attack_n
    if index >= total - release_n:
        return max(0.0, (total - index - 1) / release_n)
    return 1.0


def normalize(samples: list[float], peak: float = 0.82) -> list[float]:
    maximum = max((abs(value) for value in samples), default=1.0) or 1.0
    scale = peak / maximum
    return [max(-1.0, min(1.0, value * scale)) for value in samples]


def write_wav(path: Path, samples: list[float]) -> None:
    data = normalize(samples)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", int(value * 32767)) for value in data)
        output.writeframes(frames)


def add_tone(buffer: list[float], frequency: float, start: float, duration: float, amplitude: float = 1.0, saw: bool = False) -> None:
    start_i = int(start * SAMPLE_RATE)
    count = int(duration * SAMPLE_RATE)
    for i in range(count):
        target = start_i + i
        if target >= len(buffer):
            break
        t = i / SAMPLE_RATE
        if saw:
            value = 2.0 * ((frequency * t) % 1.0) - 1.0
        else:
            value = math.sin(2.0 * math.pi * frequency * t)
        buffer[target] += amplitude * value * envelope(i, count)


def make_air_horn() -> list[float]:
    duration = 1.70
    count = int(duration * SAMPLE_RATE)
    output = [0.0] * count
    for i in range(count):
        t = i / SAMPLE_RATE
        frequency = 470.0 + 8.0 * math.sin(2.0 * math.pi * 5.0 * t)
        phase = 2.0 * math.pi * frequency * t
        value = 0.58 * math.sin(phase) + 0.27 * math.sin(2 * phase) + 0.12 * math.sin(3 * phase)
        output[i] = value * envelope(i, count, 0.015, 0.28)
    return output


def make_level_up() -> list[float]:
    output = [0.0] * int(1.55 * SAMPLE_RATE)
    for index, frequency in enumerate((523.25, 659.25, 783.99, 1046.50)):
        start = index * 0.24
        add_tone(output, frequency, start, 0.42, 0.80)
        add_tone(output, frequency * 2.0, start, 0.42, 0.16)
    return output


def make_sad_trumpet() -> list[float]:
    # Three repetitions keep the current sustained playback duration full while
    # restoring the short descending "wah-wah" identity of the original effect.
    output = [0.0] * int(7.65 * SAMPLE_RATE)
    notes = (311.0, 277.0, 247.0, 220.0)
    for repetition in range(3):
        base = repetition * 2.42
        for index, frequency in enumerate(notes):
            start = base + index * 0.48
            start_i = int(start * SAMPLE_RATE)
            count = int(0.62 * SAMPLE_RATE)
            phase = 0.0
            for i in range(count):
                target = start_i + i
                if target >= len(output):
                    break
                t = i / SAMPLE_RATE
                vibrating_frequency = frequency * (1.0 + 0.012 * math.sin(2.0 * math.pi * 5.2 * t))
                phase += 2.0 * math.pi * vibrating_frequency / SAMPLE_RATE
                value = 0.72 * math.sin(phase) + 0.18 * math.sin(2 * phase) + 0.08 * math.sin(3 * phase)
                output[target] += value * envelope(i, count, 0.02, 0.18)
    return output


def make_victory() -> list[float]:
    output = [0.0] * int(6.25 * SAMPLE_RATE)
    notes = (
        (523.25, 0.00, 0.60), (659.25, 0.45, 0.60), (783.99, 0.90, 0.70),
        (1046.50, 1.40, 1.00), (783.99, 2.50, 0.45), (1046.50, 2.85, 0.45),
        (1318.50, 3.25, 1.55),
    )
    for frequency, start, duration in notes:
        add_tone(output, frequency, start, duration, 0.34, saw=True)
        add_tone(output, frequency * 2.0, start, duration, 0.09)
    rng = random.Random(4)
    for start in (1.40, 3.25):
        start_i = int(start * SAMPLE_RATE)
        count = int(0.70 * SAMPLE_RATE)
        for i in range(count):
            target = start_i + i
            if target >= len(output):
                break
            output[target] += rng.uniform(-1.0, 1.0) * math.exp(-i / (SAMPLE_RATE * 0.18)) * 0.16
    return output


def make_podium() -> list[float]:
    output = [0.0] * int(7.25 * SAMPLE_RATE)
    rng = random.Random(7)
    # Tight snare-like roll before a compact award fanfare.
    strike = 0.0
    while strike < 2.0:
        start_i = int(strike * SAMPLE_RATE)
        count = int(0.075 * SAMPLE_RATE)
        for i in range(count):
            target = start_i + i
            if target >= len(output):
                break
            output[target] += rng.uniform(-1.0, 1.0) * math.exp(-i / (SAMPLE_RATE * 0.025)) * 0.13
        strike += 0.11
    for frequency, start, duration in ((392.0, 2.0, 0.55), (523.25, 2.4, 0.55), (659.25, 2.8, 0.55), (783.99, 3.25, 1.0), (1046.50, 4.15, 1.50)):
        add_tone(output, frequency, start, duration, 0.32, saw=True)
        add_tone(output, frequency * 2.0, start, duration, 0.08)
    return output


def encode_mp3(wav_path: Path, target: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path), "-ar", str(SAMPLE_RATE), "-ac", "1", "-b:a", "96k", str(target)],
        check=True,
    )


def make_game_over(temp_dir: Path, target: Path) -> None:
    aiff = temp_dir / "game-over.aiff"
    wav_path = temp_dir / "game-over.wav"
    if shutil.which("say"):
        subprocess.run(["say", "-v", "Daniel", "-r", "125", "-o", str(aiff), "Game over"], check=True)
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(aiff), "-af", "asetrate=36000,aresample=44100,lowpass=f=3200,volume=1.25", "-t", "1.85", "-ar", str(SAMPLE_RATE), "-ac", "1", "-b:a", "96k", str(target)],
            check=True,
        )
        return

    # Non-macOS fallback used only for local validation.
    fallback = [0.0] * int(1.20 * SAMPLE_RATE)
    for frequency, start in ((180.0, 0.0), (145.0, 0.58)):
        add_tone(fallback, frequency, start, 0.55, 0.8, saw=True)
    write_wav(wav_path, fallback)
    encode_mp3(wav_path, target)


def main() -> None:
    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg is required to generate ShakeCheer audio")

    RESOURCES.mkdir(parents=True, exist_ok=True)
    generators = {
        "air-horn": make_air_horn,
        "level-up": make_level_up,
        "sad-trumpet": make_sad_trumpet,
        "victory": make_victory,
        "podium": make_podium,
    }

    with tempfile.TemporaryDirectory(prefix="shakecheer-audio-") as temp:
        temp_dir = Path(temp)
        for name, generator in generators.items():
            wav_path = temp_dir / f"{name}.wav"
            write_wav(wav_path, generator())
            encode_mp3(wav_path, RESOURCES / f"{name}.mp3")
        make_game_over(temp_dir, RESOURCES / "game-over.mp3")

    print("Generated original ShakeCheer effects: air-horn, game-over, level-up, podium, sad-trumpet, victory")


if __name__ == "__main__":
    main()
