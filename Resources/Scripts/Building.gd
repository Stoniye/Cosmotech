extends Resource
class_name Building

@export var image: Texture2D
@export var name: String
@export var code: Script
@export_enum("1 Block Building", "4 Block Building") var building_type: String = "1 Block Building"
@export var info_window: PackedScene
@export var receives_items: bool
@export var gives_items: bool
@export var maxToConnection: int
@export var cost_item: Array[Item]
@export var cost_count: Array[int]
@export var description: String
@export var ConveyorPlacing: bool
@export var buildingHealth: int
@export var has_to_align: bool = false
@export var longDescription: String
