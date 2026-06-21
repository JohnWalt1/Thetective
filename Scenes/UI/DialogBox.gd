# DialogBox.gd
extends CanvasLayer

# ==========================================
#  NODE REFS
# ==========================================
@onready var panel = $Panel
@onready var name_label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var text_label = $Panel/MarginContainer/VBoxContainer/TextLabel
@onready var continue_label = $Panel/MarginContainer/VBoxContainer/ContinueLabel

# ==========================================
#  VARIABLES
# ==========================================
var dialog_queue: Array = []       # Antrian kalimat [nama, teks]
var is_displaying: bool = false
var current_index: int = 0

# ==========================================
#  INIT
# ==========================================
func _ready():
	panel.visible = false
	continue_label.visible = false

# ==========================================
#  FUNGSI PUBLIK
# ==========================================
func show_dialog(npc_name: String, dialog_text: String):
	# Jika masih ada dialog berjalan, tambahkan ke antrian
	if is_displaying:
		dialog_queue.append([npc_name, dialog_text])
		return
	
	# Mulai dialog baru
	dialog_queue = [[npc_name, dialog_text]]
	current_index = 0
	display_current()

func display_current():
	if current_index >= dialog_queue.size():
		close_dialog()
		return
	
	var entry = dialog_queue[current_index]
	name_label.text = entry[0]
	text_label.text = entry[1]
	panel.visible = true
	is_displaying = true
	continue_label.visible = true

func next_line():
	current_index += 1
	if current_index < dialog_queue.size():
		display_current()
	else:
		close_dialog()

func close_dialog():
	panel.visible = false
	is_displaying = false
	continue_label.visible = false
	dialog_queue.clear()

# ==========================================
#  INPUT
# ==========================================
func _input(event):
	if not is_displaying:
		return
	
	# Lanjutkan dialog dengan Spasi, Enter, atau E (atau klik)
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		next_line()

# ==========================================
#  (OPSIONAL) EFFECT TYPEWRITER
# ==========================================
# Nanti bisa ditambahkan efek mengetik per karakter.
