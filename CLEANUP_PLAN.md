# Rooster Warrior - Cleanup Plan

## Goal
Make the current project easier to understand and safer to extend without changing the working game loop first.

## Core Loop Scripts
These are the scripts that directly support the current playable slice and should be treated as the highest-priority set.

### Server
- `src/ServerScriptService/RoosterCombatServer.server.lua`
- `src/ServerScriptService/DemonAIServer.server.lua`
- `src/ServerScriptService/DemonHealthBar.server.lua`
- `src/ServerScriptService/WaveManager.server.lua`
- `src/ServerScriptService/EnemyRewardsServer.server.lua`
- `src/ServerScriptService/ProgressionServer.server.lua`
- `src/ServerScriptService/MissionProgressServer.server.lua`
- `src/ServerScriptService/RoosterMorphServer.server.lua`

### Client
- `src/StarterPlayer/StarterPlayerScripts/RoosterAttackClient.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/PlayerHealthUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/WaveUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/MissionUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/FeathersUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/UpgradeUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/CharacterSelectUI.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/KenchiAnimation.client.lua`
- `src/StarterPlayer/StarterPlayerScripts/KeijiAnimation.client.lua`

### Required remotes
- `RoosterAttack`
- `RoosterHitConfirm`
- `CharacterSelect`
- `UpgradePurchase`

## Supporting Or Extra Systems
These are not useless, but they are not the first files we should optimize around when maintaining the core loop.

### Lower priority or optional right now
- `src/ServerScriptService/CivilianSystem.server.lua`
- `src/ServerScriptService/VillageMap.server.lua`
- `src/StarterPlayer/StarterPlayerScripts/KenchiSoundClient.client.lua`

## Current structural issues
- The project started as a tiny prototype, but the script set now behaves more like a vertical slice.
- Script names still suggest a smaller scope than the current implementation.
- Some large files mix setup, config, game logic, VFX, and tuning in one place.
- Combat tuning exists on both client and server, which can drift over time.
- Character-specific logic is spread across combat, morph, UI, and animation scripts.
- There is no single document that tells a new contributor which scripts are essential.

## Cleanup priorities

### Phase 1: Document ownership
Goal: make it obvious which files matter most.

Tasks:
- Keep this file updated as the entry point for repo structure
- Add short header comments to the largest gameplay scripts describing their responsibility
- Document which systems are core loop and which are optional

### Phase 2: Separate config from behavior
Goal: reduce duplication and make balancing safer.

Tasks:
- Move attack tuning into a shared module
- Move rooster character stats into a shared module
- Move enemy tuning into a shared module
- Keep server authority for damage and rules, with client data used only for presentation

### Phase 3: Break up oversized scripts
Goal: reduce the risk of one file owning too many responsibilities.

Targets:
- `RoosterCombatServer.server.lua`
- `DemonAIServer.server.lua`
- `RoosterAttackClient.client.lua`
- `RoosterMorphServer.server.lua`

Suggested split:
- combat rules
- combat VFX / feedback helpers
- enemy definitions
- enemy spawn / lifecycle
- rooster definitions
- morph construction helpers

### Phase 4: Clarify naming
Goal: reduce confusion between original prototype terms and current systems.

Tasks:
- Keep existing script names for now if renaming would be risky
- Document where current naming differs from the original prototype brief
- If we rename later, do it in a dedicated pass with Studio sync verification

## Recommended next cleanup task
The best next cleanup task is:

1. Create shared config modules for attacks, rooster stats, and enemy definitions.
2. Update the current scripts to read from those shared definitions.
3. Leave gameplay behavior unchanged while doing it.

This gives us the biggest maintainability win with the lowest design risk.

## Working rule
During cleanup, do not add new gameplay features unless the cleanup exposes a bug that must be fixed immediately.
