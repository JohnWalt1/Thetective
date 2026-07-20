class_name DialogCondition
extends Resource


enum ConditionType { NONE, HAS_CLUE, MISSING_CLUE, FLAG_TRUE, FLAG_FALSE, HAS_ITEM ,SECRET_CLUE_COUNT_GTE}

@export var condition_type: ConditionType = ConditionType.NONE
@export var required_clue_id: String = ""
@export var required_flag: String = ""
@export var required_item: ItemData
@export var required_secret_clue_count: int = 0
@export var lines: Array[String] = []   
@export var sets_flag_on_trigger:String=""
func check_condition() -> bool:
	match condition_type:
		ConditionType.NONE:
			return true   
		ConditionType.HAS_CLUE:
			return ClueManager.has(required_clue_id)
		ConditionType.MISSING_CLUE:
			return not ClueManager.has(required_clue_id)
		ConditionType.FLAG_TRUE:
			return Dialogic.VAR.get_variable(required_flag) == true
		ConditionType.FLAG_FALSE:
			return Dialogic.VAR.get_variable(required_flag) == false
		ConditionType.HAS_ITEM:
			return InventoryManager.has_item(required_item)
		ConditionType.SECRET_CLUE_COUNT_GTE:
			return ClueManager.secret_count()>=required_secret_clue_count
	return false
