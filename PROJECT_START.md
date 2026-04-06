# Rooster Warrior — Project Start

## Goal
Build a Roblox action game called **Rooster Warrior**.

The game is inspired by the absurd heroic energy of a rooster fighting giant demons and protecting civilians. The gameplay should feel fast, readable, dramatic, and fun early in development.

## Development approach
We are starting from scratch in **VS Code + Codex** and building the project in small playable milestones.

For now:
- Use the normal Roblox player character temporarily
- Build gameplay first
- Replace the player with a rooster rig later
- Keep the code simple, modular, and beginner-friendly
- Prefer a working prototype over overengineering

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

## Core prototype loop
1. Player spawns
2. Demon appears
3. Demon chases player
4. Player attacks demon
5. Demon attacks player
6. Demon dies
7. Demon respawns
8. Repeat

## Current scope
Build only a **small playable prototype**.

### Included now
- Basic map / baseplate
- Normal Roblox player character
- Left-click attack
- Simple peck/lunge feel
- One demon enemy
- Demon health
- Demon AI chase
- Demon melee attack
- Demon respawn
- Demon health bar
- Hit VFX and feedback
- Simple readable code structure

### Not included yet
- Open world
- Civilian rescue system
- Rooster selection
- Currency
- Save data
- Progression system
- Bosses
- Final UI polish
- Final rooster character rig
- Multiplayer complexity

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
- Enemy model: `DemonDummy`
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