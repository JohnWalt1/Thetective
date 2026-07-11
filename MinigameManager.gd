extends Node

signal minigame_started()
signal minigame_ended(reward)

var current_minigame:MinigameBase=null
var minigame_scenes:Dictionary={
	"overlap_puzzle":preload("res://overlap_puzzle.tscn")
}


func start_minigame(minigame_id:String,data:Dictionary={}):
	if current_minigame:
		return
	if not minigame_scenes.has(minigame_id):
		return
	var scene=minigame_scenes[minigame_id]
	current_minigame=scene.instantiate
	
	var canvas = get_tree().current_scene.get_node_or_null("CanvasLayer")
	if not canvas:
		canvas = CanvasLayer.new()
		get_tree().current_scene.add_child(canvas)
	canvas.add_child(current_minigame)
	
	# Inisialisasi dengan data
	if current_minigame.has_method("setup"):
		current_minigame.setup(data)
	
	current_minigame.completed.connect(_on_minigame_completed)
	minigame_started.emit()
	
func _on_minigame_completed(reward):
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	minigame_ended.emit(reward)
	give_reward(reward)
	
func give_reward(reward: Dictionary):
	if reward.type == "flag":
		Global.set_flag(reward.id, true) 
	elif reward.type == "item":
		var item="res://Resources/ItemDatas/BarangAneh.tres"
		InventoryManager.add_item(item)
	else:
		print("Unknown reward: ", reward)
