extends Node2D

@onready var line = $TrailLine
var max_points = 50          # panjang trail (jumlah titik)
var point_distance = 5.0     # jarak minimal antar titik

var last_position = Vector2.ZERO

func _ready():
	line.points = []         # kosongkan di awal

# Fungsi ini dipanggil dari player setiap frame (atau setiap _physics_process)
func add_point(pos: Vector2):
	# Jika belum ada titik, tambahkan langsung
	if line.points.is_empty():
		line.add_point(pos)
		last_position = pos
		return

	# Cek jarak dari titik terakhir agar tidak terlalu rapat
	if last_position.distance_to(pos) >= point_distance:
		line.add_point(pos)
		last_position = pos

	# Batasi jumlah titik (buang titik paling tua)
	while line.points.size() > max_points:
		line.remove_point(0)
