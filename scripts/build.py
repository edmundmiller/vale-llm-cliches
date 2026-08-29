#!/usr/bin/env python3
"""Build a reproducible Vale package archive."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

SOURCE = Path("package/LLMCliches")
OUTPUT = Path("build/LLMCliches.zip")
TIMESTAMP = (1980, 1, 1, 0, 0, 0)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(OUTPUT, "w", ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sorted(item for item in SOURCE.rglob("*") if item.is_file()):
            name = Path("LLMCliches") / path.relative_to(SOURCE)
            info = ZipInfo(name.as_posix(), TIMESTAMP)
            info.compress_type = ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes(), compresslevel=9)


if __name__ == "__main__":
    main()
