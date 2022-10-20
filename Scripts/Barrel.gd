extends StaticBody2D

onready var main = get_parent()
export (PackedScene) var explosion

func _ready():
	#main.barrels += self
	pass

func handle_hit(playerThatShot):
	var explosion_instance = explosion.instance()
	queue_free()
