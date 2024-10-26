extends Node2D

var to_building: Array[Area2D] = []
var from_building: Area2D

var speed: int = 50
var holdingItem: Sprite2D

var side: bool = false

func _ready() -> void:
	create_crate()

func create_crate() -> void:
	var newSprite: Sprite2D = Sprite2D.new()
	newSprite = get_node("../Image").duplicate()
	newSprite.texture = load("res://Textures/Buildings/Transportation/Distributor_Crate.png")
	newSprite.z_index = 2
	get_parent().add_child.call_deferred(newSprite)

func align() -> void:
	if from_building == null:
		return
	
	var from_dir: Vector2 = (from_building.position - get_parent().position).normalized()
	
	match from_dir:
		Vector2(1 ,0):
			get_parent().rotation_degrees = -90
		Vector2(-1 ,0):
			get_parent().rotation_degrees = 90
		Vector2(0 ,1):
			get_parent().rotation_degrees = 0
		Vector2(0 ,-1):
			get_parent().rotation_degrees = 180
	
	if to_building.size() >= 2:
		var filter_dir: Vector2 = (to_building[1].position - get_parent().position).normalized()
		match filter_dir:
			Vector2(0, -1):
				get_node("../Image").flip_h = true
				return
			Vector2(-1, 0):
				get_node("../Image").flip_h = true
				return
	
	get_node("../Image").flip_h = false

func test_buildings() -> void:
	for i: int in to_building.size():
		if i < to_building.size():
			if to_building[i] == null:
				to_building.remove_at(i)

func can_receive_item(_itemNode: Sprite2D) -> bool:
	return holdingItem == null

func receive_item(item: Item, node: Sprite2D) -> void:
	holdingItem = node

func _physics_process(delta: float) -> void:
	test_buildings()
	if holdingItem == null:
		return
	
	var index: int = 0
	
	if side && to_building.size() >= 2:
		index = 1
	
	if holdingItem.global_position == get_parent().global_position:
		if to_building[index] != null:
			if to_building[index].get_node("Script").can_receive_item(holdingItem):
				to_building[index].get_node("Script").receive_item(holdingItem)
				holdingItem = null
				side = !side
	else:
		holdingItem.global_position = holdingItem.global_position.move_toward(get_parent().global_position, speed * delta)

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: DistributorSaveData = DistributorSaveData.new()
	my_data.position = get_parent().position
	my_data.resource = get_parent().buildingRes
	my_data.planet = get_node("../../..").name
	if holdingItem != null:
		my_data.holdingItem = WorldItemSafeData.new()
		my_data.holdingItem.pos = holdingItem.global_position
		my_data.holdingItem.item = holdingItem.item
		my_data.holdingItem.damage = holdingItem.damage
		my_data.holdingItem.heatLevel = holdingItem.heatLevel
	for i: int in to_building.size():
		my_data.to_building_pos.append(to_building[i].position)
	if from_building != null:
		my_data.from_building_pos = from_building.position
	my_data.side = side
	my_data.buildingHealth = get_parent().buildingHealth
	saveData.append(my_data)

func on_game_load(saveData: SaveData) -> void:
	side = saveData.side
	
	if saveData.holdingItem != null:
		holdingItem = Sprite2D.new()
		holdingItem.scale = Vector2(0.45, 0.45)
		holdingItem.texture = saveData.holdingItem.item.image
		holdingItem.z_index = 1
		holdingItem.set_script(load("res://Scripts/WorldItem.gd"))
		holdingItem.item = saveData.holdingItem.item
		holdingItem.damage = saveData.holdingItem.damage
		holdingItem.heatLevel = saveData.holdingItem.heatLevel
		get_node("../..").add_child(holdingItem)
		holdingItem.global_position = saveData.holdingItem.pos
