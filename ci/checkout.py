#!/usr/bin/env python3
"""Check out exactly the upstream revisions recorded in sources.lock."""
import pathlib
import subprocess
import sys

packaging = pathlib.Path(__file__).resolve().parents[1]
sources = dict(line.split() for line in (packaging / "sources.lock").read_text().splitlines()
               if line and not line.startswith("#"))
projects = sys.argv[1:] or list(sources)
for project in projects:
    if project == "cutefish-desktop":
        continue
    revision = sources[project]
    target = packaging.parent / project
    target.mkdir(exist_ok=True)
    subprocess.run(["git", "init", "--quiet", str(target)], check=True)
    subprocess.run(["git", "-C", str(target), "fetch", "--quiet", "--depth", "1",
                    f"https://github.com/cutefishos/{project}.git", revision], check=True)
    subprocess.run(["git", "-C", str(target), "checkout", "--quiet", "--detach", "FETCH_HEAD"], check=True)
    actual = subprocess.check_output(["git", "-C", str(target), "rev-parse", "HEAD"], text=True).strip()
    if actual != revision:
        raise RuntimeError(f"Unexpected revision for {project}: {actual}")
    print(f"{project} {revision}", flush=True)
