extends KinematicBody2D
 
export (int) var speed = 50
export (float) var rotation_speed = 1.5

const acc = 1
var local_velocity = Vector2()
var rotation_dir = 0

func get_input():
	rotation_dir = 0
	if Input.is_action_pressed("move_up"):
		#move, no rotation:
		#local_velocity.y = max(local_velocity.y - acc, -speed)
		#move w/ lerp, rotation:
		#local_velocity = Vector2(0, max(local_velocity.y - acc, -speed)).rotated(rotation)
		#move, rotation:
		local_velocity = Vector2(0, -speed).rotated(rotation)
	elif Input.is_action_pressed("move_down"):
		#cool dodge idea: when pressed this does a short burst backwards. can't move for 1.5 seconds
		#local_velocity.y = min(local_velocity.y + acc, speed)
		#local_velocity = Vector2(0, min(local_velocity.y + acc, speed)).rotated(rotation)
		local_velocity = Vector2(0, speed).rotated(rotation)
	elif Input.is_action_pressed("move_left"):
		rotation_dir -= 1
	elif Input.is_action_pressed("move_right"):
		rotation_dir += 1
	else:
		local_velocity.x = lerp(local_velocity.x,0,0.025)
		local_velocity.y = lerp(local_velocity.y,0,0.025)

func _physics_process(delta):
	var linear_velocity = Vector2()
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	#linear_velocity = global_transform.basis.orthonormalized().xform(local_velocity)
	local_velocity = move_and_slide(local_velocity)
	print(local_velocity.y)
