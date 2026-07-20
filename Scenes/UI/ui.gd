extends CanvasLayer

@onready var button: Button = $Button
@onready var usable_panel: UsablePanel = $UsablePanel

func _ready():
	button.pressed.connect(_open_usable_popup)


func _open_usable_popup():
	usable_panel.popup_centered()

func show_locked_message(text:String)->void:
	print(text)
