extends Marker2D
class_name SpawnPoint
@export var spawn_id:String="default"

func _ready():
	add_to_group("spawn_point")
