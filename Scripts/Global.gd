extends Node
#Stat
var is_det_eye_active: bool = false
var player_hp: int = 500
var player_max_hp: int =500
var inventory: Array = []
var is_gameplay_paused:bool=false

signal inventory_updated(inventor:Array)
signal det_eye_toggled(active)

var flags: Dictionary = {
	"talked_to_slime": false,
	"naga_defeated": false,
	"has_sword": false,
	"talked_to_elder": false,
}
func add_clue(item_name:String):
	if not inventory.has(item_name):
		inventory.append(item_name)
		print("Clue founded:",item_name)
		print("Inventory:",inventory)
	else:
		print("Clue sudah ada:",item_name)

func toggle_det_eye(active:bool):
	is_det_eye_active=active
	det_eye_toggled.emit(active)
	print("Det Eye status", active)

func set_flag(flag_name: String, value: bool = true) -> void:
	if flag_name not in flags:
		push_warning("Flag '%s' tidak dikenal" % flag_name)
		return
	flags[flag_name] = value
	print("[Global] Flag '%s' = %s" % [flag_name, value])
	
func get_flag(flag_name: String) -> bool:
	if flag_name not in flags:
		push_warning("Flag '%s' tidak dikenal" % flag_name)
		return false
	return flags[flag_name]

func pause_gameplay():
	if is_gameplay_paused:
		return
	is_gameplay_paused=true
	get_tree().paused=true

func resume_gameplay():
	if not is_gameplay_paused:
		return
	is_gameplay_paused = false
	get_tree().paused = false
