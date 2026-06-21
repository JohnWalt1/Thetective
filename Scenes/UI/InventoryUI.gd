extends Panel

@onready var item_container: GridContainer = $ScrollContainer/GridContainer
@onready var close_button: Button = $CloseButton
@onready var empty_label: Label = $EmptyLabel  # Opsional: label "Inventory kosong"

func _ready():
	visible = false
	
	Global.clue_collected.connect(_on_clue_collected)
	
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	update_inventory_display()

# ==========================================
#  TOGGLE INVENTORY (DARI INPUT)
# ==========================================
func _input(event):
	# Tekan Tab atau I untuk buka/tutup inventory
	if event.is_action_pressed("inventory_toggle"):
		visible = !visible
		if visible:
			update_inventory_display()  # Refresh isi saat dibuka
			
func update_inventory_display():
	# Hapus semua anak di GridContainer (kecuali jika ada template)
	for child in item_container.get_children():
		child.queue_free()
	
	# Jika inventory kosong
	if Global.inventory.is_empty():
		if empty_label:
			empty_label.visible = true
		return
	else:
		if empty_label:
			empty_label.visible = false
	
	# Buat slot untuk setiap item di inventory
	for item_name in Global.inventory:
		var slot = create_item_slot(item_name)
		item_container.add_child(slot)

func create_item_slot(item_name: String) -> Panel:
	var slot = Panel.new()
	slot.size = Vector2(120, 40)
	
	# border
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.7)
	slot.add_theme_stylebox_override("panel", style)
	
	# Label nama item
	var label = Label.new()
	label.text = "🔍 " + item_name
	label.position = Vector2(10, 8)
	label.add_theme_color_override("font_color", Color.WHITE)
	slot.add_child(label)
	
	
	
	return slot

func _on_clue_collected(clue_name: String):
	# Update otomatis saat clue baru ditambahkan (tanpa harus buka/tutup)
	# Tapi hanya jika inventory sedang terbuka
	if visible:
		update_inventory_display()
	print("[InventoryUI] Clue baru: ", clue_name)

func _on_close_button_pressed():
	visible = false
