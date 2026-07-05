extends Resource
class_name Effect

enum EffectType{HEAL,BUFF_STAT, BUFF_TIME, PERMANENT_STAT, SPECIAL }

@export var type: EffectType
@export var stat: String = ""            # misal "attack", "defense", "speed"
@export var value: float = 0.0
@export var duration: float = 0.0        # untuk buff_time (detik)
@export var description: String = ""
@export var special_script: Script = null # untuk efek custom
