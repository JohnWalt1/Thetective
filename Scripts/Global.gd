extends Node
#Stat
var is_det_eye_active: bool = false
var is_battle_active: bool = false
var player_hp: int = 500
var player_max_hp: int =500
#Inventory
var inventory: Array = []
#signal-> for UI
signal clue_collected(clue_name)
signal battle_started(enemy_data)
signal battle_ended(is_win)
signal det_eye_toggled(active)

func add_clue(item_name:String):
	if not inventory.has(item_name):
		inventory.append(item_name)
		print("Clue founded:",item_name)
	else:
		print("Clue sudah ada:",item_name)

func toggle_det_eye(active:bool):
	is_det_eye_active=active
	det_eye_toggled.emit(active)
	print("Det Eye status", active)
