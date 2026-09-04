#!/usr/bin/env python3
"""Install the user-selected ShakeCheer audio pack before XcodeGen.

The selected source recordings were trimmed and normalized offline, then stored
as one repository archive. This script intentionally does not synthesize or
redownload replacement sounds: TestFlight/App Store builds use the exact
processed selections approved for this pass.

Three uploaded replacements are intentionally not extracted for commercial
builds: the volleyball crowd/drum recording is CC BY-NC 4.0, while the uploaded
coin and party-blower licences were not verified strongly enough for release.
The existing documented CC0 versions of `drum-crowd.mp3`, `coin.mp3` and
`party-blower.mp3` therefore remain active.
"""

from __future__ import annotations

import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "Resources"
PACK = ROOT / "scripts" / "assets" / "user-selected-audio.zip"

EXPECTED = {
    "air-horn.mp3",
    "boo.mp3",
    "cheer-crowd.mp3",
    "crowd-disappointment.mp3",
    "crowd-hey.mp3",
    "fail-buzzer.mp3",
    "game-over.mp3",
    "laugh-track.mp3",
    "level-up.mp3",
    "podium.mp3",
    "referee-whistle.mp3",
    "sad-trumpet.mp3",
    "victory.mp3",
}


def main() -> None:
    if not PACK.is_file():
        raise SystemExit(f"Missing user-selected audio pack: {PACK}")

    RESOURCES.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(PACK) as archive:
        names = {Path(name).name for name in archive.namelist() if not name.endswith("/")}
        missing = EXPECTED - names
        if missing:
            raise SystemExit(f"Audio pack is incomplete: {sorted(missing)}")

        for filename in sorted(EXPECTED):
            with archive.open(filename) as source:
                (RESOURCES / filename).write_bytes(source.read())

    empty = [name for name in EXPECTED if (RESOURCES / name).stat().st_size == 0]
    if empty:
        raise SystemExit(f"Empty audio files after extraction: {empty}")

    print(f"Installed {len(EXPECTED)} user-selected ShakeCheer sounds")
    print("Retained existing CC0 drum-crowd.mp3, coin.mp3 and party-blower.mp3")


if __name__ == "__main__":
    main()
