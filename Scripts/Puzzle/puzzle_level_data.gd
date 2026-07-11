extends Resource
class_name PuzzleLevelData
## Definisi 1 level overlap_puzzle: ukuran grid, bentuk target, dan blok yang tersedia.
## Buat lewat FileSystem > klik kanan > New Resource > PuzzleLevelData.

@export var level_name: String = "Level 1"

## Ukuran grid dalam jumlah sel (bukan pixel).
@export var grid_size: Vector2i = Vector2i(6, 6)

## Ukuran 1 sel dalam pixel.
@export var cell_size: int = 64

## Sel-sel yang HARUS terlihat (hasil overlap ganjil) supaya puzzle dianggap selesai.
@export var target_cells: Array[Vector2i] = []

## Semua blok yang dipakai di level ini.
@export var blocks: Array[PuzzleBlockData] = []
