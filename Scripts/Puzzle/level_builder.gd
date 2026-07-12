@tool
extends EditorScript
## CARA PAKAI:
## 1. Buka file ini di Script Editor Godot (double click di FileSystem)
## 2. Edit LEVEL_NAME, GRID_SIZE, target_pattern, dan blocks_pattern di bawah
##    sesuai level yang mau kamu buat
## 3. Tekan Ctrl+Shift+X (atau menu File > Run) — JANGAN di-attach ke node manapun,
##    ini dijalankan langsung dari Script Editor
## 4. Cek folder res://levels/ — file .tres baru otomatis muncul di situ
## 5. Ulangi dari langkah 2 buat bikin level lain (ganti OUTPUT_PATH biar gak ketimpa)

const OUTPUT_PATH := "res://Puzzle/OverlapPuzzle_lv/level_testt.tres"

func _run() -> void:
	var level := PuzzleLevelData.new()
	level.level_name = "Level Baru"
	level.grid_size = Vector2i(6, 6)
	level.canvas_size=Vector2i(11,6)
	level.cell_size = 100

	# --- TARGET: '.' = kosong, karakter lain = sel yang harus terisi (ganjil) ---
	var target_pattern := [
		".####.",
		"######",
		"######",
		".####.",
	]
	level.target_cells = PuzzlePatternUtils.cells_from_pattern(target_pattern)

	# --- BLOK: tiap huruf berbeda = 1 blok terpisah, '.' = kosong ---
	# posisi huruf di grid ini otomatis jadi start_cell blok tsb saat game mulai
	var blocks_pattern := [
		"AAABBB..",
		"AAABBB..",
		"CCCC....",
		"CCCCDDDD",
		"CCCCDDDD",
		"....DDDD",
	]
	var colors := {
		"A": Color(0.3, 0.7, 1.0),
		"B": Color(1.0, 0.5, 0.2),
		"C": Color(0.3, 0.7, 1.0),
		"D": Color(0.3, 0.7, 1.0),
	}
	level.blocks = PuzzlePatternUtils.blocks_from_pattern(blocks_pattern, colors)

	# --- SAVE ---
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("levels"):
		dir.make_dir("levels")

	var err := ResourceSaver.save(level, OUTPUT_PATH)
	if err == OK:
		print("[LevelBuilder] kelar dah & disimpan ke: ", OUTPUT_PATH)
		print("[LevelBuilder] Target cells: ", level.target_cells.size())
		print("[LevelBuilder] Jumlah blok: ", level.blocks.size())
	else:
		push_error("[LevelBuilder] Gagal menyimpan level, error code: %s" % err)
