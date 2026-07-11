extends CanvasLayer
class_name OverlapPuzzleUI
## Root scene yang dibuka MinigameManager.open_minigame("overlap_puzzle", {"level": ...}).
## Struktur node yang dibutuhkan (buat manual, simpan sebagai overlap_puzzle_ui.tscn):
##   OverlapPuzzleUI (CanvasLayer, script ini)
##     └─ Background (ColorRect, full rect, warna gelap semi transparan)
##     └─ OverlapPuzzle (instance overlap_puzzle.tscn, taruh di tengah layar)
##     └─ CloseButton (Button, pojok, terhubung ke _on_close_button_pressed)

signal closed(result: Dictionary)
@onready var puzzle :OverlapPuzzle=$OverlapPuzzle


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	puzzle.puzzle_solved.connect(_on_solved)

## Dipanggil MinigameManager setelah scene di-instantiate.
func configure(config: Dictionary) -> void:
	var level: PuzzleLevelData = config.get("level")
	if level:
		puzzle.load_level(level)
	else:
		push_error("OverlapPuzzleUI.configure() dipanggil tanpa 'level'.")

func _on_solved() -> void:
	closed.emit({"success": true})

func _on_close_button_pressed() -> void:
	closed.emit({"success": false})
