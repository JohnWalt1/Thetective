extends Interactable
class_name PuzzleTrigger

@export var clue_id: String = ""
@export var item_data: ItemData
@export var level: PuzzleLevelData
@export var dialog_entries: Array[DialogCondition] = []
@export var is_secret_clue: bool = false 
func _on_interact(_source: Node) -> void:
	if clue_id == "":
		push_warning("PuzzleClue tanpa clue_id: " + name)
		return
	if not level:
		push_warning("PuzzleClue '%s' belum diisi level-nya." % name)
		return
	if ClueManager.has(clue_id):
		return   # sudah pernah selesai, cegah re-trigger

	Global.pause_gameplay()

	var entry := _resolve_entry()
	if entry != null and not entry.lines.is_empty():
		DialogManager.dialog_ended.connect(_on_intro_dialog_finished, CONNECT_ONE_SHOT)
		DialogManager.start_dialog(global_position, entry.lines)
	else:
		_start_puzzle()

func _on_intro_dialog_finished() -> void:
	_start_puzzle()

func _start_puzzle() -> void:
	MinigameManager.minigame_closed.connect(_on_puzzle_finished, CONNECT_ONE_SHOT)
	MinigameManager.open_minigame("overlap_puzzle", {"level": level})

func _on_puzzle_finished(_minigame_name:String,result:Dictionary) -> void:
	Global.resume_gameplay()
	var success=result.get("success",false)
	if success:
		if item_data:
			InventoryManager.add_item(item_data, 1)
		ClueManager.collect(clue_id,is_secret_clue)
	else:
		return

func _resolve_entry() -> DialogCondition:
	for entry in dialog_entries:
		if entry.check_condition():
			return entry
	return null
