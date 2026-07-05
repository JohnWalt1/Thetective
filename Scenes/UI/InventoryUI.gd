extends Control

# --- Referensi node UI ---
@onready var weapon_slot = $Panel/VBoxContainer/HBoxContainer/WeaponSlotButton
@onready var head_slot = $Panel/VBoxContainer/HBoxContainer/HeadSlotButton
@onready var chest_slot = $Panel/VBoxContainer/HBoxContainer/ChestSlotButton
@onready var accessory_slot = $Panel/VBoxContainer/HBoxContainer/AccessorySlotButton
@onready var bag_button = $Panel/VBoxContainer/HBoxContainer/BagButton
@onready var close_button = $Panel/VBoxContainer/HBoxContainer/CloseButton
@onready var mode_label = $Panel/VBoxContainer/Label
@onready var item_grid = $Panel/VBoxContainer/ScrollContainer/ItemGrid
@onready var capacity_label = $Panel/VBoxContainer/CapacityLabel
@onready var detail_panel = $Panel/DetailPanel
@onready var detail_name = $DetailPanel/NameLabel
@onready var detail_quality = $DetailPanel/QualityLabel
@onready var detail_desc = $DetailPanel/DescLabel
@onready var detail_stats = $DetailPanel/StatsLabel
@onready var use_button = $DetailPanel/UseButton
@onready var close_detail_button = $DetailPanel/CloseDetailButton
# --- Referensi Manager ---
var inventory_manager: InventoryManager
var player: Player

enum Mode { EQUIPMENT, ITEMS }
var current_mode: Mode = Mode.ITEMS
var current_slot_filter: String = ""

func setup(manager: InventoryManager, player_node: Player) -> void:
	inventory_manager = manager
	player = player_node
	inventory_manager.inventory_updated.connect(_update_ui)
	_connect_signals()
	_update_ui()

func _connect_signals():
	weapon_slot.pressed.connect(_on_equipment_slot_pressed.bind("Weapon"))
	head_slot.pressed.connect(_on_equipment_slot_pressed.bind("Head"))
	chest_slot.pressed.connect(_on_equipment_slot_pressed.bind("Chest"))
	accessory_slot.pressed.connect(_on_equipment_slot_pressed.bind("Accessory"))
	bag_button.pressed.connect(_on_bag_pressed)
	close_button.pressed.connect(toggle)
	use_button.pressed.connect(_on_use_button_pressed)
	close_detail_button.pressed.connect(_on_close_detail)

func toggle() -> void:
	visible = not visible
	if visible:
		_update_ui()
		detail_panel.visible = false

func _update_ui() -> void:
	if not inventory_manager:
		return
	
	# 1. Update tombol equipment (slot yang terpakai)
	_update_equipment_slots()
	
	# 2. Update grid berdasarkan mode
	_update_grid()
	
	# 3. Update capacity
	capacity_label.text = str(inventory_manager.items.size()) + " / " + str(inventory_manager.max_inventory)

func _update_equipment_slots():
	var slots = {
		"Weapon": weapon_slot,
		"Head": head_slot,
		"Chest": chest_slot,
		"Accessory": accessory_slot
	}
	for slot_name in slots:
		var item = inventory_manager.get_equipment(slot_name)
		slots[slot_name].set_equipment(item)

func _update_grid():
	_clear_grid()
	var items_to_show: Array[ItemData] = []
	
	match current_mode:
		Mode.EQUIPMENT:
			mode_label.text = "Equipment"
			if current_slot_filter == "":
				items_to_show = inventory_manager.get_equipment_items()
			else:
				items_to_show = inventory_manager.get_equipment_items_for_slot(current_slot_filter)
		Mode.ITEMS:
			mode_label.text = "Items"
			items_to_show = inventory_manager.get_regular_items()
	
	# Buat slot grid
	for i in range(items_to_show.size()):
		var item = items_to_show[i]
		var slot = _create_item_slot(item, i)
		item_grid.add_child(slot)

func _create_item_slot(item: ItemData, index: int) -> Panel:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(64, 64)
	slot.size = Vector2(64, 64)
	slot.set_meta("item_index", index)
	
	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = _get_quality_color(item.quality) if item else Color(0.3,0.3,0.4)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	slot.add_theme_stylebox_override("panel", style)
	
	# Icon
	var icon = TextureRect.new()
	icon.texture = item.icon
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.custom_minimum_size = Vector2(56, 56)
	icon.position = Vector2(4, 4)
	slot.add_child(icon)
	
	# Stack label jika >1
	if item.max_stack > 1 and item.current_stack > 1:
		var stack_label = Label.new()
		stack_label.text = str(item.current_stack)
		stack_label.position = Vector2(44, 44)
		stack_label.add_theme_font_size_override("font_size", 14)
		stack_label.add_theme_color_override("font_color", Color.WHITE)
		slot.add_child(stack_label)
	
	# Event
	slot.gui_input.connect(_on_item_slot_gui_input.bind(index))
	return slot

func _clear_grid():
	for child in item_grid.get_children():
		child.queue_free()

func _get_quality_color(quality: String) -> Color:
	match quality:
		"Common": return Color(0.667, 0.667, 0.667)
		"Uncommon": return Color(0.118, 0.941, 0.0)
		"Rare": return Color(0.0, 0.439, 0.863)
		"Epic": return Color(0.639, 0.208, 0.933)
		"Legendary": return Color(1.0, 0.502, 0.0)
		_: return Color(0.3, 0.3, 0.4)

# --- Tombol-tombol ---
func _on_equipment_slot_pressed(slot_name: String):
	current_mode = Mode.EQUIPMENT
	current_slot_filter = slot_name   # tampilkan hanya equipment yang cocok slot ini
	detail_panel.visible = false
	_update_grid()

func _on_bag_pressed():
	current_mode = Mode.ITEMS
	current_slot_filter = ""
	detail_panel.visible = false
	_update_grid()

# --- Item slot click ---
func _on_item_slot_gui_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Dapatkan item berdasarkan mode dan filter
			var item = _get_item_at(index)
			if item:
				_show_detail(item, index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var item = _get_item_at(index)
			if item and item.is_consumable:
				inventory_manager.use_item(index, player)
				_update_ui()
				detail_panel.visible = false

func _get_item_at(index: int) -> ItemData:
	match current_mode:
		Mode.EQUIPMENT:
			if current_slot_filter == "":
				var list = inventory_manager.get_equipment_items()
				return list[index] if index < list.size() else null
			else:
				var list = inventory_manager.get_equipment_items_for_slot(current_slot_filter)
				return list[index] if index < list.size() else null
		Mode.ITEMS:
			var list = inventory_manager.get_regular_items()
			return list[index] if index < list.size() else null
	return null

# --- Detail panel ---
func _show_detail(item: ItemData, index: int):
	detail_name.text = item.name
	detail_quality.text = "Quality: " + item.quality
	detail_quality.add_theme_color_override("font_color", _get_quality_color(item.quality))
	detail_desc.text = item.description
	var stats_text = ""
	if item.is_consumable and item.use_effect:
		stats_text += "Effect: " + item.use_effect.description + "\n"
	if item.is_equipment:
		stats_text += "Slot: " + item.equip_slot + "\n"
	detail_stats.text = stats_text
	
	# Tombol Use / Equip
	if item.is_equipment:
		use_button.text = "Equip"
		use_button.set_meta("action", "equip")
		use_button.set_meta("index", index)
	else:
		use_button.text = "Use"
		use_button.set_meta("action", "use")
		use_button.set_meta("index", index)
	
	detail_panel.visible = true

func _on_use_button_pressed():
	var action = use_button.get_meta("action", "")
	var index = use_button.get_meta("index", -1)
	if action == "equip":
		# Coba equip item (dari inventory) ke slot yang sesuai
		var item = _get_item_at(index)
		if item and item.is_equipment:
			# Kita panggil use_item yang sudah menangani equip
			inventory_manager.use_item(index, player)
			_update_ui()
			detail_panel.visible = false
	elif action == "use":
		var item = _get_item_at(index)
		if item and item.is_consumable:
			inventory_manager.use_item(index, player)
			_update_ui()
			detail_panel.visible = false

func _on_close_detail():
	detail_panel.visible = false

# --- Toggle dari tombol luar (opsional) ---
func _on_toggle_button_pressed():
	toggle()
