extends MinigameBase

@export var grid_size:Vector2i=Vector2i(8,8)
@export var cell_scene: PackedScene = preload("res://puzzle_cell.tscn")

var target_grid:Array[Array]=[]
var current_grid:Array[Array]=[]

@onready var grid: GridContainer = $MarginContainer/Grid
@onready var status_label: Label = $MarginContainer/StatsLabel
@onready var reset_button: Button = $MarginContainer/ResetButton

var cells:Array[Array]=[]

func _ready():
	reset_button.pressed.connect(_reset_puzzle)
	initialize_grid()

func setup(data:Dictionary):
	if data.has("target_grid"):
		target_grid = data.target_grid
		grid_size = Vector2i(target_grid[0].size(), target_grid.size())
		rebuild_grid()
	elif data.has("level_id"):
		load_level(data.level_id)
	else:
		load_default_level()

func initialize_grid():
	for child in grid.get_children():
		child.queue_free()
	grid.columns = grid_size.x
	cells.clear()
	current_grid = []
	for y in range(grid_size.y):
		var row_cells: Array = []
		var grid_row: Array = []
		for x in range(grid_size.x):
			var cell = cell_scene.instantiate()
			cell.cell_position = Vector2i(x, y)
			cell.cell_clicked.connect(_on_cell_clicked)
			grid.add_child(cell)
			row_cells.append(cell)
			grid_row.append(0) 
		cells.append(row_cells)
		current_grid.append(grid_row)

	if target_grid.is_empty():
		generate_default_target()
	apply_target_to_grid()
	
func load_level(level_id: int):
	var levels = {
		1: {
			"size": Vector2i(5,5),
			"target": [
				[0,1,1,1,0],
				[1,0,0,0,1],
				[1,0,0,0,1],
				[1,0,0,0,1],
				[0,1,1,1,0]
			]
		},
		2: {
			"size": Vector2i(8,8),
			"target": [
				[0,0,1,1,1,1,0,0],
				[0,1,0,0,0,0,1,0],
				[1,0,0,0,0,0,0,1],
				[1,0,0,0,0,0,0,1],
				[1,0,0,0,0,0,0,1],
				[1,0,0,0,0,0,0,1],
				[0,1,0,0,0,0,1,0],
				[0,0,1,1,1,1,0,0]
			]
		}
	}
	var level_data = levels.get(level_id)
	if level_data:
		grid_size = level_data.size
		target_grid = level_data.target
		rebuild_grid()
	else:
		print("Level tidak ditemukan")

func load_default_level():
	target_grid = [
		[0,1,1,0],
		[1,1,1,1],
		[1,1,1,1],
		[0,1,1,0]
	]
	grid_size = Vector2i(4,4)
	rebuild_grid()

func generate_default_target():
	var mid = grid_size.x / 2
	target_grid = []
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			if x == mid or y == mid:
				row.append(1)
			else:
				row.append(0)
		target_grid.append(row)

func rebuild_grid():
	initialize_grid()

func apply_target_to_grid():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var val = target_grid[y][x] if y < target_grid.size() and x < target_grid[y].size() else 0
			current_grid[y][x] = val
			var cell = cells[y][x]
			cell.is_active = (val == 1)
			cell.overlay_count = 2 if val == 1 else 0  # supaya parity genap
			cell.update_visual()

func _on_cell_clicked(cell_pos: Vector2i):
	var x = cell_pos.x
	var y = cell_pos.y
	var cell = cells[y][x]
	
	cell.increment_overlay()
	current_grid[y][x] = 1 if cell.is_active else 0
	
	check_win()

func check_win():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if current_grid[y][x] != target_grid[y][x]:
				return 

	status_label.text = "Puzzle Selesai! 🎉"
	complete({"type": "flag", "id": "overlap_puzzle_done"})

# --- Reset ---
func _reset_puzzle():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell = cells[y][x]
			cell.reset_cell()
			current_grid[y][x] = 0
	status_label.text = ""

func load_level_by_id(id):
	load_level(id)
	status_label.text = "Level " + str(id)
