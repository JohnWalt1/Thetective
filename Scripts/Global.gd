extends Node
#Stat
var is_det_eye_active: bool = false
var player_hp: int = 500
var player_max_hp: int =500
var inventory: Array = []
var is_gameplay_paused:bool=false
var story_progress:int=0
var _active_ysort: Node = null 
var flags: Dictionary = {
	"talked_to_slime": false,
	"naga_defeated": false,
	"has_sword": false,
	"talked_to_elder": false,
}

signal inventory_updated(inventory:Array)
signal det_eye_toggled(active)
signal flag_changed(flag_name:String,value)

func add_clue(item_name:String):
	if not inventory.has(item_name):
		inventory.append(item_name)
	else:
		print("Clue sudah ada:",item_name)

func toggle_det_eye(active:bool):
	is_det_eye_active=active
	det_eye_toggled.emit(active)
	

func set_flag(flag_name: String, value) -> void:
	flags[flag_name] = value
	Dialogic.VAR.set_variable(flag_name,value)
	flag_changed.emit(name,value)
	
func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name,null)
	
func register_ysort(node: Node) -> void:
	_active_ysort = node
	
func pause_gameplay():
	if _active_ysort:
		_active_ysort.process_mode = Node.PROCESS_MODE_DISABLED

func resume_gameplay():
	if _active_ysort:
		_active_ysort.process_mode = Node.PROCESS_MODE_INHERIT
