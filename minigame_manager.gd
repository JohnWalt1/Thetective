extends Node
## AUTOLOAD. Daftarkan di Project Settings > Autoload dengan nama "MinigameManager".
## Bertugas membuka/menutup minigame apapun (overlap_puzzle sekarang, minigame lain nanti
## tinggal didaftarkan di dictionary `minigame_scenes`).

signal minigame_opened(minigame_name: String)
signal minigame_closed(minigame_name: String, result: Dictionary)

# Daftar semua minigame yang tersedia. Tambahkan entry baru di sini untuk minigame berikutnya.
var minigame_scenes: Dictionary = {
	"overlap_puzzle": preload("res://Scenes/puzzle/overlap_puzzle_ui.tscn"),
}

var current_minigame: Node = null
var _current_name: String = ""

## config: Dictionary bebas, diteruskan ke fungsi configure() milik scene minigame.
## Untuk overlap_puzzle, pakai: {"level": preload("res://levels/my_level.tres")}
func open_minigame(minigame_name: String, config: Dictionary = {}) -> void:
	if current_minigame != null:
		push_warning("Minigame lain masih terbuka, abaikan permintaan open '%s'." % minigame_name)
		return

	var scene: PackedScene = minigame_scenes.get(minigame_name)
	if scene == null:
		push_error("Minigame tidak ditemukan: %s" % minigame_name)
		return

	current_minigame = scene.instantiate()
	_current_name = minigame_name
	get_tree().root.add_child(current_minigame)

	if current_minigame.has_method("configure"):
		current_minigame.configure(config)

	if current_minigame.has_signal("closed"):
		current_minigame.closed.connect(_on_minigame_closed)

	get_tree().paused = true
	minigame_opened.emit(minigame_name)

func _on_minigame_closed(result: Dictionary) -> void:
	get_tree().paused = false
	var closed_name := _current_name
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	_current_name = ""
	minigame_closed.emit(closed_name, result)
