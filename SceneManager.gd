extends Node


# Called when the node enters the scene tree for the first time.
var pending_spawn_id:String="default"

func goto_scene(scene_path:String,spawn_id:String="default")->void:
	pending_spawn_id=spawn_id
	get_tree().change_scene_to_file(scene_path)
