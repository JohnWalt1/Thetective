extends Control
class_name MinigameBase

signal completed(reward: Dictionary)

var reward_data: Dictionary = {}

func setup(data: Dictionary):
	pass

func complete(reward: Dictionary):
	reward_data = reward
	completed.emit(reward)
