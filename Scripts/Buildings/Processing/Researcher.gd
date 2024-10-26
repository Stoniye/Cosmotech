extends BuildingScriptClass

var needed_Items: Array[Item] = []
var needed_Count: Array[int] = []
var reseaching: Reseachable = null

func can_receive_item(itemNode: Sprite2D) -> bool:
	return needed_Items.has(itemNode.item)

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
	my_data = ReseacerSaveData.new()
	my_data.needed_Count = needed_Count
	my_data.needed_Items = needed_Items
	my_data.reseaching = reseaching
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	needed_Count = saveData.needed_Count
	needed_Items = saveData.needed_Items
	reseaching = saveData.reseaching
