extends Node2D

onready var shot_manager = $ShotManager
onready var players = get_tree().get_nodes_in_group("Players")

func _ready() -> void:
	for player in players:
		player.connect("playerFiredShot", shot_manager, "handleShotSpawned")
		player.connect("gameOver", self, "whoWon")

func _process(delta):
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().quit()

func whoWon(playerWhoWon: int):
	for player in players:
		player.queue_free()
	print("Player ", playerWhoWon+1, " wins!")
