extends Resource
class_name StoryTrigger

enum TriggerType { SPECIFIC_CLUE, CLUE_COUNT, FLAG }
@export var id :String=""
@export var type: TriggerType
@export var required_clue_id: String = ""
@export var required_count: int = 0
@export var required_flag: String = ""
@export var invert_condition: bool = false
@export var timeline: DialogicTimeline
@export var one_shot: bool = true
@export var pause_gameplay_during: bool = true
