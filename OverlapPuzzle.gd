# OverlapPuzzle.gd
extends MinigameBase

@export var grid_size: Vector2i = Vector2i(8, 8)
@export var target_shape: Array[Vector2i]  # koordinat sel yang harus terisi (1)

var grid: Array[int]  # flat array, 0 atau 1 untuk setiap sel
var overlay_count: Array[int]  # jumlah tumpukan blok per sel

func setup(data: Dictionary):
	# data bisa berisi target_shape atau level_id
	if data.has("target_shape"):
		target_shape = data.target_shape
	else:
		# jika tidak, ambil dari level yang ditentukan
		load_level(data.get("level_id", 0))
	reset_grid()

func reset_grid():
	var total = grid_size.x * grid_size.y
	grid = [0] * total
	overlay_count = [0] * total
	# Tampilkan UI (update visual)

# Fungsi ketika pemain mengklik sel
func on_cell_clicked(cell_pos: Vector2i):
	var index = cell_pos.y * grid_size.x + cell_pos.x
	overlay_count[index] += 1
	# Update grid berdasarkan aturan ganjil/genap
	grid[index] = 1 if overlay_count[index] % 2 == 0 else 0
	update_cell_visual(cell_pos)
	check_complete()

func check_complete():
	# Cek apakah grid sesuai dengan target_shape
	var correct = true
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var idx = y * grid_size.x + x
			var expected = 1 if Vector2i(x, y) in target_shape else 0
			if grid[idx] != expected:
				correct = false
				break
		if not correct: break
	if correct:
		complete({"type": "flag", "id": "puzzle_completed"})

# Fungsi visual dan lainnya
