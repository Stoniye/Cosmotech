extends Sprite2D

var item: Item
var damage: int
var heatLevel: int

func _ready() -> void:
	damage = item.bullet_damage
	if heatLevel > 0:
		heatUp(heatLevel)

func heatUp(newLevel: int) -> void:
	if newLevel >= heatLevel:
		heatLevel = newLevel
		self_modulate = Color(1, 1-(heatLevel*0.0043), 1-(heatLevel*0.0020), 1)
		get_node("../../../WorldTimer").connect("timeout", coolDown)

func coolDown() -> void:
	heatLevel -= 3
	self_modulate = Color(1, 1-(heatLevel*0.0043), 1-(heatLevel*0.0020), 1)
	if heatLevel <= 0:
		get_node("../../../WorldTimer").disconnect("timeout", coolDown)
		self_modulate = Color(1, 1, 1, 1)
		heatLevel = 0
