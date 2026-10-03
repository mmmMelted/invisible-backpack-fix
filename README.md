# Invisible Backpack Fix

**Fixes the backpack bugs on dead AI in Road to Vostok.**

- **No more invisible backpacks.** Bodies only drop the backpack you can actually see, not a pile of hidden ones.
- **Backpacks have collision.** A backpack stays on the body instead of sinking into the ground, so you can always
  loot it.
- **Bodies settle properly.** Take the backpack and the body drops back down to the ground instead of floating.
- **More backpacks.** About 1 in 4 AI now carry one (vanilla is 1 in 20):
  - **Bandits and Nomads:** cheap bags (Duffel bags, Nomad backpacks, sometimes a Patrol backpack).
  - **Guards:** mostly Patrol and Jaeger backpacks.
  - **Military:** mostly Jaeger and Kantamus backpacks.

Bosses are left alone.

## Settings

Want vanilla backpack rates? Edit `%APPDATA%\Road to Vostok\rtv_backpackfix.cfg` (created on first launch) and set
`chance_percent` to `5`:

```
[backpacks]
chance_percent=25.0
```

## Download

Get `InvisibleBackpackFix.vmz` from the [Releases](https://github.com/mmmMelted/invisible-backpack-fix/releases) page (or
build it yourself with `python build.py`).

## Requirements

- Road to Vostok Build 2 ("Nomads", v0.2.0.0).
- [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) v3.4.1 or newer.

## Install

Drop `InvisibleBackpackFix.vmz` into `Road to Vostok/mods/` and check it in the loader window.
To uninstall, delete the file (or uncheck it).

## Compatibility

Single player. Safe for existing saves. Works alongside other AI mods.

## Troubleshooting

The log is at `%APPDATA%\Road to Vostok\logs\godot.log` (written when the game closes). Look for
`[InvisibleBackpackFix] v1.4.0 loaded`.

## Credits

- Mod by **mmmMelted** ([github.com/mmmMelted](https://github.com/mmmMelted)).
- Built on [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) by ametrocavich (RTVModLib hooks).
- Made with AI assistance: diagnosed and written with Claude Code (Anthropic, Claude Opus 5.5), tested by mmmMelted.
- No game files or assets are included.

## License

MIT, see `LICENSE` (in the mod folder).
