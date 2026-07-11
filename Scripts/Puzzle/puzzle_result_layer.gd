extends Node2D
## Menggambar HASIL AKHIR overlap: sel dengan jumlah tumpukan ganjil = terlihat (solid),
## genap = transparan (tidak digambar sama sekali). Ini "kebenaran visual" dari puzzle,
## dipisah dari tampilan blok individual (lihat puzzle_block.gd) supaya logikanya jelas
## dan tidak bergantung pada trik alpha-blending bawaan Godot.
##
## Node ini harus jadi sibling dari BlocksContainer dan diletakkan SETELAHNYA di tree
## (Scene panel) agar digambar di atas semua blok.

@onready var puzzle: OverlapPuzzle = get_parent()

func _draw() -> void:
	if not puzzle or not puzzle.level:
		return
	var cs: int = puzzle.level.cell_size

	for cell in puzzle.overlap_count.keys():
		var count: int = puzzle.overlap_count[cell]
		if count % 2 == 1:
			var r := Rect2(Vector2(cell) * cs, Vector2(cs, cs))
			draw_rect(r, Color(1, 1, 1, 0.95), true)
			draw_rect(r, Color(0, 0, 0, 0.4), false, 1.5)
