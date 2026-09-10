# Smash Drop MVP — One-shot vertical slice

A complete colorful 3D casual physics-puzzle MVP built in **Godot 4.7.2**.

## What is included
- 20 playable handcrafted levels
- 4 themed worlds: Meadow, Coast, Ice, Sunset
- Toy-like 3D cannon model built in-engine
- Wood, Stone and Ice material families
- Wood, Stone, Fire and Wild ammo
- Visible projectile flight, muzzle flash, impact bursts and camera shake
- Real rigid-body collapse and chain reactions
- Material-specific break debris; ground impact destroys fallen blocks
- Balls disappear and count toward completion when they reach the ground
- Limited ammo and delayed fail check so the final shot can finish a chain reaction
- 1–3 star scoring based on shot efficiency
- Home, level select, HUD, pause, win and fail screens
- Local level/star progression save
- Original procedural SFX and lightweight music loop
- Audited CC0 KayKit scenery/crate geometry bundled locally
- GitHub Actions parser check + startup smoke test + Web export + Pages deploy

## Core loop
Observe the stack → choose ammo → shoot the right support → watch physics collapse the structure → drop every ball to the ground before ammo runs out.

## Run
1. Install Godot 4.7.2 stable.
2. Open `project.godot`.
3. Run the project.
4. Mouse clicks emulate mobile touch.

## Web preview
Pushes to `main` run the full CI gate and deploy to GitHub Pages.

## MVP acceptance target
Validate whether smart support shots plus readable material counters create a satisfying chain-reaction puzzle loop worth scaling beyond 20 levels.
