extends Node2D
class_name PuzzleBlock
## Satu blok yang bisa di-drag & drop di grid overlap_puzzle.
## Digambar transparan tipis (hanya bantuan visual saat drag) — hasil "ganjil/genap"
## yang sesungguhnya digambar oleh PuzzleResultLayer, bukan oleh blok ini.

signal moved(block: PuzzleBlock)
signal picked_up(block: PuzzleBlock)

var cells: Array[Vector2i] = [Vector2i.ZERO]   # bentuk blok, offset relatif
var grid_pos: Vector2i = Vector2i.ZERO          # posisi sel acuan (kiri-atas) di grid puzzle
var color: Color = Color.WHITE
var movable: bool = true
var cell_size: int = 64
var grid_bounds: Vector2i = Vector2i(6, 6)      # dipakai untuk clamp posisi

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func setup(data: PuzzleBlockData, cell_px: int, bounds: Vector2i) -> void:
	cells = data.cells.duplicate()
	grid_pos = data.start_cell
	color = data.color
	movable = data.movable
	cell_size = cell_px
	grid_bounds = bounds
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

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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
	# clamp supaya blok tidak keluar area grid
	raw_cell.x = clampi(raw_cell.x, 0, grid_bounds.x - 1)
	raw_cell.y = clampi(raw_cell.y, 0, grid_bounds.y - 1)
	grid_pos = raw_cell
	_update_position()
	moved.emit(self)
