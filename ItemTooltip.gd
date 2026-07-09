extends PopupPanel
class_name ItemTooltip

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

func show_tooltip(item:ItemData,position:Vector2):
	name_label.text=item.name
	description_label.text=item.description
	if item.item_type==ItemData.ItemType.USABLE:
		stats_label.text= "Effect: " + str(item.effect_type) + " " + str(item.effect_value)
	else:
		stats_label.text= "Stats: " + str(item.stat_bonus)
	popup(Rect2(position,size)) 
