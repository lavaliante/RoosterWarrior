local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local missionRefreshQueued = false
local waveRefreshQueued = false

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
		local container = createContainer(screenGui, UDim2.new(0, 176, 0, 102), UDim2.new(1, -12, 0, 14))

		local chapterLabel = createLabel(container, "ChapterLabel", UDim2.new(0, 10, 0, 6), UDim2.new(1, -20, 0, 12), Enum.Font.GothamBold, 10, Color3.fromRGB(255, 221, 92))
		local waveLabel = createLabel(container, "WaveLabel", UDim2.new(0, 10, 0, 20), UDim2.new(1, -20, 0, 14), Enum.Font.GothamBold, 12, Color3.fromRGB(255, 243, 176))
		local waveStatusLabel = createLabel(container, "WaveStatusLabel", UDim2.new(0, 10, 0, 34), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, 10, Color3.fromRGB(255, 255, 255))
		local civilianLabel = createLabel(container, "CivilianLabel", UDim2.new(0, 10, 0, 46), UDim2.new(1, -20, 0, 12), Enum.Font.GothamBold, 10, Color3.fromRGB(142, 255, 156))
		local divider = Instance.new("Frame")
		divider.Name = "Divider"
		divider.BackgroundColor3 = Color3.fromRGB(255, 215, 90)
		divider.BackgroundTransparency = 0.35
		divider.BorderSizePixel = 0
		divider.Position = UDim2.new(0, 10, 0, 60)
		divider.Size = UDim2.new(1, -20, 0, 1)
		divider.Parent = container

		local missionLabel = createLabel(container, "MissionLabel", UDim2.new(0, 10, 0, 65), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, 10, Color3.fromRGB(255, 255, 255))
		local progressLabel = createLabel(container, "ProgressLabel", UDim2.new(0, 10, 0, 79), UDim2.new(1, -20, 0, 12), Enum.Font.GothamBold, 11, Color3.fromRGB(98, 255, 111))

		ui.ChapterLabel = chapterLabel
		ui.MissionLabel = missionLabel
		ui.ProgressLabel = progressLabel
		ui.WaveLabel = waveLabel
		ui.WaveStatusLabel = waveStatusLabel
		ui.CivilianLabel = civilianLabel
		return ui
	end

	local container = createContainer(screenGui, UDim2.new(0, 290, 0, 110), UDim2.new(1, -20, 0, 108))

	local titleLabel = createLabel(container, "TitleLabel", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18), Enum.Font.GothamBold, 14, Color3.fromRGB(255, 243, 176))
		
	local missionLabel = createLabel(container, "MissionLabel", UDim2.new(0, 12, 0, 32), UDim2.new(1, -24, 0, 30), Enum.Font.Gotham, 15, Color3.fromRGB(255, 255, 255))
	local progressLabel = createLabel(container, "ProgressLabel", UDim2.new(0, 12, 0, 74), UDim2.new(1, -24, 0, 22), Enum.Font.GothamBold, 18, Color3.fromRGB(98, 255, 111))

	ui.TitleLabel = titleLabel
	ui.MissionLabel = missionLabel
	ui.ProgressLabel = progressLabel
	return ui
end

local function updateMissionUI(ui, chapterTitle, missionTitle, missionProgress, missionTarget, missionComplete, campaignComplete)
	if ui.TitleLabel then
		ui.TitleLabel.Text = chapterTitle.Value ~= "" and string.upper(chapterTitle.Value) or "CURRENT MISSION"
	end

	if ui.ChapterLabel then
		ui.ChapterLabel.Text = chapterTitle.Value ~= "" and chapterTitle.Value or "Current Mission"
	end

	ui.MissionLabel.Text = missionTitle.Value

	if campaignComplete.Value then
		ui.ProgressLabel.Text = "Chapter Cleared"
		ui.ProgressLabel.TextColor3 = Color3.fromRGB(255, 221, 92)
	elseif missionComplete.Value then
		ui.ProgressLabel.Text = "Complete!"
		ui.ProgressLabel.TextColor3 = Color3.fromRGB(255, 221, 92)
	else
		ui.ProgressLabel.Text = string.format("%d / %d", missionProgress.Value, missionTarget.Value)
		ui.ProgressLabel.TextColor3 = Color3.fromRGB(98, 255, 111)
	end
end

local function updateWaveUI(ui, waveNumber, aliveEnemies, targetEnemies, status, activeCivilians, totalCivilians, lostThisWave, protectionStatus)
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

	ui.CivilianLabel.Text = string.format("Civ %d/%d  Lost %d", activeCivilians.Value, totalCivilians.Value, lostThisWave.Value)

	if activeCivilians.Value > math.floor(totalCivilians.Value * 0.5) then
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(142, 255, 156)
	elseif activeCivilians.Value > 1 then
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(255, 214, 102)
	else
		ui.CivilianLabel.TextColor3 = Color3.fromRGB(255, 110, 110)
	end
end

local function connectMissionData()
	local missionFolder = player:WaitForChild("MissionData")
	local chapterTitle = missionFolder:WaitForChild("ChapterTitle")
	local missionTitle = missionFolder:WaitForChild("MissionTitle")
	local missionProgress = missionFolder:WaitForChild("MissionProgress")
	local missionTarget = missionFolder:WaitForChild("MissionTarget")
	local missionComplete = missionFolder:WaitForChild("MissionComplete")
	local campaignComplete = missionFolder:WaitForChild("CampaignComplete")
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
		protectionStatus = protectionState:WaitForChild("Status")
	end

	local function refreshMission()
		missionRefreshQueued = false
		if ui.MissionLabel.Parent and ui.ProgressLabel.Parent then
			updateMissionUI(ui, chapterTitle, missionTitle, missionProgress, missionTarget, missionComplete, campaignComplete)
		end

		if missionComplete.Value and not previousMissionComplete and ui.RewardBanner and not campaignComplete.Value then
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
		waveRefreshQueued = false
		if ui.IsMobile and ui.WaveLabel.Parent and ui.WaveStatusLabel.Parent then
			updateWaveUI(ui, waveNumber, aliveEnemies, targetEnemies, status, activeCivilians, totalCivilians, lostThisWave, protectionStatus)
		end
	end

	local function queueMissionRefresh()
		if missionRefreshQueued then
			return
		end

		missionRefreshQueued = true
		task.defer(refreshMission)
	end

	local function queueWaveRefresh()
		if waveRefreshQueued then
			return
		end

		waveRefreshQueued = true
		task.defer(refreshWave)
	end

	refreshMission()
	refreshWave()

	chapterTitle.Changed:Connect(queueMissionRefresh)
	missionTitle.Changed:Connect(queueMissionRefresh)
	missionProgress.Changed:Connect(queueMissionRefresh)
	missionTarget.Changed:Connect(queueMissionRefresh)
	missionComplete.Changed:Connect(queueMissionRefresh)
	campaignComplete.Changed:Connect(queueMissionRefresh)

	if ui.IsMobile then
		waveNumber.Changed:Connect(queueWaveRefresh)
		aliveEnemies.Changed:Connect(queueWaveRefresh)
		targetEnemies.Changed:Connect(queueWaveRefresh)
		status.Changed:Connect(queueWaveRefresh)
		activeCivilians.Changed:Connect(queueWaveRefresh)
		totalCivilians.Changed:Connect(queueWaveRefresh)
		lostThisWave.Changed:Connect(queueWaveRefresh)
		protectionStatus.Changed:Connect(queueWaveRefresh)
	end
end

connectMissionData()
