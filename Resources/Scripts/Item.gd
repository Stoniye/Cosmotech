extends Resource
class_name Item

@export var image: Texture2D
@export var name: String
@export var energy: int
@export var smelted: Item
@export var refined: Item
@export var stamped: Item
@export_enum("Drill", "Pump") var extraction_type: String = "Drill"
@export var extraction_time: int
@export var bullet_Color: Color
@export var bullet_damage: int
@export var longDescription: String
@export var alloyMultiplicator: float
