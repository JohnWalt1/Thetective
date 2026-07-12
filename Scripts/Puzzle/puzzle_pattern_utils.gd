class_name PuzzlePatternUtils
## Helper opsional untuk desain level tanpa harus klak-klik Array di Inspector satu-satu.
## Cocok dipanggil dari script @tool atau dari _ready() level testing sementara.
##
## Contoh pakai:
##   var pattern := [
##       "..##..",
##       ".####.",
##       "##..##",
##       "..##..",
##   ]
##   level.target_cells = PuzzlePatternUtils.cells_from_pattern(pattern)
## '#' (atau karakter apapun selain '.' / spasi) = sel target, '.' = kosong.

static func cells_from_pattern(pattern: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(pattern.size()):
		var row: String = pattern[y]
		for x in range(row.length()):
			var ch := row[x]
			if ch != "." and ch != " ":
				result.append(Vector2i(x, y))
	return result

static func blocks_from_pattern(pattern: Array, color_map: Dictionary = {}) -> Array[PuzzleBlockData]:
	var groups: Dictionary = {}  # symbol (String) -> Array[Vector2i] posisi absolut
	for y in range(pattern.size()):
		var row: String = pattern[y]
		for x in range(row.length()):
			var ch := row[x]
			if ch == "." or ch == " ":
				continue
			if not groups.has(ch):
				groups[ch] = []
			groups[ch].append(Vector2i(x, y))
 
	var auto_colors := [
		Color(0.3, 0.7, 1.0), Color(1.0, 0.5, 0.2), Color(0.6, 1.0, 0.4),
		Color(1.0, 0.3, 0.6), Color(0.8, 0.6, 1.0), Color(1.0, 0.9, 0.3),
	]
 
	var result: Array[PuzzleBlockData] = []
	var i := 0
	for symbol in groups.keys():
		var positions: Array = groups[symbol]
		var min_pos: Vector2i = positions[0]
		for p in positions:
			min_pos.x = mini(min_pos.x, p.x)
			min_pos.y = mini(min_pos.y, p.y)
 
		var cells: Array[Vector2i] = []
		for p in positions:
			cells.append(p - min_pos)
 
		var block := PuzzleBlockData.new()
		block.cells = cells
		block.start_cell = min_pos
		block.color = color_map.get(symbol, auto_colors[i % auto_colors.size()])
		block.movable = true
		result.append(block)
		i += 1
 
	return result
 
