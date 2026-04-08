local AttackConfig = {}

AttackConfig.ServerBase = {
	Peck = {
		Damage = 24,
		Cooldown = 0.4,
		HitboxSize = Vector3.new(5, 4.5, 6),
		ForwardOffset = 4.5,
		Knockback = 55,
		HitBurstColor = Color3.fromRGB(255, 214, 97),
	},
	Scratch = {
		Damage = 14,
		Cooldown = 0.65,
		HitboxSize = Vector3.new(8, 4.5, 8),
		ForwardOffset = 3.2,
		Knockback = 32,
		HitBurstColor = Color3.fromRGB(255, 132, 74),
	},
}

AttackConfig.ServerCharacterModifiers = {
	Kenchi = {
		Peck = {
			Cooldown = 0.32,
			Damage = 26,
			ForwardOffset = 5.2,
			Knockback = 48,
			HitBurstColor = Color3.fromRGB(255, 234, 126),
		},
		Scratch = {
			Cooldown = 0.58,
			Damage = 15,
			ForwardOffset = 3.6,
			Knockback = 28,
			HitBurstColor = Color3.fromRGB(255, 166, 92),
		},
	},
	Kenjuke = {
		Peck = {
			Cooldown = 0.48,
			Damage = 22,
			ForwardOffset = 4.1,
			Knockback = 68,
			HitBurstColor = Color3.fromRGB(255, 132, 132),
		},
		Scratch = {
			Cooldown = 0.78,
			Damage = 20,
			HitboxSize = Vector3.new(9.5, 5, 9.5),
			ForwardOffset = 3.4,
			Knockback = 52,
			HitBurstColor = Color3.fromRGB(255, 94, 94),
		},
	},
}

AttackConfig.ClientBase = {
	Peck = {
		Cooldown = 0.4,
		LungeSpeed = 52,
		RecoverySpeed = 12,
		CameraPunchFov = 76,
		PulseColor = Color3.fromRGB(255, 217, 78),
		PulseOffset = CFrame.new(0, -1.75, -3.2),
		PulseSize = Vector3.new(0.35, 1.2, 1.2),
		PulseExpandSize = Vector3.new(0.35, 5.5, 5.5),
		SoundId = "rbxasset://sounds/swordlunge.wav",
		SoundVolume = 0.85,
		SoundPitch = 1.25,
	},
	Scratch = {
		Cooldown = 0.65,
		LungeSpeed = 24,
		RecoverySpeed = 8,
		CameraPunchFov = 73,
		PulseColor = Color3.fromRGB(255, 146, 76),
		PulseOffset = CFrame.new(0, -1.2, -2.4),
		PulseSize = Vector3.new(0.35, 1.6, 1.6),
		PulseExpandSize = Vector3.new(0.35, 6.8, 6.8),
		SoundId = "rbxasset://sounds/swordslash.wav",
		SoundVolume = 0.8,
		SoundPitch = 1.05,
	},
}

AttackConfig.ClientCharacterModifiers = {
	Kenchi = {
		Peck = {
			Cooldown = 0.32,
			LungeSpeed = 58,
			RecoverySpeed = 15,
			CameraPunchFov = 77,
			SoundPitch = 1.35,
			PulseExpandSize = Vector3.new(0.35, 6.2, 6.2),
		},
		Scratch = {
			Cooldown = 0.58,
			LungeSpeed = 28,
			RecoverySpeed = 10,
			CameraPunchFov = 74,
			SoundPitch = 1.12,
		},
	},
	Kenjuke = {
		Peck = {
			Cooldown = 0.48,
			LungeSpeed = 42,
			RecoverySpeed = 8,
			CameraPunchFov = 74,
			SoundPitch = 0.95,
			PulseColor = Color3.fromRGB(255, 128, 128),
		},
		Scratch = {
			Cooldown = 0.78,
			LungeSpeed = 18,
			RecoverySpeed = 6,
			CameraPunchFov = 78,
			SoundPitch = 0.82,
			PulseColor = Color3.fromRGB(255, 98, 98),
			PulseExpandSize = Vector3.new(0.35, 8.4, 8.4),
		},
	},
}

local function mergeConfig(baseConfig, modifierConfig)
	local mergedConfig = table.clone(baseConfig)

	if modifierConfig then
		for key, value in pairs(modifierConfig) do
			mergedConfig[key] = value
		end
	end

	return mergedConfig
end

function AttackConfig.GetServerAttackConfig(roosterName, attackName)
	local baseConfig = AttackConfig.ServerBase[attackName]

	if not baseConfig then
		return nil
	end

	local characterModifiers = AttackConfig.ServerCharacterModifiers[roosterName]
	return mergeConfig(baseConfig, characterModifiers and characterModifiers[attackName])
end

AttackConfig.ServerCharacterModifiers.Chico = AttackConfig.ServerCharacterModifiers.Kenjuke
AttackConfig.ServerCharacterModifiers.Keijuke = AttackConfig.ServerCharacterModifiers.Kenjuke
AttackConfig.ClientCharacterModifiers.Chico = AttackConfig.ClientCharacterModifiers.Kenjuke
AttackConfig.ClientCharacterModifiers.Keijuke = AttackConfig.ClientCharacterModifiers.Kenjuke

function AttackConfig.GetClientAttackConfig(roosterName, attackName)
	local baseConfig = AttackConfig.ClientBase[attackName]

	if not baseConfig then
		return nil
	end

	local characterModifiers = AttackConfig.ClientCharacterModifiers[roosterName]
	return mergeConfig(baseConfig, characterModifiers and characterModifiers[attackName])
end

return AttackConfig
