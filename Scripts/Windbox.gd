extends Area2D

onready var players = get_tree().get_nodes_in_group("Players")
	
func _on_Windbox_body_entered(body):
	if body.is_in_group("Players"):
		body.inWindbox = true
		body.wind_Direction = rotation_degrees
			#print("Windbox is working on player ", body.player_index+1, ". Rotation give value is between ",
			#current_direction+give_degrees, " and ", current_direction-give_degrees," current player rotation value is",
			#body.rotation_degrees)
		print("Player ", body.player_index+1, " is in a windbox")

func _on_Windbox_body_exited(body):
	if body.is_in_group("Players"):
		body.inWindbox = false
