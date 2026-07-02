#extends CharacterBody2D
#
## === Ekspor ===
#@export var speed: float = 200.0
#@export var sight_range: float = 300.0      # jarak maksimum untuk melihat player
#@export var lost_timeout: float = 3.0       # detik sebelum kembali ke wander
#@export var wander_radius: float = 100.0    # radius untuk patroli acak
#@export var player: Node2D = null
#
## === Komponen ===
#@onready var raycast: RayCast2D = $RayCast2D
#@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
#@onready var state_timer: Timer = $Timer    # untuk interval wander & timeout
#
## === State ===
#enum EnemyState { WANDER, CHASE }
#var current_state: EnemyState = EnemyState.WANDER
#
## Variabel internal
#var last_known_player_position: Vector2
#var wander_target: Vector2
#var time_since_player_seen: float = 0.0
#var is_direct_chase: bool = true   # untuk mode chase (sama seperti sebelumnya)
#
## === _ready ===
#func _ready():
	#if not player:
		#player = get_tree().get_first_node_in_group("player")
	#
	#navigation_agent.target_desired_distance = 10.0
	#navigation_agent.path_desired_distance = 5.0
	#await get_tree().process_frame
	## Inisialisasi posisi
	#last_known_player_position = player.global_position
	#wander_target = get_random_wander_point()
	#navigation_agent.target_position = wander_target
	#
	## Timer untuk update wander & cek timeout
	#state_timer.timeout.connect(_on_state_timer_timeout)
	#state_timer.start(0.5)   # interval cek setiap 0.5 detik
#
## === Physics Process ===
#func _physics_process(delta):
	## Update raycast ke player
	#update_raycast_to_player()
	#
	## Cek apakah player terlihat (raycast tidak collide dan jarak <= sight_range)
	#var player_visible = is_player_visible()
	#
	## Update time since last seen
	#if player_visible:
		#time_since_player_seen = 0.0
		## Simpan posisi player saat ini (untuk chase)
		#last_known_player_position = player.global_position
	#else:
		#time_since_player_seen += delta
	#
	## State transition
	#match current_state:
		#EnemyState.WANDER:
			#if player_visible:
				## Player terlihat, langsung chase
				#current_state = EnemyState.CHASE
				## Set target ke posisi player saat ini
				#navigation_agent.target_position = player.global_position
		#EnemyState.CHASE:
			#if not player_visible and time_since_player_seen > lost_timeout:
				## Player hilang terlalu lama, kembali wander
				#current_state = EnemyState.WANDER
				#wander_target = get_random_wander_point()
				#navigation_agent.target_position = wander_target
	#
	## Eksekusi gerakan sesuai state
	#move_enemy(delta)
#
## === Fungsi Pergerakan ===
#func move_enemy(delta):
	## Dapatkan arah dari navigation agent
	#var next_pos = navigation_agent.get_next_path_position()
	#var direction = (next_pos - global_position).normalized()
	#
	## Jika di state CHASE dan player terlihat, kita bisa update target ke posisi player langsung
	#if current_state == EnemyState.CHASE and is_player_visible():
		#navigation_agent.target_position = player.global_position
		## (Opsional) bisa langsung set direction ke player tanpa agent, tapi biar agent tetap bekerja
	#
	## Terapkan velocity
	#velocity = direction * speed
	#move_and_slide()
	#
	## (Opsional) deteksi stuck dan escape (bisa ditambahkan seperti sebelumnya)
#
## === Fungsi Deteksi Player ===
#func is_player_visible() -> bool:
	#if not player:
		#return false
	## Cek jarak
	#var dist = global_position.distance_to(player.global_position)
	#if dist > sight_range:
		#return false
	## Cek raycast: tidak boleh collide dengan obstacle
	## Raycast harus diarahkan ke player (update sudah dilakukan)
	#return not raycast.is_colliding()
#
## === Update Raycast ===
#func update_raycast_to_player():
	#if player:
		#var dir = (player.global_position - global_position)
		#raycast.target_position = dir.normalized() * min(dir.length(), sight_range)
#
## === Fungsi Wander ===
#func get_random_wander_point() -> Vector2:
	## Dapatkan titik acak di sekitar dalam radius wander_radius
	#var angle = randf() * 2 * PI
	#var radius = randf() * wander_radius
	#var offset = Vector2(cos(angle), sin(angle)) * radius
	#var target = global_position + offset
	#
	## Pastikan target berada di dalam navigation map (jika perlu)
	#var map = get_world_2d().navigation_map
	#var safe_target = NavigationServer2D.map_get_closest_point(map, target)
	#return safe_target
#
## === Timer Timeout ===
#func _on_state_timer_timeout():
	## Untuk state WANDER: jika sudah mencapai target, cari target baru
	#if current_state == EnemyState.WANDER:
		## Jika jarak ke target sangat dekat, buat target baru
		#if global_position.distance_to(navigation_agent.target_position) < 20.0:
			#wander_target = get_random_wander_point()
			#navigation_agent.target_position = wander_target
	# State CHASE tidak perlu timer karena update setiap frame
		
######################################################################################################		
		#
extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 100.0
@export var player: Node2D = null
@export var sight_range:float=300.0
@export var lost_timeout:float=3.0
@export var wander_radius:float=100.0
@export var knockback_friction: float = 0.9  # faktor perlambatan
@export var hit_stun_duration: float = 0.3
@onready var raycast: RayCast2D = $RayCast2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var state_timer: Timer = $StateTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum EnemyState{WANDER,CHASE}
var is_hit:bool=false
var hit_timer:float=0.0
var health:int=100
var current_state:EnemyState=EnemyState.WANDER
var last_known_player_position: Vector2
var is_direct_chase: bool = true
var wander_target:Vector2
var time_since_player_seen:float=0.0
# Variabel untuk deteksi stuck
var stuck_timer: float = 0.0
var last_position: Vector2
var is_stuck: bool = false
var escape_direction: Vector2 = Vector2.ZERO
var wan_speed:float
#SIGNAL
signal died
func _ready():
	
	wan_speed=speed
	if not player:
		player = get_tree().get_first_node_in_group("player")
	navigation_agent.target_desired_distance = 10.0
	navigation_agent.path_desired_distance = 5.0
	await get_tree().process_frame
	last_known_player_position = player.global_position
	wander_target=get_random_wander_point()
	navigation_agent.target_position = wander_target
	last_position = global_position
	state_timer.timeout.connect(_on_state_timer_timeout)
	state_timer.start(0.5)
func update_animation():
	if velocity.length()<10.0:
		animated_sprite_2d.play("idle")
	else:
		if current_state==EnemyState.WANDER:
			animated_sprite_2d.play("wander")
			speed=wan_speed
		else:
			animated_sprite_2d.play("chase")
			speed=500.0
	if velocity.x>0 and is_hit==false:
		animated_sprite_2d.flip_h=false
	elif velocity.x<0 and is_hit==false:
		animated_sprite_2d.flip_h=true
func _physics_process(delta):
	# Update raycast ke player
	update_raycast_to_player()
	
	var player_visible=is_player_visible()
	if is_hit:
		hit_timer += delta
		# Perlambat velocity
		velocity *= knockback_friction
		if velocity.length() < 5.0 or hit_timer > hit_stun_duration:
			is_hit = false
			velocity = Vector2.ZERO
		move_and_slide()
		
		return
	if player_visible:
		time_since_player_seen=0.0
		last_known_player_position=player.global_position
	else:
		time_since_player_seen+=delta
		
	match current_state:
		EnemyState.WANDER:
			if player_visible:
				current_state=EnemyState.CHASE
				navigation_agent.target_position=player.global_position
		EnemyState.CHASE:
			if not player_visible and time_since_player_seen>lost_timeout:
				current_state=EnemyState.WANDER
				wander_target=get_random_wander_point()
				navigation_agent.target_position=wander_target
				escape_direction=Vector2.ZERO
	move_enemy(delta)

func move_enemy(delta):
	var next_pos=navigation_agent.get_next_path_position()
	var target_direction=(next_pos-global_position).normalized()
	
	if velocity.length()>10 and global_position.distance_to(last_position)<0.5:
		stuck_timer+=delta
	else:
		stuck_timer=0.0
		
	if stuck_timer>0.5:
		is_stuck=true
	else:
		stuck_timer=0.0
		is_stuck=false
		escape_direction=Vector2.ZERO
	if is_stuck:
		if escape_direction == Vector2.ZERO:
			escape_direction = find_free_direction()
		if escape_direction != Vector2.ZERO:
			velocity = escape_direction * speed * 0.6 
		else:
			velocity = Vector2.ZERO
	else:
		velocity = target_direction * speed
		if current_state==EnemyState.CHASE and is_player_visible():
			navigation_agent.target_position=player.global_position
	move_and_slide()
	last_position=global_position
	update_animation()
	if not is_stuck and escape_direction!=Vector2.ZERO:
		escape_direction=Vector2.ZERO
func is_player_visible()->bool:
	if not player:
		return false
	if global_position.distance_to(player.global_position)>sight_range:
		return false
	var collider=raycast.get_collider()
	return not raycast.is_colliding() or collider==player
	
func get_random_wander_point()->Vector2:
	var angle = randf() * 2 * PI
	var radius = randf() * wander_radius
	var offset = Vector2(cos(angle), sin(angle)) * radius
	var target = global_position + offset
	
	# Proyeksikan ke navigation map agar aman
	var map = get_world_2d().navigation_map
	var safe_target = NavigationServer2D.map_get_closest_point(map, target)
	return safe_target
# Fungsi untuk mencari arah bebas menggunakan test_move
func find_free_direction() -> Vector2:
	var directions = [
		Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
		Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)
	]
	var step = 5.0  # jarak pergeseran untuk test
	for dir in directions:
		# test_move membutuhkan transform dan delta, kita gunakan delta kecil
		if not test_move(transform, dir * step):
			# Tidak ada tabrakan -> arah ini aman
			return dir.normalized()
	return Vector2.ZERO  # tidak ada arah aman

func update_raycast_to_player():
	if player:
		var dir = (player.global_position - global_position)
		raycast.target_position = dir.normalized() * min(dir.length(), sight_range)

func take_damage(damage:int,knockback_direction: Vector2 = Vector2.ZERO):
	health-=damage
	await get_tree().create_timer(0.1).timeout
	modulate=Color.WHITE
	if knockback_direction != Vector2.ZERO:
		is_hit=true
		hit_timer=0.0
		velocity = knockback_direction * 400
	if health<=0:
		die()

func die():
	emit_signal("died")
	queue_free()

func _on_state_timer_timeout() -> void:
	if current_state == EnemyState.WANDER:
		# Jika sudah dekat dengan target, buat target baru
		if global_position.distance_to(navigation_agent.target_position) < 20.0:
			wander_target = get_random_wander_point()
			navigation_agent.target_position = wander_target
