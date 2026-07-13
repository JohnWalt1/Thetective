extends Resource
class_name PuzzleBlockData

@export var cells: Array[Vector2i] = [Vector2i.ZERO]
@export var start_cell: Vector2i = Vector2i.ZERO
@export var start_in_tray: bool = true
@export var color: Color = Color(0.3, 0.7, 1.0)
@export var movable: bool = true
