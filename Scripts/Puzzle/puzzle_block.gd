extends Node2D
class_name PuzzleBlock

signal moved(block: PuzzleBlock)
signal picked_up(block: PuzzleBlock)

var cells: Array[Vector2i] = [Vector2i.ZERO]   
var grid_pos: Vector2i = Vector2i.ZERO          
var color: Color = Color.WHITE
var movable: bool = true
var cell_size: int = 64
var grid_bounds: Vector2i = Vector2i(6, 6)     

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func setup(data: PuzzleBlockData, cell_px: int, bounds: Vector2i) -> void:
	cells = data.cells.duplicate()
	grid_pos = data.start_cell
	color = data.color
	movable = data.movable
	cell_size = cell_px
	grid_bounds = bounds
	print("[PuzzleBlock] setup: cells=%s grid_pos=%s color=%s cell_size=%s visible=%s" % [cells, grid_pos, color, cell_size, visible])
	_update_position()
	queue_redraw()

func _update_position() -> void:
	position = Vector2(grid_pos) * cell_size

func _draw() -> void:
	for c in cells:
		var rect := Rect2(Vector2(c) * cell_size, Vector2(cell_size, cell_size))
		draw_rect(rect, Color(color.r, color.g, color.b, 0.18 if not _dragging else 0.35), true)
		draw_rect(rect, color, false, 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if not movable:
		return

	if event is InputEventMouseButton and event.button_index== MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_mouse_over_block():
				_dragging = true
				_drag_offset = position - get_global_mouse_position()
				z_index = 10
				picked_up.emit(self)
				queue_redraw()
				get_viewport().set_input_as_handled()
		elif _dragging:
			_dragging = false
			z_index = 0
			_snap_to_grid()
			queue_redraw()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and _dragging:
		position = get_global_mouse_position() + _drag_offset

func _is_mouse_over_block() -> bool:
	var local_mouse: Vector2 = get_local_mouse_position()
	var cell := Vector2i(floori(local_mouse.x / cell_size), floori(local_mouse.y / cell_size))
	return cell in cells

func _snap_to_grid() -> void:
	var raw_cell := Vector2i(roundi(position.x / cell_size), roundi(position.y / cell_size))

	var min_offset:=cells[0]
	var max_offset:=cells[0]
	for c in cells:
		min_offset.x = mini(min_offset.x, c.x)
		min_offset.y = mini(min_offset.y, c.y)
		max_offset.x = maxi(max_offset.x, c.x)
		max_offset.y = maxi(max_offset.y, c.y)
	raw_cell.x = clampi(raw_cell.x, -min_offset.x, grid_bounds.x - 1 - max_offset.x)
	raw_cell.y = clampi(raw_cell.y, -min_offset.y, grid_bounds.y - 1 - max_offset.y)
	grid_pos = raw_cell
	_update_position()
	moved.emit(self)
