extends Node2D
class_name PuzzleBlock

signal placed(block:PuzzleBlock)
signal returned_to_tray(blok:PuzzleBlock)

enum State{TRAY,DRAGGING,PLACED}
const TRAY_SCALE:=0.5

var cells: Array[Vector2i] = [Vector2i.ZERO]   
var grid_pos: Vector2i = Vector2i.ZERO  
var grid_size: Vector2i = Vector2i(6, 6)        
var color: Color = Color.WHITE
var movable: bool = true
var cell_size: int = 64
var state:State=State.TRAY
var tray_position: Vector2 = Vector2.ZERO
var _drag_offset: Vector2 = Vector2.ZERO

func setup(data: PuzzleBlockData, cell_px: int, bounds: Vector2i, tray_pos:Vector2) -> void:
	cells = data.cells.duplicate()
	color = data.color
	movable = data.movable
	cell_size = cell_px
	tray_position=tray_pos
	if data.start_in_tray:
		_go_to_tray()
	else:
		_go_to_grid(data.start_cell)

func _go_to_tray() -> void:
	state = State.TRAY
	scale = Vector2.ONE * TRAY_SCALE
	position = tray_position
	z_index = 0
	queue_redraw()

func _go_to_grid(cell: Vector2i) -> void:
	state = State.PLACED
	grid_pos = cell
	scale = Vector2.ONE
	position = Vector2(cell) * cell_size
	z_index = 0
	queue_redraw()
	
func _draw() -> void:
	for c in cells:
		var rect := Rect2(Vector2(c) * cell_size, Vector2(cell_size, cell_size))
		var alpha: float
		match state:
			State.TRAY:
				alpha = 0.85   
			State.DRAGGING:
				alpha = 0.35   
			_:  # PLACED
				alpha = 0.15   
		draw_rect(rect, Color(color.r, color.g, color.b, alpha), true)
		draw_rect(rect, color, false, 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if not movable:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_mouse_over_block():
				state = State.DRAGGING
				scale = Vector2.ONE  # langsung ukuran penuh begitu diangkat, biar enak digeser
				_drag_offset = global_position - get_global_mouse_position()
				z_index = 10
				queue_redraw()
				get_viewport().set_input_as_handled()
		elif state == State.DRAGGING:
			_drop()
			get_viewport().set_input_as_handled()
 
	elif event is InputEventMouseMotion and state == State.DRAGGING:
		global_position = get_global_mouse_position() + _drag_offset
 
func _drop()->void:
	var raw_cell := Vector2i(roundi(position.x / cell_size), roundi(position.y / cell_size))
 
	var min_offset := cells[0]
	var max_offset := cells[0]
	for c in cells:
		min_offset.x = mini(min_offset.x, c.x)
		min_offset.y = mini(min_offset.y, c.y)
		max_offset.x = maxi(max_offset.x, c.x)
		max_offset.y = maxi(max_offset.y, c.y)
 
	var fits: bool = (
		raw_cell.x + min_offset.x >= 0 and raw_cell.x + max_offset.x < grid_size.x
		and raw_cell.y + min_offset.y >= 0 and raw_cell.y + max_offset.y < grid_size.y
	)
 
	z_index = 0
	if fits:
		_go_to_grid(raw_cell)
		placed.emit(self)
	else:
		_go_to_tray()
		returned_to_tray.emit(self)
func _is_mouse_over_block() -> bool:
	var local_mouse: Vector2 = get_local_mouse_position()
	var cell := Vector2i(floori(local_mouse.x / cell_size), floori(local_mouse.y / cell_size))
	return cell in cells
