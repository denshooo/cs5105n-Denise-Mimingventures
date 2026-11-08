extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var lives_label = $LivesLabel
@onready var panel = $GameOverPanel
@onready var score_result = $GameOverPanel/VBoxContainer/ScoreResult
@onready var high_result = $GameOverPanel/VBoxContainer/HighScoreResult
@onready var try_again = $GameOverPanel/VBoxContainer/TryAgainButton
@onready var level_label = $LevelLabel
@onready var pause_panel = $PausePanel
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var mute_button = $PausePanel/VBoxContainer/MuteButton
@onready var hunger_bar = $HungerBar

const NORMAL_COLOR = Color(0.3, 0.8, 0.2)
const LOW_COLOR = Color(1.0, 0.6, 0.1)
const POISON_COLOR = Color(0.9, 0.2, 0.2)

var fill_style: StyleBoxFlat
var muted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()
	pause_panel.hide()
	try_again.pressed.connect(_on_try_again)
	resume_button.pressed.connect(_toggle_pause)
	mute_button.pressed.connect(_toggle_mute)
	fill_style = StyleBoxFlat.new()
	fill_style.bg_color = NORMAL_COLOR
	fill_style.set_corner_radius_all(6)
	hunger_bar.add_theme_stylebox_override("fill", fill_style)
	

func update_hud(score: int, lives: int, level: int) -> void:
	score_label.text = "Score: %d" % score
	lives_label.text = "Lives: %d" % lives
	level_label.text = "Level %d" % level

func show_level_up(level: int) -> void:
	level_label.text = "LEVEL UP! Level %d" % level
	var tween = create_tween()
	level_label.scale = Vector2(1.5, 1.5)
	level_label.pivot_offset = level_label.size / 2
	tween.tween_property(level_label, "scale", Vector2(1, 1), 0.4)
	await get_tree().create_timer(1.2).timeout
	level_label.text = "Level %d" % level

func show_game_over(score: int, high_score: int) -> void:
	score_result.text = "Score: %d" % score
	high_result.text = "Highest Score: %d" % high_score
	panel.show()

func hide_game_over() -> void:
	panel.hide()

func _on_try_again() -> void:
	get_parent().start_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("mute"):
		_toggle_mute()

func _toggle_pause() -> void:
	# don't allow pausing on the game over screen
	if not get_tree().paused and not get_parent().game_active:
		return
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused

func _toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	mute_button.text = "Unmute" if muted else "Mute"
	
func update_hunger(value: float, poisoned: bool = false) -> void:
	hunger_bar.value = value
	if poisoned:
		fill_style.bg_color = POISON_COLOR
	elif value < 25.0:
		fill_style.bg_color = LOW_COLOR
	else:
		fill_style.bg_color = NORMAL_COLOR
