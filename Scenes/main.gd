extends Node
@onready var normal_terrain: Node2D = $GameWorld/NormalTerrain
@onready var un_terrain: Node2D = $GameWorld/UnTerrain
@onready var ysort: Node = $ysort
@onready var player: Player = get_tree().get_first_node_in_group("player")
func _ready():
	Global.register_ysort(ysort)
	Global.register_world_layers(normal_terrain,un_terrain)
	StoryManager.recheck()
	_place_player_at_spawn()
func _place_player_at_spawn()->void:
	var spawns=get_tree().get_nodes_in_group("spawn_point")
	for spawn in spawns:
		if spawn is SpawnPoint and spawn.spawn_id==SceneManager.pending_spawn_id:
			player.global_position=spawn.global_position
			return
