extends Area2D

@export var item_data:ItemData
@export var minigame_id:String=""
@export var minigame_data:Dictionary={}
var player_ref:Node2D=null
func _ready():
	pass
	

func _input(event:InputEvent):
	if event.is_action_pressed("interact") and has_overlapping_bodies():
		var bodies=get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				trigger_minigame()
				break

func trigger_minigame():
	MinigameManager.start_miigame(minigame_id,minigame_data)
