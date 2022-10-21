extends KinematicBody2D
 
onready var players = get_tree().get_nodes_in_group("Players")
onready var spawns = get_tree().get_nodes_in_group("Spawns")
signal playerFiredShot(shot, position, direction)
signal gameOver(playerWhoWon)

export var player_index = 0
export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (int) var health = 10
export (int) var score = 0
export (PackedScene) var Shot

onready var sprite = $Sprite
onready var collider = $CollisionShape2D
onready var cooldownTimer = $ShotCooldown
onready var respawnTimer = $RespawnTimer
onready var invulnTimer = $InvulnTimer
onready var rightCannon = $RightCannon
onready var rightShotDirection = $RightCannonDirection
onready var leftCannon = $LeftCannon
onready var leftShotDirection = $LeftCannonDirection
onready var animPlayer = $AnimationPlayer
onready var scoreUI
onready var rSmoke = $RightCannonBlast
onready var lSmoke = $LeftCannonBlast

const acc = 1
var local_velocity = Vector2()
var rotation_dir = 0
var motor = 0
var spawnPicker = 0
var spawnsNotChosen = []
onready var inWindbox = false

func _physics_process(delta):
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	#linear_velocity = global_transform.basis.orthonormalized().xform(local_velocity)
	if !inWindbox:
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
		emit_signal("playerFiredShot", shot_instance, rightCannon.global_position, direction, player_index)
		play_anim("rCannonRecoil")
		rSmoke.emitting = true
		cooldownTimer.start()
func shoot_left():
	if cooldownTimer.is_stopped():
		var shot_instance = Shot.instance()
		var direction = (leftShotDirection.global_position - leftCannon.global_position).normalized()
		emit_signal("playerFiredShot", shot_instance, leftCannon.global_position, direction, player_index)
		play_anim("lCannonRecoil")
		lSmoke.emitting = true #todo: make this it's own seperate node and use the playerFiredShot signal
		cooldownTimer.start()

func handle_hit(playerThatShot: int):
	if invulnTimer.is_stopped():
		health -= 5
		print("player ", player_index+1 ," hit! health: ", health)
		if health <= 0: 
			#BUG: shooting where a player died causes them to die again if they haven't respawned
			#partially because the collider doesn't actually appear on death
			#spawn them reeaaaaally far out instead? then they can sail in like Ryan said
			death(playerThatShot)
	else:
		print("Shot from player ", playerThatShot+1, " didn't hit player ", player_index+1, " since they were invincible")

func death(playerThatShot: int):
	sprite.visible = false
	#collider.disabled = true #does not work
	self.position = Vector2(rand_range(2000, 5000), rand_range(2000,5000))
	#really hacky awful way to prevent player from getting shot after death
	for player in players:
		if player.player_index == playerThatShot:
			player.score += 1
			player.scoreUI.text = str(player.score)
			print("Player ", player_index+1, " was killed by Player ", playerThatShot+1, ". Player ", playerThatShot+1, "'s score: ", player.score)
			if player.score == 10:
				emit_signal("gameOver", player.player_index)
				break
	respawnTimer.start()

func respawn():
	spawnPicker = randi() % spawns.size()
	for spawn in spawns:
		if spawn.spawnValue == spawnPicker:
			var bodiesInSpawn = spawn.get_overlapping_bodies()
			if bodiesInSpawn.size() == 0:
				self.position = spawn.position
				spawnsNotChosen = []
				spawnPicker = 0
			else:
				spawnsNotChosen.append(spawn.spawnValue)
				spawnPicker = randi() % spawns.size()
#	for spawn in spawns:
		
	#self.position = Vector2(500,500)
	sprite.visible = true
	#collider.disabled = false
	print("Player ", player_index+1, " respawned")
	invulnTimer.start()
	health = 10

func play_anim(anim_name):
	if animPlayer.is_playing() and animPlayer.current_animation == anim_name:
		return
	animPlayer.play(anim_name)
