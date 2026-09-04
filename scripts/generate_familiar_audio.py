#!/usr/bin/env python3
"""Generate closer-to-original ShakeCheer Pro effects before XcodeGen.

Real-world effects use verified CC0 BigSoundBank recordings when possible.
Game/crowd cues are generated from code or macOS system speech so no Pixabay
recording is reintroduced.
"""

from __future__ import annotations

import math
import random
import shutil
import struct
import subprocess
import tempfile
import urllib.request
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "Resources"
BIGSOUNDBANK_MP3 = "https://bigsoundbank.com/UPLOAD/mp3/{sound_id}.mp3"


def run(args: list[str]) -> None:
    subprocess.run(args, check=True)


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
        value = (2.0 * ((frequency * t) % 1.0) - 1.0) if saw else math.sin(2.0 * math.pi * frequency * t)
        buffer[target] += amplitude * value * envelope(i, count)


def encode_mp3(source: Path, target: Path, filters: str | None = None, duration: float | None = None) -> None:
    args = ["ffmpeg", "-y", "-loglevel", "error", "-i", str(source)]
    if filters:
        args += ["-af", filters]
    if duration is not None:
        args += ["-t", f"{duration:.2f}"]
    args += ["-ar", str(SAMPLE_RATE), "-ac", "1", "-b:a", "96k", str(target)]
    run(args)


def download_cc0(sound_id: int, temp_dir: Path) -> Path:
    target = temp_dir / f"bigsoundbank-{sound_id}.mp3"
    request = urllib.request.Request(
        BIGSOUNDBANK_MP3.format(sound_id=sound_id),
        headers={"User-Agent": "ShakeCheer/1.0"},
    )
    with urllib.request.urlopen(request, timeout=30) as response, target.open("wb") as output:
        output.write(response.read())
    return target


def make_level_up() -> list[float]:
    output = [0.0] * int(1.45 * SAMPLE_RATE)
    for index, frequency in enumerate((523.25, 659.25, 783.99, 1046.50, 1318.51)):
        start = index * 0.18
        add_tone(output, frequency, start, 0.34, 0.76)
        add_tone(output, frequency * 2.0, start, 0.34, 0.12)
    return output


def make_coin() -> list[float]:
    output = [0.0] * int(0.72 * SAMPLE_RATE)
    add_tone(output, 987.77, 0.00, 0.22, 0.78)
    add_tone(output, 1318.51, 0.12, 0.35, 0.82)
    add_tone(output, 2637.02, 0.12, 0.20, 0.14)
    return output


def make_sad_trumpet() -> list[float]:
    output = [0.0] * int(2.38 * SAMPLE_RATE)
    notes = (311.13, 277.18, 246.94, 220.00)
    for index, frequency in enumerate(notes):
        start = index * 0.44
        start_i = int(start * SAMPLE_RATE)
        count = int(0.62 * SAMPLE_RATE)
        phase = 0.0
        for i in range(count):
            target = start_i + i
            if target >= len(output):
                break
            t = i / SAMPLE_RATE
            vibrating_frequency = frequency * (1.0 + 0.018 * math.sin(2.0 * math.pi * 5.0 * t))
            phase += 2.0 * math.pi * vibrating_frequency / SAMPLE_RATE
            value = 0.58 * math.sin(phase) + 0.25 * math.sin(2 * phase) + 0.12 * math.sin(3 * phase)
            output[target] += value * envelope(i, count, 0.025, 0.20)
    return output


def make_victory() -> list[float]:
    output = [0.0] * int(7.55 * SAMPLE_RATE)
    sequence = (
        (392.00, 0.00, 0.42), (523.25, 0.36, 0.42), (659.25, 0.72, 0.42),
        (783.99, 1.10, 0.70), (659.25, 2.00, 0.34), (783.99, 2.30, 0.34),
        (987.77, 2.60, 0.52), (1046.50, 3.10, 0.55), (1318.51, 3.55, 1.65),
    )
    for frequency, start, duration in sequence:
        add_tone(output, frequency, start, duration, 0.28, saw=True)
        add_tone(output, frequency * 2.0, start, duration, 0.08)
    for f in (523.25, 659.25, 783.99):
        add_tone(output, f, 5.35, 1.70, 0.20, saw=True)
    rng = random.Random(4)
    for start in (1.10, 3.55, 5.35):
        start_i = int(start * SAMPLE_RATE)
        count = int(0.80 * SAMPLE_RATE)
        for i in range(count):
            target = start_i + i
            if target >= len(output):
                break
            output[target] += rng.uniform(-1.0, 1.0) * math.exp(-i / (SAMPLE_RATE * 0.20)) * 0.13
    return output


def make_podium() -> list[float]:
    output = [0.0] * int(21.90 * SAMPLE_RATE)
    rng = random.Random(7)
    strike = 0.0
    while strike < 4.0:
        start_i = int(strike * SAMPLE_RATE)
        count = int(0.075 * SAMPLE_RATE)
        for i in range(count):
            target = start_i + i
            if target >= len(output):
                break
            output[target] += rng.uniform(-1.0, 1.0) * math.exp(-i / (SAMPLE_RATE * 0.025)) * 0.12
        strike += 0.10
    fanfare = (
        (392.00, 4.00, 0.65), (523.25, 4.55, 0.65), (659.25, 5.10, 0.65),
        (783.99, 5.70, 1.10), (523.25, 7.15, 0.55), (659.25, 7.60, 0.55),
        (783.99, 8.05, 0.60), (1046.50, 8.55, 1.40),
    )
    for frequency, start, duration in fanfare:
        add_tone(output, frequency, start, duration, 0.25, saw=True)
        add_tone(output, frequency * 2.0, start, duration, 0.06)
    for frequency, start, duration in fanfare:
        shifted = start + 9.30
        add_tone(output, frequency, shifted, duration, 0.23, saw=True)
        add_tone(output, frequency * 2.0, shifted, duration, 0.05)
    return output


def make_speech_cue(temp_dir: Path, target: Path, text: str, duration: float, crowd: bool = False) -> None:
    aiff = temp_dir / f"{target.stem}.aiff"
    if not shutil.which("say"):
        fallback = [0.0] * int(duration * SAMPLE_RATE)
        for frequency, start in ((180.0, 0.0), (145.0, min(0.55, duration / 2))):
            add_tone(fallback, frequency, start, min(0.50, duration / 2), 0.7, saw=True)
        wav = temp_dir / f"{target.stem}.wav"
        write_wav(wav, fallback)
        encode_mp3(wav, target)
        return
    run(["say", "-r", "125", "-o", str(aiff), text])
    if crowd:
        filter_complex = (
            "[0:a]asplit=5[a0][a1][a2][a3][a4];"
            "[a0]aresample=44100,volume=0.95[b0];"
            "[a1]asetrate=47000,aresample=44100,adelay=70,volume=0.80[b1];"
            "[a2]asetrate=41500,aresample=44100,adelay=135,volume=0.78[b2];"
            "[a3]asetrate=49000,aresample=44100,adelay=210,volume=0.64[b3];"
            "[a4]asetrate=39500,aresample=44100,adelay=285,volume=0.60[b4];"
            "[b0][b1][b2][b3][b4]amix=inputs=5:normalize=0,alimiter=limit=0.90[out]"
        )
        run([
            "ffmpeg", "-y", "-loglevel", "error", "-i", str(aiff),
            "-filter_complex", filter_complex, "-map", "[out]",
            "-t", f"{duration:.2f}", "-ar", str(SAMPLE_RATE), "-ac", "1",
            "-b:a", "96k", str(target),
        ])
    else:
        encode_mp3(aiff, target, "asetrate=36000,aresample=44100,lowpass=f=3200,volume=1.20", duration)


def main() -> None:
    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg is required to generate ShakeCheer audio")
    RESOURCES.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="shakecheer-audio-") as temp:
        temp_dir = Path(temp)
        air_horn = download_cc0(1827, temp_dir)
        encode_mp3(air_horn, RESOURCES / "air-horn.mp3", "loudnorm=I=-14:TP=-1.5:LRA=7", 1.35)
        buzzer = download_cc0(1586, temp_dir)
        encode_mp3(buzzer, RESOURCES / "fail-buzzer.mp3", "loudnorm=I=-15:TP=-1.5:LRA=7", 1.90)
        generators = {
            "level-up": make_level_up,
            "coin": make_coin,
            "sad-trumpet": make_sad_trumpet,
            "victory": make_victory,
            "podium": make_podium,
        }
        for name, generator in generators.items():
            wav = temp_dir / f"{name}.wav"
            write_wav(wav, generator())
            encode_mp3(wav, RESOURCES / f"{name}.mp3")
        make_speech_cue(temp_dir, RESOURCES / "game-over.mp3", "Game over", 1.90)
        make_speech_cue(temp_dir, RESOURCES / "crowd-hey.mp3", "Hey! Hey! Hey!", 3.30, crowd=True)
        make_speech_cue(temp_dir, RESOURCES / "boo.mp3", "Boooo!", 2.30, crowd=True)
        make_speech_cue(temp_dir, RESOURCES / "boo-crowd.mp3", "Awwww! Boooo!", 4.00, crowd=True)
    print("Generated closer familiar effects: air-horn, fail-buzzer, game-over, crowd-hey, boo, boo-crowd, coin, level-up, sad-trumpet, victory, podium")


if __name__ == "__main__":
    main()
