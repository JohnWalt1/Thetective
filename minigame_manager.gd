extends Node

signal minigame_opened(minigame_name: String)
signal minigame_closed(minigame_name: String, result: Dictionary)

# Daftar semua minigame yang tersedia. Tambahkan entry baru di sini untuk minigame berikutnya.
var minigame_scenes: Dictionary = {
	"overlap_puzzle": preload("res://Scenes/puzzle/overlap_puzzle_ui.tscn"),
}

var current_minigame: Node = null
var _current_name: String = ""

func open_minigame(minigame_name: String, config: Dictionary = {}) -> void:
	print("[MinigameManager] open_minigame('%s') dipanggil" % minigame_name)
	if current_minigame != null:
		push_warning("Minigame lain masih terbuka, abaikan permintaan open '%s'." % minigame_name)
		return

	var scene: PackedScene = minigame_scenes.get(minigame_name)
	if scene == null:
		push_error("Minigame tidak ditemukan: %s" % minigame_name)
		return
	print("[MinigameManager] scene ditemukan: %s" % scene.resource_path)

	current_minigame = scene.instantiate()
	print("[MinigameManager] instance dibuat: %s" % current_minigame)
	_current_name = minigame_name
	get_tree().root.add_child(current_minigame)

	if current_minigame.has_method("configure"):
		print("[MinigameManager] memanggil configure()")
		current_minigame.configure(config)
	else:
		push_warning("[MinigameManager] scene '%s' TIDAK punya method configure()" % minigame_name)

	if current_minigame.has_signal("closed"):
		current_minigame.closed.connect(_on_minigame_closed)
	else:
		push_warning("[MinigameManager] scene '%s' TIDAK punya signal closed" % minigame_name)

	get_tree().paused = true
	minigame_opened.emit(minigame_name)

func _on_minigame_closed(result: Dictionary) -> void:
	get_tree().paused = false
	var closed_name := _current_name
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	_current_name = ""

	if result.get("success", false):
		_grant_rewards(result.get("rewards", []))

	minigame_closed.emit(closed_name,result)

func _grant_rewards(rewards: Array) -> void:
	print("[MinigameManager] _grant_rewards dipanggil, jumlah reward=%d" % rewards.size())
	for reward in rewards:
		if reward == null or reward.item == null:
			print("[MinigameManager] skip: reward atau reward.item null")
			continue
		print("[MinigameManager] granting: item=%s amount=%d" % [reward.item.resource_path, reward.amount])
		InventoryManager.add_item(reward.item,reward.amount)
		NotificationManager.show_notification("+%d %s" % [reward.amount,reward.item.name],reward.item.icon)
