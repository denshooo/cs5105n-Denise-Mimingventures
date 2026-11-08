extends Control

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	$LeftButton.button_down.connect(func(): Input.action_press("move_left"))
	$LeftButton.button_up.connect(func(): Input.action_release("move_left"))
	$RightButton.button_down.connect(func(): Input.action_press("move_right"))
	$RightButton.button_up.connect(func(): Input.action_release("move_right"))
	$PauseButton.pressed.connect(func(): get_parent().get_node("UI")._toggle_pause())
	
