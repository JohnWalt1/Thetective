extends Area2D
class_name Interactable
## Base class untuk objek yang bisa di-interact player (tombol, NPC, puzzle trigger, dll).
## Cara pakai: extend script ini, override _on_interact(source).

signal interacted(source: Node)

@export var prompt_text: String = "Tekan E untuk berinteraksi"

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if body.has_method("register_interactable"):
			body.register_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if body.has_method("unregister_interactable"):
			body.unregister_interactable(self)

## Dipanggil dari kode player saat tombol "interact" ditekan.
func try_interact(source: Node) -> void:
	print("[Interactable:%s] try_interact dipanggil, player_in_range=%s" % [name, player_in_range])
	if player_in_range:
		interacted.emit(source)
		_on_interact(source)

## Override di child class (mis. PuzzleTrigger) untuk logika spesifik.
func _on_interact(_source: Node) -> void:
	pass
