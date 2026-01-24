extends Node2D

@export var health := 3
@export var knockback := 10.0
@export var shake_amount := 5.0
@export var shake_duration := 0.1
@export var break_time := 0.5   # how long the break animation lasts

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var original_position: Vector2
var is_shaking := false
var is_broken := false

func _ready() -> void:
	original_position = position
	hurtbox.monitoring = true
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_broken:
		return

	if not area.is_in_group("player_hitbox"):
		return

	health -= 1
	print("Wall HP:", health)

	if not is_shaking:
		shake_wall()

	var dir: float = sign(global_position.x - area.global_position.x)
	position.x += dir * knockback

	if health <= 0:
		break_wall()

func break_wall() -> void:
	is_broken = true
	hurtbox.monitoring = false
	sprite.play("Break")

	await get_tree().create_timer(break_time).timeout
	queue_free()

func shake_wall() -> void:
	is_shaking = true

	var shake_timer := Timer.new()
	shake_timer.one_shot = true
	shake_timer.wait_time = shake_duration
	add_child(shake_timer)
	shake_timer.start()

	position += Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)

	shake_timer.timeout.connect(func():
		position = original_position
		is_shaking = false
		shake_timer.queue_free()
	)
