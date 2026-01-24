extends CharacterBody2D

var is_attacking: bool = false
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
@onready var Animated_sprite = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():

		velocity.y = JUMP_VELOCITY

func _ready() -> void:
	# Make sure the signal is connected in case it's not
	if not Animated_sprite.animation_finished.is_connected(_on_animation_finished):
		Animated_sprite.animation_finished.connect(_on_animation_finished)


	#Direction: -1(left).0,1(Right)
	var direction := Input.get_axis("Run_Left", "Run_Right")
	
#Attack input
	if Input.is_action_just_pressed("attack"):
		Animated_sprite. play("Attack")

	#Flips Character
	if direction > 0:
		Animated_sprite. flip_h = false
		
	elif  direction <0:
		Animated_sprite. flip_h = true
		
	if is_on_floor():
		if direction == 0:
			Animated_sprite. play("Idle")
		else: 
			Animated_sprite. play("Running")
	else:
		Animated_sprite. play("Jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	if is_attacking:
	# Don't override attack animation
		return
	elif not is_on_floor():
		Animated_sprite.play("Jump")
	elif direction == 0:
		Animated_sprite.play("Idle")
	else:
		Animated_sprite.play("Running")

func _process(delta: float) -> void:
	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		Animated_sprite.play("Attack")
		velocity.x = 0  # lock horizontal movement during attack


func _on_animation_finished() -> void:
	# Only reset if the finished animation was Attack
	if Animated_sprite.animation == "Attack":
		is_attacking = false
