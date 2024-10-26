extends BuildingScriptClass

var smeltItem: Item = null
var fuelItem: Item = null

var smeltCount: int
var fuelCount: int
var activeEnergie: int
var fuelStorage: int = 10
var smeltStorage: int = 10

var smeltTime: int = 3
var smeltTimer: int = 0

var smokeParticles: GPUParticles2D

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", smelt)
	smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
	smokeParticles.emitting = false
	get_parent().add_child.call_deferred(smokeParticles)

func smelt() -> void:
	if !test_buildings():
		smokeParticles.emitting = false
		return
	
	if smeltItem == null || fuelItem == null || smeltCount <= 0 || fuelCount <= 0:
		smokeParticles.emitting = false
		return
	
	smeltTimer += 1
	smokeParticles.emitting = true
	
	if smeltTimer >= smeltTime && can_spawn_item(smeltItem.smelted):
		
		if activeEnergie <= 0:
			activeEnergie = fuelItem.energy
			fuelCount -= 1
			if fuelCount <= 0:
				fuelItem = null
		
		smeltCount -= 1
		activeEnergie -= 1
		smeltTimer = 0
		
		spawn_item(smeltItem.smelted)
		
		if smeltCount <= 0:
			smeltItem = null
		
		return

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.smelted == null && item.energy <= 0:
		return false
	
	if fuelCount >= fuelStorage && item.energy >= 1:
		return false
	
	if smeltItem != null && item.smelted != null:
		if smeltItem != item:
			return false
	
	if smeltCount >= smeltStorage && item.smelted != null:
		return false
	
	return true

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	#If Smeltable
	if item.smelted != null && smeltItem == null:
		smeltItem = item
		smeltCount = 1
	elif smeltItem == item:
		smeltCount += 1
	
	#If Fuel
	if item.energy >= 1 && fuelItem == null:
		fuelItem = item
		fuelCount = 1
	elif fuelItem == item:
		fuelCount += 1

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = FurnaceSaveData.new()
	my_data.fuelStorage = fuelStorage
	my_data.smeltStorage = smeltStorage
	my_data.smeltItem = smeltItem
	my_data.fuelItem = fuelItem
	my_data.smeltCount = smeltCount
	my_data.fuelCount = fuelCount
	my_data.smeltTimer = smeltTimer
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	smeltTimer = saveData.smeltTimer
	fuelStorage = saveData.fuelStorage
	smeltStorage = saveData.smeltStorage
	smeltItem = saveData.smeltItem
	fuelItem = saveData.fuelItem
	smeltCount = saveData.smeltCount
	fuelCount = saveData.fuelCount
