# Rooster Warrior Lore Plan

## Goal
Turn the story of Suncrest Village, the Rooster Warriors, and the return of the demons into a playable narrative layer that fits the current combat-first vertical slice.

## What was added now
- Shared lore data in `src/ReplicatedStorage/Config/GameLore.lua`
- Story dialogue UI in `src/StarterPlayer/StarterPlayerScripts/StoryDialogueUI.client.lua`
- Chapter 1 quest data in `src/ReplicatedStorage/Config/ChapterQuestConfig.lua`
- Mission progression logic in `src/ServerScriptService/MissionProgressServer.server.lua`
- Chapter ending flow and `Master Kaien` scene scaffold in `src/ServerScriptService/ChapterEndingServer.server.lua`
- Opening Scene and Chapter 1 story text now exist as game content instead of living only in a prompt

## Current implementation snapshot
These pieces are already in the project:

- Canon lore text is centralized in `GameLore.lua`
- A reusable dialogue popup UI exists and listens to the `StoryDialogue` remote
- Chapter 1 has a live quest chain with mission progress values on the player
- Chapter 1 now ends by sending the player to speak with `Master Kaien` at the eastern docks
- Story dialogue now lives in shared config data for villagers and `Master Kaien`
- The current Chapter 1 flow now uses story-facing quest objectives, but the encounter layer is still powered by the wave system
- A wandering warrior named `Master Kaien` already appears near the eastern docks
- The chapter ending currently resolves after the final farm-defense wave and points the player toward the docks

## Current gaps
These parts are still planned or only partially implemented:

- No dedicated lore panel or journal view yet
- No Mistfang Demon boss encounter yet
- No full mist-cleanup, rescue, and forest-push quest sequence yet
- No saved chapter progression or lore unlock persistence yet

## Creation plan

### Phase 1: Establish the narrative foundation
Goal: make the world and premise readable inside the game.

Tasks:
- Keep all canon story text in one shared lore module
- Add chapter and story metadata fields later if needed, such as `UnlockOrder`, `Summary`, and `QuestIds`
- Decide which story beats are always visible and which unlock after progress
- Add a title-screen or first-spawn prompt that tells players where to find story and chapter information
- Decide whether story reference lives in a lore panel, codex, quest journal, or chapter screen

### Phase 2: Convert Chapter 1 into playable objectives
Goal: map the new story to actual quest content.

Tasks:
- Continue replacing the remaining wave-only framing with a fuller onboarding quest chain for Suncrest Village
- Add early quests for villagers, farm defense, black mist cleanup, and forest rescue
- Tie beginner abilities to milestones instead of giving everything up front
- Add a chapter-complete state after Mistfang Demon is defeated
- Keep the existing farm-defense beats only if they support the new chapter flow cleanly

### Phase 3: Add dialogue and cutscene delivery
Goal: make the story feel authored, not just described.

Tasks:
- Expand the shared NPC dialogue data beyond villagers and `Master Kaien`
- Extend the current dialogue UI into short intro and ending cutscene delivery using camera framing, text boxes, and temporary input locks
- Trigger the bloodline reveal after the first mini-boss encounter
- Add a dock departure scene that closes Chapter 1 cleanly

### Phase 4: Build the Chapter 1 content layer
Goal: support the story with real map and encounter content.

Tasks:
- Expand the village into named spaces: farms, market, wheat fields, forest edge, docks
- Add corrupted rats, wild beasts, black mist hazards, and the Mistfang Demon mini-boss
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
2. Update this plan whenever implementation changes so the doc stays aligned with the live game.
3. Build out the missing Chapter 1 objective beats: mist cleanup, rescues, and forest push.
4. Extend the shared dialogue data into a fuller authored dialogue and cutscene system.
5. Add a boss encounter script for Mistfang Demon.
6. Add chapter unlock tracking and save support after the content loop is fun.

## Design guardrails
- Keep story delivery short during active combat sections.
- Let gameplay actions reveal the lore instead of relying on long text walls.
- Use the lore panel for reference and worldbuilding, not as the only storytelling surface.
- Keep names consistent: `Suncrest Village`, `demons`, `Rooster Warriors`, `Mistfang Demon`, `Master Kaien`.
