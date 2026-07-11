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
