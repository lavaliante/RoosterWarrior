local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local configFolder = ReplicatedStorage:WaitForChild("Config")
local characterSelectRemote = remotesFolder:WaitForChild("CharacterSelect")
local CharacterConfig = require(configFolder:WaitForChild("CharacterConfig"))

local CHARACTER_STORE = DataStoreService:GetDataStore("PlayerCharacter_v1")
local SAVE_RETRY_COUNT = 3
local SAVE_RETRY_DELAY = 1
local ROOSTER_SWAP_COOLDOWN = 2

local saveDebounces = {}

local function getCharacterDataKey(player)
	return "player_" .. tostring(player.UserId)
end

local function getCharacterConfig(characterName)
	return CharacterConfig.Get(characterName)
end

local function clearOldMorph(character)
	local oldModel = character:FindFirstChild("RoosterMorph")

	if oldModel then
		oldModel:Destroy()
	end
end

local function weldToPart(basePart, part, jointsFolder)
	local weld = Instance.new("Weld")
	weld.Name = part.Name .. "Joint"
	weld.Part0 = basePart
	weld.Part1 = part
	weld.C0 = basePart.CFrame:ToObjectSpace(part.CFrame)
	weld.Parent = jointsFolder
	return weld
end

local function createMorphPart(name, size, color, cframe, parent, collide)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.BrickColor = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = collide or false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CFrame = cframe
	part.Parent = parent
	return part
end

local function hideDefaultCharacter(character)
	for _, instance in ipairs(character:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.Transparency = 1
			instance.CanCollide = false
		elseif instance:IsA("Decal") then
			instance.Transparency = 1
		elseif instance:IsA("Accessory") then
			local handle = instance:FindFirstChild("Handle")
			if handle then
				handle.Transparency = 1
			end
		end
	end
end

local function findFirstPart(character, names)
	for _, name in ipairs(names) do
		local part = character:FindFirstChild(name)

		if part and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function attachToHead(morphModel, head, config)
	local headCFrame = head.CFrame
	local jointsFolder = morphModel:WaitForChild("Joints")

	local face = createMorphPart("RoosterFace", Vector3.new(2.2, 2.55, 2.75), config.BodyColor, headCFrame * CFrame.new(0, 0.42, -0.22) * CFrame.Angles(math.rad(-12), 0, 0), morphModel)
	weldToPart(head, face, jointsFolder)

	local beak = createMorphPart("Beak", Vector3.new(0.9, 0.72, 1.6), config.BeakColor, headCFrame * CFrame.new(0, 0.18, -1.95) * CFrame.Angles(math.rad(-10), 0, 0), morphModel)
	weldToPart(head, beak, jointsFolder)

	local combBase = createMorphPart("CombBase", Vector3.new(0.5, 0.78, 0.45), config.CombColor, headCFrame * CFrame.new(0, 1.7, -0.52), morphModel)
	local combMid = createMorphPart("CombMid", Vector3.new(0.45, 1.08, 0.45), config.CombColor, headCFrame * CFrame.new(0, 2.08, -0.04), morphModel)
	local combBack = createMorphPart("CombBack", Vector3.new(0.4, 0.82, 0.4), config.CombColor, headCFrame * CFrame.new(0, 1.78, 0.54), morphModel)

	weldToPart(head, combBase, jointsFolder)
	weldToPart(head, combMid, jointsFolder)
	weldToPart(head, combBack, jointsFolder)

	local wattleLeft = createMorphPart("WattleLeft", Vector3.new(0.3, 0.72, 0.3), config.CombColor, headCFrame * CFrame.new(-0.24, -0.46, -1.0), morphModel)
	local wattleRight = createMorphPart("WattleRight", Vector3.new(0.3, 0.72, 0.3), config.CombColor, headCFrame * CFrame.new(0.24, -0.46, -1.0), morphModel)

	weldToPart(head, wattleLeft, jointsFolder)
	weldToPart(head, wattleRight, jointsFolder)
end

local function attachToRoot(morphModel, rootPart, config)
	local rootCFrame = rootPart.CFrame
	local jointsFolder = morphModel:WaitForChild("Joints")

	local body = createMorphPart("RoosterBody", Vector3.new(3.6, 3.25, 4.15), config.BodyColor, rootCFrame * CFrame.new(0, 0.55, 0.38), morphModel)
	weldToPart(rootPart, body, jointsFolder)

	local chest = createMorphPart("RoosterChest", Vector3.new(2.95, 2.6, 2.55), config.ChestColor, rootCFrame * CFrame.new(0, 0.15, -1.12), morphModel)
	weldToPart(rootPart, chest, jointsFolder)

	local hip = createMorphPart("RoosterHip", Vector3.new(2.4, 1.8, 2.3), config.BodyColor, rootCFrame * CFrame.new(0, -1.05, 1.05), morphModel)
	weldToPart(rootPart, hip, jointsFolder)

	local leftWing = createMorphPart("LeftWing", Vector3.new(0.95, 3.8, 3.4), config.WingColor, rootCFrame * CFrame.new(-2.45, 1.2, 0.18) * CFrame.Angles(0, math.rad(-10), math.rad(42)), morphModel)
	local rightWing = createMorphPart("RightWing", Vector3.new(0.95, 3.8, 3.4), config.WingColor, rootCFrame * CFrame.new(2.45, 1.2, 0.18) * CFrame.Angles(0, math.rad(10), math.rad(-42)), morphModel)
	local leftWingTip = createMorphPart("LeftWingTip", Vector3.new(0.7, 3.1, 2.6), config.BodyColor, rootCFrame * CFrame.new(-3.15, 2.35, 0.08) * CFrame.Angles(0, math.rad(-16), math.rad(58)), morphModel)
	local rightWingTip = createMorphPart("RightWingTip", Vector3.new(0.7, 3.1, 2.6), config.BodyColor, rootCFrame * CFrame.new(3.15, 2.35, 0.08) * CFrame.Angles(0, math.rad(16), math.rad(-58)), morphModel)

	weldToPart(rootPart, leftWing, jointsFolder)
	weldToPart(rootPart, rightWing, jointsFolder)
	weldToPart(rootPart, leftWingTip, jointsFolder)
	weldToPart(rootPart, rightWingTip, jointsFolder)

	local tail1 = createMorphPart("Tail1", Vector3.new(0.42, 2.4, 1.25), config.TailColor, rootCFrame * CFrame.new(-0.58, 1.75, 2.45) * CFrame.Angles(math.rad(-64), 0, math.rad(-20)), morphModel)
	local tail2 = createMorphPart("Tail2", Vector3.new(0.42, 2.85, 1.25), config.TailColor, rootCFrame * CFrame.new(0, 1.95, 2.65) * CFrame.Angles(math.rad(-72), 0, 0), morphModel)
	local tail3 = createMorphPart("Tail3", Vector3.new(0.42, 2.4, 1.25), config.TailColor, rootCFrame * CFrame.new(0.58, 1.75, 2.45) * CFrame.Angles(math.rad(-64), 0, math.rad(20)), morphModel)
	local tailTip1 = createMorphPart("TailTip1", Vector3.new(0.32, 1.25, 0.8), config.TailTipColor, rootCFrame * CFrame.new(-0.8, 2.7, 3.1) * CFrame.Angles(math.rad(-84), 0, math.rad(-22)), morphModel)
	local tailTip2 = createMorphPart("TailTip2", Vector3.new(0.32, 1.45, 0.8), config.TailTipColor, rootCFrame * CFrame.new(0, 3.05, 3.35) * CFrame.Angles(math.rad(-88), 0, 0), morphModel)
	local tailTip3 = createMorphPart("TailTip3", Vector3.new(0.32, 1.25, 0.8), config.TailTipColor, rootCFrame * CFrame.new(0.8, 2.7, 3.1) * CFrame.Angles(math.rad(-84), 0, math.rad(22)), morphModel)

	weldToPart(rootPart, tail1, jointsFolder)
	weldToPart(rootPart, tail2, jointsFolder)
	weldToPart(rootPart, tail3, jointsFolder)
	weldToPart(rootPart, tailTip1, jointsFolder)
	weldToPart(rootPart, tailTip2, jointsFolder)
	weldToPart(rootPart, tailTip3, jointsFolder)

end

local function attachLegMorph(morphModel, basePart, sideName, config)
	local sideSign = sideName == "Left" and -1 or 1
	local baseCFrame = basePart.CFrame
	local jointsFolder = morphModel:WaitForChild("Joints")

	local thigh = createMorphPart(sideName .. "Thigh", Vector3.new(0.75, 1.5, 0.75), config.LegColor, baseCFrame * CFrame.new(0, 0.15, 0), morphModel)
	local shin = createMorphPart(sideName .. "Shin", Vector3.new(0.5, 1.7, 0.5), config.LegColor, baseCFrame * CFrame.new(0, -1.15, -0.08) * CFrame.Angles(math.rad(-8), 0, 0), morphModel)
	local toe1 = createMorphPart(sideName .. "Toe1", Vector3.new(0.2, 0.2, 0.9), config.LegColor, baseCFrame * CFrame.new(0, -2.05, -0.48) * CFrame.Angles(math.rad(10), 0, math.rad(14 * sideSign)), morphModel)
	local toe2 = createMorphPart(sideName .. "Toe2", Vector3.new(0.18, 0.18, 0.82), config.LegColor, baseCFrame * CFrame.new(-0.16 * sideSign, -2.0, -0.35) * CFrame.Angles(math.rad(8), math.rad(14 * sideSign), math.rad(24 * sideSign)), morphModel)
	local toe3 = createMorphPart(sideName .. "Toe3", Vector3.new(0.18, 0.18, 0.82), config.LegColor, baseCFrame * CFrame.new(0.16 * sideSign, -2.0, -0.35) * CFrame.Angles(math.rad(8), math.rad(-14 * sideSign), math.rad(-24 * sideSign)), morphModel)

	weldToPart(basePart, thigh, jointsFolder)
	weldToPart(basePart, shin, jointsFolder)
	weldToPart(basePart, toe1, jointsFolder)
	weldToPart(basePart, toe2, jointsFolder)
	weldToPart(basePart, toe3, jointsFolder)
end

local function saveSelectedCharacter(player)
	local selectedCharacter = player:GetAttribute("SelectedRooster") or "Kenchi"
	local success = false
	local lastError

	for _ = 1, SAVE_RETRY_COUNT do
		success, lastError = pcall(function()
			CHARACTER_STORE:SetAsync(getCharacterDataKey(player), selectedCharacter)
		end)

		if success then
			return true
		end

		task.wait(SAVE_RETRY_DELAY)
	end

	warn(string.format("Failed to save rooster selection for %s: %s", player.Name, tostring(lastError)))
	return false
end

local function scheduleSelectionSave(player)
	if saveDebounces[player] then
		return
	end

	saveDebounces[player] = true

	task.delay(1.5, function()
		saveDebounces[player] = nil

		if player.Parent then
			saveSelectedCharacter(player)
		end
	end)
end

local function applyCharacterAttributes(player, configName)
	local config = getCharacterConfig(configName)
	player:SetAttribute("SelectedRooster", configName)
	player:SetAttribute("CharacterDamageBonus", config.DamageBonus)
	player:SetAttribute("CharacterHealthBonus", config.HealthBonus)
	player:SetAttribute("CharacterWalkSpeed", config.WalkSpeed)
end

local function loadSelectedCharacter(player)
	local success, storedCharacter = pcall(function()
		return CHARACTER_STORE:GetAsync(getCharacterDataKey(player))
	end)

	if success and type(storedCharacter) == "string" and CharacterConfig.IsValid(storedCharacter) then
		applyCharacterAttributes(player, storedCharacter)
	else
		applyCharacterAttributes(player, CharacterConfig.DefaultCharacterName)
	end
end

local function applyRoosterMorph(player, character)
	local selectedCharacter = player:GetAttribute("SelectedRooster") or "Kenchi"
	local config = getCharacterConfig(selectedCharacter)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local head = character:WaitForChild("Head")
	local leftLeg = findFirstPart(character, { "LeftFoot", "LeftLowerLeg", "Left Leg" })
	local rightLeg = findFirstPart(character, { "RightFoot", "RightLowerLeg", "Right Leg" })

	clearOldMorph(character)
	hideDefaultCharacter(character)

	humanoid.WalkSpeed = config.WalkSpeed
	humanoid.JumpPower = config.JumpPower
	humanoid.UseJumpPower = true
	humanoid.HipHeight = config.HipHeight
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = config.DisplayName

	local morphModel = Instance.new("Model")
	morphModel.Name = "RoosterMorph"
	morphModel.Parent = character

	local jointsFolder = Instance.new("Folder")
	jointsFolder.Name = "Joints"
	jointsFolder.Parent = morphModel

	attachToRoot(morphModel, rootPart, config)
	attachToHead(morphModel, head, config)

	if leftLeg then
		attachLegMorph(morphModel, leftLeg, "Left", config)
	end

	if rightLeg then
		attachLegMorph(morphModel, rightLeg, "Right", config)
	end
end

local function applyCharacterMovementStats(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local selectedCharacter = player:GetAttribute("SelectedRooster") or "Kenchi"
	local config = getCharacterConfig(selectedCharacter)

	if not humanoid then
		return
	end

	humanoid.WalkSpeed = config.WalkSpeed
	humanoid.JumpPower = config.JumpPower
	humanoid.UseJumpPower = true
	humanoid.HipHeight = config.HipHeight
end

local function onCharacterAdded(player, character)
	task.defer(applyRoosterMorph, player, character)
end

local function setSelectedCharacter(player, characterName)
    if type(characterName) ~= "string" or not CharacterConfig.IsValid(characterName) then
        return
    end

    if player:GetAttribute("SelectedRooster") == characterName then
        return
    end

    local now = Workspace:GetServerTimeNow()
    local availableAt = player:GetAttribute("RoosterSwapAvailableAt") or 0
    if availableAt > now then
        return
    end

    player:SetAttribute("RoosterSwapAvailableAt", now + ROOSTER_SWAP_COOLDOWN)
    applyCharacterAttributes(player, characterName)
    scheduleSelectionSave(player)
    applyCharacterMovementStats(player)

    local character = player.Character
    if character then
        task.defer(applyRoosterMorph, player, character)
    end
end

characterSelectRemote.OnServerEvent:Connect(function(player, characterName)
	setSelectedCharacter(player, characterName)
end)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("RoosterSwapAvailableAt", 0)
	loadSelectedCharacter(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player:GetAttribute("RoosterSwapAvailableAt") == nil then
		player:SetAttribute("RoosterSwapAvailableAt", 0)
	end
	loadSelectedCharacter(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	if player.Character then
		task.defer(applyRoosterMorph, player, player.Character)
	end
end

Players.PlayerRemoving:Connect(function(player)
	saveDebounces[player] = nil
	saveSelectedCharacter(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveSelectedCharacter(player)
	end
end)




