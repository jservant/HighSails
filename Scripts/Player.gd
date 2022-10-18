extends KinematicBody2D
 
signal playerFiredShot(shot, position, direction)

export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (PackedScene) var Shot


onready var rightCannon = $RightCannon

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
		
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	var shot_instance = Shot.instance()
	#var target = Vector2(rightCannon.global_position.x + 5, rightCannon.global_position.y)
	# code above is the end goal but currently doesn't work as intended
	var target = get_global_mouse_position()
	var direction_to_shoot = rightCannon.global_position.direction_to(target).normalized()
	emit_signal("playerFiredShot", shot_instance, rightCannon.global_position, direction_to_shoot)
