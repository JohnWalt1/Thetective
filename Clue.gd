extends Area2D

@export var item_data:ItemData
@export var minigame_id:String=""
@export var minigame_data:Dictionary={}
var player_ref:Node2D=null
@export var trigger_story: DialogicTimeline=null
@export var dialog_entries: Array[DialogCondition]=[]
@export var is_puzzle:bool=false
func _ready():
	pass
	

func _input(event:InputEvent):
	if event.is_action_pressed("interact") and has_overlapping_bodies():
		var bodies=get_overlapping_bodies()
		InventoryManager.add_item(item_data,1)
		Global.pause_gameplay()
		var entry:=_resolve_entry()
		if entry==null or entry.lines.is_empty():
			Global.resume_gameplay()
			print("Tidak ada lah :v")
			return
		DialogManager.dialog_ended.connect(_on_custom_dialog_finished, CONNECT_ONE_SHOT)
		DialogManager.start_dialog(global_position, entry.lines)
		for body in bodies:
			if body.is_in_group("player") and is_puzzle:
				trigger_minigame()
				break
func _on_custom_dialog_finished():
	Global.resume_gameplay()
	if trigger_story!=null:
		trigger_dialogic()
func _resolve_entry() -> DialogCondition:
	for entry in dialog_entries:
		var result:=dialog_entries
		if result:
			return entry
	return null

func trigger_dialogic():
	Global.pause_gameplay()
	Dialogic.start("Arrest")
	Dialogic.timeline_ended.connect(_on_arrest_ended, CONNECT_ONE_SHOT)

func _on_arrest_ended():
	Global.resume_gameplay()
	Dialogic.VAR.act1_completed=true

func trigger_minigame():
	MinigameManager.start_minigame(minigame_id,minigame_data)
