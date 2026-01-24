extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var is_attacking: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.

func _ready() -> void:
	# Connect animation finished signal
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump (disable while attacking)
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# Movement input
	var direction := Input.get_axis("Run_Left", "Run_Right")

	if not is_attacking:
		# Horizontal movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Flip sprite
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true

	move_and_slide()

	# Handle animations
	if is_attacking:
		return  # don’t override attack animation
	elif not is_on_floor():
		anim.play("Jump")
	elif direction == 0:
		anim.play("Idle")
	else:
		anim.play("Running")

func _process(delta: float) -> void:
	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		anim.play("Attack")
		velocity.x = 0  # lock movement during attack

func _on_animation_finished() -> void:
	print("Animation finished:", anim.animation) # Debug
	if anim.animation == "Attack":
		is_attacking = false
