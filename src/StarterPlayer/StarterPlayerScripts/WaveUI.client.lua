local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

if UserInputService.TouchEnabled then
	return
end

local refreshQueued = false

local function createWaveGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("WaveGui")

	if existingGui then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WaveGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Position = UDim2.new(0.5, 0, 0, 20)
	container.Size = UDim2.new(0, 320, 0, 110)
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

	local waveLabel = Instance.new("TextLabel")
	waveLabel.Name = "WaveLabel"
	waveLabel.BackgroundTransparency = 1
	waveLabel.Position = UDim2.new(0, 12, 0, 8)
	waveLabel.Size = UDim2.new(1, -24, 0, 24)
	waveLabel.Font = Enum.Font.GothamBold
	waveLabel.Text = "Wave 1"
	waveLabel.TextColor3 = Color3.fromRGB(255, 243, 176)
	waveLabel.TextSize = 22
	waveLabel.Parent = container

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.BackgroundTransparency = 1
	statusLabel.Position = UDim2.new(0, 12, 0, 38)
	statusLabel.Size = UDim2.new(1, -24, 0, 24)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Text = "Prepare for battle"
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.TextSize = 16
	statusLabel.Parent = container

	local civilianLabel = Instance.new("TextLabel")
	civilianLabel.Name = "CivilianLabel"
	civilianLabel.BackgroundTransparency = 1
	civilianLabel.Position = UDim2.new(0, 12, 0, 68)
	civilianLabel.Size = UDim2.new(1, -24, 0, 18)
	civilianLabel.Font = Enum.Font.GothamBold
	civilianLabel.Text = "Civilians 8/8"
	civilianLabel.TextColor3 = Color3.fromRGB(142, 255, 156)
	civilianLabel.TextSize = 15
	civilianLabel.Parent = container

	local protectionLabel = Instance.new("TextLabel")
	protectionLabel.Name = "ProtectionLabel"
	protectionLabel.BackgroundTransparency = 1
	protectionLabel.Position = UDim2.new(0, 12, 0, 86)
	protectionLabel.Size = UDim2.new(1, -24, 0, 16)
	protectionLabel.Font = Enum.Font.Gotham
	protectionLabel.Text = "Protect the village"
	protectionLabel.TextColor3 = Color3.fromRGB(255, 244, 188)
	protectionLabel.TextSize = 13
	protectionLabel.Parent = container

	return waveLabel, statusLabel, civilianLabel, protectionLabel
end

local function connectWaveState()
	local waveState = Workspace:WaitForChild("WaveState")
	local waveNumber = waveState:WaitForChild("WaveNumber")
	local aliveEnemies = waveState:WaitForChild("AliveEnemies")
	local targetEnemies = waveState:WaitForChild("TargetEnemies")
	local status = waveState:WaitForChild("Status")
	local protectionState = Workspace:WaitForChild("CivilianProtectionState")
	local activeCivilians = protectionState:WaitForChild("ActiveCivilians")
	local totalCivilians = protectionState:WaitForChild("TotalCivilians")
	local lostThisWave = protectionState:WaitForChild("LostThisWave")
	local protectionStatus = protectionState:WaitForChild("Status")
	local waveLabel, statusLabel, civilianLabel, protectionLabel = createWaveGui()

	local function refresh()
		refreshQueued = false
		waveLabel.Text = "Wave " .. tostring(math.max(1, waveNumber.Value))

		if string.find(status.Value, "Next wave", 1, true) or string.find(status.Value, "Retry", 1, true) then
			statusLabel.Text = status.Value
			statusLabel.TextColor3 = string.find(status.Value, "Retry", 1, true) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(255, 221, 92)
		else
			statusLabel.Text = string.format("%s  |  %d / %d left", status.Value, aliveEnemies.Value, targetEnemies.Value)
			statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		civilianLabel.Text = string.format(
			"Civilians %d / %d  |  Lost %d",
			activeCivilians.Value,
			totalCivilians.Value,
			lostThisWave.Value
		)

		if activeCivilians.Value > math.floor(totalCivilians.Value * 0.5) then
			civilianLabel.TextColor3 = Color3.fromRGB(142, 255, 156)
		elseif activeCivilians.Value > 1 then
			civilianLabel.TextColor3 = Color3.fromRGB(255, 214, 102)
		else
			civilianLabel.TextColor3 = Color3.fromRGB(255, 110, 110)
		end

		protectionLabel.Text = protectionStatus.Value
		protectionLabel.TextColor3 = activeCivilians.Value <= 1
			and Color3.fromRGB(255, 120, 120)
			or Color3.fromRGB(255, 244, 188)
	end

	local function queueRefresh()
		if refreshQueued then
			return
		end

		refreshQueued = true
		task.defer(refresh)
	end

	refresh()
	waveNumber.Changed:Connect(queueRefresh)
	aliveEnemies.Changed:Connect(queueRefresh)
	targetEnemies.Changed:Connect(queueRefresh)
	status.Changed:Connect(queueRefresh)
	activeCivilians.Changed:Connect(queueRefresh)
	totalCivilians.Changed:Connect(queueRefresh)
	lostThisWave.Changed:Connect(queueRefresh)
	protectionStatus.Changed:Connect(queueRefresh)
end

connectWaveState()
