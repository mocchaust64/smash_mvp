# One-shot MVP QA gate

Automated gate:
- Godot editor import/parse succeeds (including bundled OBJ assets and SVG UI)
- headless startup smoke test stays alive without script errors
- Web release export succeeds

Gameplay acceptance:
- 20 levels are selectable/unlock sequentially
- only gameplay blocks receive shots; UI/ground/tray do not steal taps
- correct ammo destroys a target; wrong ammo consumes the shot and gives clear feedback
- destroying a support wakes the stack and produces physics-driven collapse
- blocks that reach the ground break into debris and disappear
- balls reaching the ground disappear and count toward victory
- the final shot receives a settle window before fail is decided
- pause/restart/home/next paths work
- stars + unlocked levels persist through reloads
- mouse and touch both work

Visual acceptance:
- cannon, ammo crates, tray and environment are visible in the first frame
- Wood/Stone/Ice are distinguishable without reading labels
- KayKit CC0 rock/tree/crate geometry is present at runtime
- four worlds have visibly distinct palettes/background dressing
- impact, muzzle flash, debris, camera shake, chain text and victory confetti are present
