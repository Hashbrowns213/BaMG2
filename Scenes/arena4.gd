extends Node2D

## ===============================
## SETTINGS
## ===============================
@export var enemy_scene: PackedScene
@export var max_enemies: int = 20
@export var spawn_delay: float = 2.0

## ===============================
## SIGNALS
## ===============================
signal wave_warning(msg: String)
signal wave_cleared(msg: String)

## ===============================
## NODES
## ===============================
@onready var trigger: Area2D = $Trigger
@onready var spawn_area: Area2D = $SpawnArea
@onready var spawn_shape: CollisionShape2D = $SpawnArea/SpawnArea
@onready var barrier: CollisionShape2D = $Barrier/wol
@onready var arena_ui: CanvasLayer = $CanvasLayer

## ===============================
## STATE
## ===============================
var enemies_alive: int = 0
var spawning: bool = false
var wave_started: bool = false


# =====================================================
# READY
# =====================================================
func _ready() -> void:
	print("Arena ready")

	if trigger:
		trigger.body_entered.connect(_on_body_entered)
	else:
		push_error("Trigger node missing!")

	if arena_ui:
		wave_warning.connect(arena_ui.show_message)
		wave_cleared.connect(arena_ui.show_message)
	else:
		push_error("Arena UI missing!")


# =====================================================
# PLAYER ENTERS ARENA
# =====================================================
func _on_body_entered(body: Node) -> void:
	if wave_started:
		return

	if body.is_in_group("player"):
		start_wave()


# =====================================================
# START WAVE
# =====================================================
func start_wave() -> void:
	wave_started = true
	spawning = true

	print("Wave starting")
	wave_warning.emit("Warning: Wave Incoming")

	await get_tree().create_timer(1.2).timeout
	spawn_enemies_one_by_one()


# =====================================================
# SPAWN LOOP (1 BY 1)
# =====================================================
func spawn_enemies_one_by_one() -> void:
	for i in range(max_enemies):
		spawn_enemy()
		await get_tree().create_timer(spawn_delay).timeout

	spawning = false
	print("Finished spawning enemies")


# =====================================================
# SPAWN SINGLE ENEMY
# =====================================================
func spawn_enemy() -> void:
	if enemy_scene == null:
		push_error("Enemy scene not assigned!")
		return

	var enemy: Node2D = enemy_scene.instantiate()
	get_parent().add_child(enemy)

	enemy.global_position = get_random_spawn_position()

	enemies_alive += 1
	print("Enemy spawned | Alive:", enemies_alive)

	# SUPER RELIABLE death detection
	enemy.tree_exited.connect(_on_enemy_removed)


# =====================================================
# RANDOM POSITION INSIDE RECTANGLE SPAWN AREA
# =====================================================
func get_random_spawn_position() -> Vector2:
	if spawn_shape == null:
		push_error("Spawn collision shape missing!")
		return global_position

	var rect_shape: RectangleShape2D = spawn_shape.shape as RectangleShape2D
	if rect_shape == null:
		push_error("Spawn shape is not RectangleShape2D!")
		return global_position

	var extents: Vector2 = rect_shape.extents

	var rand_x: float = randf_range(-extents.x, extents.x)
	var rand_y: float = randf_range(-extents.y, extents.y)

	return spawn_area.to_global(Vector2(rand_x, rand_y))


# =====================================================
# ENEMY REMOVED (WHEN queue_free() HAPPENS)
# =====================================================
func _on_enemy_removed() -> void:
	enemies_alive -= 1
	print("Enemy died | Remaining:", enemies_alive)

	if enemies_alive <= 0 and !spawning:
		finish_wave()


# =====================================================
# FINISH WAVE
# =====================================================
func finish_wave() -> void:
	print("Wave cleared")
	wave_cleared.emit("Wave Cleared")
	disable_barrier()


# =====================================================
# DISABLE BARRIER (WOL COLLISION)
# =====================================================
func disable_barrier() -> void:
	print("DISABLE BARRIER CALLED")
	print("Barrier node:", barrier)

	if barrier == null:
		push_error("Barrier CollisionShape2D is NULL!")
		return

	barrier.disabled = true

	# Hide StaticBody parent visually (optional)
	if barrier.get_parent():
		barrier.get_parent().visible = false

	print("Barrier collision disabled successfully")
