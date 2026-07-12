extends Node2D
class_name OverlapPuzzle

signal puzzle_solved

const PuzzleBlockScene := preload("res://Scenes/puzzle/puzzle_block.tscn")

@export var level: PuzzleLevelData
@export var visible_area_size:Vector2=Vector2(384,384)
@onready var blocks_container: Node2D = $BlocksContainer
@onready var result_layer: Node2D = $ResultLayer

var blocks: Array[PuzzleBlock] = []
var overlap_count: Dictionary = {}  
var solved: bool = false
var _panning: bool = false
var _pan_last_mouse: Vector2 = Vector2.ZERO
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if level:
		load_level(level)

func load_level(data: PuzzleLevelData) -> void:
	level = data
	solved = false

	for b in blocks:
		b.queue_free()
	blocks.clear()
	overlap_count.clear()

	for block_data in level.blocks:
		var block: PuzzleBlock = PuzzleBlockScene.instantiate()
		blocks_container.add_child(block)
		var canvas_bounds:Vector2i=level.canvas_size if level.canvas_size!=Vector2i.ZERO else level.grid_size
		block.setup(block_data, level.cell_size, canvas_bounds)
		block.moved.connect(_on_block_moved)
		blocks.append(block)

	_recompute_overlap()
	queue_redraw()
	if result_layer:
		result_layer.queue_redraw()

func _on_block_moved(_block: PuzzleBlock) -> void:
	_recompute_overlap()
	if result_layer:
		result_layer.queue_redraw()

	if not solved and _check_win():
		solved = true
		puzzle_solved.emit()

func _recompute_overlap() -> void:
	overlap_count.clear()
	for block in blocks:
		for local_cell in block.cells:
			var world_cell: Vector2i = block.grid_pos + local_cell
			overlap_count[world_cell] = overlap_count.get(world_cell, 0) + 1

func get_visible_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in overlap_count.keys():
		if overlap_count[cell] % 2 == 1:
			result.append(cell)
	return result

func _check_win() -> bool:
	var visible := get_visible_cells()
	if visible.size() != level.target_cells.size():
		return false
	var target_set := {}
	for c in level.target_cells:
		target_set[c] = true
	for c in visible:
		if not target_set.has(c):
			return false
	return true

func _draw() -> void:
	if not level:
		return
	var cs: int = level.cell_size


	for x in range(level.grid_size.x):
		for y in range(level.grid_size.y):
			var r := Rect2(Vector2(x, y) * cs, Vector2(cs, cs))
			draw_rect(r, Color(1, 1, 1, 0.04), true)
			draw_rect(r, Color(1, 1, 1, 0.12), false, 1.0)

	for c in level.target_cells:
		var r := Rect2(Vector2(c) * cs, Vector2(cs, cs))
		draw_rect(r, Color(0.2, 1.0, 0.5, 0.5), false, 2.0)


func _on_close_button_pressed() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			_panning=true
			_pan_last_mouse=event.position
		else:
			_panning=false
	elif event is InputEventMouseMotion and _panning:
		var delta: Vector2 = event.position - _pan_last_mouse
		_pan_last_mouse = event.position
		position += delta
		_clamp_pan()


func _clamp_pan()->void:
	if not level:
		return
	var bounds:Vector2i=level.canvas_size if level.canvas_size!=Vector2i.ZERO else level.grid_size
	var content_size:Vector2=Vector2(bounds)*level.cell_size
	var min_x: float = minf(0.0, visible_area_size.x - content_size.x)
	var min_y: float = minf(0.0, visible_area_size.y - content_size.y)
	position.x = clampf(position.x, min_x, 0.0)
	position.y = clampf(position.y, min_y, 0.0)
