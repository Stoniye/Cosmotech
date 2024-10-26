extends Node2D

var to_building: Array[Area2D] = []
var from_building: Area2D

var holdingItem: Sprite2D
var speed: float = 50.54

func _ready() -> void:
	get_node("../Image").hframes = 8
	var animator: AnimationPlayer = load("res://Prefabs/Animators/ConveyorAnimator.tscn").instantiate()
	animator.name = "ConveyorAnimator"
	get_parent().add_child.call_deferred(animator)
	animator.play("Move")

func fake_align() -> void:
	var fake_to: Vector2 = Vector2(0, 0)
	var fake_from: Vector2 = Vector2(0, 0)
	
	if to_building.size() >= 1:
		var nearest_ConnectionPoint_To: Vector2 = Vector2(0, 0)
		for point: Vector2 in to_building[0].connectionPoints:
			if get_parent().position.distance_to(point + to_building[0].position) < get_parent().position.distance_to(nearest_ConnectionPoint_To):
				nearest_ConnectionPoint_To = point + to_building[0].position
		fake_to = (nearest_ConnectionPoint_To - get_parent().position).normalized()
	
	if from_building != null:
		var nearest_ConnectionPoint_From: Vector2 = Vector2(0, 0)
		for point: Vector2 in from_building.connectionPoints:
			if get_parent().position.distance_to(point + from_building.position) < get_parent().position.distance_to(nearest_ConnectionPoint_From):
				nearest_ConnectionPoint_From = point + from_building.position
		fake_from = (nearest_ConnectionPoint_From - get_parent().position).normalized()
	
	if fake_to != Vector2(0, 0):
		set_image(fake_to, -fake_to)
	if fake_from != Vector2(0, 0):
		set_image(-fake_from, fake_from)

func set_image(to: Vector2, from: Vector2) -> void:
	var image: Sprite2D = get_node("../Image")
	
	match from:
		Vector2(1 ,0):
			match to:
				Vector2(-1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Right2Left.png")
				Vector2(0, 1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Right2Down.png")
				Vector2(0, -1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Right2Up.png")
		Vector2(-1 ,0):
			match to:
				Vector2(1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Left2Right.png")
				Vector2(0, 1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Left2Down.png")
				Vector2(0, -1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Left2Up.png")
		Vector2(0 ,1):
			match to:
				Vector2(-1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Down2Left.png")
				Vector2(1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Down2Right.png")
				Vector2(0, -1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Down2Up.png")
		Vector2(0 ,-1):
			match to:
				Vector2(-1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Up2Left.png")
				Vector2(1, 0):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Up2Right.png")
				Vector2(0, 1):
					image.texture = load("res://Textures/Buildings/Transportation/Conveyor - Normal/Up2Down.png")

func align() -> void:
	test_buildings()
	
	if to_building.size() <= 0 || from_building == null:
		return
	
	var nearest_ConnectionPoint_To: Vector2 = Vector2(0, 0)
	for point: Vector2 in to_building[0].connectionPoints:
		if get_parent().position.distance_to(point + to_building[0].position) < get_parent().position.distance_to(nearest_ConnectionPoint_To):
			nearest_ConnectionPoint_To = point + to_building[0].position
	
	var nearest_ConnectionPoint_From: Vector2 = Vector2(0, 0)
	for point: Vector2 in from_building.connectionPoints:
		if get_parent().position.distance_to(point + from_building.position) < get_parent().position.distance_to(nearest_ConnectionPoint_From):
			nearest_ConnectionPoint_From = point + from_building.position
	
	var from_dir: Vector2 = ((nearest_ConnectionPoint_From) - get_parent().position).normalized()
	var to_dir: Vector2 = ((nearest_ConnectionPoint_To) - get_parent().position).normalized()
	
	set_image(to_dir, from_dir)

func test_buildings() -> void:
	for i: int in to_building.size():
		if i < to_building.size():
			if to_building[i] == null:
				to_building.remove_at(i)
	
	if to_building.size() <= 0 || from_building == null:
		if get_parent().testArea == null:
			get_parent().buildingRes.receives_items = from_building == null
			get_parent().buildingRes.gives_items = to_building.size() <= 0
			get_parent().init_test_area()
	elif to_building.size() >= 1 && from_building != null:
		if get_parent().testArea != null:
			get_parent().testArea.queue_free()

func can_receive_item(_itemNode: Sprite2D) -> bool:
	return holdingItem == null

func receive_item(node: Sprite2D) -> void:
	holdingItem = node

func _physics_process(delta: float) -> void:
	test_buildings()
	
	if holdingItem == null:
		return
	
	if holdingItem.global_position == get_parent().global_position:
		if to_building.size() >= 1:
			if to_building[0].get_node("Script").can_receive_item(holdingItem):
				to_building[0].get_node("Script").receive_item(holdingItem)
				holdingItem = null
	else:
		holdingItem.global_position = holdingItem.global_position.move_toward(get_parent().global_position, speed * delta)

func on_delete() -> void:
	if holdingItem != null:
		holdingItem.queue_free()

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: ConveyorSaveData = ConveyorSaveData.new()
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
	
	if to_building.size() <= 0 || from_building == null:
		fake_align()
