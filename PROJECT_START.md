# Rooster Warrior — Project Start

## Goal
Build a Roblox action game called **Rooster Warrior**.

The game is inspired by the absurd heroic energy of a rooster fighting giant demons and protecting civilians. The gameplay should feel fast, readable, dramatic, and fun early in development.

## Development approach
We are building this in **VS Code + Codex** and moving forward in small playable milestones.

Current approach:
- Keep gameplay readable and fun first
- Stabilize what already exists before adding more systems
- Keep code simple, modular, and beginner-friendly
- Prefer a working playable slice over overengineering

## Tech assumptions
- Language: **Luau**
- Editor: **VS Code**
- Roblox workflow: file-based project structure compatible with **Rojo**
- Target platform first: PC
- Future target platform: Xbox / controller support

## Main game fantasy
The player is a fearless rooster warrior who:
- runs into danger
- fights giant demons
- protects innocent people
- feels small but powerful
- becomes stronger over time

## Narrative foundation
The game now has a defined story direction centered on:
- `Suncrest Village` as the opening area
- `Kijuu` as corruption-born monsters tied to fear, anger, greed, and despair
- the lost `Rooster Warriors` order as the heroic bloodline behind the player
- Chapter 1 focused on village defense, black mist corruption, villager rescues, and the `Mistfang Kijuu` mini-boss

Canonical lore text lives in `src/ReplicatedStorage/Config/GameLore.lua`.
Implementation planning for turning that story into quests and chapter progression lives in `GAME_LORE_PLAN.md`.

## Core prototype loop
1. Player spawns
2. Demon appears
3. Demon chases player
4. Player attacks demon
5. Demon attacks player
6. Demon dies
7. Demon respawns
8. Repeat

## Status snapshot
This repo is no longer at the "starting from scratch" stage.

### Implemented so far
- Base playable combat loop
- `Peck` and `Scratch` attacks with client feedback and server hit detection
- Demon hit flash, hit VFX, knockback, and hit confirm feedback
- Multiple demon types instead of a single `DemonDummy`
- Demon chase AI, melee attacks, death burst, and respawn flow
- Demon health bars
- Wave progression system
- Character selection with rooster morphs
- Upgrade system using feathers
- Mission tracking and rewards
- Civilian spawning / possession-related systems
- Player health UI, wave UI, mission UI, upgrade UI, and feather UI
- Rojo-compatible project structure and synced remotes in `default.project.json`

### Important note
The original prototype brief has been exceeded in several areas. The plan from this point should focus on stabilizing and organizing the current game slice before adding major new features.

## Current scope
Treat the current game as a **vertical slice in progress**, not a blank prototype.

### In active scope now
- Tighten the combat feel
- Make wave progression reliable
- Make current UI and rewards readable
- Keep the rooster morph / character choice working
- Improve beginner-friendly structure where the code has grown messy
- Test the full loop in Roblox Studio and fix rough edges

### Out of scope for the next milestone
- Open world expansion
- Boss fights
- Multiplayer complexity
- Large content expansion
- Major monetization systems
- Save-data expansion beyond what already exists
- Final polish pass across every UI surface

## Updated milestone plan

### Milestone 1: Stabilize the current vertical slice
Goal: make the existing systems consistently playable from spawn through several waves.

Tasks:
- Verify the full loop from spawn to combat to wave clear to next wave
- Confirm all remotes and UI scripts are wired correctly in Studio
- Check that character select, upgrades, missions, and rewards all work together
- Remove or simplify anything that creates confusion during the first 5 minutes of play
- Fix naming drift where practical, or document it clearly where changing it would be risky

### Milestone 2: Clean up code and project structure
Goal: make the project easier to maintain and safer to extend.

Tasks:
- Separate prototype-critical systems from optional systems
- Reduce duplicated combat and character tuning data where possible
- Add clear script responsibilities and short setup notes
- Review server scripts for responsibilities that have grown too large

### Milestone 3: Improve the first-time player experience
Goal: make the game readable and fun without needing explanation.

Tasks:
- Improve onboarding and immediate clarity of controls
- Improve combat readability, enemy readability, and progression feedback
- Tune wave pacing, reward pacing, and difficulty spikes
- Polish the map enough to support the current systems cleanly

### Later milestones
- Civilian rescue gameplay that matters to the main loop
- Boss encounters
- Broader map / world expansion
- More rooster characters and progression depth
- Controller-focused polish
- Final presentation pass

## Immediate next step
The next milestone is **Milestone 1: Stabilize the current vertical slice**.

Start by testing and validating these systems together:
- Attack flow
- Demon spawning and respawning
- Wave progression
- Mission progress
- Feather rewards and upgrades
- Character select / morph behavior

If something breaks during that pass, fix reliability before adding new content.

## Code quality rules
When generating code:
- Always provide complete scripts, not partial fragments, unless explicitly asked
- Always say exactly where each script belongs
- Keep code easy to read
- Use short useful comments only
- Avoid giant systems and unnecessary abstractions
- Prefer feature-by-feature implementation
- If replacing an older script, say so clearly
- If creating Explorer objects, list them clearly
- Keep naming consistent

## Naming conventions
Use these names unless there is a strong reason to change them:
- RemoteEvent: `RoosterAttack`
- Enemy model: `DemonDummy` was the original prototype target, but the current repo uses multiple demon names such as `RedDemon`, `BlueDemon`, `GreenDemon`, `PurpleDemon`, and `WhiteDemon`
- Client attack script: `RoosterAttackClient`
- Server combat script: `RoosterCombatServer`
- Demon AI script: `DemonAIServer`
- Demon health bar script: `DemonHealthBar`

## Recommended project structure
Use a simple Roblox project structure like this:

```text
default.project.json
src/
  ReplicatedStorage/
    Remotes/
      RoosterAttack.remote.json
  ServerScriptService/
    RoosterCombatServer.server.lua
    DemonAIServer.server.lua
    DemonHealthBar.server.lua
  StarterPlayer/
    StarterPlayerScripts/
      RoosterAttackClient.client.lua
```
