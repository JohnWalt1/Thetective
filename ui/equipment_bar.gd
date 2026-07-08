extends Control
class_name EquipmentBar

@onready var slot_buttons: Array[TextureButton] = [
	$HBoxContainer/Panel/Slot0,
	$HBoxContainer/Panel2/Slot1,
	$HBoxContainer/Panel3/Slot2,
	$HBoxContainer/Panel4/Slot3,
]
@onready var picker: EquipPickerPopup = $EquipPickerPopup



func _ready() -> void:
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(_on_slot_button_pressed.bind(i))
		slot_buttons[i].gui_input.connect(_on_slot_gui_input.bind(i))
	picker.item_chosen.connect(_on_item_chosen)
	InventoryManager.equipment_slot_changed.connect(_on_equipment_slot_changed)

	_refresh_all()


func _refresh_all() -> void:
	for i in range(slot_buttons.size()):
		_update_button_icon(i, InventoryManager.equipped_slots[i])


func _update_button_icon(index: int, item: ItemData) -> void:
	slot_buttons[index].texture_normal = item.icon if item else null


func _on_slot_button_pressed(index: int) -> void:
	picker.open_for_slot(index)


func _on_item_chosen(slot_index: int, item: ItemData) -> void:
	if item:
		InventoryManager.equip_item(slot_index, item)


func _on_equipment_slot_changed(slot_index: int, item: ItemData) -> void:
	_update_button_icon(slot_index, item)
	
func _on_slot_gui_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if InventoryManager.equipped_slots[index] != null:
			InventoryManager.unequip_slot(index)
