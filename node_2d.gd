extends Node2D

@export var item_scene: PackedScene
@export var treat_textures: Array[Texture2D] = []
@export var hazard_textures: Array[Texture2D] = []
@export var spawn_min_x: float = 80.0
@export var spawn_max_x: float = 1080.0

# --- level settings ---
const TREATS_PER_LEVEL = 10
const BASE_FALL_SPEED = 250.0
const SPEED_PER_LEVEL = 60.0
const BASE_SPAWN_TIME = 1.0
const SPAWN_TIME_DROP_PER_LEVEL = 0.1
const MIN_SPAWN_TIME = 0.35
const MAX_HUNGER = 100.0
const BASE_HUNGER_DRAIN = 5.0          # points lost per second
const HUNGER_DRAIN_PER_LEVEL = 0.5     # drain gets faster each level
const HUNGER_PER_TREAT = 12.0
const HUNGER_AFTER_STARVING = 50.0
const POISON_DURATION = 4.0
const POISON_DRAIN_MULTIPLIER = 2.0

var poison_time: float = 0.0
var hunger: float = MAX_HUNGER
var score: int = 0
var lives: int = 3
var level: int = 1
var high_score: int = 0
var game_active: bool = false

const SAVE_PATH = "user://highscore.save"

@onready var spawn_timer: Timer = $SpawnTimer
@onready var player = $Player
@onready var ui = $UI

func _ready() -> void:
	randomize()
	load_high_score()
	player.get_node("CatchZone").area_entered.connect(_on_item_caught)
	spawn_timer.timeout.connect(_spawn_item)
	start_game()

func start_game() -> void:
	score = 0
	lives = 3
	level = 1
	game_active = true
	spawn_timer.wait_time = BASE_SPAWN_TIME
	hunger = MAX_HUNGER
	ui.update_hunger(hunger)
	spawn_timer.start()
	ui.update_hud(score, lives, level)
	ui.hide_game_over()
	poison_time = 0.0

func _current_fall_speed() -> float:
	return BASE_FALL_SPEED + (level - 1) * SPEED_PER_LEVEL

func _current_spawn_time() -> float:
	return max(MIN_SPAWN_TIME, BASE_SPAWN_TIME - (level - 1) * SPAWN_TIME_DROP_PER_LEVEL)

func _spawn_item() -> void:
	if not game_active:
		return
	if item_scene == null:
		push_error("Item Scene not assigned on Main")
		return
	var item = item_scene.instantiate()
	var is_treat = randf() > 0.3
	item.is_treat = is_treat
	var tex_list = treat_textures if is_treat else hazard_textures
	item.get_node("Sprite2D").texture = tex_list.pick_random()
	item.position = Vector2(randf_range(spawn_min_x, spawn_max_x), -40)
	item.fall_speed = _current_fall_speed()
	add_child(item)
	spawn_timer.wait_time = _current_spawn_time()

func _on_item_caught(area: Area2D) -> void:
	if not game_active:
		return
	if area.is_in_group("treat"):
		score += 1
		hunger = min(MAX_HUNGER, hunger + HUNGER_PER_TREAT)
		_check_level_up()
		ui.update_hud(score, lives, level)
	elif area.is_in_group("hazard"):
		poison_time = POISON_DURATION
		lose_life()
	area.queue_free()
	ui.update_hud(score, lives, level)
	if lives <= 0:
		game_over()

func _check_level_up() -> void:
	var new_level = 1 + score / TREATS_PER_LEVEL
	if new_level > level:
		level = new_level
		ui.show_level_up(level)

func game_over() -> void:
	game_active = false
	spawn_timer.stop()
	for node in get_tree().get_nodes_in_group("treat") + get_tree().get_nodes_in_group("hazard"):
		node.queue_free()
	if score > high_score:
		high_score = score
		save_high_score()
	ui.show_game_over(score, high_score)

func save_high_score() -> void:
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_32(high_score)

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = f.get_32()
		
func lose_life() -> void:
	if not game_active:
		return
	lives -= 1
	ui.update_hud(score, lives, level)
	if lives <= 0:
		game_over()

func _process(delta: float) -> void:
	if not game_active:
		return
	var drain = BASE_HUNGER_DRAIN + (level - 1) * HUNGER_DRAIN_PER_LEVEL
	if poison_time > 0.0:
		poison_time -= delta
		drain *= POISON_DRAIN_MULTIPLIER
	hunger -= drain * delta
	if hunger <= 0.0:
		hunger = HUNGER_AFTER_STARVING
		lose_life()
	ui.update_hunger(hunger, poison_time > 0.0)
