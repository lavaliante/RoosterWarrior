local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FINAL_WAVE = 3
local FINAL_WAVE_STATUS = "Suncrest Village is safe for now"
local DIALOGUE_REMOTE_NAME = "StoryDialogue"
local WARRIOR_NAME = "Master Kaien"
local WARRIOR_DIALOGUE = {
	{
		Speaker = WARRIOR_NAME,
		Text = "You stood against the darkness when the whole village trembled. That is no small thing, young rooster.",
	},
	{
		Speaker = WARRIOR_NAME,
		Text = "The mark in your feathers carries an old bloodline. The Rooster Warriors were not erased after all.",
	},
	{
		Speaker = WARRIOR_NAME,
		Text = "Meet me at the eastern docks when you are ready. Suncrest was only the beginning.",
	},
}
local DIALOGUE_STEP_DELAY = 4

local waveState = Workspace:WaitForChild("WaveState")
local waveNumberValue = waveState:WaitForChild("WaveNumber")
local aliveEnemiesValue = waveState:WaitForChild("AliveEnemies")
local countdownActiveValue = waveState:WaitForChild("CountdownActive")
local statusValue = waveState:WaitForChild("Status")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local storyDialogueRemote = remotesFolder:FindFirstChild(DIALOGUE_REMOTE_NAME)

if not storyDialogueRemote then
	storyDialogueRemote = Instance.new("RemoteEvent")
	storyDialogueRemote.Name = DIALOGUE_REMOTE_NAME
	storyDialogueRemote.Parent = remotesFolder
end

local endingTriggered = false
local warriorModel

local function createPart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createWarrior()
	if warriorModel and warriorModel.Parent then
		return warriorModel
	end

	local village = Workspace:FindFirstChild("Village")
	if not village then
		return nil
	end

	local docks = village:FindFirstChild("EasternDocks")
	local dockHouse = village:FindFirstChild("DockHouse")
	local spawnPosition

	if docks and docks:IsA("Model") and docks:FindFirstChild("PierMain") then
		spawnPosition = docks.PierMain.Position + Vector3.new(-10, 2.5, 0)
	elseif dockHouse and dockHouse:IsA("Model") and dockHouse:FindFirstChild("Body") then
		spawnPosition = dockHouse.Body.Position + Vector3.new(-10, 0.5, -8)
	else
		spawnPosition = Vector3.new(110, 8, 22)
	end

	local model = Instance.new("Model")
	model.Name = "WanderingWarrior"

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CFrame = CFrame.new(spawnPosition)
	rootPart.Parent = model

	local torso = createPart(model, "Torso", Vector3.new(2.4, 2.8, 1.4), rootPart.CFrame * CFrame.new(0, 1.8, 0), Color3.fromRGB(74, 58, 45), Enum.Material.WoodPlanks)
	local chest = createPart(model, "ChestWrap", Vector3.new(2.55, 1.2, 1.5), rootPart.CFrame * CFrame.new(0, 2.25, -0.05), Color3.fromRGB(170, 132, 64), Enum.Material.Fabric)
	local head = createPart(model, "Head", Vector3.new(1.9, 1.9, 1.9), rootPart.CFrame * CFrame.new(0, 4.1, 0), Color3.fromRGB(237, 198, 152), Enum.Material.SmoothPlastic)
	local crest = createPart(model, "Crest", Vector3.new(0.8, 1.5, 0.6), rootPart.CFrame * CFrame.new(0, 5.35, 0.1), Color3.fromRGB(190, 48, 42), Enum.Material.SmoothPlastic)
	local beak = createPart(model, "Beak", Vector3.new(0.6, 0.45, 0.9), rootPart.CFrame * CFrame.new(0, 4.0, -1.2), Color3.fromRGB(225, 182, 74), Enum.Material.SmoothPlastic)
	local leftArm = createPart(model, "LeftArm", Vector3.new(0.8, 2.4, 0.8), rootPart.CFrame * CFrame.new(-1.7, 1.8, 0), Color3.fromRGB(74, 58, 45), Enum.Material.SmoothPlastic)
	local rightArm = createPart(model, "RightArm", Vector3.new(0.8, 2.4, 0.8), rootPart.CFrame * CFrame.new(1.7, 1.8, 0), Color3.fromRGB(74, 58, 45), Enum.Material.SmoothPlastic)
	local leftLeg = createPart(model, "LeftLeg", Vector3.new(0.9, 2.8, 0.9), rootPart.CFrame * CFrame.new(-0.55, -0.4, 0), Color3.fromRGB(102, 75, 48), Enum.Material.SmoothPlastic)
	local rightLeg = createPart(model, "RightLeg", Vector3.new(0.9, 2.8, 0.9), rootPart.CFrame * CFrame.new(0.55, -0.4, 0), Color3.fromRGB(102, 75, 48), Enum.Material.SmoothPlastic)
	local cape = createPart(model, "Cape", Vector3.new(2.8, 3.6, 0.4), rootPart.CFrame * CFrame.new(0, 2.2, 0.9), Color3.fromRGB(103, 34, 28), Enum.Material.Fabric)
	local staff = createPart(model, "Staff", Vector3.new(0.35, 7, 0.35), rootPart.CFrame * CFrame.new(2.25, 1.6, 0), Color3.fromRGB(117, 82, 47), Enum.Material.Wood)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = WARRIOR_NAME
	humanoid.Parent = model

	for _, part in ipairs({ torso, chest, head, crest, beak, leftArm, rightArm, leftLeg, rightLeg, cape, staff }) do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = rootPart
		weld.Part1 = part
		weld.Parent = part
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TalkPrompt"
	prompt.ActionText = "Speak"
	prompt.ObjectText = WARRIOR_NAME
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso

	prompt.Triggered:Connect(function(player)
		storyDialogueRemote:FireClient(player, {
			Speaker = WARRIOR_NAME,
			Text = "When you are ready, the eastern sea will carry us toward the truth of the Kijuu.",
		})
	end)

	model.PrimaryPart = rootPart
	model:SetAttribute("StoryNpc", true)
	model.Parent = Workspace
	warriorModel = model
	return model
end

local function isFinalWaveCleared()
	return waveNumberValue.Value >= FINAL_WAVE
		and aliveEnemiesValue.Value <= 0
		and countdownActiveValue.Value == false
		and statusValue.Value == FINAL_WAVE_STATUS
end

local function playEndingDialogue()
	for _, entry in ipairs(WARRIOR_DIALOGUE) do
		for _, player in ipairs(Players:GetPlayers()) do
			storyDialogueRemote:FireClient(player, entry)
		end
		task.wait(DIALOGUE_STEP_DELAY)
	end
end

local function triggerEndingIfReady()
	if endingTriggered or not isFinalWaveCleared() then
		return
	end

	endingTriggered = true
	createWarrior()
	task.spawn(playEndingDialogue)
end

Players.PlayerAdded:Connect(function(player)
	if endingTriggered then
		task.delay(1.5, function()
			if player.Parent then
				createWarrior()
				storyDialogueRemote:FireClient(player, {
					Speaker = WARRIOR_NAME,
					Text = "Suncrest stands because you fought. Meet me at the eastern docks.",
				})
			end
		end)
	end
end)

waveNumberValue.Changed:Connect(triggerEndingIfReady)
aliveEnemiesValue.Changed:Connect(triggerEndingIfReady)
countdownActiveValue.Changed:Connect(triggerEndingIfReady)
statusValue.Changed:Connect(triggerEndingIfReady)

triggerEndingIfReady()
