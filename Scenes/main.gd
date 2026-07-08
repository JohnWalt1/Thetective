extends Node

@onready var button: Button = $UI/Button
@onready var usable_panel: UsablePanel = $UI/UsablePanel

func _ready():
	button.pressed.connect(_open_usable_popup)

func _open_usable_popup():
	usable_panel.popup_centered()
