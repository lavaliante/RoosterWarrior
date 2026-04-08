local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ATTACK_FLAP_DURATION = 0.22

local activeConnection
local activeTrack = {
	lastPeck = 0,
	lastScratch = 0,
}

local function applyJointC0(joint, baseC0, offset)
	if joint and joint.Parent then
		joint.C0 = baseC0 * offset
	end
end

local function hookAttackTracking(character)
	character:GetAttributeChangedSignal("PeckTick"):Connect(function()
		activeTrack.lastPeck = os.clock()
	end)

	character:GetAttributeChangedSignal("ScratchTick"):Connect(function()
		activeTrack.lastScratch = os.clock()
	end)

	activeTrack.lastPeck = 0
	activeTrack.lastScratch = 0
end

local function startAnimation(character)
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end

	local humanoid = character:WaitForChild("Humanoid")
	local morphModel = character:WaitForChild("RoosterMorph")
	local jointsFolder = morphModel:WaitForChild("Joints")

	local bodyJoint = jointsFolder:FindFirstChild("RoosterBodyJoint")
	local chestJoint = jointsFolder:FindFirstChild("RoosterChestJoint")
	local headJoint = jointsFolder:FindFirstChild("RoosterFaceJoint")
	local leftWingJoint = jointsFolder:FindFirstChild("LeftWingJoint")
	local rightWingJoint = jointsFolder:FindFirstChild("RightWingJoint")
	local leftWingTipJoint = jointsFolder:FindFirstChild("LeftWingTipJoint")
	local rightWingTipJoint = jointsFolder:FindFirstChild("RightWingTipJoint")
	local tail1Joint = jointsFolder:FindFirstChild("Tail1Joint")
	local tail2Joint = jointsFolder:FindFirstChild("Tail2Joint")
	local tail3Joint = jointsFolder:FindFirstChild("Tail3Joint")

	local baseC0 = {
		body = bodyJoint and bodyJoint.C0,
		chest = chestJoint and chestJoint.C0,
		head = headJoint and headJoint.C0,
		leftWing = leftWingJoint and leftWingJoint.C0,
		rightWing = rightWingJoint and rightWingJoint.C0,
		leftWingTip = leftWingTipJoint and leftWingTipJoint.C0,
		rightWingTip = rightWingTipJoint and rightWingTipJoint.C0,
		tail1 = tail1Joint and tail1Joint.C0,
		tail2 = tail2Joint and tail2Joint.C0,
		tail3 = tail3Joint and tail3Joint.C0,
	}

	hookAttackTracking(character)

	activeConnection = RunService.RenderStepped:Connect(function()
		if not character.Parent or humanoid.Health <= 0 then
			return
		end

		if player:GetAttribute("SelectedRooster") ~= "Keijuke" then
			return
		end

		local now = os.clock()
		local moveSpeed = humanoid.MoveDirection.Magnitude
		local moving = moveSpeed > 0.05
		local bobTime = tick() * 6.4
		local idleTime = tick() * 2.6
		local bobAmount = moving and math.sin(bobTime) * 0.08 or math.sin(idleTime) * 0.035
		local swayAmount = moving and math.sin(bobTime * 0.5) * 0.07 or 0
		local headNod = moving and math.sin(bobTime) * math.rad(3) or math.sin(idleTime) * math.rad(1.5)
		local wingFlap = moving and math.sin(bobTime) * math.rad(5) or math.sin(idleTime) * math.rad(2)
		local tailSwing = moving and math.sin(bobTime * 0.65) * math.rad(5) or math.sin(idleTime * 0.8) * math.rad(2)

		local peckAlpha = 1 - math.clamp((now - activeTrack.lastPeck) / ATTACK_FLAP_DURATION, 0, 1)
		local scratchAlpha = 1 - math.clamp((now - activeTrack.lastScratch) / ATTACK_FLAP_DURATION, 0, 1)
		local attackBodyDip = peckAlpha * -0.16
		local attackHeadThrust = peckAlpha * 0.26
		local attackWingBurst = math.max(peckAlpha, scratchAlpha) * math.rad(16)
		local scratchSway = scratchAlpha * math.rad(12)
		local scratchHeadTurn = scratchAlpha * math.rad(7)
		local scratchHeadDip = scratchAlpha * math.rad(5)

		applyJointC0(bodyJoint, baseC0.body, CFrame.new(0, bobAmount + attackBodyDip, 0) * CFrame.Angles(0, swayAmount + scratchSway, 0))
		applyJointC0(chestJoint, baseC0.chest, CFrame.new(0, bobAmount * 0.4, -attackHeadThrust * 0.25))
		applyJointC0(headJoint, baseC0.head, CFrame.new(0, bobAmount * 0.2, -attackHeadThrust) * CFrame.Angles(headNod + peckAlpha * math.rad(-10) + scratchHeadDip, scratchHeadTurn, 0))
		applyJointC0(leftWingJoint, baseC0.leftWing, CFrame.Angles(0, 0, math.rad(42) + wingFlap - attackWingBurst))
		applyJointC0(rightWingJoint, baseC0.rightWing, CFrame.Angles(0, 0, math.rad(-42) - wingFlap + attackWingBurst))
		applyJointC0(leftWingTipJoint, baseC0.leftWingTip, CFrame.Angles(0, 0, math.rad(58) + wingFlap * 1.15 - attackWingBurst))
		applyJointC0(rightWingTipJoint, baseC0.rightWingTip, CFrame.Angles(0, 0, math.rad(-58) - wingFlap * 1.15 + attackWingBurst))
		applyJointC0(tail1Joint, baseC0.tail1, CFrame.Angles(0, tailSwing, 0))
		applyJointC0(tail2Joint, baseC0.tail2, CFrame.Angles(0, tailSwing * 1.1, 0))
		applyJointC0(tail3Joint, baseC0.tail3, CFrame.Angles(0, tailSwing * 0.9, 0))
	end)
end

local function onCharacterAdded(character)
	task.defer(startAnimation, character)
end

if player.Character then
	task.defer(startAnimation, player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
