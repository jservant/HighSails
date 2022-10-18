extends Node2D

onready var shot_manager = $ShotManager
onready var player = $Player

func _ready() -> void:
	player.connect("playerFiredShot", shot_manager, "handleShotSpawned")
