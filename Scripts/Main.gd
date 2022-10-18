extends Node2D

onready var shot_manager = $ShotManager
onready var players = get_tree().get_nodes_in_group("Players")

func _ready() -> void:
	for player in players:
		player.connect("playerFiredShot", shot_manager, "handleShotSpawned")
