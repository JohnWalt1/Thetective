# DialogManager.gd (Autoload)
extends Node

var dialog_box: Node = null

func _ready():
	# Cari DialogBox di scene utama (asumsikan ada di UI)
	# Atau kamu bisa instance secara manual
	var main = get_tree().current_scene
	if main:
		dialog_box = main.get_node_or_null("UI/DialogBox")
		if not dialog_box:
			# Jika tidak ada, buat instance dari scene
			var scene = load("res://Scenes/UI/DialogBox.tscn")
			if scene:
				dialog_box = scene.instantiate()
				main.add_child(dialog_box)
				print("[DialogManager] DialogBox di-instance otomatis.")

func show_dialog(npc_name: String, text: String):
	if dialog_box:
		dialog_box.show_dialog(npc_name, text)
	else:
		print("[DialogManager] ERROR: DialogBox tidak ditemukan!")
