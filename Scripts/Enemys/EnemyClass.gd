extends Area2D
class_name EnemyClass

var walkSpeed: int = 10
var buildingDamage: int = 1
var health: int = 2

var walkDir: Vector2
var targetedBuilding: Area2D = null
var move: bool = true
@onready var base: Area2D = $"../../Buildings/Base"

func _physics_process(delta: float) -> void:
	if base == null:
		return
	
	if targetedBuilding != null:
		walkDir = (targetedBuilding.position - position).normalized()
	else:
		$DamageRate.stop()
		move = true
		walkDir = (base.position - position).normalized()
	
	if move:
		rotation = walkDir.angle()
		position += walkDir * walkSpeed * delta

func _on_see_range_area_entered(area: Area2D) -> void:
	if area.has_method("init_test_area") && targetedBuilding == null && area.get_node("../..") == get_node("../.."):
		targetedBuilding = area

func _on_area_entered(area: Area2D) -> void:
	if area == targetedBuilding:
		move = false
		$DamageRate.start()
	elif area == base:
		move = false
		$DamageRate.start()
		targetedBuilding = base

func play_death_animation() -> void:
	var tween: Tween = get_tree().create_tween()
	var sprite: Sprite2D = get_node("Image")
	
	tween.tween_property(
		sprite, "scale", Vector2(0, 0), 0.2
	).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()

func damage(amound: int) -> void:
	health -= amound
	if health <= 0:
		play_death_animation()

func damageBuilding() -> void:
	if targetedBuilding != null:
		targetedBuilding.damage(buildingDamage)

func on_game_save(saveData: Array[SaveData]) -> void:
	var my_data: SaveData = SaveData.new()
	my_data.position = position
	my_data.resource = load("res://Prefabs/Enemys/Bob.tscn")
	my_data.planet = get_node("../..").name
	my_data.buildingHealth = health
	my_data.isBuilding = false
	saveData.append(my_data)

func on_game_load(saveData: SaveData) -> void:
	health = saveData.buildingHealth
