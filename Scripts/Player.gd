extends KinematicBody2D
 
signal playerFiredShot(shot, position, direction)

export var player_index = 0
export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (PackedScene) var Shot

onready var rightCannon = $RightCannon
onready var rightShotDirection = $RightCannonDirection
onready var leftCannon = $LeftCannon
onready var leftShotDirection = $LeftCannonDirection

const acc = 1
var local_velocity = Vector2()
var rotation_dir = 0

func _physics_process(delta):
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	#linear_velocity = global_transform.basis.orthonormalized().xform(local_velocity)
	local_velocity = move_and_slide(local_velocity)
	print(local_velocity.y)

func get_input():
	rotation_dir = 0
	if Input.is_joy_button_pressed(player_index, 12): #up
		#move, no rotation:
		#local_velocity.y = max(local_velocity.y - acc, -speed)
		#move w/ lerp, rotation:
		#local_velocity = Vector2(0, max(local_velocity.y - acc, -speed)).rotated(rotation)
		#move, rotation:
		local_velocity = Vector2(0, -speed).rotated(rotation)
	elif Input.is_joy_button_pressed(player_index, 13): #down
		#cool dodge idea: when pressed this does a short burst backwards. can't move for 1.5 seconds
		#local_velocity.y = min(local_velocity.y + acc, speed)
		#local_velocity = Vector2(0, min(local_velocity.y + acc, speed)).rotated(rotation)
		local_velocity = Vector2(0, speed).rotated(rotation)
	elif Input.is_joy_button_pressed(player_index, 14): #left
		rotation_dir -= 1
	elif Input.is_joy_button_pressed(player_index, 15): #right
		rotation_dir += 1
	else:
		local_velocity.x = lerp(local_velocity.x,0,0.025)
		local_velocity.y = lerp(local_velocity.y,0,0.025)
	
	#todo: program a cooldown timer for shots
	if Input.is_joy_button_pressed(player_index, 5): # RB/R1
		shoot_right()
	if Input.is_joy_button_pressed(player_index, 4): # LB/L1
		shoot_left()

func shoot_right():
	var shot_instance = Shot.instance()
	var direction = (rightShotDirection.global_position - rightCannon.global_position).normalized()
	emit_signal("playerFiredShot", shot_instance, rightCannon.global_position, direction)
func shoot_left():
	var shot_instance = Shot.instance()
	var direction = (leftShotDirection.global_position - leftCannon.global_position).normalized()
	emit_signal("playerFiredShot", shot_instance, leftCannon.global_position, direction)
