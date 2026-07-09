extends PopupPanel

@onready var use_button: Button = $HBoxContainer/UseButton
@onready var equip_button: Button = $HBoxContainer/EquipButton

signal action_use
signal action_discard


func show_actions(item:ItemData,position:Vector2):
	if item.item_type==ItemData.ItemType.USABLE:
		use_button.text="Use"
	else:
		use_button.text="Equip"
	
	popup(Rect2(position,size))
