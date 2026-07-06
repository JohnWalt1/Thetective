extends Resource
class_name ItemData


enum ItemType{USABLE,EQUIPABLE}
enum EffectType{NONE,HEAL,BUFF_ATK}
@export var id:String
@export var name:String
@export var icon:Texture2D
@export var item_type:ItemType
@export var description:String

@export var effect_type: EffectType = EffectType.NONE
@export var effect_value: float = 0.0
@export var duration: float = 0.0 # 0 = instant, >0 = buff berdurasi (detik)

@export var stat_bonus:Dictionary={}
