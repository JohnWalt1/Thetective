extends CharacterBody2D

@export var npc_name: String = "Warga"
@export var dialogue_text: String = "Aku Slime yang tidak berbahaya"
@export var is_hidden_clue: bool = false  
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

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

#Interaction
func interact():
	print("=====================================")
	print(" [", npc_name, "] : ", dialogue_text)
	print("=====================================")
	
	# TODO: Nanti sambungkan ke sistem Dialog Box UI
	if DialogManager:
		DialogManager.start_dialog(global_position, lines)
	# Jika NPC ini adalah hidden clue, mungkin setelah diajak bicara dia memberi item
	if is_hidden_clue:
		print(" [", npc_name, "] memberimu petunjuk tersembunyi!")
		# Global.add_clue("Petunjuk dari " + npc_name)
