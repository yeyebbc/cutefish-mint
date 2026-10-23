# Cutefish for Linux Mint 22

An unofficial Ubuntu 24.04 (Noble), amd64 build of the current Cutefish desktop.
All compilation and Debian packaging run on GitHub Actions. Upstream is
[cutefishos](https://github.com/cutefishos); this repository adapts its
[packaging](https://github.com/cutefishos/packaging).

## Install

Use a successful [GitHub release](https://github.com/yeyebbc/cutefish-mint/releases).
Download `cutefish-mint22-amd64.tar.xz` and `SHA256SUMS` into the same directory:

```sh
sha256sum --ignore-missing --check SHA256SUMS
mkdir cutefish-mint22
tar -xJf cutefish-mint22-amd64.tar.xz -C cutefish-mint22
cd cutefish-mint22
bash install.sh
```

The installer checks the OS, CPU architecture, package checksums, and Wayland
version. It previews the APT transaction and refuses package removals. APT asks
for confirmation before installing. Log out and choose **Cutefish (Wayland)** at
the login screen. Choose **Cinnamon** there to return to your existing desktop.
Run `bash install.sh --check` for a read-only dependency simulation without sudo.

Target: Linux Mint 22.x / Ubuntu 24.04, amd64, with Wayland >= 1.23. The intended
Mint 22.3 machine already has `1.24.0-2~24.04.1` from the `3v1n0/gamescope` PPA.
CI uses that exact backport and pins the PPA to Wayland packages only. The
installer does not add repositories or replace the system's Wayland packages.
A stock Noble installation with Wayland 1.22 does not meet this prerequisite.

## What is included

The compositor, session services, toolkit, framework, file manager, settings,
terminal, calculator, calendar, text editor, video player, system monitor,
desktop portal, Qt integration, icons, and wallpapers. `expected-packages.txt`
defines the complete bundle and is checked before publication.

The existing login manager and X11 default session are retained. The standalone
Cutefish display manager, disk/OS installer, and optional agent-control server
are not included. Desktop selection is provided by the existing login screen.

Noble adaptations include JPEG XL 0.7, Qt 6.4, PipeWire 1.0, libssh 0.10,
kernel headers, keyboard constants, and the appropriate runtime package names.
Qt applications may need restarting after a cursor-theme change with Qt 6.4.
SFTP transfers use libssh's synchronous API on Noble.
Sources are pinned in `sources.lock`; source patches live beside
the Debian packaging. Each release includes Debian source packages and build
metadata, preserving upstream copyright and licensing information.

## Validation

The workflow builds inside Ubuntu 24.04 containers, builds the desktop components
after the shared foundation, then installs the complete bundle in a fresh
Ubuntu 24.04 container with LightDM and Cinnamon session packages. It checks
dependencies, missing shared libraries, session files, a real Wayland client
connecting to the headless compositor, and preservation of the login manager
and default session. A release is created only after these checks
pass. Existing component tests run where enabled by upstream packaging.

This is a prerelease port. CI cannot establish that a real GPU, monitor layout,
or interactive login works on the target PC. Those need a desktop session test.

## Rebuild

Run **Build Mint packages** in the Actions tab. Pushes to `main` also build.
There is no scheduled build. The workflow needs the standard GitHub Actions
token; only the final verified-release job has repository contents write access.
Skia compiler outputs are cached to make fixes less expensive to rebuild.

To remove the added desktop, first log into Cinnamon, then review and run:

```sh
sudo apt-get remove $(awk '{print $1}' PACKAGES.txt)
```

APT leaves shared dependencies installed. Review any later `autoremove`
transaction separately.
