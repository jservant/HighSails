extends Node2D

func handleShotSpawned(shot: Shot, position: Vector2, direction: Vector2):
	add_child(shot)
	shot.global_position = position
	shot.set_direction(direction)
