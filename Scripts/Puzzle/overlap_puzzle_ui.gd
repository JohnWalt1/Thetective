extends CanvasLayer
class_name OverlapPuzzleUI

signal closed(result: Dictionary)
@onready var puzzle :OverlapPuzzle=$OverlapPuzzle


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	puzzle.puzzle_solved.connect(_on_solved)

func configure(config: Dictionary) -> void:
	var level: PuzzleLevelData = config.get("level")
	if level:
		puzzle.load_level(level)
	else:
		push_error("OverlapPuzzleUI.configure() dipanggil tanpa 'level'.")

func _on_solved() -> void:
	closed.emit({"success": true,"rewards":puzzle.level.rewards})

func _on_close_button_pressed() -> void:
	closed.emit({"success": false})

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()
		get_viewport().set_input_as_handled()
