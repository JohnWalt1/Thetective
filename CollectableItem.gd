extends Area2D

@export var loot:ItemStack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 1 << 3   # Layer 4 (item layer)
	collision_mask = 1 << 2    # Layer 3 (player layer)
	
	# Koneksi sinyal
	body_entered.connect(_on_body_entered)
	
	# Set visible (sprite harus sudah ada di child)
	if has_node("Sprite2D") and loot.item and loot.item.icon:
		$Sprite2D.texture = loot.item.icon

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		InventoryManager.add_item(loot.item, loot.amount)
		NotificationManager.show_notification("+%d %s" %[loot.amount,loot.item.name],loot.item.icon)
		queue_free()  # Hapus item dari dunia
