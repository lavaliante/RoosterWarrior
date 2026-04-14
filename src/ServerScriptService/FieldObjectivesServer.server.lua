local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MIST_RESPAWN_DELAY = 12
local MIST_BASE_SIZE = Vector3.new(6, 4.5, 6)
local MIST_PROMPT_DISTANCE = 8
local MIST_HOLD_DURATION = 0.6

local RESCUE_RESPAWN_DELAY = 20
local RESCUE_PROMPT_DISTANCE = 8

-- Village marker folders
local village = Workspace:WaitForChild("Village")
local mistMarkerFolder = village:WaitForChild("MistObjectiveMarkers")
local rescueMarkerFolder = village:WaitForChild("RescueObjectiveMarkers")

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local storyDialogueRemote = remotesFolder:FindFirstChild("StoryDialogue")
if not storyDialogueRemote then
	storyDialogueRemote = Instance.new("RemoteEvent")
	storyDialogueRemote.Name = "StoryDialogue"
	storyDialogueRemote.Parent = remotesFolder
end

local storyDialogueConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("StoryDialogueConfig"))
local RESCUE_LINES = storyDialogueConfig.StrandedVillagers.RescueLines

-- Unlock state
local mistUnlocked = false
local rescueUnlocked = false
local totalMistCleared = 0

-- ─── Black Mist Pockets ───────────────────────────────────────────────────────

local function spawnMistPocket(position)
	local model = Instance.new("Model")
	model.Name = "BlackMistPocket"

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Size = MIST_BASE_SIZE
	core.Material = Enum.Material.Neon
	core.Color = Color3.fromRGB(28, 12, 42)
	core.Transparency = 0.35
	core.Anchored = true
	core.CanCollide = false
	core.CanQuery = false
	core.CanTouch = false
	core.CFrame = CFrame.new(position + Vector3.new(0, 2.5, 0))
	core.Parent = model

	local innerGlow = Instance.new("Part")
	innerGlow.Name = "InnerGlow"
	innerGlow.Shape = Enum.PartType.Ball
	innerGlow.Size = MIST_BASE_SIZE * 0.52
	innerGlow.Material = Enum.Material.Neon
	innerGlow.Color = Color3.fromRGB(98, 32, 140)
	innerGlow.Transparency = 0.45
	innerGlow.Anchored = true
	innerGlow.CanCollide = false
	innerGlow.CanQuery = false
	innerGlow.CanTouch = false
	innerGlow.CFrame = core.CFrame
	innerGlow.Parent = model

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(120, 40, 180)
	light.Brightness = 2.2
	light.Range = 16
	light.Parent = core

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CleansePrompt"
	prompt.ActionText = "Cleanse"
	prompt.ObjectText = "Black Mist"
	prompt.MaxActivationDistance = MIST_PROMPT_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = MIST_HOLD_DURATION
	prompt.Parent = core

	model.PrimaryPart = core
	model:SetAttribute("MistActive", true)
	model.Parent = Workspace

	-- Gentle pulse — stopped when cleansing begins
	local pulseActive = true
	task.spawn(function()
		local expandSize = MIST_BASE_SIZE * 1.14
		while core.Parent and pulseActive do
			local t1 = TweenService:Create(core, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = expandSize,
				Transparency = 0.5,
			})
			t1:Play()
			t1.Completed:Wait()
			if not core.Parent or not pulseActive then
				break
			end
			local t2 = TweenService:Create(core, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = MIST_BASE_SIZE,
				Transparency = 0.35,
			})
			t2:Play()
			t2.Completed:Wait()
		end
	end)

	prompt.Triggered:Connect(function(player)
		if not model:GetAttribute("MistActive") then
			return
		end
		model:SetAttribute("MistActive", false)
		pulseActive = false

		-- Increment per-player and global counters
		local currentCount = player:GetAttribute("MistClearedCount") or 0
		player:SetAttribute("MistClearedCount", currentCount + 1)

		totalMistCleared += 1

		-- Fade out mist and light together; prompt stays until model is destroyed
		local FADE_TIME = 0.65
		TweenService:Create(core, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()
		TweenService:Create(innerGlow, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()
		TweenService:Create(light, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
		}):Play()
		Debris:AddItem(model, FADE_TIME + 0.05)

		task.delay(MIST_RESPAWN_DELAY, function()
			spawnMistPocket(position)
		end)
	end)
end

-- ─── Stranded Villagers ───────────────────────────────────────────────────────

local VILLAGER_NAMES = { "Sora", "Teva", "Miro" }
local nextNameIndex = 1

function spawnStrandedVillager(position)
	local name = VILLAGER_NAMES[nextNameIndex]
	nextNameIndex = (nextNameIndex % #VILLAGER_NAMES) + 1

	local model = Instance.new("Model")
	model.Name = name

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CanQuery = false
	rootPart.CanTouch = false
	rootPart.CFrame = CFrame.new(position)
	rootPart.Parent = model

	local function makePart(partName, size, color, offset)
		local part = Instance.new("Part")
		part.Name = partName
		part.Size = size
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		part.CFrame = rootPart.CFrame * CFrame.new(offset)
		part.Parent = model
		return part
	end

	local skinColor = Color3.fromRGB(230, 185, 140)
	local hue = math.random() * 0.2 + 0.05
	local shirtColor = Color3.fromHSV(hue, 0.55, 0.75)
	local pantsColor = Color3.fromRGB(72, 58, 44)

	local torso = makePart("Torso", Vector3.new(2.2, 2.4, 1.3), shirtColor, Vector3.new(0, 1.8, 0))
	makePart("Head", Vector3.new(1.8, 1.8, 1.8), skinColor, Vector3.new(0, 3.9, 0))
	makePart("LeftArm", Vector3.new(0.8, 2.2, 0.8), shirtColor, Vector3.new(-1.45, 1.8, 0))
	makePart("RightArm", Vector3.new(0.8, 2.2, 0.8), shirtColor, Vector3.new(1.45, 1.8, 0))
	makePart("LeftLeg", Vector3.new(0.9, 2.5, 0.9), pantsColor, Vector3.new(-0.45, -0.2, 0))
	makePart("RightLeg", Vector3.new(0.9, 2.5, 0.9), pantsColor, Vector3.new(0.45, -0.2, 0))

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 211, 94)
	highlight.OutlineColor = Color3.fromRGB(255, 242, 184)
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = name
	humanoid.Parent = model

	model.PrimaryPart = rootPart
	model:SetAttribute("RescueActive", true)
	model.Parent = Workspace

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RescuePrompt"
	prompt.ActionText = "Rescue"
	prompt.ObjectText = name
	prompt.MaxActivationDistance = RESCUE_PROMPT_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.Parent = torso

	prompt.Triggered:Connect(function(player)
		if not model:GetAttribute("RescueActive") then
			return
		end
		model:SetAttribute("RescueActive", false)

		local currentCount = player:GetAttribute("VillagersRescuedCount") or 0
		player:SetAttribute("VillagersRescuedCount", currentCount + 1)

		storyDialogueRemote:FireClient(player, {
			Speaker = name,
			Text = RESCUE_LINES[math.random(1, #RESCUE_LINES)],
		})

		-- Fade out villager and highlight together; prompt stays until model is destroyed
		local FADE_TIME = 0.5
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
				}):Play()
			end
		end
		TweenService:Create(highlight, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 1,
		}):Play()
		Debris:AddItem(model, FADE_TIME + 0.05)

		task.delay(RESCUE_RESPAWN_DELAY, function()
			spawnStrandedVillager(position)
		end)
	end)
end

-- ─── Unlock Sequence ─────────────────────────────────────────────────────────
-- Mist appears when any player's MissionIndex reaches 3 (quest 3 is active).
-- Villagers appear when any player's MissionIndex reaches 4 (quest 4 is active).
-- This is tied to MissionIndex rather than AliveEnemies to avoid the 2.5-second
-- gap caused by MISSION_RESET_DELAY in MissionProgressServer.

local function tryUnlockMist()
	if mistUnlocked then
		return
	end
	mistUnlocked = true
	for _, marker in ipairs(mistMarkerFolder:GetChildren()) do
		if marker:IsA("BasePart") then
			spawnMistPocket(marker.Position)
		end
	end
end

local function tryUnlockRescue()
	if rescueUnlocked then
		return
	end
	rescueUnlocked = true
	for _, marker in ipairs(rescueMarkerFolder:GetChildren()) do
		if marker:IsA("BasePart") then
			spawnStrandedVillager(marker.Position)
		end
	end
end

local function watchPlayerMissionIndex(player)
	task.defer(function()
		if not player.Parent then
			return
		end

		local missionData = player:WaitForChild("MissionData", 30)
		if not missionData then
			return
		end

		local missionIndex = missionData:WaitForChild("MissionIndex", 30)
		if not missionIndex then
			return
		end

		local function checkUnlocks()
			if missionIndex.Value >= 3 then
				tryUnlockMist()
			end
			if missionIndex.Value >= 4 then
				tryUnlockRescue()
			end
		end

		missionIndex.Changed:Connect(checkUnlocks)
		checkUnlocks()
	end)
end

Players.PlayerAdded:Connect(watchPlayerMissionIndex)

for _, player in ipairs(Players:GetPlayers()) do
	watchPlayerMissionIndex(player)
end
