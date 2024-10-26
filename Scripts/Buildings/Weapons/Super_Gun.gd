extends WeaponsClass

func _ready() -> void:
	storage = 30
	rotationSpeed = 1.2
	damageMulitplyer = 1.5
	shotingRate.wait_time = 0.7
	seeArea = 360
	super._ready()
