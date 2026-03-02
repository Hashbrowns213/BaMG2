extends CharacterBody2D

# ======================
# EXPORTS
# ======================
@export var max_health := 3
@export var attack := 10
@export var coin_scene: PackedScene
@export var projectile_scene: PackedScene

@export var hover_height := 20.0
@export var move_speed := 150.0
@export var preferred_distance := 150.0
@export var attack_distance := 150.0
@export var retreat_distance := 80.0
@export var attack_cooldown := 1.0

@export var bob_amount := 6.0
@export var bob_speed := 3.0

# ======================
# NODES
# ======================
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionRange
@onready var shoot_point: Marker2D = $ShootPoint
@onready var Hitbox: Area2D = $Hitbox
@onready var Hurtbox: Area2D = $Hurtbox

# ======================
# INTERNAL
# ======================
var health: int
var player: Node2D = null
var base_y: float
var time := 0.0

var can_attack := true
var is_attacking := false
var is_hit := false
var is_dead := false

# ======================
# READY
# ======================
func _ready():
	health = max_health
	base_y = global_position.y - hover_height

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	Hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	anim_player.animation_finished.connect(_on_animation_finished)
	Hurtbox.monitoring = true

# ======================
# PHYSICS
# ======================
func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	time += delta

	# Hover motion
	var target_y = base_y + sin(time * bob_speed) * bob_amount
	velocity.y = (target_y - global_position.y) * 6.0

	# If hit or attacking, block horizontal movement
	if is_hit or is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	if not player:
		velocity.x = 0
		_play_animation("Idle")
		move_and_slide()
		return

	# Movement logic
	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0

	if dist < retreat_distance:
		velocity.x = -dir * move_speed
		_play_animation("Back")
	elif dist <= attack_distance and can_attack:
		_start_attack()
	elif dist > preferred_distance:
		velocity.x = dir * move_speed
		_play_animation("Forward")
	else:
		velocity.x = 0
		_play_animation("Idle")

	move_and_slide()

# ======================
# ATTACK
# ======================
func _start_attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0
	_play_animation("Fire")

	await get_tree().create_timer(0.2).timeout
	_shoot_projectile()

# Shoot projectile toward player
func _shoot_projectile():
	if not player or not projectile_scene:
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = shoot_point.global_position

	if projectile.has_method("setup"):
		projectile.setup(player.global_position)

# ======================
# DAMAGE SYSTEM
# ======================
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_dead or is_hit:
		return

	var damage = 0
	if area.is_in_group("player_hitbox"):
		damage = Stats.player_stats["attack"]
	elif area.is_in_group("Projectile"):
		damage = Stats.player_stats["Projectile"] if Stats.player_stats.has("Projectile") else Stats.player_stats["attack"]
	else:
		return

	# Apply damage
	health -= damage
	print("Drone HP:", health, "(-" + str(damage) + ")")

	# Enter hit state
	is_hit = true
	is_attacking = false
	can_attack = false
	_play_animation("Hit")

	if health <= 0:
		is_dead = true
		Hurtbox.monitoring = false
		_play_animation("Death")
	else:
		_reset_hit_state()

# Resets hit state and re-enables attack
func _reset_hit_state() -> void:
	var anim_len = anim_player.get_animation("Hit").length if anim_player.has_animation("Hit") else 0.3
	await get_tree().create_timer(anim_len).timeout
	is_hit = false
	can_attack = true

# ======================
# ANIMATION FINISHED
# ======================
func _on_animation_finished(anim_name: StringName):
	if anim_name == "Fire":
		is_attacking = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
	elif anim_name == "Death":
		_die()

# ======================
# DEATH
# ======================
func _die():
	print("Drone died")
	if coin_scene and randf() < 0.6:
		var coin = coin_scene.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
	queue_free()

# ======================
# DETECTION
# ======================
func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body == player:
		player = null

# ======================
# ANIMATION HELPER
# ======================
func _play_animation(name: String):
	if anim_player.current_animation != name:
		anim_player.play(name)
