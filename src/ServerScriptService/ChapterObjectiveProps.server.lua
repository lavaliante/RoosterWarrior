local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local village = Workspace:WaitForChild("Village")
local mistMarkers = village:WaitForChild("MistObjectiveMarkers")
local rescueMarkers = village:WaitForChild("RescueObjectiveMarkers")

local propsFolder = Workspace:FindFirstChild("ChapterObjectiveProps")
if propsFolder then
	propsFolder:Destroy()
end

propsFolder = Instance.new("Folder")
propsFolder.Name = "ChapterObjectiveProps"
propsFolder.Parent = Workspace

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

local function incrementPlayerCountAttribute(player, attributeName)
	local currentValue = player:GetAttribute(attributeName)
	if type(currentValue) ~= "number" then
		currentValue = 0
	end

	player:SetAttribute(attributeName, currentValue + 1)
end

local function createMistPocket(marker, index)
	local model = Instance.new("Model")
	model.Name = "MistPocket" .. tostring(index)
	model.Parent = propsFolder

	local root = createPart(model, "Root", Vector3.new(4.4, 0.4, 4.4), CFrame.new(marker.Position), Color3.fromRGB(33, 26, 45), Enum.Material.Slate)
	root.Transparency = 1
	root.CanCollide = false

	for ringIndex, ringData in ipairs({
		{ Size = Vector3.new(5.6, 2.6, 5.6), Offset = Vector3.new(0, 1.3, 0), Transparency = 0.38 },
		{ Size = Vector3.new(4.4, 3.2, 4.4), Offset = Vector3.new(0.7, 1.9, 0.3), Transparency = 0.46 },
		{ Size = Vector3.new(3.8, 2.4, 3.8), Offset = Vector3.new(-0.5, 2.5, -0.4), Transparency = 0.52 },
	}) do
		local mist = createPart(
			model,
			"Mist" .. tostring(ringIndex),
			ringData.Size,
			CFrame.new(marker.Position + ringData.Offset),
			Color3.fromRGB(34, 27, 48),
			Enum.Material.ForceField
		)
		mist.Shape = Enum.PartType.Ball
		mist.Transparency = ringData.Transparency
		mist.CanCollide = false
	end

	local glow = createPart(model, "Glow", Vector3.new(1.2, 1.2, 1.2), CFrame.new(marker.Position + Vector3.new(0, 2.8, 0)), Color3.fromRGB(122, 74, 168), Enum.Material.Neon)
	glow.Shape = Enum.PartType.Ball
	glow.Transparency = 0.15
	glow.CanCollide = false

	local beacon = createPart(model, "Beacon", Vector3.new(0.8, 4.8, 0.8), CFrame.new(marker.Position + Vector3.new(0, 2.4, 0)), Color3.fromRGB(98, 62, 144), Enum.Material.Neon)
	beacon.Transparency = 0.35
	beacon.CanCollide = false

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CleansePrompt"
	prompt.ActionText = "Cleanse"
	prompt.ObjectText = "Black Mist"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 10
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = root

	local claimed = false
	prompt.Triggered:Connect(function(player)
		if claimed then
			return
		end

		claimed = true
		incrementPlayerCountAttribute(player, "MistClearedCount")
		model:Destroy()
	end)
end

local function createRescueSite(marker, index)
	local model = Instance.new("Model")
	model.Name = "RescueSite" .. tostring(index)
	model.Parent = propsFolder

	local base = createPart(model, "Base", Vector3.new(5.5, 0.4, 5.5), CFrame.new(marker.Position), Color3.fromRGB(112, 83, 55), Enum.Material.WoodPlanks)
	local cage = createPart(model, "Cage", Vector3.new(3.8, 4.4, 3.8), CFrame.new(marker.Position + Vector3.new(0, 2.2, 0)), Color3.fromRGB(125, 96, 64), Enum.Material.WoodPlanks)
	cage.Transparency = 0.15
	local captive = createPart(model, "Captive", Vector3.new(1.4, 3, 1.4), CFrame.new(marker.Position + Vector3.new(0, 1.8, 0)), Color3.fromRGB(240, 214, 172), Enum.Material.SmoothPlastic)
	captive.Shape = Enum.PartType.Ball
	captive.Transparency = 0.2

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RescuePrompt"
	prompt.ActionText = "Rescue"
	prompt.ObjectText = "Stranded Villager"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 10
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = cage

	local claimed = false
	prompt.Triggered:Connect(function(player)
		if claimed then
			return
		end

		claimed = true
		incrementPlayerCountAttribute(player, "VillagersRescuedCount")
		model:Destroy()
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	if player:GetAttribute("MistClearedCount") == nil then
		player:SetAttribute("MistClearedCount", 0)
	end
	if player:GetAttribute("VillagersRescuedCount") == nil then
		player:SetAttribute("VillagersRescuedCount", 0)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player:GetAttribute("MistClearedCount") == nil then
		player:SetAttribute("MistClearedCount", 0)
	end
	if player:GetAttribute("VillagersRescuedCount") == nil then
		player:SetAttribute("VillagersRescuedCount", 0)
	end
end)

for index, marker in ipairs(mistMarkers:GetChildren()) do
	if marker:IsA("BasePart") then
		createMistPocket(marker, index)
	end
end

for index, marker in ipairs(rescueMarkers:GetChildren()) do
	if marker:IsA("BasePart") then
		createRescueSite(marker, index)
	end
end
