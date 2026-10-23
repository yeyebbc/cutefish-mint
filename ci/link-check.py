#!/usr/bin/env python3
"""Check every installed ELF payload, including plugins and service helpers."""
from pathlib import Path
import subprocess

packages = [line.split()[0] for line in Path("PACKAGES.txt").read_text().splitlines()]
paths = subprocess.check_output(["dpkg-query", "--listfiles", *packages], text=True)
checked = 0
for name in sorted(set(paths.splitlines())):
    path = Path(name)
    if not path.is_file() or path.is_symlink():
        continue
    with path.open("rb") as stream:
        if stream.read(4) != b"\x7fELF":
            continue
    result = subprocess.run(["ldd", str(path)], text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    if "not found" in result.stdout:
        raise RuntimeError(f"Unresolved runtime library in {path}:\n{result.stdout}")
    if result.returncode and "not a dynamic executable" not in result.stdout:
        raise RuntimeError(f"Cannot check {path}:\n{result.stdout}")
    checked += 1
if not checked:
    raise RuntimeError("No ELF payloads found")
print(f"Runtime dependencies resolved for {checked} ELF executables and libraries.")
