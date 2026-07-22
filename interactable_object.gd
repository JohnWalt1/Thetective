extends Interactable
class_name InteractableObject

@export var dialog_entries:Array[DialogCondition]=[]

func _on_interact(_source:Node)->void:
	Global.pause_gameplay()
	var entry:=_resolve_entry()
	if entry==null or entry.lines.is_empty():
		Global.resume_gameplay()
		return
	DialogManager.dialog_ended.connect(_on_dialog_finished,CONNECT_ONE_SHOT)
	DialogManager.start(global_position,entry.lines)

func _on_dialog_finished()->void:
	Global.resume_gameplay()
func _resolve_entry()->DialogCondition:
	for entry in dialog_entries:
		if entry.check_condition():
			return entry
	return null
