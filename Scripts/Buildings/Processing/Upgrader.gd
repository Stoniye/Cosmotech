extends Node2D

var needed_Items: Array[Item] = []
var needed_Count: Array[int] = []
var reseaching: Reseachable = null

var holdingImage: Sprite2D
var to_building: Array[Area2D] = []

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	var can: bool = true
	
	if needed_Items.find(item) == -1:
		can = false
	
	return can

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	var index: int = needed_Items.find(item)
	
	needed_Count[index] -= 1
	
	if needed_Count[index] <= 0:
		needed_Items.remove_at(index)
		needed_Count.remove_at(index)
	
	if needed_Items.size() <= 0:
		get_node("../../../..").unlockedBuildings.append(reseaching.reseachBuilding.resource_name.replace(".tres", "").replace(".remap", ""))
		reseaching = null
		needed_Items = []
		needed_Count = []

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: ReseacerSaveData = ReseacerSaveData.new()
	my_data.position = get_parent().position
	my_data.resource = get_parent().buildingRes
	
	my_data.needed_Count = needed_Count
	my_data.needed_Items = needed_Items
	my_data.reseaching = reseaching
	
	my_data.planet = get_node("../../..").name
	for i: int in to_building.size():
		my_data.to_building_pos.append(to_building[i].position)
	my_data.buildingHealth = get_parent().buildingHealth
	saveData.append(my_data)

func on_game_load(saveData: SaveData) -> void:
	needed_Count = saveData.needed_Count
	needed_Items = saveData.needed_Items
	reseaching = saveData.reseaching
