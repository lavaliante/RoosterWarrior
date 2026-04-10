local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function createGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("FarmAlarmGui")
	if existingGui then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FarmAlarmGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local isMobile = UserInputService.TouchEnabled

	local banner = Instance.new("Frame")
	banner.Name = "Banner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = isMobile and UDim2.new(0.5, 0, 0, 132) or UDim2.new(0.5, 0, 0, 24)
	banner.Size = isMobile and UDim2.new(0, 300, 0, 60) or UDim2.new(0, 360, 0, 52)
	banner.BackgroundColor3 = Color3.fromRGB(110, 22, 22)
	banner.BackgroundTransparency = 0.08
	banner.BorderSizePixel = 0
	banner.Visible = false
	banner.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = banner

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 120)
	stroke.Thickness = 2
	stroke.Parent = banner

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 14, 0, 6)
	title.Size = UDim2.new(1, -28, 0, 18)
	title.Font = Enum.Font.GothamBold
	title.Text = "Farm Attack"
	title.TextColor3 = Color3.fromRGB(255, 235, 188)
	title.TextSize = isMobile and 16 or 18
	title.Parent = banner

	local body = Instance.new("TextLabel")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 14, 0, 25)
	body.Size = UDim2.new(1, -28, 0, isMobile and 26 or 18)
	body.Font = Enum.Font.Gotham
	body.Text = "Demons are attacking the farms. Protect the villagers."
	body.TextColor3 = Color3.fromRGB(255, 255, 255)
	body.TextSize = isMobile and 12 or 14
	body.TextWrapped = isMobile
	body.Parent = banner

	return banner, isMobile
end

local banner, isMobile = createGui()
local visible = false

local function setBannerVisible(shouldShow)
	if shouldShow == visible then
		return
	end

	visible = shouldShow

	if shouldShow then
		banner.Visible = true
		banner.Position = isMobile and UDim2.new(0.5, 0, 0, 118) or UDim2.new(0.5, 0, 0, 10)
		banner.BackgroundTransparency = 0.4
		TweenService:Create(banner, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = isMobile and UDim2.new(0.5, 0, 0, 132) or UDim2.new(0.5, 0, 0, 24),
			BackgroundTransparency = 0.08,
		}):Play()
	else
		local tween = TweenService:Create(banner, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = isMobile and UDim2.new(0.5, 0, 0, 118) or UDim2.new(0.5, 0, 0, 10),
			BackgroundTransparency = 1,
		})
		tween:Play()
		tween.Completed:Once(function()
			if not visible and banner.Parent then
				banner.Visible = false
			end
		end)
	end
end

local function connectWaveState()
	local waveState = Workspace:WaitForChild("WaveState")
	local alarmActive = waveState:WaitForChild("AlarmActive")
	local status = waveState:WaitForChild("Status")

	local function refresh()
		local shouldShow = alarmActive.Value == true and string.find(status.Value, "Alarm!", 1, true) ~= nil
		setBannerVisible(shouldShow)
	end

	alarmActive.Changed:Connect(refresh)
	status.Changed:Connect(refresh)
	refresh()
end

connectWaveState()
