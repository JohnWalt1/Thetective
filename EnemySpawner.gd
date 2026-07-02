extends Node2D

@export var enemy_scene:PackedScene=null
@export var spawn_count:int=3
@export var spawn_radius:float=150.0

@export var max_enemies:int =10
@export var spawn_interval:float= 0.0
@export var auto_spawn_on_ready:bool=true

var spawned_enemies:Array[Node]=[]
var spawn_timer:Timer=null

signal enemy_spawned(enemy:Node2D)
signal all_enemies_defeated()

# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy_scene==null:
		return
	if spawn_interval>0:
		spawn_timer = Timer.new()
		spawn_timer.wait_time = spawn_interval
		spawn_timer.autostart = false
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		add_child(spawn_timer)
	if auto_spawn_on_ready:
		await get_tree().process_frame
		spawn_enemies()

func spawn_enemies():
	if enemy_scene==null:
		return
	var available_slots=max_enemies if max_enemies>0 else 99999
	var current_count = get_alive_enemy_count()
	var can_spawn = min(spawn_count, available_slots - current_count)
	
	if can_spawn<=0:
		return
	for i in range (can_spawn):
		spawn_single_enemy()
func spawn_single_enemy()->Node2D:
	if enemy_scene==null:
		return null
	var angle = randf() * 2 * PI
	var radius = randf() * spawn_radius
	var offset = Vector2(cos(angle), sin(angle)) * radius
	var spawn_position = global_position + offset
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	
	get_tree().current_scene.call_deferred("add_child",enemy)
	spawned_enemies.append(enemy)
	
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	else:
		pass
		
	emit_signal("enemy_spawned",enemy)
	return enemy
	
func get_alive_enemy_count() -> int:
	spawned_enemies = spawned_enemies.filter(func(e): return is_instance_valid(e))
	return spawned_enemies.size()
	
func clear_all_enemies():
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()

func _on_enemy_died():
	if get_alive_enemy_count() == 0:
		emit_signal("all_enemies_defeated")
		
func _on_spawn_timer_timeout():
	spawn_enemies()
	
func start_auto_spawn():
	if spawn_timer and spawn_interval>0:
		spawn_timer.start()
func stop_suto_spawn():
	if spawn_timer:
		spawn_timer.stop()
func trigger_spawn():
	spawn_enemies()
