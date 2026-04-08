local orderedCharacters = {
	{
		Name = "Kenchi",
		DisplayName = "Kenchi",
		Subtitle = "Balanced fighter",
		Stats = "Normal health, normal damage",
		MobileStats = "Balanced",
		ThemeColor = Color3.fromRGB(255, 221, 112),
		WalkSpeed = 20,
		JumpPower = 58,
		HipHeight = 1.6,
		HealthBonus = 0,
		DamageBonus = 0,
		BodyColor = BrickColor.new("Institutional white"),
		ChestColor = BrickColor.new("Light yellow"),
		WingColor = BrickColor.new("Light yellow"),
		LegColor = BrickColor.new("Bright yellow"),
		BeakColor = BrickColor.new("New Yeller"),
		CombColor = BrickColor.new("Bright red"),
		TailColor = BrickColor.new("Cool yellow"),
		TailTipColor = BrickColor.new("Brick yellow"),
	},
	{
		Name = "Kenjuke",
		DisplayName = "Kenjuke",
		Subtitle = "Heavy bruiser",
		Stats = "+30 health, +4 damage, slower speed",
		MobileStats = "+30 HP, +4 DMG",
		ThemeColor = Color3.fromRGB(255, 120, 120),
		WalkSpeed = 14,
		JumpPower = 56,
		HipHeight = 1.65,
		HealthBonus = 30,
		DamageBonus = 4,
		BodyColor = BrickColor.new("Dark stone grey"),
		ChestColor = BrickColor.new("Crimson"),
		WingColor = BrickColor.new("Really black"),
		LegColor = BrickColor.new("Reddish brown"),
		BeakColor = BrickColor.new("Bright orange"),
		CombColor = BrickColor.new("Bright red"),
		TailColor = BrickColor.new("Really black"),
		TailTipColor = BrickColor.new("Crimson"),
	},
}

local CharacterConfig = {
	DefaultCharacterName = "Kenchi",
	List = orderedCharacters,
	ByName = {},
	LegacyNames = {
		Chico = "Kenjuke",
		Keijuke = "Kenjuke",
	},
}

for _, character in ipairs(orderedCharacters) do
	CharacterConfig.ByName[character.Name] = character
end

for legacyName, canonicalName in pairs(CharacterConfig.LegacyNames) do
	CharacterConfig.ByName[legacyName] = CharacterConfig.ByName[canonicalName]
end

function CharacterConfig.NormalizeName(characterName)
	if type(characterName) ~= "string" then
		return CharacterConfig.DefaultCharacterName
	end

	return CharacterConfig.LegacyNames[characterName] or characterName
end

function CharacterConfig.Get(characterName)
	local normalizedName = CharacterConfig.NormalizeName(characterName)
	return CharacterConfig.ByName[normalizedName] or CharacterConfig.ByName[CharacterConfig.DefaultCharacterName]
end

function CharacterConfig.IsValid(characterName)
	local normalizedName = CharacterConfig.NormalizeName(characterName)
	return CharacterConfig.ByName[normalizedName] ~= nil
end

return CharacterConfig
