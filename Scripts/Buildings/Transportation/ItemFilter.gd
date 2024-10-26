extends Node2D

var to_building: Array[Area2D] = []
var from_building: Area2D

var filterItem: Sprite2D

var holdingItem: Sprite2D
var speed: int = 50

var last5Items: Array[Item]
var filteringItem: Item

func _ready() -> void:
	create_crate()

func create_crate() -> void:
	var newSprite: Sprite2D = Sprite2D.new()
	newSprite = get_node("../Image").duplicate()
	newSprite.texture = load("res://Textures/Buildings/Transportation/ItemFilter_Crate.png")
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
	if holdingItem != null || filterItem != null:
		return false
	
	if filteringItem != null && to_building.size() <= 1:
		return false
	
	return true

func receive_item(node: Sprite2D) -> void:
	
	if node.item == filteringItem:
		filterItem = node
	else:
		holdingItem = node
	
	for newItem: Item in last5Items:
		if newItem == node.item:
			return
	
	if last5Items.size() >= 5:
		last5Items.remove_at(0)
	
	last5Items.append(node.item)

func _physics_process(delta: float) -> void:
	test_buildings()
	move_normal_item(delta)
	move_filter_item(delta)

func move_normal_item(delta: float) -> void:
	if holdingItem == null:
		return
	
	if holdingItem.global_position == get_parent().global_position:
		if to_building[0] != null:
			if to_building[0].get_node("Script").can_receive_item(holdingItem):
				to_building[0].get_node("Script").receive_item(holdingItem)
				holdingItem = null
	else:
		holdingItem.global_position = holdingItem.global_position.move_toward(get_parent().global_position, speed * delta)

func move_filter_item(delta: float) -> void:
	if filterItem == null:
		return
	
	if filterItem.global_position == get_parent().global_position:
		if to_building[1] != null:
			if to_building[1].get_node("Script").can_receive_item(filterItem):
				to_building[1].get_node("Script").receive_item(filterItem)
				filterItem = null
	else:
		filterItem.global_position = filterItem.global_position.move_toward(get_parent().global_position, speed * delta)

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: ItemFilterSaveData = ItemFilterSaveData.new()
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
	if filterItem != null:
		my_data.filterholdingItem = WorldItemSafeData.new()
		my_data.filterholdingItem.pos = filterItem.global_position
		my_data.filterholdingItem.item = filterItem.item
		my_data.filterholdingItem.damage = filterItem.damage
		my_data.filterholdingItem.heatLevel = filterItem.heatLevel
	my_data.last5Items = last5Items
	my_data.filteringItem = filteringItem
	my_data.buildingHealth = get_parent().buildingHealth
	saveData.append(my_data)

func on_game_load(saveData: SaveData) -> void:
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
	
	if saveData.filterholdingItem != null:
		filterItem = Sprite2D.new()
		filterItem.scale = Vector2(0.45, 0.45)
		filterItem.texture = saveData.filterholdingItem.item.image
		filterItem.z_index = 1
		filterItem.set_script(load("res://Scripts/WorldItem.gd"))
		filterItem.item = saveData.filterholdingItem.item
		filterItem.damage = saveData.filterholdingItem.damage
		filterItem.heatLevel = saveData.filterholdingItem.heatLevel
		get_node("../..").add_child(filterItem)
		filterItem.global_position = saveData.filterholdingItem.pos
