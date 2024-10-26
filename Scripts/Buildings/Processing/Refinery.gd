extends BuildingScriptClass

var refineItem: Item = null
var fuelItem: Item = null

var refineCount: int
var fuelCount: int
var activeEnergie: int
var fuelStorage: int = 10
var refineStorage: int = 10

var smokeParticles: GPUParticles2D

var refineTime: int = 5
var refineTimer: int = 0

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", refine)
	smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
	smokeParticles.emitting = false
	smokeParticles.position = Vector2(-7, 6)
	get_parent().add_child.call_deferred(smokeParticles)

func refine() -> void:
	if !test_buildings():
		smokeParticles.emitting = false
		return
	
	if refineItem == null || fuelItem == null || refineCount <= 0 || fuelCount <= 0 || !can_spawn_item(refineItem.refined):
		smokeParticles.emitting = false
		return
	
	refineTimer += 1
	smokeParticles.emitting = true
	
	if refineTimer >= refineTime:
		
		if activeEnergie <= 0:
			activeEnergie = fuelItem.energy
			fuelCount -= 1
			if fuelCount <= 0:
				fuelItem = null
		
		refineCount -= 1
		activeEnergie -= 1
		
		spawn_item(refineItem.refined)
		
		refineTimer = 0
		return

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.refined == null && item.energy <= 0:
		return false
	
	if item.energy >= 1:
		return fuelCount < fuelStorage
	
	if item.refined != null:
		return refineCount < refineStorage
	
	return false

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	#If Smeltable
	if item.refined != null && refineItem == null:
		refineItem = item
		refineCount = 1
		return
	elif refineItem == item:
		refineCount += 1
		return
	
	#If Fuel
	if item.energy >= 1 && fuelItem == null:
		fuelItem = item
		fuelCount = 1
		return
	elif fuelItem == item:
		fuelCount += 1
		return

func on_game_save(saveData: Array[SaveData]) -> void:
	my_data = RefineSaveData.new()
	my_data.fuelStorage = fuelStorage
	my_data.refineStorage = refineStorage
	my_data.refineItem = refineItem
	my_data.fuelItem = fuelItem
	my_data.refineCount = refineCount
	my_data.fuelCount = fuelCount
	my_data.refineTimer = refineTimer
	super.on_game_save(saveData)

func on_game_load(saveData: SaveData) -> void:
	refineTimer = saveData.refineTimer
	fuelStorage = saveData.fuelStorage
	refineStorage = saveData.refineStorage
	refineItem = saveData.refineItem
	fuelItem = saveData.fuelItem
	refineCount = saveData.refineCount
	fuelCount = saveData.fuelCount
