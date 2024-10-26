extends Resource
class_name GenerationTile

var Atlas_ID: Array[Vector2i]
var prob: int
var number_of_tiles: int
var radius_of_tiles: int

func _init(tileID: Array[Vector2i], tileProb: int, tileNumber: int, tileRaduis: int) -> void:
	Atlas_ID = tileID
	prob = tileProb
	number_of_tiles = tileNumber
	radius_of_tiles = tileRaduis
