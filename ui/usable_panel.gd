extends Control
class_name UsablePanel

@onready var grid: InventoryGrid = $InventoryGrid


func _ready() -> void:
	InventoryManager.usable_inventory_changed.connect(_refresh)
	grid.item_selected.connect(_on_item_selected)
	_refresh()


func _refresh() -> void:
	grid.populate(InventoryManager.usable_items)


func _on_item_selected(item: ItemData) -> void:
	if item:
		PlayerStats.use_item(item)
