extends Node

@onready var button: Button = $UI/Button
@onready var usable_panel: UsablePanel = $UI/UsablePanel
var is_begin=true
func _ready():
	button.pressed.connect(_open_usable_popup)
	if not Dialogic.VAR.act1_completed:
		start_tutorial_intro()
	else:
		pass
func _open_usable_popup():
	usable_panel.popup_centered()
	
func start_tutorial_intro():
	get_node("ysort").process_mode=Node.PROCESS_MODE_DISABLED
	
	Dialogic.start("Intro")
	Dialogic.timeline_ended.connect(_on_intro_ended, CONNECT_ONE_SHOT)
func _on_intro_ended():
	get_node("ysort").process_mode=Node.PROCESS_MODE_INHERIT
