# AGENTS.md: Heartwood Hollow

Read this whole file before you touch the project. It applies to every agent (Antigravity, Codex, Claude or any other).

## What this is

Heartwood Hollow, a cozy third person narrative adventure in one giant forest: Wren, a courier with a brass lantern and a wooden sword, four zones, two decisions with two branches each, three endings. It is Xogot video 10 (Xogot x Letta Corporation).

- **Engine: Xogot for Mac 4.8 (Godot 4.8), Mobile renderer, macOS.** The base project was prepared stamped `4.7` (`config/features` in `project.godot`) because no stable Godot 4.8 build existed to validate it on Windows. Xogot for Mac 4.8 converts it on the first open; accept that once and never change the version stamp again. Never open this project in a different desktop Godot.
- **Builder: Gemini 4 Neon at its maximum effort (Extra) in Google Antigravity** (personal account with Google AI Pro), driving Xogot for Mac and Xogot Modeler through Xogot's `xo` command line, `xo modeler` included. Antigravity reads Xogot's `xogot` skill from `.agents/skills/xogot/SKILL.md`, installed from Xogot on the Mac (Editor Settings > AI > External Agents, Codex, project scope; ignored by Git). Use only Xogot's own tools: no other editor bridge, MCP server or plugin.

## Read first, in this order

1. `skills/game-dev/SKILL.md` and the references it names: the game dev skill. It is a local, private copy that is never committed (see Privacy). On the Mac: `git -C ~/Skills/game-dev pull` and `python3 ~/Skills/game-dev/install_to_project.py "<this project>"`.
2. `docs/GDD.md`: the build contract (the PDF is `docs/GDD.pdf`, the concepts are in `docs/concept/`, one reference crop per Modeler asset in `docs/concept/refs/`). Where the GDD and the skill differ, the GDD wins.
3. `.agents/skills/xogot/SKILL.md`: every `xo` command, including `xo modeler`.

The kickoff prompt is `docs/KICKOFF_PROMPT.md`: read the GDD and the skill, then build the complete game.

## The models of the game come from Xogot Modeler

- The ten hero assets of GDD Section 1.5 (sword, lantern, rocks, trees, capelet, the Heartwood, the Heartseed and Pip's shard, the bridge, the honey pot, the guard's shield) and the level geometry of Section 1.7 (paths, riverbanks, the ruins plaza) are modeled by you, in this project, with **Xogot Modeler**, into `assets/modeler/`. Never import, download, generate with another tool or script those meshes, and never substitute a pack model, not even temporarily.
- Every Modeler problem goes to `docs/MODELER_LOG.md` (Issues section, at the top) the moment it happens and to the chat as one line starting with `MODELER ISSUE:`. Joseph at Xogot asked to hear about them right away.
- The packs are only the supporting cast: characters, monsters, ground cover, ruins, village and camp pieces. Models of Modeler categories (trees, rocks, weapons, shields, lanterns, torches, pots, bottles, crystals, bridges) were removed from the packs at setup on purpose.

## What is already in the project (setup, 2026-11-21)

- `assets/quaternius/`: CC0 packs, measured in `docs/MEASUREMENTS.md` (size, bottom, triangles, bones, clips, traps). Each pack keeps its license file. Scales and tints go on instances, never on the source files or their import settings.
- `assets/audio/`: CC0 music and ambience, plus original effects and stingers synthesized by `tools/audio/make_sfx.py`. Roles and sources in `docs/AUDIO_LICENSES.md`.
- `assets/fonts/candidates/`: three OFL fonts to try in the dialogue box (GDD Section 8.1).
- Empty `scenes/`, `scripts/`, `tests/`, `assets/modeler/` folders and no main scene: the build starts from zero.
- `docs/MODELER_LOG.md` with its sections, ready to fill.

## Repo rules

- Public repo, MIT license with third-party assets under their own licenses (`LICENSE`, `THIRD_PARTY_NOTICES.md`). Add a row to `THIRD_PARTY_NOTICES.md` and `docs/AUDIO_LICENSES.md` for anything third-party you add.
- One commit per milestone of the GDD build order (Section 16), message says what the step was, no AI attribution lines. Each version of the game: commit, annotated tag `vN` and branch `vN`, all pushed.
- `docs/GDD.md` is versioned in place: later rounds add a superseding section, never a rewrite.
- The tag `setup-finished` marks the empty starting state. Do not move it.

## Privacy (hard rule)

`skills/` holds a private skill. It is ignored by Git and must never be committed, pushed, exported or packaged. Also ignored: `.godot/`, `.agents/`, builds, logs and credentials. Before every commit run `git status` and confirm nothing under `skills/` is staged.
