extends Node
#Stat
var is_det_eye_active: bool = false
var player_hp: int = 500
var player_max_hp: int =500
#Inventory
var inventory: Array = []
#signal-> for UI
signal clue_collected(clue_name)
signal inventory_updated(inventor:Array)
signal det_eye_toggled(active)

var naga_defeated:bool=false
var has_sword:bool=false
var talked_to_elder:bool=false
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
