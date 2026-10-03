# Invisible Backpack Fix

**Dead AI drop a pile of invisible backpacks. This stops that.**

Every AI in Road to Vostok carries one of each backpack model, hidden. When an AI spawns, only about 1 in 20 actually
gets a backpack: the game shows that one and deletes the others. For everyone else it does nothing, so all the hidden
backpacks stay on them. When the AI dies, the game switches every backpack it carries into a physical, lootable item,
visible or not. That's where the stack of invisible backpacks on a body comes from.

This mod removes the unused hidden backpacks as soon as an AI spawns without one (the same thing the game already
does when an AI does get a backpack), and clears any leftovers right before death. AI that really wear a backpack
still drop it like normal.

It also fixes worn backpacks disappearing into the ground. The game welds the backpack to the body as a frozen item
that the ragdoll doesn't know about, so a body that falls backward pushes it into the floor where you can't reach it.
The mod makes the backpack part of the ragdoll instead: the backpack stays on the body, and a body that falls on its
back lies on top of it, like you'd expect.

## More backpacks, by faction

In vanilla only about 1 in 20 AI carries a backpack. With this mod **1 in 4** do, and what they carry depends on who
they are:

- **Bandits and Nomads:** low-tier. Duffel bags and Nomad backpacks, sometimes a Patrol backpack.
- **Guards:** mostly Patrol and Jaeger backpacks, occasionally something else.
- **Military:** mostly Jaeger and Kantamus backpacks, sometimes a Patrol backpack.

The mod makes the choice itself, so every AI ends up with exactly one visible backpack or none.

To change how often AI carry one, edit `%APPDATA%\Road to Vostok\rtv_backpackfix.cfg` (created on first launch):

```
[backpacks]
chance_percent=25.0
```

Set it to `5.0` for the vanilla rate.

## Download

Get `InvisibleBackpackFix.vmz` from the [Releases](https://github.com/mmmMelted/invisible-backpack-fix/releases) page (or
build it yourself with `python build.py`).

## Requirements

- Road to Vostok Build 2 ("Nomads", v0.2.0.0), Godot 4.6.3.
- [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) v3.4.1 or newer.

## Install

Drop `InvisibleBackpackFix.vmz` into `Road to Vostok/mods/` and make sure it's checked in the loader window.
Uninstall: delete the file (or uncheck it).

## Compatibility

Single player. Doesn't touch your save. Works alongside other AI mods; it only runs right after the game's own
backpack roll and right before an AI dies.

## Troubleshooting

The log is at `%APPDATA%\Road to Vostok\logs\godot.log` (written when the game closes). Look for
`[InvisibleBackpackFix] v1.3.2 loaded` and a line saying how many AI got a backpack when the map loaded.

## Credits

- Mod by **mmmMelted** ([github.com/mmmMelted](https://github.com/mmmMelted)).
- Built on [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) by ametrocavich (RTVModLib hooks).
- Made with AI assistance: diagnosed and written with Claude Code (Anthropic, Claude Opus 5.5), tested by mmmMelted.
- No game files or assets are included.

## License

MIT, see `LICENSE` (in the mod folder).
