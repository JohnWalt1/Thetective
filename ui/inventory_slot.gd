extends Button
class_name InventorySlot

signal slot_pressed(item: ItemData)

var item_data: ItemData = null

@onready var icon_rect: TextureRect = $Icon

signal hover_started(item:ItemData,position:Vector2)
signal hover_ended()


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_item(item: ItemData) -> void:
	item_data = item
	if item_data:
		icon_rect.texture = item_data.icon
		tooltip_text = item_data.name
	else:
		icon_rect.texture = null
		tooltip_text = ""

func _on_mouse_entered():
	if item_data:
		hover_started.emit(item_data,get_global_mouse_position())

func _on_mouse_exited():
	hover_ended.emit()

func _pressed() -> void:
	slot_pressed.emit(item_data)
