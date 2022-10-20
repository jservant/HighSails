extends Node2D

onready var shot_manager = $ShotManager
onready var players = get_tree().get_nodes_in_group("Players")
onready var barrels = get_tree().get_nodes_in_group("Barrels")
onready var p1ScoreUI = get_node("HUD/P1Score")
onready var p2ScoreUI = get_node("HUD/P2Score")
onready var p3ScoreUI = get_node("HUD/P3Score")
onready var p4ScoreUI = get_node("HUD/P4Score")
onready var youWinUI = get_node("HUD/YouWin")
var isGameOver = false

func _ready() -> void:
	#from prev screen ask how many people want to play
	#while pAmount is not 0, instantiate a player with their respective pindex
	#assign colors here too
	for player in players:
		player.connect("playerFiredShot", shot_manager, "handleShotSpawned")
		player.connect("gameOver", self, "whoWon")
		match (player.player_index):
			0: player.scoreUI = p1ScoreUI
			1: player.scoreUI = p2ScoreUI
			2: player.scoreUI = p3ScoreUI
			3: player.scoreUI = p4ScoreUI
			#assign player colors to these numbers
	if (players.size() < 4):
		if(players.size() < 3):
			p3ScoreUI.text = ""
		p4ScoreUI.text = ""

func _process(delta):
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().quit()
	if isGameOver == true:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
	#print("# of barrels in barrels: ", barrels.size())

func whoWon(playerWhoWon: int):
	for player in players:
		player.queue_free()
	youWinUI.text = str("Player ", playerWhoWon+1 ," wins!\nPress Start to play again")
	print("Player ", playerWhoWon+1, " wins!")
	isGameOver = true
