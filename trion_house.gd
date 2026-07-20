extends Node

@onready var ysort: Node = $ysort
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	Global.register_ysort(ysort)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	StoryManager.recheck()

func _on_dialogic_signal(arg: String) -> void:
	match arg:
		"act2_goto_new_district":
			_unlock_new_district()
		_:
			pass

func _unlock_new_district() -> void:
	# buka akses area baru di scene, atau ganti scene kalau district-nya terpisah
	pass
