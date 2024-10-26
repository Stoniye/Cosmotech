extends Area2D
class_name BlockBuildingClass

var buildingRes: Building
var ClickZone: Vector2 = Vector2(25, 25)
var ClickedPos: Vector2
var testArea: Area2D
var buildingHealth: int = 0
var AreaRad: int = 22
var connectionPoints: Array[Vector2] = [Vector2(0, 0)]

func _ready() -> void:
	init_test_area()
	add_to_group(buildingRes.name)
	buildingHealth = buildingRes.buildingHealth

#Creates testing area if building needs one
func init_test_area() -> void:
	if (buildingRes.receives_items || buildingRes.gives_items) && testArea == null:
		var area: Area2D = Area2D.new()
		var shape: CircleShape2D = CircleShape2D.new()
		var coll: CollisionShape2D = CollisionShape2D.new()
		shape.radius = AreaRad
		coll.shape = shape
		area.add_child(coll)
		area.connect("area_entered", entered)
		area.monitorable = false
		testArea = area
		add_child(area)

#Testing area entered other area
func entered(area: Area2D) -> void:
	if area.is_in_group("isConveyor"):
		if area.get_node("../..") == get_node("../.."): #Check if on same planet
			
			if area == get_node("."):
				return
			
			if is_in_group("isConveyor"):
				if get_node("Script").from_building == area:
					return
				for building: Area2D in get_node("Script").to_building:
					if building == area:
						return
			
			#If building can both, give conveyor what is needed
			if buildingRes.gives_items && buildingRes.receives_items:
				if area.get_node("Script").from_building == null:
					area.get_node("Script").from_building = get_node(".")
					get_node("Script").to_building.append(area)
				else:
					if area.get_node("Script").to_building.size() >= area.buildingRes.maxToConnection:
						return
					area.get_node("Script").to_building.append(get_node("."))
					if is_in_group("isConveyor"):
						get_node("Script").from_building = area
			else:
				if buildingRes.gives_items && area.get_node("Script").from_building == null:
					area.get_node("Script").from_building = get_node(".")
					get_node("Script").to_building.append(area)
				elif buildingRes.receives_items:
					if area.get_node("Script").to_building.size() >= area.buildingRes.maxToConnection:
						return
					area.get_node("Script").to_building.append(get_node("."))
					if is_in_group("isConveyor"):
						get_node("Script").from_building = area
			
			area.get_node("Script").align()
			if is_in_group("isConveyor"):
				get_node("Script").align()

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			ClickedPos = event.position
		else:
			#If Finger didn't drag
			if (ClickedPos+ClickZone).x >= event.position.x && (ClickedPos-ClickZone).x <= event.position.x && (ClickedPos+ClickZone).y >= event.position.y && (ClickedPos-ClickZone).y <= event.position.y:
				get_node("../../..")._building_selected(get_node("."))

func play_damage_animation() -> void:
	var tween: Tween = get_tree().create_tween()
	var sprite: Sprite2D = get_node("Image")
	
	sprite.scale = Vector2(1, 1)
	
	tween.tween_property(
		sprite, "scale", Vector2(0.93, 0.93), 0.1
	).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		sprite, "scale", Vector2(1, 1), 0.1
	).set_ease(Tween.EASE_OUT).set_delay(0.1)
	
	await tween.finished

func play_destroy_animation() -> void:
	var tween: Tween = get_tree().create_tween()
	var sprite: Sprite2D = get_node("Image")
	
	sprite.scale = Vector2(1, 1)
	
	tween.tween_property(
		sprite, "scale", Vector2(0, 0), 0.2
	).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	if get_node("Script").has_method("on_delete"):
		get_node("Script").on_delete()
	
	queue_free()

func damage(amound: int) -> void:
	buildingHealth -= amound
	play_damage_animation()
	if buildingHealth <= 0:
		play_destroy_animation()
