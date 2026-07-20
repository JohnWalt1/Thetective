extends Node

signal clue_collected(clue_id: String)

var collected: Dictionary = {}  
var secret_collected:Dictionary={}
func collect(clue_id: String, is_secret:bool=false) -> void:
	if clue_id=="" or collected.has(clue_id):
		return
	collected[clue_id] = true
	if is_secret:
		secret_collected[clue_id]=true
	clue_collected.emit(clue_id)

func count() -> int:
	return collected.size()

func secret_count() -> int:
	return secret_collected.size()

func has(clue_id: String) -> bool:
	return collected.has(clue_id)
