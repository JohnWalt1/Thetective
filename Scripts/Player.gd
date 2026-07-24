extends CharacterBody2D

class_name Player
# state
enum PlayerState { IDLE, WALK, DODGE, ATTACK }
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: Vector2 = Vector2.RIGHT
var hitbox_offset:Vector2
var is_attacking:bool=false


@export var max_hp:float=100.0

@export var base_speed:float=20.0
@export var walk_speed: float = 150.0
@export var dodge_speed: float = 500.0
@export var dodge_duration: float = 0.2
@export var attack_radius:float=50.0
@export var hitbox_size: Vector2 = Vector2(58, 120)  
@export var use_mouse:bool=true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var dodge_timer: Timer = $DodgeTimer
@onready var det_eye_duration: Timer = $DetEyeDuration
@onready var det_eye_cooldown: Timer = $DetEyeCooldown
@onready var canvas_modulate: CanvasModulate = $"../../CanvasModulate"
@onready var idle_timer:Timer=$IdleTimer
@onready var hitbox: Area2D = $Hitbox
@onready var swing: AudioStreamPlayer2D = $swing

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dodge_sound: AudioStreamPlayer2D = $dodge







#input user
var input_direction: Vector2 = Vector2.ZERO

var nearby_clue: Area2D = null 
var _nearby_interactable:Array[Interactable]=[]

var is_un_terrain_active:bool =false
signal un_terrain_entered
signal un_terrain_exited

func _ready():

	add_to_group("player")
	det_eye_duration.wait_time = 10.0   
	det_eye_cooldown.wait_time = 2  
	dodge_timer.wait_time=dodge_duration
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	det_eye_duration.timeout.connect(_on_det_eye_duration_timeout)
	det_eye_cooldown.timeout.connect(_on_det_eye_cooldown_timeout)
	idle_timer.wait_time=3
	hitbox_offset=hitbox.position

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

	update_animation()
	update_interaction_ray()
func _process(delta):
	update_attack_area_position()
func update_attack_area_position():
	var direction:Vector2
	
	if use_mouse:
		var mouse_pos=get_global_mouse_position()
		direction=(mouse_pos-global_position).normalized()
		facing_direction=direction
	else:
		direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
		facing_direction=direction
	hitbox.global_position=global_position+direction*attack_radius
	hitbox.rotation=direction.angle()
func handle_movement(delta):
	input_direction=Input.get_vector("move_left", "move_right","move_up", "move_down")
	
	if input_direction!=Vector2.ZERO:
		
		current_state=PlayerState.WALK
		velocity=(input_direction*walk_speed)
		
	else:
		current_state=PlayerState.IDLE
		velocity =Vector2.ZERO
func handle_attack():
	if Input.is_action_just_pressed("attack"):
		attacksystem()
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
			return
		elif not det_eye_cooldown.is_stopped():
			return

func attempt_interaction():
	if not interaction_ray.is_colliding():
		return
	
	var collider = interaction_ray.get_collider()
	if not collider:
		return
		
	
	if collider.is_in_group("npc") and collider.visible:
		collider.interact()
		return



#######################################################
func activate_det_eye():
	Global.is_det_eye_active = true
	det_eye_duration.start()
	if canvas_modulate:
		canvas_modulate.color = Color(0.15, 0.2, 0.5)
	enter_un_terrain()
	toggle_spawners(true)

func _on_det_eye_duration_timeout():
	Global.is_det_eye_active = false
	det_eye_cooldown.start()
	if canvas_modulate:
		canvas_modulate.color = Color.WHITE
	exit_un_terrain()
	toggle_spawners(false)

func _on_det_eye_cooldown_timeout():
	pass

func toggle_spawners(active:bool):
	var spawners=get_tree().get_nodes_in_group("enemy_spawner")
	for spawner in spawners:
		if spawner.has_method("set_active"):
			spawner.set_active(active)

func enter_un_terrain() -> void:
	if is_un_terrain_active:
		return
	is_un_terrain_active = true
	Global.enter_un_terrain_layer()
	un_terrain_entered.emit()

func exit_un_terrain() -> void:
	if not is_un_terrain_active:
		return
	is_un_terrain_active = false
	Global.exit_un_terrain_layer()
	un_terrain_exited.emit()
	
func attacksystem():
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

#func update_hitbox():
	#var collision=$Hitbox/CollisionShape2D
	#if not collision:
		#return
	#var x:=hitbox_offset.x
	#var y:=hitbox_offset.y
	#
	#match facing_direction:
		#Vector2.LEFT:
			#hitbox.position=Vector2(-x,y)
			#collision.shape.extents = hitbox_size
		#Vector2.RIGHT:
			#hitbox.position=Vector2(x,y)
			#collision.shape.extents = hitbox_size
		#Vector2.UP:
			#hitbox.position=Vector2(y,-x)
			#collision.shape.extents = Vector2(hitbox_size.y,hitbox_size.x)
		#Vector2.DOWN:
			#hitbox.position=Vector2(-y,x)
			#collision.shape.extents = Vector2(hitbox_size.y,hitbox_size.x)
			#
			

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			var knockback_dir = (body.global_position - global_position).normalized()
			body.take_damage(PlayerStats.get_total_atk(),knockback_dir)
		
		print("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking=false
		

func register_interactable(i:Interactable)->void:
	_nearby_interactable.append(i)
	
func unregister_interactable(i:Interactable)->void:
	_nearby_interactable.erase(i)

func _unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed(("interact")) and not _nearby_interactable.is_empty():
		_nearby_interactable[0].try_interact(self)
