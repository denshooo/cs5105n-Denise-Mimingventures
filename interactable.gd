extends Area2D

@onready var visual: Node2D = get_parent()
var shaking: bool = false

func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.nearby_interactable = self

func _on_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.nearby_interactable == self:
		body.nearby_interactable = null

func interact() -> void:
	if shaking:
		return
	shaking = true

	var original_rotation = visual.rotation
	var tween = create_tween()
	tween.tween_property(visual, "rotation", deg_to_rad(-8), 0.05)
	tween.tween_property(visual, "rotation", deg_to_rad(8), 0.1)
	tween.tween_property(visual, "rotation", deg_to_rad(-6), 0.1)
	tween.tween_property(visual, "rotation", deg_to_rad(6), 0.1)
	tween.tween_property(visual, "rotation", original_rotation, 0.08)
	tween.tween_callback(func(): shaking = false)
