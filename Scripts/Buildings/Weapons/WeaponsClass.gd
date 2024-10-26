extends Node2D
class_name WeaponsClass

var targetedEnemy: Area2D = null
var toper: Sprite2D
var shootDir: Vector2
var shotingRate: Timer = Timer.new()

var ammu_Item: Item
var damage_Array: Array[int] = []
var ammu_Count: int

var storage: int = 20
var TestArea: Area2D
var rotationSpeed: float = 0.6
var bulletOffset: Vector2 = Vector2(10, 0)
var damageMulitplyer: float = 1
var seeArea: int = 320

func _ready() -> void:
	add_toper()
	create_area()
	create_bullet_destroy_area()
	add_timer()
	get_node("../SFX").stream = load("res://Sounds/SFX/Gunshot-1.mp3")

func add_timer() -> void:
	shotingRate.timeout.connect(shoot)
	shotingRate.autostart = true
	get_parent().add_child.call_deferred(shotingRate)

func shoot() -> void:
	if ammu_Count >= 1 && targetedEnemy != null && (toper.rotation > (shootDir.angle()-0.15) && toper.rotation < (shootDir.angle()+0.15)):
		var bullet: Sprite2D = load("res://Prefabs/Nodes for Multiple Scenes/Bullet.tscn").instantiate()
		bullet.damage = int(damage_Array[0] * damageMulitplyer)
		damage_Array.remove_at(0)
		bullet.speed = 300
		bullet.dir = shootDir
		bullet.position += bulletOffset.rotated(shootDir.angle())
		bullet.self_modulate = ammu_Item.bullet_Color
		get_parent().add_child(bullet)
	
		if get_node("../../../..").activePlanet == get_node("../../.."):
			get_node("../SFX").play()
	
		ammu_Count -= 1
		if ammu_Count <= 0:
			ammu_Item = null

func add_toper() -> void:
	var textureName: String = get_node("../Image").texture.resource_path.replace(".png", "")
	toper = Sprite2D.new()
	toper.name = "toper"
	get_node("../Image").texture = load(textureName + "_Base.png")
	toper.texture = load(textureName + "_Toper.png")
	get_parent().add_child.call_deferred(toper)

func _physics_process(delta: float) -> void:
	if targetedEnemy != null:
		shootDir = (targetedEnemy.position - get_parent().position).normalized()
		var angel_dif: float = wrapf(shootDir.angle() - toper.rotation, -180, 180)
		toper.rotation += sign(angel_dif) * min(abs(angel_dif), rotationSpeed * delta)
	else:
		var nearesRange: float = 300
		var nearestEnemy: Area2D = null
		var EnemyRange: float
		for area: Area2D in TestArea.get_overlapping_areas():
			if area.is_in_group("Enemy"):
				EnemyRange = get_parent().position.distance_to(area.position)
				if EnemyRange < nearesRange:
					nearesRange = EnemyRange
					nearestEnemy = area
		targetedEnemy = nearestEnemy

func can_receive_item(itemNode: Sprite2D) -> bool:
	var item: Item = itemNode.item
	
	if item.bullet_damage <= 0:
		return false
	
	if ammu_Count >= storage:
		return false
	
	if ammu_Item != null:
		if ammu_Item != item:
			return false
	
	return true

func receive_item(node: Sprite2D) -> void:
	var item: Item = node.item
	node.queue_free()
	
	if ammu_Item == null:
		ammu_Item = Item.new()
		ammu_Item = item
	else:
		ammu_Count += 1
	
	damage_Array.append(node.damage)

func create_area() -> void:
	var area: Area2D = Area2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	var coll: CollisionShape2D = CollisionShape2D.new()
	shape.radius = seeArea
	coll.shape = shape
	area.add_child(coll)
	area.monitorable = false
	TestArea = area
	get_parent().add_child.call_deferred(area)

func create_bullet_destroy_area() -> void:
	var area: Area2D = Area2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	var coll: CollisionShape2D = CollisionShape2D.new()
	shape.radius = 800
	coll.shape = shape
	area.add_child(coll)
	area.monitoring = false
	area.add_to_group("DestroyBullet")
	get_parent().add_child.call_deferred(area)

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: GunSaveData = GunSaveData.new()
	my_data.position = get_parent().position
	my_data.resource = get_parent().buildingRes
	my_data.planet = get_node("../../..").name
	my_data.ammu_Item = ammu_Item
	my_data.ammu_Count = ammu_Count
	my_data.storage = storage
	my_data.buildingHealth = get_parent().buildingHealth
	my_data.damage_Array = damage_Array
	saveData.append(my_data)

func on_game_load(saveData: SaveData) -> void:
	ammu_Item = saveData.ammu_Item
	ammu_Count = saveData.ammu_Count
	storage = saveData.storage
	damage_Array = saveData.damage_Array
