extends CharacterBody2D

@export var SPEED := 150.0
@export var GRAVITY := 600.0
@export var ATTACK_RANGE := 35.0
@export var TURN_COOLDOWN := 1.0
@export var PAUSE_BEFORE_TURN := 0.5

# ✅ PER-ENEMY STATS (OPTION 1)
@export var max_health := 5
@export var attack := 25

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var wall_check: RayCast2D = $Wall
@onready var wall_check2: RayCast2D = $Wall2
@onready var floor_check: RayCast2D = $Floor
@onready var floor_check2: RayCast2D = $Floor2
@onready var Hitbox: Area2D = $Hitbox
@onready var Hurtbox: Area2D = $Hurtbox

var player: CharacterBody2D = null
var direction := -1
var is_attacking := false
var is_hit := false
var is_dead := false
var turn_timer := 0.0
var pause_timer := 0.0
var pending_turn := false

# ✅ INSTANCE HEALTH
var health: int

func _ready() -> void:
	health = max_health  # ✅ each enemy gets its own HP

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	if not anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.connect(_on_animation_finished)

	if not Hurtbox.area_entered.is_connected(_on_hurtbox_area_entered):
		Hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	Hurtbox.monitoring = true

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if turn_timer > 0:
		turn_timer -= delta
	if pause_timer > 0:
		pause_timer -= delta
	else:
		if pending_turn:
			_flip_all(direction)
			pending_turn = false

	if is_attacking or is_hit:
		velocity.x = 0
		move_and_slide()
		return

	if player and player.is_in_group("player"):
		_handle_player_behavior()
	else:
		player = null
		_handle_patrol_behavior()

	move_and_slide()

func _handle_player_behavior() -> void:
	var distance := global_position.distance_to(player.global_position)
	direction = sign(player.global_position.x - global_position.x)
	_flip_all(direction)

	if distance > ATTACK_RANGE:
		velocity.x = direction * SPEED
		_play_animation("move")
	else:
		velocity.x = 0
		_play_animation("light")
		is_attacking = true

func _handle_patrol_behavior() -> void:
	if pause_timer > 0:
		velocity.x = 0
		_play_animation("idle")
		return

	velocity.x = direction * SPEED
	_play_animation("move")

	if turn_timer <= 0 and (wall_check.is_colliding() or not floor_check.is_colliding()):
		_pause_and_turn()

	if turn_timer <= 0 and (wall_check2.is_colliding() or not floor_check2.is_colliding()):
		_pause_and_turn()

func _pause_and_turn() -> void:
	velocity.x = 0
	_play_animation("idle")
	pause_timer = PAUSE_BEFORE_TURN
	turn_timer = TURN_COOLDOWN
	direction *= -1
	pending_turn = true

func _flip_all(dir: float) -> void:
	sprite.flip_h = dir < 0
	_update_hit_and_hurtbox_flip()

func _update_hit_and_hurtbox_flip() -> void:
	if sprite.flip_h:
		Hitbox.position.x = -8
		Hurtbox.position.x = -8
	else:
		Hitbox.position.x = 38
		Hurtbox.position.x = 8

func _play_animation(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "light":
		is_attacking = false
	elif anim_name == "hit":
		is_hit = false
	elif anim_name == "death":
		_die()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and not is_hit and not is_dead:
		health -= Stats.player_stats["attack"]  # ✅ LOCAL HEALTH
		print("Enemy HP:", health)

		is_hit = true
		is_attacking = false

		if health <= 0:
			is_dead = true
			Hitbox.monitoring = false
			Hurtbox.monitoring = false
			_play_animation("death")
		else:
			_play_animation("hit")

func _die() -> void:
	print("Enemy died")
	queue_free()
