extends BuildingScriptClass

var needed_Items: Array[Item] = []
var needed_Count: Array[int] = []
var producing: Ammo = null: set = change_producing

var inv_item: Array[Item] = []
var inv_count: Array[int] = []

var inv_storage: int = 20

var produceStage: int = 0
const produceStage_finished: int = 3
var producingActive: bool = false

var smokeParticles: GPUParticles2D

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", produce)
	smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
	smokeParticles.emitting = false
	get_parent().add_child.call_deferred(smokeParticles)

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if producingActive:
		return false
	
	var itemCount: int = 0
	for count in inv_count:
		itemCount += count
	
	if needed_Items.has(item) && itemCount < inv_storage:
		return true
	
	return false

func change_producing(newProducing: Ammo) -> void:
	if newProducing != null && newProducing != producing:
		producing = newProducing
		needed_Items = newProducing.cost_items
		needed_Count = newProducing.cost_count

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	if !inv_item.has(item):
		inv_item.append(item)
		inv_count.append(0)
	
	var index: int = inv_item.find(item)
	inv_count[index] += 1
	
	if finished():
		producingActive = true

func produce() -> void:
	if !producingActive:
		return
	
	smokeParticles.emitting = true
	produceStage += 1
	
	if produceStage < produceStage_finished:
		return
	
	if can_spawn_item(producing.output):
		spawn_item(producing.output)
		producingActive = false
		smokeParticles.emitting = false
		produceStage = 0
		inv_item = []
		inv_count = []

func finished() -> bool:
	for item: Item in needed_Items:
		if inv_item.has(item):
			var invIndex: int = inv_item.find(item)
			var neededIndex: int = needed_Items.find(item)
			if inv_count[invIndex] < needed_Count[neededIndex]:
				return false
		else:
			return false
	
	return true

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = AmmoFacilitySaveData.new()
	my_data.inv_count = inv_count
	my_data.inv_item = inv_item
	my_data.producing = producing
	my_data.producingActive = producingActive
	my_data.inv_storage = inv_storage
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	inv_count = saveData.inv_count
	inv_item = saveData.inv_item
	producing =  saveData.producing
	producingActive = saveData.producingActive
	inv_storage = saveData.inv_storage
