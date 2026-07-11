extends Resource
class_name PuzzleBlockData
## Definisi 1 blok: bentuknya (kumpulan sel), posisi awal, dan warnanya.
## Buat lewat FileSystem > klik kanan > New Resource > PuzzleBlockData.

## Offset sel relatif terhadap titik acuan blok. Vector2i.ZERO wajib ada sebagai acuan.
## Contoh bentuk "L" 3 sel: [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)]
@export var cells: Array[Vector2i] = [Vector2i.ZERO]

## Posisi awal blok di grid puzzle (sel kiri-atas dari bentuknya) saat level dimulai.
@export var start_cell: Vector2i = Vector2i.ZERO

## Warna tampilan blok saat sedang di-drag (hanya bantuan visual, bukan penentu hasil).
@export var color: Color = Color(0.3, 0.7, 1.0)

## false = blok statis/terkunci, tidak bisa digeser (berguna sebagai "penghalang" tetap).
@export var movable: bool = true
