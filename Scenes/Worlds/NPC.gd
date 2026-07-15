extends CharacterBody2D
#Story
@export var required_flag: String = ""
@export var required_flag_value: bool = true
@export var required_story_progress: int = -1
var is_story_unlocked: bool = false
#det_eyes
@export var is_hidden_clue: bool = false  
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var dialog_entries: Array[DialogCondition]=[]

# ==========================================
#  INIT
# ==========================================
func _ready():
	add_to_group("npc")
	_check_story_availability()
	_update_appearance()
	sprite.play("default")
	if is_hidden_clue:
		add_to_group("det_eye_hidden")
		
		visible = false
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = true
		if has_node("CollisionPolygon2D"):
			$CollisionPolygon2D.disabled = true
		process_mode = PROCESS_MODE_DISABLED
		
	else:

		visible = true
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = false
		process_mode = PROCESS_MODE_INHERIT

func _check_story_availability():
	var should_unlock=true
	if required_flag!="":
		if Global.get_flag(required_flag)!=required_flag_value:
			should_unlock=false
	if required_story_progress != -1:
		if Global.story_progress < required_story_progress:
			should_unlock = false
	
	is_story_unlocked = should_unlock
	if not is_story_unlocked:
		if is_in_group("det_eye_hidden"):
			remove_from_group("det_eye_hidden")

func _update_appearance():
	if not is_story_unlocked:
		visible = false
		_set_collision_enabled(false)
		process_mode = PROCESS_MODE_DISABLED
		return
	var eyes_active = Global.is_det_eye_active
	if is_hidden_clue:
		if eyes_active:
			visible=true
			_set_collision_enabled(true)
			process_mode=Node.PROCESS_MODE_INHERIT
		else:
			visible=false
			_set_collision_enabled(false)
			process_mode=Node.PROCESS_MODE_DISABLED
	else:
		visible=true
		_set_collision_enabled(true)
		process_mode=Node.PROCESS_MODE_INHERIT

func _set_collision_enabled(enabled:bool):
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = not enabled
	if has_node("CollisionPolygon2D"):
		$CollisionPolygon2D.disabled = not enabled
		
func refresh_visibility():
	_check_story_availability()
	_update_appearance()
func _resolve_entry() -> DialogCondition:

	for entry in dialog_entries:
		var result:=dialog_entries
		if result:
			return entry
	return null

func interact():
	Global.pause_gameplay()
	var entry:=_resolve_entry()
	if entry==null or entry.lines.is_empty():
		Global.resume_gameplay()
		print("Tidak ada lah :v")
		return
	DialogManager.dialog_ended.connect(_on_custom_dialog_finished, CONNECT_ONE_SHOT)
	DialogManager.start_dialog(global_position, entry.lines)
	Global.set_flag("on_naga_defeated",true)


func _on_custom_dialog_finished():
	Global.resume_gameplay()

	
func _check_condition(entry: DialogCondition) -> bool:
	if entry.condition_flag == "":
		return true
	var current := Global.get_flag(entry.condition_flag)
	print("    get_flag('%s') = %s, expected = %s" % [entry.condition_flag, current, entry.expected_value])
	return current == entry.expected_value
	return Global.get(entry.condition_flag) == entry.expected_value
