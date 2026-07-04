extends Area2D

@export var item_data:ItemData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 1 << 3   # Layer 4 (item layer)
	collision_mask = 1 << 2    # Layer 3 (player layer)
	
	# Koneksi sinyal
	body_entered.connect(_on_body_entered)
	
	# Set visible (sprite harus sudah ada di child)
	if has_node("Sprite2D") and item_data and item_data.icon:
		$Sprite2D.texture = item_data.icon

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var manager = body.get_node("InventoryManager")
		if manager:
			manager.add_item(item_data)
			queue_free()  # Hapus item dari dunia
