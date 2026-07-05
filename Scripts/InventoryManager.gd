extends Node


var items:Array[ItemData]=[]
var equipment_slots: Dictionary = {
	"Weapon": null,
	"Head": null,
	"Chest": null,
	"Accessory": null
}

signal inventory_updated
var max_inventory: int = 12

const QUALITY_ORDER={
	"Common":0,"Rare":1,"Epic":2,"Legendary":3
}
func add_item(item:ItemData)->bool:
	if item.is_consumable and item.max_stack > 1:
		var existing = _find_stackable_item(item)
		if existing:
			if existing.current_stack < existing.max_stack:
				existing.current_stack += 1
				sort_inventory()
				inventory_updated.emit()
				return true
	if items.size() >= max_inventory:
		return false
	if item.is_equipment:
		var slot = item.equip_slot
		if equipment_slots.has(slot):
			var old_item = equipment_slots[slot]
			if old_item:
				if items.size() >= max_inventory:
					return false  # tidak muat
				items.append(old_item)
			# Pasang item baru
			equipment_slots[slot] = item
			sort_inventory()
			inventory_updated.emit()
			return true
	else:
		items.append(item)
	sort_inventory()
	inventory_updated.emit()
	return true

func _find_stackable_item(item: ItemData) -> ItemData:
	for i in items:
		if i.id == item.id and i.current_stack < i.max_stack:
			return i
	return null
	
func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		var item = items[index]
		if item.is_consumable and item.max_stack > 1:
			item.current_stack -= 1
			if item.current_stack <= 0:
				items.remove_at(index)
		else:
			items.remove_at(index)
		sort_inventory()
		inventory_updated.emit()
		
func use_item(index: int, player: Node) -> void:
	if index < 0 or index >= items.size():
		return
	var item = items[index]
	if item.is_consumable and item.use_effect:
		_apply_effect(item.use_effect, player)
		remove_item(index)   # kurangi stack atau hapus
	elif item.is_equipment:
		var slot = item.equip_slot
		if equipment_slots.has(slot):
			var old_item = equipment_slots[slot]
			if old_item:
				if items.size() >= max_inventory:
					return  # inventory penuh
				items.append(old_item)
			
			equipment_slots[slot] = item
			items.remove_at(index)
			sort_inventory()
			inventory_updated.emit()

func _apply_effect(effect: Effect, player: Node) -> void:
	match effect.type:
		Effect.EffectType.HEAL:
			player.heal(effect.value)
		Effect.EffectType.BUFF_STAT:
			player.add_permanent_buff(effect.stat, effect.value)
		Effect.EffectType.BUFF_TIME:
			player.add_timed_buff(effect.stat, effect.value, effect.duration)
		Effect.EffectType.PERMANENT_STAT:
			player.add_permanent_stat(effect.stat, effect.value)
		Effect.EffectType.SPECIAL:
			if effect.special_script:
				var special = effect.special_script.new()
				special.execute(player, effect)

func unequip_item(slot: String) -> void:
	if equipment_slots.has(slot) and equipment_slots[slot] != null:
		var item = equipment_slots[slot]
		if items.size() < max_inventory:
			items.append(item)
			equipment_slots[slot] = null
			sort_inventory()
			inventory_updated.emit()

func sort_inventory() -> void:
	items.sort_custom(_sort_items)

func _sort_items(a: ItemData, b: ItemData) -> bool:
	if a.name.to_lower() == b.name.to_lower():
		return QUALITY_ORDER[a.quality] < QUALITY_ORDER[b.quality]
	return a.name.to_lower() < b.name.to_lower()
#Counter
func get_item_count()->int:
	return items.size()

func get_equipment(slot:String)->ItemData:
	return equipment_slots.get(slot,null)
	
func get_equipment_items() -> Array[ItemData]:
	var result = []
	for item in items:
		if item.is_equipment:
			result.append(item)
	return result

func get_equipment_items_for_slot(slot: String) -> Array[ItemData]:
	var result = []
	for item in items:
		if item.is_equipment and item.equip_slot == slot:
			result.append(item)
	return result

func get_regular_items() -> Array[ItemData]:
	var result = []
	for item in items:
		if not item.is_equipment:
			result.append(item)
	return result
