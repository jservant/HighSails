extends Node2D

func handleShotSpawned(shot: Area2D, position: Vector2, direction: Vector2, player_index: int):
	add_child(shot)
	shot.global_position = position
	shot.set_direction(direction)
	shot.playerThatShot = player_index
