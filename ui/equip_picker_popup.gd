extends PopupPanel
class_name EquipPickerPopup

signal item_chosen(slot_index: int, item: ItemData)

@onready var grid: InventoryGrid = $InventoryGrid

var target_slot_index: int = -1


func _ready() -> void:
	grid.item_selected.connect(_on_item_selected)
	InventoryManager.equipable_inventory_changed.connect(_on_equipable_inventory_changed)

# Panggil ini dari EquipmentBar saat salah satu dari 4 tombol slot ditekan
func open_for_slot(slot_index: int) -> void:
	target_slot_index = slot_index
	grid.populate(InventoryManager.equipable_items) # sama untuk keempat slot, tidak dipisah kategori
	popup_centered()


func _on_item_selected(item: ItemData) -> void:
	item_chosen.emit(target_slot_index, item)
	hide()
	
func _on_equipable_inventory_changed()->void:
	if visible:
		grid.populate(InventoryManager.equipable_items)
