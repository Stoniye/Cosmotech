extends BuildingScriptClass

var inventory_Item: Array[Item] = []
var inventory_Count: Array[int] = []

var storage: int = 5000

var exporting_items: Array[int] = []
var exportingItem: int = 0

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", export_items)

func can_receive_item(_itemNode: Sprite2D) -> bool:
	var items: int = 0
	for i: int in inventory_Count:
		items += i
	
	return items < storage

func export_items() -> void:
	if !test_buildings():
		return
	
	for building: Area2D in to_building:
		if building == null:
			continue
		
		if exporting_items.size() <= 0:
			continue
		
		dummyItem.item = inventory_Item[exporting_items[exportingItem]]
		
		if !building.get_node("Script").can_receive_item(dummyItem):
			continue
		
		holdingItem = Sprite2D.new()
		holdingItem.scale = Vector2(0.45, 0.45)
		holdingItem.texture = inventory_Item[exporting_items[exportingItem]].image
		holdingItem.z_index = 1
		
		var nearestPoint: Vector2 = Vector2(0, 0)
		for pos: Vector2 in get_parent().connectionPoints:
			if building.position.distance_to(pos + get_parent().position) < building.position.distance_to(nearestPoint + get_parent().position):
				nearestPoint = pos
		
		holdingItem.position = get_parent().position + (nearestPoint - (Vector2(16, 16) * ((nearestPoint + get_parent().position) - building.position).normalized()))
		
		holdingItem.set_script(load("res://Scripts/WorldItem.gd"))
		holdingItem.item = inventory_Item[exporting_items[exportingItem]]
		get_node("../..").add_child(holdingItem)
		building.get_node("Script").receive_item(holdingItem)
		holdingItem = null
		
		inventory_Count[exporting_items[exportingItem]] -= 1
		
		if inventory_Count[exporting_items[exportingItem]] <= 0:
			inventory_Item.remove_at(exporting_items[exportingItem])
			inventory_Count.remove_at(exporting_items[exportingItem])
			exporting_items.erase(exportingItem)
		
		exportingItem += 1
		
		if exportingItem >= exporting_items.size():
			exportingItem = 0

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	for i: int in inventory_Item.size():
		if inventory_Item[i] == item:
			inventory_Count[i] += 1
			return
	
	inventory_Item.append(item)
	inventory_Count.append(1)

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = HubSaveData.new()
	my_data.storage = storage
	my_data.inventory_Item = inventory_Item
	my_data.inventory_Count = inventory_Count
	my_data.exportingItem = exportingItem
	my_data.exporting_items = exporting_items
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	storage = saveData.storage
	inventory_Item = saveData.inventory_Item
	inventory_Count = saveData.inventory_Count
	exporting_items = saveData.exporting_items
	exportingItem = saveData.exportingItem
