extends BuildingScriptClass
class_name DrillClass

var miningItem: Item
var extractionLevel: int = 0
var extractionType: String = "Drill"
var extractionSpeed: int = 1

var smokeParticles: GPUParticles2D

func _ready() -> void:
	super._ready()
	get_item()

#Get Item from the Block under the Drill
func get_item() -> void:
	var itemPath: String = get_node("../../../TileMap").get_cell_tile_data(get_parent().position/32).get_custom_data("ItemPath") #Get item Path
	if itemPath != "":
		var item: Item = load("res://Resources/Items/" + itemPath + ".tres")
		if item.extraction_type == extractionType:
			miningItem = item
			smokeParticles = load("res://Prefabs/Particles/SmokeParticles.tscn").instantiate()
			smokeParticles.emitting = false
			get_parent().add_child.call_deferred(smokeParticles)
			get_node("../../../../WorldTimer").connect("timeout", mine)

func mine() -> void:
	extractionLevel += extractionSpeed
	smokeParticles.emitting = true
	
	if !test_buildings() || !can_spawn_item(miningItem):
		smokeParticles.emitting = false
		return
	
	if extractionLevel >= miningItem.extraction_time:
		spawn_item(miningItem)
		extractionLevel = 0
