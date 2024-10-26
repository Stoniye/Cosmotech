extends BuildingScriptClass

var stampItem: Item = null
var fuelItem: Item = null

var stampCount: int
var fuelCount: int
var activeEnergie: int
var fuelStorage: int = 10
var stampStorage: int = 10

var stampTime: int = 6
var stampTimer: int = 0

var smokeParticles: GPUParticles2D

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", stamp)
	smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
	smokeParticles.emitting = false
	get_parent().add_child.call_deferred(smokeParticles)

func stamp() -> void:
	if !test_buildings():
		smokeParticles.emitting = false
		return
	
	if stampItem == null || fuelItem == null || stampCount <= 0 || fuelCount <= 0:
		smokeParticles.emitting = false
		return
	
	stampTimer += 1
	smokeParticles.emitting = true
	
	if stampTimer >= stampTime && can_spawn_item(stampItem.smelted):
		
		if activeEnergie <= 0:
			activeEnergie = fuelItem.energy
			fuelCount -= 1
			if fuelCount <= 0:
				fuelItem = null
		
		stampCount -= 1
		activeEnergie -= 1
		stampTimer = 0
		
		spawn_item(stampItem.stamped)
		
		if stampCount <= 0:
			stampItem = null
		
		return

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.stamped == null && item.energy <= 0:
		return false
	
	if fuelCount >= fuelStorage && stampCount >= stampStorage:
		return false
	
	if item.energy > 0 && fuelCount < fuelStorage:
		if fuelItem != null:
			if item != fuelItem:
				return false
		return true
	else:
		return false
	
	if item.stamped != null && stampCount < stampStorage:
		if stampItem != null:
			if item != stampItem:
				return false
		return true
	else:
		return false
	
	return false

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	#If Stampable
	if stampCount < stampStorage:
		if item.stamped != null && stampItem == null:
			stampItem = item
			stampCount = 1
		elif stampItem == item:
			stampCount += 1
		return
	
	#If Fuel
	if item.energy >= 1 && fuelItem == null:
		fuelItem = item
		fuelCount = 1
	elif fuelItem == item:
		fuelCount += 1

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = StamperSaveData.new()
	my_data.fuelStorage = fuelStorage
	my_data.stampStorage = stampStorage
	my_data.stampItem = stampItem
	my_data.fuelItem = fuelItem
	my_data.stampCount = stampCount
	my_data.fuelCount = fuelCount
	my_data.stampTimer = stampTimer
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	stampTimer = saveData.stampTimer
	fuelStorage = saveData.fuelStorage
	stampStorage = saveData.stampStorage
	stampItem = saveData.stampItem
	fuelItem = saveData.fuelItem
	stampCount = saveData.stampCount
	fuelCount = saveData.fuelCount
