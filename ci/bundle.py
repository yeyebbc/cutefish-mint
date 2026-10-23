#!/usr/bin/env python3
"""Assemble binaries, checksums, exact source revisions and installation notes."""
import hashlib
import pathlib
import shutil
import subprocess

root = pathlib.Path.cwd()
bundle = root / "bundle"
(bundle / "debs").mkdir(parents=True, exist_ok=True)
for package in sorted((root / "artifacts").rglob("*.deb")):
    if "-dbgsym_" not in package.name and "build-deps" not in package.name:
        target = bundle / "debs" / package.name
        if target.exists() and target.read_bytes() != package.read_bytes():
            raise RuntimeError(f"Conflicting package: {package.name}")
        shutil.copy2(package, target)
for name in ("install.sh", "README.md", "sources.lock"):
    shutil.copy2(root / "packaging" / name, bundle / name)
packages = []
for path in sorted((bundle / "debs").glob("*.deb")):
    packages.append(subprocess.check_output(
        ["dpkg-deb", "--show", "--showformat=${Package} ${Version} ${Architecture}\n", str(path)], text=True))
(bundle / "PACKAGES.txt").write_text("".join(packages))
expected = {line.split()[0] for line in (root / "packaging" / "expected-packages.txt").read_text().splitlines() if line}
actual = {line.split()[0] for line in packages}
if expected != actual:
    raise RuntimeError(f"Missing {expected - actual}; unexpected {actual - expected}")
files = sorted(p for p in bundle.rglob("*") if p.is_file() and p.name != "SHA256SUMS")
(bundle / "SHA256SUMS").write_text("".join(
    f"{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.relative_to(bundle)}\n" for p in files))
