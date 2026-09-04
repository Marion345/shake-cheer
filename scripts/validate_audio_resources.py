#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "ShakeCheer" / "SoundCatalog.swift"
RESOURCES = ROOT / "Resources"

text = CATALOG.read_text(encoding="utf-8")
refs = set(re.findall(r'AudioResource\(fileName: "([^"]+)", fileExtension: "([^"]+)"\)', text))
missing = []
for name, ext in sorted(refs):
    path = RESOURCES / f"{name}.{ext}"
    if not path.is_file() or path.stat().st_size == 0:
        missing.append(str(path.relative_to(ROOT)))
if missing:
    raise SystemExit("Missing or empty audio resources: " + ", ".join(missing))
print(f"Validated {len(refs)} catalog audio resources")
