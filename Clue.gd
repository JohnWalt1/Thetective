# res://scripts/clue.gd
extends Interactable
class_name Clue

@export var clue_id: String = ""
@export var item_data: ItemData
@export var dialog_entries: Array[DialogCondition] = []
@export var is_secret_clue: bool = false 
func _on_interact(_source: Node) -> void:
	if clue_id == "":
		push_warning("Clue node tanpa clue_id: " + name)
		return
	if ClueManager.has(clue_id):
		return   # sudah pernah diambil, cegah re-trigger

	InventoryManager.add_item(item_data, 1)
	Global.pause_gameplay()

	var entry := _resolve_entry()
	if entry == null or entry.lines.is_empty():
		Global.resume_gameplay()
		ClueManager.collect(clue_id,is_secret_clue)
		return

	DialogManager.dialog_ended.connect(_on_dialog_finished, CONNECT_ONE_SHOT)
	DialogManager.start_dialog(global_position, entry.lines)

func _on_dialog_finished() -> void:
	Global.resume_gameplay()
	ClueManager.collect(clue_id,is_secret_clue)

func _resolve_entry() -> DialogCondition:
	for entry in dialog_entries:
		if entry.check_condition():
			return entry
	return null
