extends Area2D

onready var players = get_tree().get_nodes_in_group("Players")
	
func _on_Windbox_body_entered(body):
	if body.is_in_group("Players"):
		body.inWindbox = true
		print("Player ", body.player_index+1, " is in a windbox")

func _on_Windbox_body_exited(body):
	if body.is_in_group("Players"):
		body.inWindbox = false
