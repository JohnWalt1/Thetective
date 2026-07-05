extends Resource
class_name ItemData

@export var id:String=""
@export var name:String="Item"
@export var icon:Texture2D
@export var quality:String="Common"
@export var description:String=""
@export var is_equipment:bool=false
@export var is_consumable:bool=false
@export var equipment_slot=""
@export var stats:Dictionary={}
@export var use_effect:Effect=null
@export var is_interact:bool=false

@export var max_stack: int = 1
@export var current_stack: int = 1

@export var sort_order: int = 0
