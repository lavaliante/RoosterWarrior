# Rooster Warrior Lore Plan

## Goal
Turn the story of Suncrest Village, the Rooster Warriors, and the return of the Kijuu into a playable narrative layer that fits the current combat-first vertical slice.

## What was added now
- Shared lore data in `src/ReplicatedStorage/Config/GameLore.lua`
- In-game lore panel in `src/StarterPlayer/StarterPlayerScripts/LoreUI.client.lua`
- Opening Scene and Chapter 1 story text now exist as game content instead of living only in a prompt

## Creation plan

### Phase 1: Establish the narrative foundation
Goal: make the world and premise readable inside the game.

Tasks:
- Keep all canon story text in one shared lore module
- Add chapter and story metadata fields later if needed, such as `UnlockOrder`, `Summary`, and `QuestIds`
- Decide which story beats are always visible and which unlock after progress
- Add a title-screen or first-spawn prompt that tells players the lore panel exists

### Phase 2: Convert Chapter 1 into playable objectives
Goal: map the new story to actual quest content.

Tasks:
- Replace or extend the current mission rotation with an onboarding quest chain for Suncrest Village
- Add early quests for villagers, farm defense, black mist cleanup, and forest rescue
- Tie beginner abilities to milestones instead of giving everything up front
- Add a simple chapter-complete state after Mistfang Kijuu is defeated

### Phase 3: Add dialogue and cutscene delivery
Goal: make the story feel authored, not just described.

Tasks:
- Create NPC dialogue data for villagers and the wandering warrior
- Add short intro cutscenes using camera framing, text boxes, and temporary input locks
- Trigger the bloodline reveal after the first mini-boss encounter
- Add a dock departure scene that closes Chapter 1 cleanly

### Phase 4: Build the Chapter 1 content layer
Goal: support the story with real map and encounter content.

Tasks:
- Expand the village into named spaces: farms, market, wheat fields, forest edge, docks
- Add corrupted rats, wild beasts, black mist hazards, and the Mistfang Kijuu mini-boss
- Create NPC placement and rescue interaction points
- Add ambient storytelling props such as damaged crops, missing livestock pens, and mist pockets

### Phase 5: Progression and future chapters
Goal: prepare the game for a full campaign structure.

Tasks:
- Add a chapter progression service on the server
- Save unlocked chapters, lore entries, and key story flags
- Connect future lands and Rooster Warrior relics to a world map flow
- Define the next chapter before implementation so systems stay reusable

## Recommended implementation order
1. Keep the new lore module as the canonical source for story text.
2. Build a Chapter 1 quest chain in `MissionProgressServer.server.lua` or move mission logic into a dedicated quest module first.
3. Add NPC dialogue data and a reusable dialogue UI.
4. Add a boss encounter script for Mistfang Kijuu.
5. Add chapter unlock tracking and save support after the content loop is fun.

## Design guardrails
- Keep story delivery short during active combat sections.
- Let gameplay actions reveal the lore instead of relying on long text walls.
- Use the lore panel for reference and worldbuilding, not as the only storytelling surface.
- Keep names consistent: `Suncrest Village`, `Kijuu`, `Rooster Warriors`, `Mistfang Kijuu`.
