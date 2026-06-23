extends Node2D

@onready var depth_particles = $Trail_Depth
@onready var base_particles = $Trail_Base
@onready var rim_particles = $Trail_Rim

var all_particles = []

func _ready():
	all_particles = [depth_particles, base_particles, rim_particles]

# Fungsi untuk menyalakan atau mematikan jejak
func set_emitting(is_moving: bool):
	for particles in all_particles:
		particles.emitting = is_moving
