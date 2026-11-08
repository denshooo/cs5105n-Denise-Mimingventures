extends Area2D

@export var ingredient_name: String = "crop_top"
@export var category: String = "top"  # "top", "bottom", or "shoes"

func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.nearby_rack = self

func _on_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.nearby_rack == self:
		body.nearby_rack = null
