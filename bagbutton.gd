extends Button

@onready var usable: UsablePanel = $"../Usable"


func _pressed() -> void:
	usable.visible=true
	
