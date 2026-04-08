local ChapterQuestConfig = {
	ChapterId = "Chapter1",
	ChapterTitle = "Chapter 1 - Suncrest Village",
	CompletionTitle = "Chapter Complete",
	CompletionDescription = "Suncrest Village stands for now. The road beyond the eastern docks awaits.",
	Quests = {
		{
			Id = "LearnFromTheVillage",
			Title = "Talk to 3 villagers in Suncrest Village",
			Target = 3,
			CompletionType = "TalkToVillagers",
		},
		{
			Id = "DriveBackTheShadows",
			Title = "Drive back the first demon at the farms",
			Target = 1,
			CompletionType = "KillAny",
		},
		{
			Id = "HoldTheVillageLine",
			Title = "Hold the village line through wave 2",
			Target = 2,
			CompletionType = "ReachWave",
		},
		{
			Id = "BreakTheBlueRaiders",
			Title = "Defeat 2 Blue Demons at the farms",
			Target = 2,
			CompletionType = "KillEnemyType",
			EnemyType = "BlueDemon",
		},
		{
			Id = "SaveSuncrestVillage",
			Title = "Clear the final farm attack",
			Target = 3,
			CompletionType = "WaveCleared",
		},
	},
}

return ChapterQuestConfig
