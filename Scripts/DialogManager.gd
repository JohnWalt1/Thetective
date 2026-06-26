# DialogManager.gd (Autoload)
extends Node

@onready var textbox_scene=preload("res://Scenes/text_box.tscn")
var dialog_lines:Array[String]=[]
var current_line_idx=0
var text_box
var tb_pos:Vector2
var is_dialog_active=false
var can_advance_line= false
func start_dialog(position:Vector2,lines:Array[String]):
	if is_dialog_active:
		return
	dialog_lines=lines
	tb_pos=position
	_show_text_box()
	is_dialog_active=true
	
func _show_text_box():
	text_box=textbox_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	#text_box.global_position= tb_pos
	text_box.display(dialog_lines[current_line_idx],tb_pos)
	can_advance_line=false
	
func _on_text_box_finished_displaying():
	print(">>> _on_text_box_finished_displaying received")
	can_advance_line=true
	
func _unhandled_input(event):
	if not (is_dialog_active && can_advance_line):
		return

	# Hanya respon terhadap klik kiri mouse atau tombol aksi (spasi/enter)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_dialog()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		_advance_dialog()

func _advance_dialog():
	text_box.queue_free()
	current_line_idx += 1
	if current_line_idx >= dialog_lines.size():
		is_dialog_active = false
		current_line_idx = 0
		print("Dialog selesai")
		return
	_show_text_box()
