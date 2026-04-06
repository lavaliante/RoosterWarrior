local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function createLabel(parent, name, position, size, font, textSize, textColor, alignment)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = font
	label.Text = ""
	label.TextColor3 = textColor
	label.TextSize = textSize
	label.TextXAlignment = alignment or Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createContainer(screenGui, size, position)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(1, 0)
	container.Position = position
	container.Size = size
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BackgroundTransparency = 0.15
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = container

	return container
end

local function createMissionGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("MissionGui")

	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MissionGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local rewardBanner = Instance.new("Frame")
	rewardBanner.Name = "RewardBanner"
	rewardBanner.AnchorPoint = Vector2.new(0.5, 0)
	rewardBanner.Position = isMobile and UDim2.new(0.5, 0, 0, 70) or UDim2.new(0.5, 0, 0, 92)
	rewardBanner.Size = isMobile and UDim2.new(0, 174, 0, 32) or UDim2.new(0, 220, 0, 38)
	rewardBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	rewardBanner.BackgroundTransparency = 0.12
	rewardBanner.BorderSizePixel = 0
	rewardBanner.Visible = false
	rewardBanner.Parent = screenGui

	local rewardCorner = Instance.new("UICorner")
	rewardCorner.CornerRadius = UDim.new(0, 14)
	rewardCorner.Parent = rewardBanner

	local rewardStroke = Instance.new("UIStroke")
	rewardStroke.Color = Color3.fromRGB(255, 215, 90)
	rewardStroke.Thickness = 2
	rewardStroke.Parent = rewardBanner

	local rewardLabel = createLabel(rewardBanner, "RewardLabel", UDim2.new(0, 12, 0, 0), UDim2.new(1, -24, 1, 0), Enum.Font.GothamBold, isMobile and 12 or 14, Color3.fromRGB(255, 243, 176), Enum.TextXAlignment.Center)
	rewardLabel.Text = "+10 Feathers"

	local ui = {
		IsMobile = isMobile,
		RewardBanner = rewardBanner,
		RewardLabel = rewardLabel,
	}

	if isMobile then
		local container = createContainer(screenGui, UDim2.new(0, 156, 0, 86), UDim2.new(1, -12, 0, 14))

		local waveLabel = createLabel(container, "WaveLabel", UDim2.new(0, 10, 0, 6), UDim2.new(1, -20, 0, 14), Enum.Font.GothamBold, 12, Color3.fromRGB(255, 243, 176))
		local waveStatusLabel = createLabel(container, "WaveStatusLabel", UDim2.new(0, 10, 0, 20), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, 10, Color3.fromRGB(255, 255, 255))
		local civilianLabel = createLabel(container, "CivilianLabel", UDim2.new(0, 10, 0, 32), UDim2.new(1, -20, 0, 12), Enum.Font.GothamBold, 10, Color3.fromRGB(142, 255, 156))
		local divider = Instance.new("Frame")
		divider.Name = "Divider"
		divider.BackgroundColor3 = Color3.fromRGB(255, 215, 90)
		divider.BackgroundTransparency = 0.35
		divider.BorderSizePixel = 0
		divider.Position = UDim2.new(0, 10, 0, 46)
		divider.Size = UDim2.new(1, -20, 0, 1)
		divider.Parent = container

		local missionLabel = createLabel(container, "MissionLabel", UDim2.new(0, 10, 0, 51), UDim2.new(1, -20, 0, 11), Enum.Font.Gotham, 10, Color3.fromRGB(255, 255, 255))
		local progressLabel = createLabel(container, "ProgressLabel", UDim2.new(0, 10, 0, 64), UDim2.new(1, -20, 0, 11), Enum.Font.GothamBold, 11, Color3.fromRGB(98, 255, 111))

		ui.MissionLabel = missionLabel
		ui.ProgressLabel = progressLabel
		ui.WaveLabel = waveLabel
		ui.WaveStatusLabel = waveStatusLabel
		ui.CivilianLabel = civilianLabel
		return ui
	end

	local container = createContainer(screenGui, UDim2.new(0, 250, 0, 90), UDim2.new(1, -20, 0, 108))

	local titleLabel = createLabel(container, "TitleLabel", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18), Enum.Font.GothamBold, 14, Color3.fromRGB(255, 243, 176))
	titleLabel.Text = "CURRENT MISSION"

	local missionLabel = createLabel(container, "MissionLabel", UDim2.new(0, 12, 0, 30), UDim2.new(1, -24, 0, 18), Enum.Font.Gotham, 16, Color3.fromRGB(255, 255, 255))
	local progressLabel = createLabel(container, "ProgressLabel", UDim2.new(0, 12, 0, 56), UDim2.new(1, -24, 0, 20), Enum.Font.GothamBold, 18, Color3.fromRGB(98, 255, 111))

	ui.MissionLabel = missionLabel
	ui.ProgressLabel = progressLabel
	return ui
end

local function updateMissionUI(ui, missionTitle, missionProgress, missionTarget, missionComplete)
	ui.MissionLabel.Text = missionTitle.Value

	if missionComplete.Value then
		ui.ProgressLabel.Text = "Complete!"
		ui.ProgressLabel.TextColor3 = Color3.fromRGB(255, 221, 92)
	else
		ui.ProgressLabel.Text = string.format("%d / %d", missionProgress.Value, missionTarget.Value)
		ui.ProgressLabel.TextColor3 = Color3.fromRGB(98, 255, 111)
	end
end

local function updateWaveUI(ui, waveNumber, aliveEnemies, targetEnemies, status, activeCivilians, totalCivilians, lostThisWave, maxLosses, protectionStatus)
	if not ui.IsMobile then
		return
	end

	ui.WaveLabel.Text = "Wave " .. tostring(math.max(1, waveNumber.Value))

	if string.find(status.Value, "Next wave", 1, true) or string.find(status.Value, "Retry", 1, true) then
		ui.WaveStatusLabel.Text = status.Value
		ui.WaveStatusLabel.TextColor3 = string.find(status.Value, "Retry", 1, true) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(255, 221, 92)
	else
		ui.WaveStatusLabel.Text = string.format("%d / %d left", aliveEnemies.Value, targetEnemies.Value)
		ui.WaveStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	ui.CivilianLabel.Text = string.format("Civ %d/%d  Loss %d/%d", activeCivilians.Value, totalCivilians.Value, lostThisWave.Value, maxLosses.Value)

	if lostThisWave.Value <= 0 then
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(142, 255, 156)
	elseif lostThisWave.Value < maxLosses.Value then
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(255, 214, 102)
	else
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(255, 110, 110)
	end

end

local function connectMissionData()
	local missionFolder = player:WaitForChild("MissionData")
	local missionTitle = missionFolder:WaitForChild("MissionTitle")
	local missionProgress = missionFolder:WaitForChild("MissionProgress")
	local missionTarget = missionFolder:WaitForChild("MissionTarget")
	local missionComplete = missionFolder:WaitForChild("MissionComplete")
	local ui = createMissionGui()
	local previousMissionComplete = missionComplete.Value

	local waveState
	local waveNumber
	local aliveEnemies
	local targetEnemies
	local status
	local protectionState
	local activeCivilians
	local totalCivilians
	local lostThisWave
	local maxLosses
	local protectionStatus

	if ui.IsMobile then
		waveState = Workspace:WaitForChild("WaveState")
		waveNumber = waveState:WaitForChild("WaveNumber")
		aliveEnemies = waveState:WaitForChild("AliveEnemies")
		targetEnemies = waveState:WaitForChild("TargetEnemies")
		status = waveState:WaitForChild("Status")
		protectionState = Workspace:WaitForChild("CivilianProtectionState")
		activeCivilians = protectionState:WaitForChild("ActiveCivilians")
		totalCivilians = protectionState:WaitForChild("TotalCivilians")
		lostThisWave = protectionState:WaitForChild("LostThisWave")
		maxLosses = protectionState:WaitForChild("MaxLosses")
		protectionStatus = protectionState:WaitForChild("Status")
	end

	local function refreshMission()
		if ui.MissionLabel.Parent and ui.ProgressLabel.Parent then
			updateMissionUI(ui, missionTitle, missionProgress, missionTarget, missionComplete)
		end

		if missionComplete.Value and not previousMissionComplete and ui.RewardBanner then
			ui.RewardBanner.Visible = true
			ui.RewardBanner.Position = ui.IsMobile and UDim2.new(0.5, 0, 0, 84) or UDim2.new(0.5, 0, 0, 104)
			ui.RewardBanner.BackgroundTransparency = 0.12
			ui.RewardLabel.TextTransparency = 0

			local inTween = TweenService:Create(ui.RewardBanner, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = ui.IsMobile and UDim2.new(0.5, 0, 0, 70) or UDim2.new(0.5, 0, 0, 92),
			})
			inTween:Play()

			task.delay(1.2, function()
				if not ui.RewardBanner.Parent then
					return
				end

				local outTween = TweenService:Create(ui.RewardBanner, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = ui.IsMobile and UDim2.new(0.5, 0, 0, 58) or UDim2.new(0.5, 0, 0, 80),
					BackgroundTransparency = 1,
				})
				local textTween = TweenService:Create(ui.RewardLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 1,
				})
				outTween:Play()
				textTween:Play()
				outTween.Completed:Once(function()
					if ui.RewardBanner.Parent then
						ui.RewardBanner.Visible = false
					end
				end)
			end)
		end

		previousMissionComplete = missionComplete.Value
	end

	local function refreshWave()
		if ui.IsMobile and ui.WaveLabel.Parent and ui.WaveStatusLabel.Parent then
			updateWaveUI(ui, waveNumber, aliveEnemies, targetEnemies, status, activeCivilians, totalCivilians, lostThisWave, maxLosses, protectionStatus)
		end
	end

	refreshMission()
	refreshWave()

	missionTitle.Changed:Connect(refreshMission)
	missionProgress.Changed:Connect(refreshMission)
	missionTarget.Changed:Connect(refreshMission)
	missionComplete.Changed:Connect(refreshMission)

	if ui.IsMobile then
		waveNumber.Changed:Connect(refreshWave)
		aliveEnemies.Changed:Connect(refreshWave)
		targetEnemies.Changed:Connect(refreshWave)
		status.Changed:Connect(refreshWave)
		activeCivilians.Changed:Connect(refreshWave)
		totalCivilians.Changed:Connect(refreshWave)
		lostThisWave.Changed:Connect(refreshWave)
		maxLosses.Changed:Connect(refreshWave)
		protectionStatus.Changed:Connect(refreshWave)
	end
end

connectMissionData()
