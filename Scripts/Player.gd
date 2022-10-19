extends KinematicBody2D
 
signal playerFiredShot(shot, position, direction)

export var player_index = 0
export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (int) var health = 10
export (PackedScene) var Shot

onready var sprite = $Sprite
onready var collider = $CollisionShape2D
onready var cooldownTimer = $ShotCooldown
onready var respawnTimer = $RespawnTimer
onready var rightCannon = $RightCannon
onready var rightShotDirection = $RightCannonDirection
onready var leftCannon = $LeftCannon
onready var leftShotDirection = $LeftCannonDirection

const acc = 1
var local_velocity = Vector2()
var rotation_dir = 0
var motor = 0

func _physics_process(delta):
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	#linear_velocity = global_transform.basis.orthonormalized().xform(local_velocity)
	local_velocity = move_and_slide(local_velocity)
	#print("local velocity y: ", local_velocity.y, " motor: ", motor)
	if health <= 0 && respawnTimer.is_stopped():
		respawn()

func get_input():
	rotation_dir = 0
	if health > 0:
		if Input.is_joy_button_pressed(player_index, 12): #up
			#move, no rotation:
			#local_velocity.y = max(local_velocity.y - acc, -speed)
			#move w/ lerp, rotation:
			motor -= acc
			local_velocity = Vector2(0, max(motor, -speed)).rotated(rotation)
			#move, rotation:
			#local_velocity = Vector2(0, -speed).rotated(rotation)
		elif Input.is_joy_button_pressed(player_index, 13): #down
	#		#cool dodge idea: when pressed this does a short burst backwards. can't move for 1.5 seconds
	#		#local_velocity.y = min(local_velocity.y + acc, speed)
	#		#local_velocity = Vector2(0, min(local_velocity.y + acc, speed)).rotated(rotation)
	#		local_velocity = Vector2(0, speed).rotated(rotation) 
	#		No going backwards. Might change this later
			pass
		elif Input.is_joy_button_pressed(player_index, 14): #left
			rotation_dir -= 1
		elif Input.is_joy_button_pressed(player_index, 15): #right
			rotation_dir += 1
		else:
			local_velocity.x = lerp(local_velocity.x,0,0.025)
			local_velocity.y = lerp(local_velocity.y,0,0.025)
		if !Input.is_joy_button_pressed(player_index, 12):
			if motor >= 0:
				motor = 0
			else: motor += 2
		
		if Input.is_joy_button_pressed(player_index, 5): # RB/R1
			shoot_right()
		if Input.is_joy_button_pressed(player_index, 4): # LB/L1
			shoot_left()

func shoot_right():
	if cooldownTimer.is_stopped(): 
		var shot_instance = Shot.instance()
		var direction = (rightShotDirection.global_position - rightCannon.global_position).normalized()
		emit_signal("playerFiredShot", shot_instance, rightCannon.global_position, direction)
		cooldownTimer.start()
func shoot_left():
	if cooldownTimer.is_stopped():
		var shot_instance = Shot.instance()
		var direction = (leftShotDirection.global_position - leftCannon.global_position).normalized()
		emit_signal("playerFiredShot", shot_instance, leftCannon.global_position, direction)
		cooldownTimer.start()

func handle_hit():
	health -= 5
	print("player ", player_index+1 ," hit! health: ", health)
	if health <= 0: 
		death()

func death():
	print("Player ", player_index+1, " has died")
	sprite.visible = false
	collider.disabled = true
	respawnTimer.start()

func respawn():
	self.position = Vector2(500,500)
	sprite.visible = true
	collider.disabled = false
	print("Player ", player_index+1, " respawned")
	health = 10
