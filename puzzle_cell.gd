extends Panel


signal cell_clicked(cell_pos:Vector2i)
@export var cell_position:Vector2i=Vector2i.ZERO
@export var cell_size:int =40

var is_active:bool=false
var overlay_count:int=0

@onready var color_rect: ColorRect = $ColorRect

func _ready():
	custom_minimum_size=Vector2(cell_size,cell_size)
	color_rect.size=Vector2(cell_size,cell_size)

func _gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		cell_clicked.emit(cell_position)
	
func increment_overlay():
	overlay_count+=1
	is_active=(overlay_count&2==0)
	update_visual()
func set_active(value:bool):
	is_active=value
	overlay_count =1 if not value else 2
	update_visual()

func update_visual():
	if is_active:
		color_rect.color=Color(0.2,0.6,1.0)
		color_rect.modulate=Color.WHITE
	else:
		color_rect.modulate=Color.TRANSPARENT
	
func reset_cell():
	overlay_count=0
	is_active=false
	update_visual()
