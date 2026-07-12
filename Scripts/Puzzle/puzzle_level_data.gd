extends Resource
class_name PuzzleLevelData

@export var level_name: String = "Level 1"
@export var grid_size: Vector2i = Vector2i(6, 6)
@export var canvas_size:Vector2i=Vector2i.ZERO
@export var cell_size: int = 64
@export var target_cells: Array[Vector2i] = []
@export var blocks: Array[PuzzleBlockData] = []
