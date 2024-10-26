extends BuildingScriptClass

var inventory_Item: Array[Item] = []
var inventory_Count: Array[int] = []

var fuel: int = 0
var rocket_storage: int = 40
var needed_Fuel: int = 70

var destination: Area2D

var rocket_Avalable: bool = true
var rocket_sprite: Sprite2D
var flightTime: int = 60
var flightTimer: int = flightTime
var isDestination: bool = false

func _ready() -> void:
	super._ready()
	rocket_sprite = Sprite2D.new()
	rocket_sprite.texture = load("res://Textures/Buildings/Processing/Rocket.png")
	rocket_sprite.z_index = 2
	get_parent().add_child.call_deferred(rocket_sprite)
	
	if isDestination:
		rocket_sprite.visible = false
		rocket_Avalable = false

func on_delete() -> void:
	if destination != null:
		destination.queue_free()

func place_destination(planet: String) -> void:
	if planet != get_node("../../..").name:
		var building: Building = load("res://Resources/Buildings/Processing/Rocket.tres")
		destination = load("res://Prefabs/Buildings/1 Block Building.tscn").instantiate()
		destination.position = get_parent().position
		destination.get_node("Image").texture = building.image
		destination.get_node("Script").set_script(building.code)
		destination.buildingRes = building
		destination.get_node("Script").isDestination = true
		destination.get_node("Script").destination = get_parent()
		get_node("../../../../" + planet + "/Buildings").add_child(destination)

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	var can: bool = true
	
	var items: int = 0
	for i: int in inventory_Count:
		items += i
	
	if items >= rocket_storage:
		can = false
	
	if item.name == "Kerosene":
		can = true
		if fuel >= needed_Fuel:
			can = false
	
	return rocket_Avalable && can && destination != null

func start_rocket() -> void:
	var items: int = 0
	for i: int in inventory_Count:
		items += i
	
	if items < rocket_storage || fuel < needed_Fuel || destination == null:
		return
	
	var tween: Tween = get_tree().create_tween()
	
	rocket_sprite.scale = Vector2(1, 1)
	
	tween.tween_property(
		rocket_sprite, "scale", Vector2(5, 5), 3
	)
	
	await tween.finished
	
	rocket_Avalable = false
	rocket_sprite.visible = false
	fuel = 0
	flightTimer = 0
	
	get_node("../../../../WorldTimer").connect("timeout", flight_countdown)

func receive_rocket(inv_Item: Array[Item], inv_Count: Array[int]) -> void:
	inventory_Item = inv_Item
	inventory_Count = inv_Count
	
	rocket_sprite.visible = true
	
	var tween: Tween = get_tree().create_tween()
	
	rocket_sprite.scale = Vector2(5, 5)
	
	tween.tween_property(
		rocket_sprite, "scale", Vector2(1, 1), 3
	)
	
	await tween.finished
	
	get_node("../../../../WorldTimer").connect("timeout", unload_inv)

func unload_inv() -> void:
	if !test_buildings():
		return
	
	if can_spawn_item(inventory_Item[0]):
		spawn_item(inventory_Item[0])
		
		inventory_Count[0] -= 1
		if inventory_Count[0] <= 0:
			inventory_Item.remove_at(0)
			inventory_Count.remove_at(0)
		
		if inventory_Item.size() <= 0:
			get_node("../../../../WorldTimer").disconnect("timeout", unload_inv)
			rocket_Avalable = true

func flight_countdown() -> void:
	flightTimer += 1
	if flightTimer >= flightTime:
		destination.get_node("Script").receive_rocket(inventory_Item, inventory_Count)
		inventory_Item = []
		inventory_Count = []
		get_node("../../../../WorldTimer").disconnect("timeout", flight_countdown)

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	if item.name == "Kerosene":
		fuel += item.energy
		start_rocket()
		return
	
	for i: int in inventory_Item.size():
		if inventory_Item[i] == item:
			inventory_Count[i] += 1
			start_rocket()
			return
	
	inventory_Item.append(item)
	inventory_Count.append(1)
	start_rocket()

func on_game_save(saveData: Array[SaveData]) -> void:
	if !isDestination:
		my_data = RocketSaveData.new()
		my_data.inventory_Item = inventory_Item
		my_data.inventory_Count = inventory_Count
		my_data.rocket_storage = rocket_storage
		my_data.rocket_Avalable = rocket_Avalable
		my_data.flightTime = flightTime
		my_data.flightTimer = flightTimer
		my_data.fuel = fuel
		if destination != null:
			my_data.D_inventory_Count = destination.get_node("Script").inventory_Count
			my_data.D_inventory_Item = destination.get_node("Script").inventory_Item
			my_data.D_rocket_Avalable = destination.get_node("Script").rocket_Avalable
			my_data.D_flightTimer = destination.get_node("Script").flightTimer
			my_data.D_BuildingHealth = destination.buildingHealth
			my_data.D_Position = destination.position
			my_data.D_Planet = destination.get_node("../..").name
			my_data.D_fuel = destination.get_node("Script").fuel
		
		super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	if !isDestination:
		saveData = saveData as RocketSaveData
		inventory_Item = saveData.inventory_Item
		inventory_Count = saveData.inventory_Count
		rocket_storage = saveData.rocket_storage
		rocket_Avalable = saveData.rocket_Avalable
		rocket_sprite.visible = rocket_Avalable
		flightTimer = saveData.flightTimer
		fuel = saveData.fuel
		if flightTimer != flightTime:
			get_node("../../../../WorldTimer").connect("timeout", flight_countdown)
		flightTime = saveData.flightTime
		
		if saveData.D_Position != Vector2.INF:
			place_destination(saveData.D_Planet)
			destination.position = saveData.D_Position
			destination.get_node("Script").inventory_Item = saveData.D_inventory_Item
			destination.get_node("Script").inventory_Count = saveData.D_inventory_Count
			destination.get_node("Script").rocket_Avalable = saveData.D_rocket_Avalable
			destination.get_node("Script").rocket_sprite.visible = destination.get_node("Script").rocket_Avalable
			destination.buildingHealth = saveData.D_BuildingHealth
			destination.get_node("Script").fuel = saveData.D_fuel
			
			destination.get_node("Script").flightTimer = saveData.D_flightTimer
			if destination.get_node("Script").flightTimer != flightTime:
				get_node("../../../../WorldTimer").connect("timeout", destination.get_node("Script").flight_countdown)
