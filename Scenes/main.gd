extends Node

@onready var button: Button = $UI/Button
@onready var usable_panel: UsablePanel = $UI/UsablePanel
@onready var ysort: Node = $ysort

func _ready():
	Global.register_ysort(ysort)
	button.pressed.connect(_open_usable_popup)
	StoryManager.recheck()
func _open_usable_popup():
	usable_panel.popup_centered()
