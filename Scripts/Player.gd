extends KinematicBody2D
 
onready var players = get_tree().get_nodes_in_group("Players")
onready var spawns = get_tree().get_nodes_in_group("Spawns")
signal playerFiredShot(shot, position, direction)
signal gameOver(playerWhoWon)

export var player_index = -1
export (int) var speedLimit = 150
export (float) var rotation_speed = 1
#export (int) var health = 5
export (int) var score = 0
export (PackedScene) var Shot

onready var sprite = $Sprite
onready var rCannonSprite = $RightCannonSprite
onready var lCannonSprite = $LeftCannonSprite
onready var collider = $CollisionShape2D
onready var lCooldownTimer = $lShotCooldown
onready var rCooldownTimer = $rShotCooldown
onready var respawnTimer = $RespawnTimer
onready var invulnTimer = $InvulnTimer
onready var rightCannon = $RightCannon
onready var rightShotDirection = $RightCannonDirection
onready var leftCannon = $LeftCannon
onready var leftShotDirection = $LeftCannonDirection
onready var lAnimPlayer = $lCannonAnimation
onready var rAnimPlayer = $rCannonAnimation
onready var scoreUI
onready var rSmoke = $RightCannonBlast
onready var lSmoke = $LeftCannonBlast

const accRate = 1
var local_velocity = Vector2()
var rotation_dir = 0
var acc = 0.0
var spawnPicker = 0
var spawnsNotChosen = []
onready var inWindbox = false
var wind_Direction = 0.0
var hasSpawned = false
var isAlive = false

func _physics_process(delta):
	if !hasSpawned and Input.is_joy_button_pressed(player_index, 11): #start
		spawn()
	if hasSpawned:
		get_input()
		rotation += rotation_dir * rotation_speed * delta
		#linear_velocity = global_transform.basis.orthonormalized().xform(local_velocity)
		local_velocity = move_and_slide(local_velocity)
		#print("local velocity y: ", local_velocity.y, " acc: ", acc)
		if !isAlive && respawnTimer.is_stopped(): #fix this
			respawn()
		if !invulnTimer.is_stopped():
			sprite.visible = not sprite.visible
			lCannonSprite.visible = not lCannonSprite.visible
			rCannonSprite.visible = not rCannonSprite.visible
		else:
			sprite.visible = true
			lCannonSprite.visible = true
			rCannonSprite.visible = true

func spawn():
	hasSpawned = true # might be wrong with this going first
	scoreUI.text = "0"
	respawn()

func get_input():
	rotation_dir = 0
	rotation_speed = -(acc / 150)
	if isAlive:
		#if Input.is_joy_button_pressed(player_index, 12): #up
			#move, no rotation:
			#local_velocity.y = max(local_velocity.y - accRate, -speedLimit)
			#move w/ lerp, rotation:
		if inWindbox:
			if rotation_degrees < wind_Direction + 30 and rotation_degrees > wind_Direction - 30:
				acc -= accRate*8
			else:
				acc -= accRate
			local_velocity = Vector2(0, acc).rotated(rotation)
		else: # the default state
			local_velocity = Vector2(0, acc).rotated(rotation)
			if acc < -speedLimit:
				acc += accRate*8
			else:
				if acc > -speedLimit:
					acc -= accRate
			#move, rotation:
			#local_velocity = Vector2(0, -speedLimit).rotated(rotation)
		#if Input.is_joy_button_pressed(player_index, 13): #down
	#		#cool dodge idea: when pressed this does a short burst backwards. can't move for 1.5 seconds
	#		#local_velocity.y = min(local_velocity.y + accRate, speedLimit)
	#		#local_velocity = Vector2(0, min(local_velocity.y + accRate, speedLimit)).rotated(rotation)
	#		local_velocity = Vector2(0, speedLimit).rotated(rotation) 
	#		No going backwards. Might change this later
			#pass
		if Input.is_joy_button_pressed(player_index, 14): #left
			rotation_dir -= 1
		elif Input.is_joy_button_pressed(player_index, 15): #right
			rotation_dir += 1
#		else:
#			local_velocity.x = lerp(local_velocity.x,0,0.025)
#			local_velocity.y = lerp(local_velocity.y,0,0.025)
#		if !Input.is_joy_button_pressed(player_index, 12):
#			if acc >= 0:
#				acc = 0
#			else: acc += 2
		
		if Input.is_joy_button_pressed(player_index, 5): # RB/R1
			shoot_right()
		if Input.is_joy_button_pressed(player_index, 4): # LB/L1
			shoot_left()

func shoot_right():
	if rCooldownTimer.is_stopped(): 
		var shot_instance = Shot.instance()
		var direction = (rightShotDirection.global_position - rightCannon.global_position).normalized()
		emit_signal("playerFiredShot", shot_instance, rightCannon.global_position, direction, player_index)
		play_anim(rAnimPlayer, "rCannonRecoil")
		rSmoke.emitting = true
		rCooldownTimer.start()
func shoot_left():
	if lCooldownTimer.is_stopped():
		var shot_instance = Shot.instance()
		var direction = (leftShotDirection.global_position - leftCannon.global_position).normalized()
		emit_signal("playerFiredShot", shot_instance, leftCannon.global_position, direction, player_index)
		play_anim(lAnimPlayer, "lCannonRecoil")
		lSmoke.emitting = true #todo: make this it's own seperate node and use the playerFiredShot signal
		lCooldownTimer.start()

func handle_hit(playerThatShot: int):
	if invulnTimer.is_stopped():
		isAlive = false
		#print("player ", player_index+1 ," hit! health: ", health)
		#if health <= 0: 
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
	print("Spawns size: ", spawns.size())
	for spawn in spawns:
		print("Spawn picker value for player ", player_index+1,": ", spawnPicker)
		if spawn.spawnValue == spawnPicker:
			var bodiesInSpawn = spawn.get_overlapping_bodies()
			print("Bodies in spawn ", spawn.spawnValue, ": ", bodiesInSpawn)
			if bodiesInSpawn.size() == 0:
				print("0 bodies found in spawn ", spawn.spawnValue, ", spawning player ", player_index+1)
				self.position = spawn.position
				spawnsNotChosen = []
				spawnPicker = 0
				bodiesInSpawn = []
				break
			else:
				print(bodiesInSpawn.size(), " bodies found in spawn ", spawn.spawnValue, ". Spawning player ", player_index+1, " sonewhere else")
				spawnsNotChosen.append(spawn.spawnValue)
				bodiesInSpawn = []
				spawnPicker = randi() % spawns.size()
	sprite.visible = true
	#collider.disabled = false
	print("Player ", player_index+1, " respawned")
	invulnTimer.start()
	isAlive = true #health = 10

func play_anim(animPlayer, anim_name):
	if animPlayer.is_playing() and animPlayer.current_animation == anim_name:
		return
	else: animPlayer.play(anim_name)
