extends Node

const TRIGGER_FOLDER := "res://Resources/StoryTriggers/"

var triggers: Array[StoryTrigger] = []
var _fired_ids: Dictionary = {}  

func _ready() -> void:
	_load_all_triggers(TRIGGER_FOLDER)
	ClueManager.clue_collected.connect(_on_clue_collected)

func _load_all_triggers(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Folder story_triggers tidak ditemukan: " + path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(path + file_name)
			if res is StoryTrigger:
				triggers.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	print("StoryManager: loaded ", triggers.size(), " triggers")

func _on_clue_collected(_clue_id: String) -> void:
	_check_all_triggers()

func recheck() -> void:
	_check_all_triggers()

func _check_all_triggers() -> void:
	for t in triggers:
		print("checking ", t.id, " -> ", _is_condition_met(t))
		if t.one_shot and _fired_ids.has(t.id):
			continue
		if _is_condition_met(t):
			_fired_ids[t.id] = true
			_play_story(t)

func _is_condition_met(t: StoryTrigger) -> bool:
	var result := false
	match t.type:
		StoryTrigger.TriggerType.SPECIFIC_CLUE:
			result = ClueManager.has(t.required_clue_id)
		StoryTrigger.TriggerType.CLUE_COUNT:
			result = ClueManager.count() >= t.required_count
		StoryTrigger.TriggerType.FLAG:
			result = Dialogic.VAR.get_variable(t.required_flag) == true
			print("  [DEBUG] flag=", t.required_flag, " value=", Dialogic.VAR.get_variable(t.required_flag), " invert=", t.invert_condition)
	return not result if t.invert_condition else result

func _play_story(t: StoryTrigger) -> void:
	if t.pause_gameplay_during:
		Global.pause_gameplay()
	Dialogic.start(t.timeline)
	Dialogic.timeline_ended.connect(
		func(): _on_story_ended(t), CONNECT_ONE_SHOT
	)

func _on_story_ended(t: StoryTrigger) -> void:
	if t.pause_gameplay_during:
		Global.resume_gameplay()
