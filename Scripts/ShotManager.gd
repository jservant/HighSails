extends Node2D

func handleShotSpawned(shot, position, direction):
	add_child(shot)
	shot.global_position = position
	shot.set_direction(direction)
