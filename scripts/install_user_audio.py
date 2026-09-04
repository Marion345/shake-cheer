#!/usr/bin/env python3
"""Install the exact ShakeCheer user-selected sounds before XcodeGen.

The repository keeps small placeholder/previous resources for source control, but
CI and Codemagic replace the 16 selected sounds from their original public
Freesound/BigSoundBank recordings before compiling the app.
"""

from __future__ import annotations

import hashlib
import re
import shutil
import subprocess
import tempfile
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "Resources"

# output filename: (source URL, trim start seconds, duration seconds)
SOURCES = {
    "air-horn.mp3": ("https://freesound.org/s/131930/", 0.0, 2.57),
    "boo.mp3": ("https://freesound.org/s/233579/", 14.8, 3.0),
    "cheer-crowd.mp3": ("https://freesound.org/s/829455/", 2.0, 5.0),
    "coin.mp3": ("https://freesound.org/s/347174/", 0.0, 0.50),
    "crowd-disappointment.mp3": ("https://freesound.org/s/764298/", 13.3, 5.0),
    "crowd-hey.mp3": ("https://freesound.org/s/243946/", 0.0, 4.9),
    "drum-crowd.mp3": ("https://freesound.org/s/500250/", 18.0, 5.95),
    "fail-buzzer.mp3": ("https://freesound.org/s/394900/", 1.8, 3.0),
    "game-over.mp3": ("https://freesound.org/s/434465/", 0.0, 2.0),
    "laugh-track.mp3": ("https://freesound.org/s/752711/", 0.0, 3.2),
    "level-up.mp3": ("https://freesound.org/s/433701/", 0.0, 1.19),
    "party-blower.mp3": ("https://freesound.org/s/140095/", 0.0, 2.58),
    "podium.mp3": ("https://freesound.org/s/867573/", 154.6, 6.5),
    "referee-whistle.mp3": ("https://bigsoundbank.com/whistle-plastic-2-s1105.html", 18.3, 2.0),
    "sad-trumpet.mp3": ("https://freesound.org/s/543966/", 0.0, 4.0),
    "victory.mp3": ("https://freesound.org/s/466133/", 0.0, 7.0),
}


def run(*args: str) -> str:
    result = subprocess.run(args, check=True, text=True, capture_output=True)
    return result.stdout.strip()


def generic_audio_from_page(url: str, work: Path) -> Path:
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 ShakeCheer/1.0"})
    html = urllib.request.urlopen(request, timeout=30).read().decode("utf-8", "ignore")
    matches = re.findall(r"(?:src|href)=[\"']([^\"']+\.(?:wav|mp3)(?:\?[^\"']*)?)[\"']", html, re.I)
    if not matches:
        raise RuntimeError(f"No downloadable audio found at {url}")
    absolute = urllib.parse.urljoin(url, matches[0])
    target = work / Path(urllib.parse.urlparse(absolute).path).name
    req = urllib.request.Request(absolute, headers={"User-Agent": "Mozilla/5.0 ShakeCheer/1.0"})
    with urllib.request.urlopen(req, timeout=60) as response, target.open("wb") as handle:
        shutil.copyfileobj(response, handle)
    return target


def download_source(url: str, work: Path) -> Path:
    template = str(work / "source.%(ext)s")
    try:
        output = run(
            "yt-dlp",
            "--no-playlist",
            "--no-progress",
            "--retries", "5",
            "--socket-timeout", "30",
            "-x",
            "--audio-format", "wav",
            "--audio-quality", "0",
            "-o", template,
            "--print", "after_move:filepath",
            url,
        )
        candidate = Path(output.splitlines()[-1])
        if candidate.is_file():
            return candidate
    except (subprocess.CalledProcessError, IndexError):
        pass
    return generic_audio_from_page(url, work)


def encode(source: Path, output: Path, start: float, duration: float) -> None:
    subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
            "-ss", f"{start:.2f}", "-i", str(source), "-t", f"{duration:.2f}",
            "-vn", "-ac", "1", "-ar", "44100",
            "-af", "loudnorm=I=-16:LRA=11:TP=-1.5",
            "-c:a", "libmp3lame", "-b:a", "64k",
            str(output),
        ],
        check=True,
    )
    if not output.is_file() or output.stat().st_size < 1000:
        raise RuntimeError(f"Invalid generated audio: {output}")


def main() -> None:
    RESOURCES.mkdir(parents=True, exist_ok=True)
    for filename, (url, start, duration) in SOURCES.items():
        with tempfile.TemporaryDirectory(prefix="shakecheer-audio-") as temp_dir:
            work = Path(temp_dir)
            print(f"Installing {filename} from {url}")
            source = download_source(url, work)
            output = RESOURCES / filename
            encode(source, output, start, duration)
            digest = hashlib.sha256(output.read_bytes()).hexdigest()[:16]
            print(f"  {filename}: {output.stat().st_size} bytes sha256={digest}")

    missing = [name for name in SOURCES if not (RESOURCES / name).is_file()]
    if missing:
        raise SystemExit(f"Missing generated user audio: {missing}")
    print(f"Installed {len(SOURCES)} user-selected ShakeCheer sounds")


if __name__ == "__main__":
    main()
