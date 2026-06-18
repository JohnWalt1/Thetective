extends CharacterBody2D
# state
enum PlayerState { IDLE, WALK, DODGE }
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: Vector2 = Vector2.RIGHT

@export var walk_speed: float = 150.0
@export var dodge_speed: float = 500.0
@export var dodge_duration: float = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var dodge_timer: Timer = $DodgeTimer
@onready var det_eye_duration: Timer = $DetEyeDuration
@onready var det_eye_cooldown: Timer = $DetEyeCooldown
@onready var canvas_modulate: CanvasModulate = get_node("/root/Main/CanvasModulate")

#input user
var input_direction: Vector2 = Vector2.ZERO


func _ready():
	det_eye_duration.wait_time = 10.0   # Skill aktif 10 detik
	det_eye_cooldown.wait_time = 30.0   # Cooldown 30 detik
	
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	det_eye_duration.timeout.connect(_on_det_eye_duration_timeout)
	det_eye_cooldown.timeout.connect(_on_det_eye_cooldown_timeout)

func _physics_process(delta):

	if Global.is_battle_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match current_state:
		# State DODGE
		PlayerState.DODGE:
			move_and_slide()
			return


		_:
			input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			
			if input_direction != Vector2.ZERO:
				facing_direction = input_direction
				current_state = PlayerState.WALK
				velocity = input_direction * walk_speed
			else:
				current_state = PlayerState.IDLE
				velocity = Vector2.ZERO

			move_and_slide()

			if Input.is_action_just_pressed("dodge") and dodge_timer.is_stopped():
				current_state = PlayerState.DODGE
				velocity = facing_direction * dodge_speed
				dodge_timer.start()

	update_animation()
	update_interaction_ray()


func _on_dodge_timer_timeout():
	current_state = PlayerState.IDLE
	velocity = Vector2.ZERO

func update_interaction_ray():
	# raycast depan 40 px
	interaction_ray.target_position = facing_direction * 40.0

func _input(event):
	if event.is_action_pressed("interact"):
		attempt_interaction()
	
	if event.is_action_pressed("det_eye"):
		if det_eye_cooldown.is_stopped() and not Global.is_det_eye_active and not Global.is_battle_active:
			activate_det_eye()
		elif Global.is_det_eye_active:
			print("[Player] Det Eye masih aktif!")
		elif not det_eye_cooldown.is_stopped():
			print("[Player] Det Eye sedang cooldown!")

func attempt_interaction():
	if not interaction_ray.is_colliding():
		return
	
	var collider = interaction_ray.get_collider()
	if not collider:
		return

	if collider.is_in_group("npc") and collider.visible:
		collider.interact()
		return

	if collider.is_in_group("enemy") and collider.visible:
		if Global.is_det_eye_active:
			start_battle(collider)
		else:
			print("[Player] Aktifkan Det Eye dulu untuk melihat dan melawan musuh!")
		return

	if collider.is_in_group("clue_pickup") and collider.visible:
		collider.pickup()
		return

func activate_det_eye():
	Global.is_det_eye_active = true
	det_eye_duration.start()
	
	if canvas_modulate:
		canvas_modulate.color = Color(0.15, 0.2, 0.5)

	toggle_hidden_objects(true)
	
	print("[Player] DET EYE activated! (10 detik)")

func _on_det_eye_duration_timeout():
	Global.is_det_eye_active = false
	det_eye_cooldown.start()
	
	# Warna Normal
	if canvas_modulate:
		canvas_modulate.color = Color.WHITE
	
	# Sembunyikan semua objek tersembunyi
	toggle_hidden_objects(false)
	
	print("[Player] DET EYE Cooldown! (Cooldown 30 detik)")

func _on_det_eye_cooldown_timeout():
	print("[Player] Det Eye ready")


func toggle_hidden_objects(active: bool):
	var objects = get_tree().get_nodes_in_group("det_eye_hidden")
	for obj in objects:
		obj.visible = active
		# Collision
		if obj.has_node("CollisionShape2D"):
			obj.get_node("CollisionShape2D").disabled = not active
		if obj.has_node("CollisionPolygon2D"):
			obj.get_node("CollisionPolygon2D").disabled = not active

		obj.process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED

func start_battle(enemy_node):
	Global.is_battle_active = true
	
	var battle_ui = get_node("/root/Main/UI/BattleUI")
	if battle_ui:
		battle_ui.start_battle(enemy_node)
	else:
		print("[Player] ERROR: BattleUI tidak ditemukan!")

func update_animation():
	# Prioritas Dodge
	if current_state == PlayerState.DODGE:
		sprite.play("dodge")
		return
	
	# Idle vs Walk
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
	
	# Flip sprite 
	if facing_direction.x != 0:
		sprite.flip_h = facing_direction.x < 0
