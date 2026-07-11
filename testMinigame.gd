extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data={
		"level_id":2
	}
	MinigameManager.start_minigame("overlap_puzzle",data)
