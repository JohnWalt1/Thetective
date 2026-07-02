extends CharacterBody2D
# state
enum PlayerState { IDLE, WALK, DODGE, ATTACK }
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: Vector2 = Vector2.RIGHT
var hitbox_offset:Vector2
var is_attacking:bool=false
@export var walk_speed: float = 150.0
@export var dodge_speed: float = 500.0
@export var dodge_duration: float = 0.2

@export var hitbox_size: Vector2 = Vector2(58, 120)  


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var dodge_timer: Timer = $DodgeTimer
@onready var det_eye_duration: Timer = $DetEyeDuration
@onready var det_eye_cooldown: Timer = $DetEyeCooldown
@onready var canvas_modulate: CanvasModulate = get_node("/root/Main/CanvasModulate")
@onready var idle_timer:Timer=$IdleTimer
@onready var hitbox: Area2D = $Hitbox
@onready var swing: AudioStreamPlayer2D = $swing
@onready var seamless_particles_trail: Node2D = $SeamlessParticlesTrail
@onready var trail_line: Node2D = $Node2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dodge_sound: AudioStreamPlayer2D = $dodge
@onready var joystick: VirtualJoystick = $"../../joystick"



#input user
var input_direction: Vector2 = Vector2.ZERO


var nearby_clue: Area2D = null   # <-- Ini tempat menyimpan clue yang sedang didekati

func _ready():
	joystick.item_rect_changed.connect(_on_joystick_moved)
	add_to_group("player")
	det_eye_duration.wait_time = 10.0   # Skill aktif 10 detik
	det_eye_cooldown.wait_time = 2   # Cooldown 30 detik
	dodge_timer.wait_time=dodge_duration
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	det_eye_duration.timeout.connect(_on_det_eye_duration_timeout)
	det_eye_cooldown.timeout.connect(_on_det_eye_cooldown_timeout)
	idle_timer.wait_time=3
	#initialize hitbox offset
	hitbox_offset=hitbox.position
func _on_joystick_moved(direction:Vector2):
	velocity=direction*walk_speed
func _physics_process(delta):
	
	if current_state == PlayerState.DODGE:
		move_and_slide()
		update_animation()
		update_interaction_ray()
		return
	if current_state==PlayerState.ATTACK:
		velocity=Vector2.ZERO
		move_and_slide()
		update_animation()
		update_interaction_ray()
		return
	hitbox.monitoring=false
	handle_movement(delta)
	dodge()
	handle_attack()
	
	move_and_slide()
	if velocity.length() > 10.0: 
		seamless_particles_trail.set_emitting(true)
		trail_line.add_point(global_position)
	else:
		seamless_particles_trail.set_emitting(false)
	update_animation()
	update_interaction_ray()
	
func handle_movement(delta):
	input_direction=Input.get_vector("move_left", "move_right","move_up", "move_down")
	
	if input_direction!=Vector2.ZERO:
		facing_direction=input_direction
		current_state=PlayerState.WALK
		velocity=(input_direction*walk_speed)
		update_hitbox()
	else:
		current_state=PlayerState.IDLE
		velocity =Vector2.ZERO
func handle_attack():
	if Input.is_action_just_pressed("attack"):
		attack()
func dodge():
	if Input.is_action_just_pressed("dodge") and dodge_timer.is_stopped() and current_state!=PlayerState.DODGE:
		dodge_sound.play()
		await get_tree().create_timer(2).timeout
		current_state=PlayerState.DODGE
		velocity= facing_direction*dodge_speed
		dodge_timer.start()
		collision_shape_2d.disabled=true

		
func _on_dodge_timer_timeout():
	current_state = PlayerState.IDLE
	velocity = Vector2.ZERO
	collision_shape_2d.disabled=false
func update_interaction_ray():
	# raycast depan 40 px
	interaction_ray.target_position = facing_direction * 40.0

func _input(event):
	if event.is_action_pressed("interact"):
		attempt_interaction()
	
	if event.is_action_pressed("det_eye"):
		if det_eye_cooldown.is_stopped() and not Global.is_det_eye_active:
			activate_det_eye()
		elif Global.is_det_eye_active:
			print("[Player] Det Eye masih aktif!")
		elif not det_eye_cooldown.is_stopped():
			print("[Player] Det Eye sedang cooldown!")

		

#func attempt_interaction():
	#if not interaction_ray.is_colliding():
		#print("Tidak ada apapun di depan")
		#return
	#
	#var collider = interaction_ray.get_collider()
	#if not collider:
	
		#return
	#print(" Ray mengenai: ", collider.name, " (", collider.get_class(), ")")
	#if collider.is_in_group("npc") and collider.visible:
		#collider.interact()
		#return
	#
	#if collider.is_in_group("enemy") and collider.visible:
		#if Global.is_det_eye_active:
			#start_battle(collider)
		#else:
			#print("[Player] Aktifkan Det Eye dulu untuk melihat dan melawan musuh!")
		#return
#
	#if collider.is_in_group("clue_pickup") and collider.visible:
		#collider.pickup()
		#return

func attempt_interaction():
	if nearby_clue and nearby_clue.visible:
		print("[Player]  Mengambil clue via overlap!")
		nearby_clue.pickup()
		nearby_clue = null  # Reset setelah diambil
		return

	if not interaction_ray.is_colliding():
		return
	
	var collider = interaction_ray.get_collider()
	if not collider:
		return
		
	# 1. Interaksi NPC (Biasa atau Hidden)
	if collider.is_in_group("npc") and collider.visible:
		collider.interact()
		return

	# 2. Interaksi Musuh (Hanya jika Det Eye aktif)
	if collider.is_in_group("enemy") and collider.visible:
		if Global.is_det_eye_active:
			start_battle(collider)
		return
	
# Fungsi alternatif: deteksi Area2D di sekitar player (pakai overlap)
func detect_nearby_interactables():
	var areas = get_tree().get_nodes_in_group("clue_pickup")
	for area in areas:
		if area is Area2D and area.visible:
			var dist = global_position.distance_to(area.global_position)
			if dist < 50.0:  # Jarak dekat
				var dir_to_area = (area.global_position - global_position).normalized()
				if dir_to_area.dot(facing_direction) > 0.7:  # Arah depan
					area.pickup()
					return
#######################################################
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
		if obj.has_node("CollisionShape2D"):
			var shape = obj.get_node("CollisionShape2D")
			shape.disabled = not active
		# Aktifkan proses agar sinyal overlap bisa berjalan
		obj.process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
func start_battle(enemy_node):
	Global.is_battle_active = true
	
	var battle_ui = get_node("/root/Main/UI/BattleUI")
	if battle_ui:
		battle_ui.start_battle(enemy_node)
	else:
		print("[Player] ERROR: BattleUI tidak ditemukan!")


func attack():
	if current_state==PlayerState.ATTACK:
		return
	current_state=PlayerState.ATTACK
	is_attacking=true
	hitbox.monitoring=true
	swing.play()
	sprite.play("attack")
	
	await get_tree().create_timer(0.3).timeout
	current_state=PlayerState.IDLE
func update_animation():
	# Prioritas Dodge
	if current_state == PlayerState.DODGE:
		if sprite.animation!="dodge":
			sprite.play("dodge")
		return
	# Idle vs Walk
	if current_state == PlayerState.ATTACK:
		if sprite.animation != "attack":
			sprite.play("attack")
		
		return
	if velocity.length() > 0:
		if sprite.animation!="walk":
			sprite.play("walk")
	else:
		if sprite.animation!="idle":
			sprite.play("idle")
	
	# Flip sprite 
	if facing_direction.x != 0:
		sprite.flip_h = facing_direction.x < 0

func update_hitbox():
	var collision=$Hitbox/CollisionShape2D
	if not collision:
		return
	var x:=hitbox_offset.x
	var y:=hitbox_offset.y
	
	match facing_direction:
		Vector2.LEFT:
			hitbox.position=Vector2(-x,y)
			collision.shape.extents = hitbox_size
		Vector2.RIGHT:
			hitbox.position=Vector2(x,y)
			collision.shape.extents = hitbox_size
		Vector2.UP:
			hitbox.position=Vector2(y,-x)
			collision.shape.extents = Vector2(hitbox_size.y,hitbox_size.x)
		Vector2.DOWN:
			hitbox.position=Vector2(-y,x)
			collision.shape.extents = Vector2(hitbox_size.y,hitbox_size.x)
			
			

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			var knockback_dir = (body.global_position - global_position).normalized()
			body.take_damage(20,knockback_dir)
		
		print("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking=false
		
