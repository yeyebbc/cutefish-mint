# Mint desktop refinements

- [x] Restore the Cutefish logo in the top-left system menu.
- [x] Add persistent weight selectors for every font category in Settings → Appearance → Fonts.
- [x] Make dock spacing compact while preserving icon size and usable click targets.
- [x] Use a flat, translucent menu-bar tint in light and dark appearance, without a gradient.
- [x] Prefer existing configuration; keep required patches small and separate from upstream sources.
- [ ] Verify settings persistence, rendering, and existing desktop behavior in GitHub CI.
- [ ] Publish the tested upgrade and check its APT transaction on Mint.

Keep existing user preferences. Document any new optional configuration keys and
the reason for each downstream patch so upstream updates remain straightforward.
