# Mint appearance patches

All upstream repositories remain pinned and unmodified. Debian quilt applies the
patches in this repository during GitHub Actions builds.

## Shell appearance

`debian/cutefish-compositor/debian/patches/mint-shell-appearance.patch`:

- Shows the existing Cutefish logo while the account image is missing, loading,
  or undecodable. A valid account photo still takes its place.
- Uses the existing dock geometry calculation, with compact gaps and padding.
  Icon size, pins, direction, visibility, and glass tint remain user preferences.
- Gives the menu bar a uniform translucent tint with blur in light and dark
  appearance. The wallpaper's compensating gradient is suppressed.

The two additions to `~/.config/cutefish/shell.conf` are optional and default
to `true`. Set either to `false` to restore that part of upstream styling.
Merge these keys into existing sections; do not replace the file:

```ini
[Dock]
CompactSpacing=true

[Statusbar]
FlatBackground=true
```

These switches are read at login. No maintainer script rewrites user settings.

## Font weights

The small `font-weights.patch` files extend the existing appearance service,
client, toolkit, Settings page, Qt integration, shell, and text editor. The
Settings page reuses its existing list rows and combo boxes.

General and fixed fonts each offer Thin (100) through Black (900). The default
is Regular (400). Values live alongside the existing font families:

```ini
# ~/.config/cutefish/services.conf — normally written by Settings
[Appearance]
FontWeight=400
FixedFontWeight=400
```

The appearance service validates requests, saves changes, and sends notifications.
Native default text and Qt platform fonts use the numeric weights; GTK receives
Pango font descriptions through the existing settings bridge. Applications with
their own font preferences can override desktop defaults, and some applications
need restarting. Fonts without a requested weight use their renderer's nearest
available face. Explicit emphasis in native controls remains explicit.

Adding weight to the toolkit's Theme and FontSpec changes their binary layout.
All known consumers are rebuilt, versioned, and constrained to upgrade together;
install the complete bundle and log out/back in before continuing the session.

## Upstream sync and validation

1. Update `sources.lock` and check each quilt series still applies.
2. Keep the shell styling patch separate from font support and Noble API fixes.
3. If upstream adds equivalent support, drop the matching patch and preserve the
   saved keys or provide a migration. Revisit the coordinated ABI constraints
   when changing the toolkit structures again.
4. Run the GitHub workflow. It checks native rendered text, independent Settings
   selections over D-Bus, Qt settings reloads, missing/valid account images,
   flat and upstream menu-bar modes, dock geometry, and the existing cursor tests.
5. The clean-install job changes font weights through the packaged service,
   verifies GTK/config files, restarts the service to check persistence, and
   checks package linking and the headless calculator. Preview artifacts show
   the Fonts page at 1×/2× and menu-bar elements in both appearances.

The live Mint session and real GPU appearance still need the final login check.
