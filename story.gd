extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("timeline01")
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
func _on_timeline_ended():
	# Putuskan sambungan sinyal agar tidak terpanggil dua kali
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	
	# Ganti ke scene utama
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
