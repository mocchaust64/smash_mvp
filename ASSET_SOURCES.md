# Asset & license manifest

Smash Drop MVP ships with a small audited subset of **CC0 3D geometry** plus original in-engine gameplay art. The external models are bundled in the repository, so the game has no network/runtime dependency.

## KayKit — Prototype Bits 1.0
- Author: Kay Lousberg / KayKit
- Source: https://github.com/KayKit-Game-Assets/KayKit-Prototype-Bits-1.0
- License: Creative Commons Zero (CC0 1.0 Universal)
- Commercial use: allowed
- Attribution: not required
- Runtime asset used: `assets/vendor/kaykit/Box_A.obj`
- Use in game: stylized ammo/crate dressing around the cannon area

## KayKit — Medieval Hexagon Pack 1.0
- Author: Kay Lousberg / KayKit
- Source: https://github.com/KayKit-Game-Assets/KayKit-Medieval-Hexagon-Pack-1.0
- License: Creative Commons Zero (CC0 1.0 Universal)
- Commercial use: allowed
- Attribution: not required
- Runtime assets used:
  - `assets/vendor/kaykit/rock_single_A.obj`
  - `assets/vendor/kaykit/tree_single_A.obj`
- Use in game: low-poly scenery in Meadow, Coast, Ice and Sunset worlds

The source OBJ files were reduced to geometry/normals only by removing upstream material/texture references. Shape data is retained; Smash Drop supplies its own palette so all worlds remain visually coherent and lightweight on mobile.

A copy of the relevant CC0 notice is kept at `assets/vendor/kaykit/LICENSE.txt`.

## Project-authored runtime art
- Cannon: custom toy-like 3D assembly in `scripts/cannon.gd`
- Wood/Stone/Ice gameplay blocks: custom readable material families in `scripts/block.gd`
- Balls/projectiles: custom 3D meshes
- Tray/world composition: custom Godot scene construction plus the audited KayKit scenery above
- UI icons: custom SVGs in `assets/ui/`
- App icon/splash: custom `assets/icon.svg`
- VFX: custom procedural hit bursts, debris, muzzle flash, confetti and camera shake
- SFX/music: generated procedurally at runtime by `scripts/audio_lab.gd`

## Rule for future additions
Only import assets with a clear commercial-use license. Keep the source URL/license in this file, normalize scale/materials, and avoid importing whole packs when only a few models are needed.
