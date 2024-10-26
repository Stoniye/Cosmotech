extends SaveData
class_name RocketSaveData

#Both
@export var rocket_storage: int
@export var flightTime: int

#Start
@export var inventory_Item: Array[Item]
@export var inventory_Count: Array[int]
@export var rocket_Avalable: bool
@export var flightTimer: int
@export var fuel: int

#Destination
@export var D_inventory_Item: Array[Item]
@export var D_inventory_Count: Array[int]
@export var D_rocket_Avalable: bool
@export var D_flightTimer: int
@export var D_BuildingHealth: int
@export var D_Position: Vector2 = Vector2.INF
@export var D_Planet: String
@export var D_fuel: int
