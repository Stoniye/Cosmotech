extends BuildingScriptClass

var alloyItem: Item = null
var alloyCount: int
var oreItem: Item = null
var oreCount: int

var oreStorage: int = 10
var alloyStorage: int = 10

var alloyTime: int = 3
var alloyTimer: int = 0

var smokeParticles: GPUParticles2D

func _ready() -> void:
	super._ready()
	get_node("../../../../WorldTimer").connect("timeout", alloy)
	smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
	smokeParticles.emitting = false
	get_parent().add_child.call_deferred(smokeParticles)

func alloy() -> void:
	if !test_buildings():
		smokeParticles.emitting = false
		return
	
	if alloyItem == null || oreItem == null || alloyCount <= 0 || oreCount <= 0:
		smokeParticles.emitting = false
		return
	
	smokeParticles.emitting = true
	alloyTimer += 1
	
	if alloyTimer >= alloyTime && can_spawn_item(alloyItem):
		oreCount -= 1
		alloyCount -= 1
		alloyTimer = 0
		
		spawn_item(alloyItem)
		
		if alloyCount <= 0:
			alloyItem = null
		if oreCount <= 0:
			oreItem = null
		return

func editItem(itemNode: Sprite2D) -> Sprite2D:
	itemNode.damage *= oreItem.alloyMultiplicator
	return itemNode

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.bullet_damage > 0:
		if alloyCount >= alloyStorage:
			return false
		if alloyItem != null:
			if item != alloyItem:
				return false
		return true
	
	if itemNode.heatLevel >= 30 && item.alloyMultiplicator > 0:
		if oreCount >= oreStorage:
			return false
		if oreItem != null:
			if item != oreItem:
				return false
		return true
	
	return false

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	#If alloyable
	if item.bullet_damage > 0 && alloyItem == null:
		alloyItem = item
		alloyCount = 1
	elif alloyItem == item:
		alloyCount += 1
	
	#If ore
	if item.alloyMultiplicator > 0 && oreItem == null:
		oreItem = item
		oreCount = 1
	elif oreItem == item:
		oreCount += 1

#func on_game_save(saveData: Array[SaveData]) -> void:
	#my_data = FurnaceSaveData.new()
	#my_data.oreStorage = oreStorage
	#my_data.alloyStorage = alloyStorage
	#my_data.alloyItem = alloyItem
	#my_data.oreItem = oreItem
	#my_data.alloyCount = alloyCount
	#my_data.oreCount = oreCount
	#my_data.alloyTimer = alloyTimer
	#super.on_game_save(saveData)
#
#func on_game_load(saveData: SaveData) -> void:
	#alloyTimer = saveData.alloyTimer
	#oreStorage = saveData.oreStorage
	#alloyStorage = saveData.alloyStorage
	#alloyItem = saveData.alloyItem
	#oreItem = saveData.oreItem
	#alloyCount = saveData.alloyCount
	#oreCount = saveData.oreCount
