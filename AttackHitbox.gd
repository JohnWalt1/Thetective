# AttackHitbox.gd
extends Area2D

@export var damage: int = 15
@export var life_span: float = 0.15  # Hanya hidup 0.15 detik

var has_hit: bool = false  # Cegah hit berkali-kali dalam 1 ayunan

func _ready():
	# Hubungkan sinyal
	body_entered.connect(_on_body_entered)
	# Hancurkan setelah life_span
	await get_tree().create_timer(life_span).timeout
	queue_free()

func _on_body_entered(body):
	if has_hit:
		return
	# Pastikan yang kena adalah musuh
	if body.is_in_group("enemy"):
		has_hit = true
		body.take_damage(damage)
		# Bisa kasih efek knockback atau getar di sini
		print("[Hitbox] Menyerang ", body.name, " dengan damage ", damage)
