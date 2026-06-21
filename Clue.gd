## Clue.gd (Sistem Overlap - Tanpa RayCast)
#extends Area2D
#
## ==========================================
##  EXPORT VARIABLES (Isi di Inspector)
## ==========================================
#@export var clue_name: String = "Pecahan Kaca"
#@export var clue_description: String = "Sepotong kaca dengan sidik jari."
#
## ==========================================
##  NODE REFS
## ==========================================
#@onready var sprite: Sprite2D = $Sprite2D
#@onready var collision_shape: CollisionShape2D = $CollisionShape2D
#
## ==========================================
##  INIT
## ==========================================
#func _ready():
	## --- Groups ---
	#add_to_group("clue_pickup")
	#add_to_group("det_eye_hidden")  # Biar muncul saat Det Eye
	#
	## --- Set Layer (Wajib) ---
	## Collision Layer = Layer 4 (interactable)
	#collision_layer = 1 << 3  # Geser bit ke index 3 (Layer 4)
	## Collision Mask = Layer 3 (player) agar bisa mendeteksi player masuk
	#collision_mask = 1 << 2  # Layer 3 (player)
	#
	## --- Koneksi Sinyal (Overlap) ---
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	#
	## --- Status Awal (Tersembunyi) ---
	#visible = false
	#if collision_shape:
		#collision_shape.disabled = true
	#process_mode = PROCESS_MODE_DISABLED
	#
	#print("[Clue] ", clue_name, " siap ditemukan.")
#
## ==========================================
##  SINYAL OVERLAP (Player Masuk / Keluar)
## ==========================================
#func _on_body_entered(body):
	## Cek apakah yang masuk adalah Player (dari group "player")
	#if body.is_in_group("player"):
		## Assign clue ini ke player agar bisa diambil
		#body.nearby_clue = self
		#print("[Clue] 🟢 Player mendekati: ", clue_name)
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		## Hapus referensi jika player menjauh
		#if body.nearby_clue == self:
			#body.nearby_clue = null
		#print("[Clue] 🔴 Player menjauh dari: ", clue_name)
#
## ==========================================
##  FUNGSI DIPANGGIL PLAYER SAAT INTERAKSI (E)
## ==========================================
#func pickup():
	#print("=====================================")
	#print("🔍 [CLUE] ", clue_name)
	#print("📝 Deskripsi: ", clue_description)
	#print("=====================================")
	#
	## Tambahkan ke Inventory Global
	#Global.add_clue(clue_name)
	#
	## Hilangkan dari peta
	#queue_free()



extends Area2D

@export var clue_name: String = "Test Clue"

func _ready():
	add_to_group("clue_pickup")
	add_to_group("det_eye_hidden")  # <-- KOMENTAR DULU UNTUK TEST
	
	# --- Set Layer ---
	collision_layer = 1 << 3  # Layer 4
	collision_mask = 1 << 2   # Layer 3 (player)
	
	# --- Shape ---
	#var shape = $CollisionShape2D
	#if shape:
		#print("Shape ditemukan!")
		#shape.disabled = false
		#print("Shape disabled: ", shape.disabled)
	#else:
		#print(" ERROR: CollisionShape2D tidak ditemukan!")
	
	# --- Status ---
	visible = false
	process_mode = PROCESS_MODE_INHERIT
	
	# --- Koneksi Sinyal MANUAL (via kode, lebih aman) ---
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	#print("Sinyal body_entered dan body_exited terhubung!")
	#print("Posisi Clue: ", global_position)
	#print("=================================")

func _on_body_entered(body):

	if body.is_in_group("player"):
		body.nearby_clue = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.nearby_clue = null

func pickup():
	Global.add_clue(clue_name)
	queue_free()
