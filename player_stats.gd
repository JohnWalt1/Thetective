extends Node

# Daftarkan sebagai Autoload dengan nama "PlayerStats"

var max_hp: float = 100.0
var current_hp: float = 100.0

var base_atk: float = 10.0
var atk_bonus_temp: float = 0.0   # dari usable item (buff berdurasi)
var atk_bonus_equip: float = 0.0 # dari item yang di-equip


func _ready() -> void:
	InventoryManager.equipment_slot_changed.connect(_on_equipment_slot_changed)


func get_total_atk() -> float:
	return base_atk + atk_bonus_temp + atk_bonus_equip


# Dipanggil saat pemain klik item usable di UI
func use_item(item: ItemData) -> void:
	match item.effect_type:
		ItemData.EffectType.HEAL:
			current_hp = min(current_hp + item.effect_value, max_hp)
			InventoryManager.remove_usable_item(item) # instant, langsung habis
		ItemData.EffectType.BUFF_ATK:
			_apply_temp_atk_buff(item)
		_:
			push_warning("Effect type belum di-handle: %s" % item.effect_type)


func _apply_temp_atk_buff(item: ItemData) -> void:
	atk_bonus_temp += item.effect_value
	InventoryManager.remove_usable_item(item) # item langsung terpakai/hilang dari inventory

	if item.duration > 0.0:
		await get_tree().create_timer(item.duration).timeout
		atk_bonus_temp -= item.effect_value


func _on_equipment_slot_changed(_slot_index: int, _item: ItemData) -> void:
	_recalculate_equip_bonus()


func _recalculate_equip_bonus() -> void:
	atk_bonus_equip = 0.0
	for equip_item in InventoryManager.equipped_slots:
		if equip_item != null and equip_item.stat_bonus.has("atk"):
			atk_bonus_equip += equip_item.stat_bonus["atk"]
