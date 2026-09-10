# Smash MVP — Godot 4.7.2

A colorful 3D casual physics-puzzle MVP.

## Core loop
- Balls and material blocks are pre-stacked on a tray.
- Materials: Wood / Stone / Ice.
- Ammo: Wood / Stone / Fire + Wild.
- Tap a block with the matching ammo.
- Break the right support and let physics collapse the structure.
- Blocks that hit the ground break into debris and disappear.
- Balls that hit the ground disappear and count toward completion.
- Clear every ball before ammo runs out.

## Run locally
1. Install Godot 4.7.2 stable.
2. Open `project.godot`.
3. Run the project.
4. Mouse input emulates touch.

## Web preview
Pushes to `main` automatically parse and export the Godot Web build through GitHub Actions, then deploy it to GitHub Pages.

Expected Pages URL after Pages is enabled for this repository:
`https://mocchaust64.github.io/smash_mvp/`

## MVP art strategy
Gameplay uses replaceable primitive meshes first. Swap them for properly licensed low-poly assets without rewriting gameplay logic. Keep one shared toy-like material and lighting direction so third-party geometry still feels like one game.

See `ASSET_SOURCES.md` for the sourcing shortlist.
