Read the file `PROJECT_START.md` in this project and use it as the source of truth.

Your task is to start the Roblox game project **Rooster Warrior** from scratch in a clean, practical, beginner-friendly way.

## What you must do
1. Read and follow all instructions in `PROJECT_START.md`
2. Create the initial project structure for a Roblox + VS Code workflow
3. Generate the first playable prototype files
4. Keep the implementation simple, modular, and easy to test
5. Do not overengineer
6. Do not jump ahead into advanced systems

## Initial files to create
Create these files if they do not exist:

- `default.project.json`
- `src/ReplicatedStorage/Remotes/RoosterAttack.remote.json`
- `src/ServerScriptService/RoosterCombatServer.server.lua`
- `src/ServerScriptService/DemonAIServer.server.lua`
- `src/ServerScriptService/DemonHealthBar.server.lua`
- `src/StarterPlayer/StarterPlayerScripts/RoosterAttackClient.client.lua`

## Prototype requirements
The first prototype must support:
- normal Roblox player character
- left click attack
- short peck/lunge feel
- one demon named `DemonDummy`
- demon chase AI
- demon melee attack
- demon health system
- demon health bar
- demon hit flash
- demon knockback
- demon respawn

## Naming rules
Use these exact names unless absolutely necessary:
- `RoosterAttack`
- `DemonDummy`
- `RoosterAttackClient`
- `RoosterCombatServer`
- `DemonAIServer`
- `DemonHealthBar`

## Technical expectations
- Use Luau
- Use a file structure compatible with Rojo
- Keep scripts complete and runnable
- Keep comments short and useful
- Prefer straightforward solutions

## Output format
Do the work directly by creating the files.

After creating them, provide:
1. a short summary of what was created
2. the expected Roblox hierarchy
3. instructions for how to sync the project into Roblox Studio
4. instructions for how to test the first playable loop

## Constraints
- Do not build the final rooster rig yet
- Do not add open world systems
- Do not add monetization
- Do not add save systems
- Do not add large UI systems yet
- Focus only on the smallest fun playable combat prototype

## If something is unclear
Prefer the simplest implementation that matches `PROJECT_START.md`.

Begin now by reading `PROJECT_START.md` and generating the initial project files.