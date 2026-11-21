# CLAUDE.md: Heartwood Hollow

Same rules as `AGENTS.md`, read it whole. In short:

- Engine: **Xogot for Mac 4.8 (Godot 4.8)**, Mobile renderer. The base project is stamped 4.7; Xogot converts it once on the first open. Never change the stamp after that.
- Read first: `skills/game-dev/SKILL.md` (local private copy, never committed), then `docs/GDD.md`, then Xogot's `xo` skill (`.agents/skills/xogot/SKILL.md`, or `.claude/skills/xogot/` if Xogot installed it for Claude).
- The game's hero models (GDD Section 1.5) and level geometry (Section 1.7) come from **Xogot Modeler**, built in this project. Never a pack model, a scripted mesh or another tool. Modeler problems go to `docs/MODELER_LOG.md` and to the chat with `MODELER ISSUE:` at once.
- Use only Xogot's own tools (`xo`, `xo modeler`). No other bridge, MCP server or plugin.
- `skills/` is never committed. Commits carry only the change description.
