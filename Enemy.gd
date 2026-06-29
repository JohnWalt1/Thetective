#extends CharacterBody2D
#
#
#@export var speed:float=200
#@export var player: Node2D=null
#
#@onready var raycast: RayCast2D = $RayCast2D
#@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
#
#var last_pos:Vector2
#var dir_chase:bool=true
#var ray_collide:bool=false
#
#func _ready():
	#if not player:
		#player=get_tree().get_first_node_in_group("player")
		#
	#navigation_agent.target_desired_distance=10.0
	#navigation_agent.path_desired_distance=5.0
	#last_pos=player.global_position
	#navigation_agent.target_position=last_pos
#func _physics_process(delta):
	#update_raycast_to_player()
	#var is_colliding=raycast.is_colliding()
	#
	#if not is_colliding:
		#dir_chase=true
		#last_pos=player.global_position
		##var direction=(player.global_position-global_position).normalized()
		##velocity=direction*speed
		##move_and_slide()
	#else:
		##if not ray_collide:
			##last_pos=player.global_position
			##dir_chase=false
			##navigation_agent.target_position=last_pos
		#if dir_chase:
			#last_pos=player.global_position
			#dir_chase=false
	#navigation_agent.target_position=last_pos
	#var next_pos=navigation_agent.get_next_path_position()
	#var direction=(next_pos-global_position).normalized()
	#velocity=direction*speed
	#move_and_slide()
#
#func update_raycast_to_player():
	#if player:
		#var direction=(player.global_position-global_position)
		#raycast.target_position=direction
		#raycast.target_position=direction.normalized()*min(direction.length(),1000)
		
		
		
extends CharacterBody2D

@export var speed: float = 200.0
@export var player: Node2D = null

@onready var raycast: RayCast2D = $RayCast2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var last_known_player_position: Vector2
var is_direct_chase: bool = true

# Variabel untuk deteksi stuck
var stuck_timer: float = 0.0
var last_position: Vector2
var is_stuck: bool = false
var escape_direction: Vector2 = Vector2.ZERO

func _ready():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	navigation_agent.target_desired_distance = 10.0
	navigation_agent.path_desired_distance = 5.0
	last_known_player_position = player.global_position
	navigation_agent.target_position = last_known_player_position
	last_position = global_position

func _physics_process(delta):
	# Update raycast ke player
	update_raycast_to_player()
	
	# Tentukan target berdasarkan visibility (seperti sebelumnya)
	var is_colliding = raycast.is_colliding()
	if not is_colliding:
		last_known_player_position = player.global_position
		is_direct_chase = true
	else:
		if is_direct_chase:
			last_known_player_position = player.global_position
			is_direct_chase = false
	
	# Set target navigation agent
	navigation_agent.target_position = last_known_player_position
	
	# Dapatkan arah dari navigation agent
	var next_pos = navigation_agent.get_next_path_position()
	var target_direction = (next_pos - global_position).normalized()
	
	# --- Deteksi stuck ---
	# Jika kecepatan tidak nol tapi posisi hampir tidak berubah, berarti stuck
	if velocity.length() > 10.0 and global_position.distance_to(last_position) < 0.5:
		stuck_timer += delta
		if stuck_timer > 0.5:  # stuck selama 0.5 detik
			is_stuck = true
	else:
		stuck_timer = 0.0
		is_stuck = false
		escape_direction = Vector2.ZERO
	
	last_position = global_position
	
	# --- Logika gerakan ---
	if is_stuck:
		# Cari arah bebas jika belum punya escape_direction
		if escape_direction == Vector2.ZERO:
			escape_direction = find_free_direction()
		
		# Bergerak ke arah escape dengan kecepatan rendah
		if escape_direction != Vector2.ZERO:
			velocity = escape_direction * speed * 0.6  # lebih lambat
		else:
			# Jika tidak ada arah bebas, diam
			velocity = Vector2.ZERO
	else:
		# Gerakan normal mengikuti agent
		velocity = target_direction * speed
	
	move_and_slide()
	
	# Jika sudah tidak stuck, reset escape_direction
	if not is_stuck and escape_direction != Vector2.ZERO:
		escape_direction = Vector2.ZERO

# Fungsi untuk mencari arah bebas menggunakan test_move
func find_free_direction() -> Vector2:
	var directions = [
		Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
		Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)
	]
	var step = 5.0  # jarak pergeseran untuk test
	for dir in directions:
		# Coba gerakkan karakter sejauh step ke arah dir
		var test_pos = global_position + dir * step
		# test_move membutuhkan transform dan delta, kita gunakan delta kecil
		if not test_move(transform, dir * step):
			# Tidak ada tabrakan -> arah ini aman
			return dir.normalized()
	return Vector2.ZERO  # tidak ada arah aman

func update_raycast_to_player():
	if player:
		var dir = (player.global_position - global_position)
		raycast.target_position = dir.normalized() * min(dir.length(), 1000.0)
