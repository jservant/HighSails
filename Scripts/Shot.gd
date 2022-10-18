extends Area2D
class_name Shot

export (int) var speed = 30
var direction := Vector2.ZERO
onready var killtimer = $Killtimer

func _ready() -> void:
	killtimer.start()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()

func _on_Killtimer_timeout():
	queue_free()
