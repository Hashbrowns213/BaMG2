extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const COMBO_TIME = 0.3  # seconds allowed between attacks

var is_attacking: bool = false
var attack_index: int = 0  # 0 = no attack, 1 = first attack, 2 = second attack
var combo_timer: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("Run_Left", "Run_Right")
	if not is_attacking:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true

	move_and_slide()

	# Animations
	if is_attacking:
		return
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("Jump")   # going up
		else:
			anim.play("Fall")   # going down
	elif direction == 0:
		anim.play("Idle")
	else:
		anim.play("Running")

	# Update combo timer
	if combo_timer > 0:
		combo_timer -= delta
	else:
		attack_index = 0  # reset combo if time runs out

func _process(delta: float) -> void:
	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_index += 1

		# Clamp combo range (max 2 attacks for now)
		if attack_index > 2:
			attack_index = 1

		match attack_index:
			1:
				anim.play("Attack1")
			2:
				anim.play("Attack2")

		velocity.x = 0  # lock movement
		combo_timer = COMBO_TIME  # reset combo window timer

func _on_animation_finished() -> void:
	if anim.animation in ["Attack1", "Attack2"]:
		is_attacking = false
