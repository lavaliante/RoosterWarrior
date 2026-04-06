local Workspace = game:GetService("Workspace")

local function updateBar(fillFrame, humanoid)
	local healthPercent = 0

	if humanoid.MaxHealth > 0 then
		healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	end

	fillFrame.Size = UDim2.new(healthPercent, 0, 1, 0)

	if healthPercent > 0.6 then
		fillFrame.BackgroundColor3 = Color3.fromRGB(96, 255, 114)
	elseif healthPercent > 0.3 then
		fillFrame.BackgroundColor3 = Color3.fromRGB(255, 210, 70)
	else
		fillFrame.BackgroundColor3 = Color3.fromRGB(255, 88, 88)
	end
end

local function attachHealthBar(demonModel)
	if demonModel:FindFirstChild("HealthBarGui") then
		return
	end

	local head = demonModel:FindFirstChild("Head")
	local humanoid = demonModel:FindFirstChildOfClass("Humanoid")

	if not head or not humanoid then
		return
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "HealthBarGui"
	billboardGui.Size = UDim2.new(0, 120, 0, 18)
	billboardGui.StudsOffset = Vector3.new(0, 4.5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 120
	billboardGui.Adornee = head
	billboardGui.Parent = demonModel

	local backFrame = Instance.new("Frame")
	backFrame.Name = "Back"
	backFrame.Size = UDim2.new(1, 0, 1, 0)
	backFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	backFrame.BorderSizePixel = 0
	backFrame.Parent = billboardGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = backFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 2)
	padding.PaddingLeft = UDim.new(0, 2)
	padding.PaddingRight = UDim.new(0, 2)
	padding.PaddingTop = UDim.new(0, 2)
	padding.Parent = backFrame

	local fillFrame = Instance.new("Frame")
	fillFrame.Name = "Fill"
	fillFrame.Position = UDim2.fromScale(0, 0)
	fillFrame.Size = UDim2.new(1, 0, 1, 0)
	fillFrame.BorderSizePixel = 0
	fillFrame.Parent = backFrame

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 5)
	fillCorner.Parent = fillFrame

	updateBar(fillFrame, humanoid)

	humanoid.HealthChanged:Connect(function()
		if fillFrame.Parent then
			updateBar(fillFrame, humanoid)
		end
	end)
end

local function onChildAdded(instance)
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		task.defer(attachHealthBar, instance)
	end
end

for _, instance in ipairs(Workspace:GetChildren()) do
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		attachHealthBar(instance)
	end
end

Workspace.ChildAdded:Connect(onChildAdded)
