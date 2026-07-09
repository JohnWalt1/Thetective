extends GridContainer
class_name InventoryGrid

signal item_selected(item: ItemData)

var _selected_item:ItemData=null
const SLOT_SCENE := preload("res://ui/inventory_slot.tscn")
var tooltip: ItemTooltip


func _ready():
	tooltip=load("res://Scenes/ItemTooltip.tscn").instantiate()
	add_child(tooltip)
	tooltip.hide()

func _show_tooltip(item,pos):
	tooltip.show_tooltip(item,pos)
	
func _hide_tooltip():
	if tooltip:
		tooltip.hide()


func populate(items: Array) -> void:
	for child in get_children():
		if child is InventorySlot:
			child.queue_free()
	await get_tree().process_frame

	for item in items:
		var slot: InventorySlot = SLOT_SCENE.instantiate()
		add_child(slot)
		slot.set_item(item)
		slot.slot_pressed.connect(_on_slot_pressed)
		slot.hover_started.connect(_show_tooltip)
		slot.hover_ended.connect(_hide_tooltip)


func _on_slot_pressed(item: ItemData) -> void:
	item_selected.emit(item)
