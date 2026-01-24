extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -320.0
const IFRAME_DURATION := 1.0
const RESPAWN_DELAY := 3.0

var current_interactable: Node = null

var is_attacking := false
var attack_index := 0
var is_hit := false
var is_dead := false
var i_frame_timer := 0.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var Hitbox: Area2D = $Hitbox
@onready var hitboxbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var Hurtbox: Area2D = $Hurtbox
@onready var death_timer: Timer = Timer.new()
@onready var Interaction: Area2D = $Interactabledetector
@onready var spawn_point: Marker2D = $"../Spawnpoint"

func _ready() -> void:
	add_to_group("player")

	anim.animation_finished.connect(_on_animation_finished)
	Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	death_timer.wait_time = RESPAWN_DELAY
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_respawn_timeout)
	add_child(death_timer)

	if Interaction:
		Interaction.area_entered.connect(_on_interaction_area_entered)
		Interaction.area_exited.connect(_on_interaction_area_exited)

	# Reset health properly (HUD will update via signal)
	Stats.reset_health()

# --- Interaction ---
func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		current_interactable = area

func _on_interaction_area_exited(area: Area2D) -> void:
	if area == current_interactable:
		current_interactable = null


# --- Movement ---
func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if i_frame_timer > 0:
		i_frame_timer -= delta

	if is_hit:
		velocity.x = 0
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("Run_Left", "Run_Right")
	if not is_attacking:
		hitboxbox.disabled = true
		velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)

	if direction != 0:
		sprite.flip_h = direction < 0

	_update_hit_and_hurtbox_flip()
	move_and_slide()
	if Input.is_action_just_pressed("kys"):
		_die()
	if Input.is_action_just_pressed("Interact") and current_interactable:
		current_interactable.interact()

	if not is_attacking and not is_hit:
		anim.play(
			"Jump" if not is_on_floor() and velocity.y < 0 else
			"Fall" if not is_on_floor() else
			"Running" if direction != 0 else "Idle"
		)


func _process(_delta: float) -> void:
	if is_hit or is_dead:
		return

	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			attack_index = 1
			velocity.x = 0
			anim.play("Attack1")
		elif attack_index == 1:
			attack_index = 2


# --- Animations ---
func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Attack1":
			if attack_index == 2:
				anim.play("Attack2")
			else:
				is_attacking = false
				attack_index = 0
		"Attack2":
			is_attacking = false
			attack_index = 0
		"Hit":
			is_hit = false
		"Death":
			death_timer.start()


# --- Combat ---
func _update_hit_and_hurtbox_flip() -> void:
	if sprite.flip_h:
		Hitbox.position.x = -38
		Hurtbox.position.x = -8
	else:
		Hitbox.position.x = 8
		Hurtbox.position.x = 8


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_dead or i_frame_timer > 0:
		return

	if area.is_in_group("enemy_hitbox"):
		i_frame_timer = IFRAME_DURATION
		is_hit = true
		anim.play("Hit")

		Stats.take_damage(Stats.enemy_stats["attack"])

		if Stats.player_stats["health"] <= 0:
			_die()

func _die() -> void:
	is_dead = true
	Hitbox.monitoring = false
	Hurtbox.monitoring = false
	Stats.lose_life()
	remove_from_group("player")
	anim.play("Death")

	if Stats.player_stats["lives"] > 0:
		# Respawn normally
		death_timer.start()
	else:
		# Full death: reset lives for next run
		print("GAME OVER")
		Stats.player_stats["lives"] = 3   # ✅ Correct assignment
		get_tree().reload_current_scene()

# --- Respawn ---
func _on_respawn_timeout() -> void:
	# Reset health
	Stats.reset_health()

	# Reset position to spawn point
	if spawn_point:
		global_position = spawn_point.global_position

	# Re-enable hitboxes and groups
	Hitbox.monitoring = true
	Hurtbox.monitoring = true
	add_to_group("player")

	is_dead = false
	is_hit = false
