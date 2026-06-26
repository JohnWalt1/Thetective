extends CharacterBody2D

@export var npc_name: String = "Warga"
@export var dialogue_text: String = "Aku Slime yang tidak berbahaya"
@export var is_hidden_clue: bool = false  
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var dialog_entries: Array[DialogCondition]=[]
const lines:Array[String]=[
	"Aku cuma slime biasa kok",
	"Tadi aku tinggal di goa yang ada naganya",
	"tunggu",
	"Mungkin itu Kadal, hehe",
]
# ==========================================
#  INIT
# ==========================================
func _ready():
	add_to_group("npc")
	sprite.play("default")
	if is_hidden_clue:
		add_to_group("det_eye_hidden")
		
		visible = false
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = true
		if has_node("CollisionPolygon2D"):
			$CollisionPolygon2D.disabled = true
		process_mode = PROCESS_MODE_DISABLED
		
		print("[NPC] ", npc_name, " tersembunyi (hidden clue).")
	else:

		visible = true
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = false
		process_mode = PROCESS_MODE_INHERIT
		print("[NPC] ", npc_name, " muncul di dunia normal.")

func _resolve_entry() -> DialogCondition:
	print("=== Resolving dialog for: ", npc_name, " ===")
	for entry in dialog_entries:
		var result:=dialog_entries
		if result:
			return entry
	return null
#Interaction
func interact():
	var entry:=_resolve_entry()
	if entry==null or entry.lines.is_empty():
		print("Tidak ada lah :v")
		return
	DialogManager.start_dialog(global_position, entry.lines)
	Global.set_flag("on_naga_defeated",true)
	# Jika NPC ini adalah hidden clue, mungkin setelah diajak bicara dia memberi item
	if is_hidden_clue:
		print(" [", npc_name, "] memberimu petunjuk tersembunyi!")
		# Global.add_clue("Petunjuk dari " + npc_name)

	
func _check_condition(entry: DialogCondition) -> bool:
	if entry.condition_flag == "":
		return true
	var current := Global.get_flag(entry.condition_flag)
	print("    get_flag('%s') = %s, expected = %s" % [entry.condition_flag, current, entry.expected_value])
	return current == entry.expected_value
	return Global.get(entry.condition_flag) == entry.expected_value
