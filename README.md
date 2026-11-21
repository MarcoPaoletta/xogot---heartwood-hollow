# Heartwood Hollow

A cozy third person narrative adventure in one giant forest, built for Xogot video 10 (Xogot x Letta Corporation). Wren, a young courier with a brass lantern and a wooden sword, walks into the Great Wood to find out why the Heartseed went dark. Raise the lantern to calm monsters, bonk the grumpy ones, and make three choices that change the forest, the village and the ending.

- **Engine:** [Xogot for Mac](https://xogot.com/mac) 4.8 (Godot 4.8), Mobile renderer. The base project is stamped 4.7; Xogot converts it once on the first open.
- **Builder:** Gemini 4 Neon at its maximum effort in Google Antigravity, driving Xogot for Mac and Xogot Modeler through Xogot's `xo` command line (including `xo modeler`).
- **Models:** the hero assets (sword, lantern, rocks, trees, capelet, the Heartwood, the Heartseed, the bridge, the honey pot, the shield) are modeled inside this project with Xogot Modeler. Characters, monsters and supporting props come from free CC0 packs.

## State

This commit is the starting point (tag `setup-finished`): empty project, packs imported, GDD. No gameplay yet. The game is built on top of it, one commit per step of the GDD build order.

## Controls (from the GDD)

WASD move, Shift toggles walk, mouse orbits the camera, hold right mouse to raise the lantern, left mouse swings the sword, E talks, M mutes, F1 to F4 presenter tools.

## How the GDD was created

The full spec is `docs/GDD.md` (PDF in `docs/GDD.pdf`, concepts in `docs/concept/`). It was written by Letta Corporation before the build:

1. Start from what exists: the packs are imported first, so every pack object the GDD names is a real file.
2. Behaviour with numbers, never code.
3. An acceptance test per pillar and per non-trivial mechanic.
4. Scope written down: what is not built, a numbered build order where each step ends with a run, a screenshot check and a commit.
5. Versioned after each round of play by adding a superseding section; the first build is one prompt (`docs/KICKOFF_PROMPT.md`).
6. Iterate with screenshots, and the agent takes its own through `xo` before reporting back.

## Repo layout

`assets/quaternius/`, `assets/kenney/` third-party CC0 packs; `assets/audio/` CC0 music and effects; `assets/fonts/candidates/` OFL fonts; `assets/modeler/` Xogot Modeler assets (built in the game); `scenes/`, `scripts/`, `tests/`; `docs/` GDD, concepts, logs.

## License

Code and project-authored content: MIT (`LICENSE`). Third-party assets keep their own licenses: see `THIRD_PARTY_NOTICES.md`.

## Credits

Quaternius and Kenney (CC0 models and sounds), OpenGameArt composers listed in `docs/AUDIO_LICENSES.md`, Google Fonts (OFL), Xogot by Xibbon, made by [Letta Corporation](https://www.youtube.com/@lettacorporation).
