extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/story.tscn")

func _on_quit_pressed():
	get_tree().quit()
	
func _on_options_pressed():
	pass
