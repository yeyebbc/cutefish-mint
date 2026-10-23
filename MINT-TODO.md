# Mint desktop refinements

- [x] Restore the Cutefish logo in the top-left system menu.
- [x] Add persistent weight selectors for every font category in Settings → Appearance → Fonts.
- [x] Make dock spacing compact while preserving icon size and usable click targets.
- [x] Use a flat, translucent menu-bar tint in light and dark appearance, without a gradient.
- [x] Prefer existing configuration; keep required patches small and separate from upstream sources.
- [x] Verify settings persistence, rendering, and existing desktop behavior in GitHub CI.
- [x] Publish the tested upgrade and check its APT transaction on Mint.

Keep existing user preferences. Document any new optional configuration keys and
the reason for each downstream patch so upstream updates remain straightforward.

Verified release: [mint22-13](https://github.com/yeyebbc/cutefish-mint/releases/tag/mint22-13).
The [final CI run](https://github.com/yeyebbc/cutefish-mint/actions/runs/39986776546)
passed clean installation, runtime linking, font persistence, and the headless
application smoke test. Component build tests also passed, including the shell
appearance and cursor regression suites. Fonts previews were checked in light
and dark appearance at 1×/2×, and the flat menu-bar previews were checked.

On the target Mint 22.3 machine, all bundle checksums passed and the installer
simulation resolved 17 upgrades, zero new packages, and zero removals. The bundle
is ready for the user's installation and logout/login check on the real GPU.
