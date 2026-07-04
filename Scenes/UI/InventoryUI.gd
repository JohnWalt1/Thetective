extends Control

# --- Referensi node UI ---
@onready var item_grid: GridContainer = $Panel/ItemGrid
@onready var equip_grid: GridContainer = $Panel/EquipGrid
@onready var detail_panel: Panel = $Panel/DetailPanel
@onready var detail_name: Label = $Panel/DetailPanel/VBoxContainer/NameLabel
@onready var detail_quality: Label = $Panel/DetailPanel/VBoxContainer/QualityLabel
@onready var detail_desc: Label = $Panel/DetailPanel/VBoxContainer/DescLabel
@onready var detail_stats: Label = $Panel/DetailPanel/VBoxContainer/StatsLabel

# --- Referensi Manager ---
var inventory_manager: InventoryManager

func setup(manager: InventoryManager) -> void:
	inventory_manager = manager
	# Koneksikan sinyal untuk update otomatis
	if not inventory_manager.inventory_updated.is_connected(_update_ui):
		inventory_manager.inventory_updated.connect(_update_ui)
	_update_ui()

func _update_ui() -> void:
	_clear_grid(item_grid)
	_clear_grid(equip_grid)

	# Tampilkan item biasa
	for item in inventory_manager.items:
		var btn = _create_item_button(item)
		item_grid.add_child(btn)

	# Tampilkan equipment
	for item in inventory_manager.equipment:
		var btn = _create_item_button(item)
		equip_grid.add_child(btn)

	# Sembunyikan detail jika inventory berubah
	detail_panel.visible = false

func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		child.queue_free()

func _create_item_button(item: ItemData) -> Button:
	var btn = Button.new()
	btn.icon = item.icon
	btn.tooltip_text = item.name
	btn.custom_minimum_size = Vector2(64, 64)
	# Ukuran ikon agar pas
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.expand_icon = true
	btn.flat = false
	
	# Simpan referensi item ke dalam button
	btn.set_meta("item_data", item)
	btn.pressed.connect(_on_item_clicked.bind(item))
	return btn

func _on_item_clicked(item: ItemData) -> void:
	# Tampilkan detail item di panel
	detail_name.text = item.name
	detail_quality.text = "Quality: " + item.quality
	detail_desc.text = item.description
	
	var stats_text = ""
	if item.stats.is_empty():
		stats_text = "No stats"
	else:
		for key in item.stats:
			stats_text += str(key) + ": " + str(item.stats[key]) + "\n"
	detail_stats.text = stats_text
	
	detail_panel.visible = true

# Sembunyikan detail jika klik di luar panel
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if detail_panel.visible:
			var mouse_pos = get_global_mouse_position()
			if not detail_panel.get_global_rect().has_point(mouse_pos):
				detail_panel.visible = false

# Bisa juga tombol close di panel detail
func _on_close_button_pressed() -> void:
	detail_panel.visible = false

func toggle()->void:
	visible=not visible
	if visible:
		_update_ui()
