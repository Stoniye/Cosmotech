extends DrillClass

var Fuel_Item: Item = null
var Fuel_Count: int
var Fuel_Storage: int = 15

var activeEnergy: int = 0

func _ready() -> void:
	extractionSpeed = 3
	super._ready()
	smokeParticles.position = Vector2(-8, -10)

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.energy <= 0 || Fuel_Count >= Fuel_Storage:
		return false
	
	if Fuel_Item != null && item.energy >= 1:
		if item != Fuel_Item:
			return false
	
	return true

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	if Fuel_Item == null:
		Fuel_Item = Item.new()
		Fuel_Item = node.item
		Fuel_Count = 1
	else:
		Fuel_Count += 1

func mine() -> void:
	if Fuel_Item == null || to_building == null || !can_spawn_item(miningItem):
		return
	
	if activeEnergy <= 0:
		activeEnergy += Fuel_Item.energy
		Fuel_Count -= 1
		if Fuel_Count <= 0:
			Fuel_Item = null
	
	super.mine()
	
	activeEnergy -= 1

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = DrillBurningSaveData.new()
	my_data.Fuel_Count = Fuel_Count
	my_data.Fuel_Item = Fuel_Item
	my_data.activeEnergy = activeEnergy
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	Fuel_Count = saveData.Fuel_Count
	Fuel_Item = saveData.Fuel_Item
	activeEnergy = saveData.activeEnergy
