extends Node2D
class_name BuildingScriptClass

var to_building: Array[Area2D] = []
var holdingItem: Sprite2D

var dummyItem: Sprite2D

var my_data: SaveData = SaveData.new()

func _ready() -> void:
	dummyItem = Sprite2D.new()
	dummyItem.set_script(load("res://Scripts/WorldItem.gd"))
	dummyItem.item = null

func can_spawn_item(item: Item) -> bool:
	for building: Area2D in to_building:
		if building != null:
			dummyItem.item = item
			if building.get_node("Script").can_receive_item(dummyItem):
				return true
	return false

func spawn_item(item: Item) -> void:
	for building: Area2D in to_building:
		if !building.get_node("Script").can_receive_item(holdingItem):
			continue
		
		holdingItem = Sprite2D.new()
		holdingItem.scale = Vector2(0.45, 0.45)
		holdingItem.texture = item.image
		holdingItem.z_index = 1
		holdingItem.position = get_parent().position + (building.position - get_parent().position) - (Vector2(16, 16) * (building.position - get_parent().position).normalized())
		holdingItem.set_script(load("res://Scripts/WorldItem.gd"))
		holdingItem.item = item
		get_node("../..").add_child(holdingItem)
		holdingItem = editItem(holdingItem)
		building.get_node("Script").receive_item(holdingItem)
		holdingItem = null
		return

func editItem(itemNode: Sprite2D) -> Sprite2D:
	return itemNode

func test_buildings() -> bool:
	for i: int in to_building.size():
		if i < to_building.size():
			if to_building[i] == null:
				to_building.remove_at(i)
	return to_building.size() >= 1

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data.position = get_parent().position
	my_data.resource = get_parent().buildingRes
	my_data.planet = get_node("../../..").name
	for i: int in to_building.size():
		my_data.to_building_pos.append(to_building[i].position)
	my_data.buildingHealth = get_parent().buildingHealth
	saveData.append(my_data)
	my_data = SaveData.new()
