extends Node

signal clue_collected(clue_id: String)

var collected: Dictionary = {}  

func collect(clue_id: String) -> void:
	if collected.has(clue_id):
		return
	collected[clue_id] = true
	clue_collected.emit(clue_id)

func count() -> int:
	return collected.size()

func has(clue_id: String) -> bool:
	return collected.has(clue_id)
