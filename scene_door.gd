extends Interactable
class_name SceneDoor

@export var target_scene_path:String=""
@export var target_spawn_id:String="default"
@export var required_flag:String=""
@export var required_flag_value:bool=true
@export var locked_message:String="Tidak bisa mengakses area ini, lanjutkan story atau tunggu update"

func _on_interact(_source:Node)->void:
	if not _check_acces():
		UI.show_locked_message(locked_message)
		return
	SceneManager.goto_scene(target_scene_path,target_spawn_id)

func _check_acces()->bool:
	if required_flag=="":
		return true
	return Global.get_flag(required_flag)==required_flag_value
