# Enemy.gd (Versi Real-Time Battle)
extends CharacterBody2D

# ==========================================
#  EXPORT STATS
# ==========================================
@export var enemy_name: String = "Shadow Beast"
@export var max_hp: int = 40
@export var attack_power: int = 10
@export var move_speed: float = 60.0
@export var chase_range: float = 200.0   # Jarak mulai mengejar
@export var attack_range: float = 20.0   # Jarak serang

# ==========================================
#  VARIABLES
# ==========================================
var current_hp: int
var is_attacking: bool = false

# ==========================================
#  NODE REFS
# ==========================================
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

# ==========================================
#  INIT
# ==========================================
func _ready():
	current_hp = max_hp
	add_to_group("enemy")
	add_to_group("det_eye_hidden")  # Biar ikut aturan Det Eye
	
	# Collision Layer: Layer 5 (enemy)
	collision_layer = 1 << 4
	# Collision Mask: Layer 1 (terrain) biar nabrak tembok, Layer 3 (player) biar bisa menyerang player
	collision_mask = (1 << 0) | (1 << 2)  # Layer 1 & 3
	
	# Status Awal Tersembunyi
	visible = false
	collision_shape.disabled = true
	process_mode = PROCESS_MODE_DISABLED
	
	# Setup Timer Serangan
	attack_cooldown_timer.wait_time = 1.0
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)

func _physics_process(delta):
	# Jika Det Eye tidak aktif, musuh beku dan tidak terlihat (tapi sudah di-handle oleh toggle_hidden_objects)
	# Kita tambahkan pengecekan tambahan agar aman
	if not Global.is_det_eye_active or not visible:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Cari Player
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	# 1. Jika jarak dekat -> Serang Player
	if distance < attack_range and attack_cooldown_timer.is_stopped():
		player.take_damage(attack_power)
		attack_cooldown_timer.start()
		print("[Enemy] ", enemy_name, " menyerang Player!")
		# Animasi serang di sini (opsional)

	# 2. Jika jarak sedang -> Kejar Player
	elif distance < chase_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		# Flip sprite menghadap player
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		# 3. Diam / Idle
		velocity = Vector2.ZERO

	move_and_slide()

# ==========================================
#  FUNGSI DAMAGE & MATI
# ==========================================
func take_damage(dmg: int):
	current_hp -= dmg
	print("[Enemy] ", enemy_name, " kena damage! (HP: ", current_hp, "/", max_hp, ")")
	
	# Efek flash putih (opsional)
	sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE  # Kembalikan normal (atau kasih warna merah)
	
	if current_hp <= 0:
		die()

func die():
	print("[Enemy] 💀 ", enemy_name, " mati!")
	# Beri Clue ke player (via Global)
	Global.add_clue("Memori: " + enemy_name)
	# Hapus musuh dari peta
	queue_free()

func _on_attack_cooldown_timeout():
	# Siap serang lagi
	pass
