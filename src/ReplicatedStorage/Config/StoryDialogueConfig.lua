local StoryDialogueConfig = {
	Civilians = {
		FirstTalkLines = {
			"The mist keeps creeping closer to the fields. Something is wrong out there.",
			"My chickens would not settle last night. They kept staring at the forest.",
			"The elders whisper about demons, but I thought those were only stories.",
			"Please be careful near the farms. We heard screaming after sunset.",
			"Black rot spread across the wheat in a single night. That is no natural blight.",
			"If the old Rooster Warrior legends are real, we may need one now more than ever.",
		},
		RepeatTalkLines = {
			"Stay sharp. The village is counting on you.",
			"The roads are not safe after dark anymore.",
			"If you head east, watch the tree line.",
		},
	},
	StrandedVillagers = {
		RescueLines = {
			"Thank you! I thought the demons had me for sure.",
			"Bless you. I could not find my way back alone.",
			"You came just in time. Something is moving near the water.",
			"I froze when I heard them. Thank the Rooster Warrior.",
		},
	},
	MasterKaien = {
		Name = "Master Kaien",
		PreEndingPrompt = {
			Speaker = "Master Kaien",
			Text = "The eastern dock is the village entrance. Hold the line here, and speak to me again when the farms are safe.",
		},
		EndingReveal = {
			{
				Speaker = "Master Kaien",
				Text = "You stood against the darkness when the whole village trembled. That is no small thing, young rooster.",
			},
			{
				Speaker = "Master Kaien",
				Text = "The mark in your feathers carries an old bloodline. The Rooster Warriors were not erased after all.",
			},
			{
				Speaker = "Master Kaien",
				Text = "Meet me at the eastern docks when you are ready. Suncrest was only the beginning.",
			},
		},
		PostEndingPrompt = {
			Speaker = "Master Kaien",
			Text = "When you are ready, the eastern sea will carry us toward the truth behind these demons.",
		},
		LateJoinGreeting = {
			Speaker = "Master Kaien",
			Text = "Suncrest stands because you fought. Meet me at the eastern docks.",
		},
	},
}

return StoryDialogueConfig
