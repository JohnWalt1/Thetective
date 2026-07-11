extends Interactable
class_name PuzzleTrigger
## Tempel di Area2D objek dunia (mis. mesin kuno, altar, dsb).
## Tinggal isi field `level` di Inspector dengan resource PuzzleLevelData yang mau dipakai.

@export var level: PuzzleLevelData

func _on_interact(_source: Node) -> void:
	print("[PuzzleTrigger:%s] _on_interact dipanggil, level=%s" % [name, level])
	if not level:
		push_warning("PuzzleTrigger '%s' belum diisi level-nya." % name)
		return
	MinigameManager.open_minigame("overlap_puzzle", {"level": level})
	print("[PuzzleTrigger:%s] open_minigame sudah dipanggil" % name)
