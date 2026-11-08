extends CharacterBody2D

const SPEED = 450.0

@export var min_x: float = 60.0
@export var max_x: float = 1100.0   # adjust to your play area width

func _physics_process(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	velocity.y = 0

	if direction != 0:
		$Sprite2D.flip_h = direction > 0

	move_and_slide()
	position.x = clamp(position.x, 60.0, get_viewport_rect().size.x - 60.0)

	
