extends Area2D

@export var is_treat: bool = true
@export var fall_speed: float = 250.0

func _ready() -> void:
	add_to_group("treat" if is_treat else "hazard")

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y > 620:   # below the screen
		queue_free()
