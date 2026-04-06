# Rooster Warrior — Project Start

## Goal
Build a Roblox action game called **Rooster Warrior**.

The game is inspired by the absurd heroic energy of a rooster fighting giant demons and protecting civilians. The gameplay should feel fast, readable, dramatic, and fun early in development.

## Development approach
We are starting from scratch in **VS Code + Codex** and building the project in small playable milestones.

Current approach:
- Keep the game playable at every step
- Build gameplay first, then deepen content and polish
- Keep the code simple, modular, and beginner-friendly
- Prefer a working prototype over overengineering
- Upgrade the existing systems in layers instead of restarting them

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

## Current gameplay loop
1. Player spawns
2. Player selects a rooster
3. Wave begins
4. Demons spawn and chase the player
5. Civilians wander and flee from danger
6. Player attacks demons with peck and scratch
7. Player earns feathers, mission progress, and wave progress
8. More enemy types unlock in later waves
9. Player buys upgrades and keeps pushing forward

## Current project status
The project is no longer just the first prototype. It already includes a playable combat loop with progression layers on top.

### Included now
- Village map and civilian system
- Rooster morph system with at least two rooster choices
- Peck and scratch attacks with client/server handling
- Character-specific attack tuning
- Multiple demon enemy types unlocked by wave
- Demon health and melee combat
- Demon AI chase, attack, death burst, and respawn logic
- Demon health bar
- Hit VFX, hit confirm feedback, attack windup feedback
- Wave manager and wave UI
- Mission system
- Feather rewards
- Upgrade system for player power
- Character selection UI
- Basic save data for selected rooster
- Simple readable code structure

### Not included yet
- Civilian rescue / escort win conditions
- Boss fights
- Stronger enemy variety beyond stat escalation
- Better balancing across roosters, upgrades, and waves
- Persistent progression for upgrades / currency
- Lose state, restart flow, and match pacing polish
- Audio polish across the full game
- Better controller / console input support
- Final UI polish
- Final art pass and environment dressing
- Final rooster animation / presentation quality
- Multiplayer complexity

## Suggested next milestone
The next best milestone is:

**Make civilians matter to the core loop.**

Right now civilians exist and demons can possess them, but the player fantasy is strongest if protecting civilians affects success and failure.

### Next concrete build target
- Add a clear civilian danger meter or rescued / lost counter
- Define a fail condition when too many civilians are lost
- Define a win condition for surviving or clearing a wave while protecting civilians
- Reward successful protection with feathers or bonus progress
- Show that state clearly in the HUD

## Roadmap

### Phase 1 - Solidify the current combat build
- Tune attack damage, cooldowns, knockback, and wave pacing
- Make demon unlock progression feel fair and readable
- Verify mission goals match real combat behavior
- Tighten hit feedback, player damage feedback, and death flow

### Phase 2 - Civilian protection loop
- Add rescue / loss rules
- Add mission variants tied to protection
- Make possession events more visible and more threatening
- Turn civilians into a real reason to move around the map

### Phase 3 - Progression that lasts
- Save feathers, upgrades, and unlocked rooster choices
- Expand upgrade paths beyond health and damage
- Add stronger reasons to replay waves

### Phase 4 - Content expansion
- Add elite demons or minibosses
- Add unique behaviors instead of only stronger stats
- Add more maps or more village event variety

### Phase 5 - Polish
- Improve UI style and readability
- Improve sound, animation, and impact
- Add controller support and input polish
- Prepare for multiplayer-friendly architecture if needed

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
- Enemy models: `RedDemon`, `BlueDemon`, `GreenDemon`, `PurpleDemon`, `WhiteDemon`
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
    CivilianSystem.server.lua
    MissionProgressServer.server.lua
    ProgressionServer.server.lua
    RoosterMorphServer.server.lua
    RoosterCombatServer.server.lua
    DemonAIServer.server.lua
    DemonHealthBar.server.lua
    WaveManager.server.lua
  StarterPlayer/
    StarterPlayerScripts/
      CharacterSelectUI.client.lua
      FeathersUI.client.lua
      MissionUI.client.lua
      PlayerHealthUI.client.lua
      RoosterAttackClient.client.lua
      UpgradeUI.client.lua
      WaveUI.client.lua
