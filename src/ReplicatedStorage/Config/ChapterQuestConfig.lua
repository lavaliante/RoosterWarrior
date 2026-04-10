local ChapterQuestConfig = {
	ChapterId = "Chapter1",
	ChapterTitle = "Chapter 1 - Suncrest Village",
	CompletionTitle = "Chapter Complete",
	CompletionDescription = "Suncrest Village stands for now. Master Kaien is ready to guide you beyond the eastern docks.",
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
			Id = "ClearTheBlackMist",
			Title = "Clear 3 black mist pockets from the fields",
			Target = 3,
			CompletionType = "PlayerAttributeCount",
			AttributeName = "MistClearedCount",
		},
		{
			Id = "RescueTheForestEdge",
			Title = "Rescue 2 stranded villagers near the forest edge",
			Target = 2,
			CompletionType = "PlayerAttributeCount",
			AttributeName = "VillagersRescuedCount",
		},
		{
			Id = "BreakTheBlueRaiders",
			Title = "Break the Blue Demon raiders at the forest edge",
			Target = 2,
			CompletionType = "KillEnemyType",
			EnemyType = "BlueDemon",
		},
		{
			Id = "MeetMasterKaien",
			Title = "Speak with Master Kaien at the eastern docks",
			Target = 1,
			CompletionType = "TalkToNpc",
			NpcAttribute = "TalkedToMasterKaien",
		},
	},
}

return ChapterQuestConfig
