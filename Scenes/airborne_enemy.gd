extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionRange

# ======================
# TUNING
# ======================

@export var hover_height := 20.0
@export var move_speed := 150.0
@export var preferred_distance := 120.0
@export var attack_distance := 100.0
@export var retreat_distance := 50.0
@export var attack_cooldown := 1.0

@export var bob_amount := 6.0
@export var bob_speed := 3.0

# ======================
# INTERNAL
# ======================

var player: Node2D = null
var base_y: float
var time := 0.0
var can_attack := true
var attacking := false


# ======================
# READY
# ======================

func _ready():
	base_y = global_position.y - hover_height
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


# ======================
# MAIN LOOP
# ======================

func _physics_process(delta):
	time += delta

	# --- ALWAYS HOVER ---
	var target_y = base_y + sin(time * bob_speed) * bob_amount
	velocity.y = (target_y - global_position.y) * 6.0

	if not player:
		velocity.x = 0
		play_anim("Idle")
		move_and_slide()
		return

	if attacking:
		move_and_slide()
		return

	var dist = global_position.distance_to(player.global_position)
	var dir = sign(player.global_position.x - global_position.x)

	# --- TOO CLOSE → RETREAT ---
	if dist < retreat_distance:
		velocity.x = -dir * move_speed
		sprite.flip_h = dir > 0
		play_anim("Back")

	# --- IN ATTACK RANGE ---
	elif dist <= attack_distance and can_attack:
		start_attack()

	# --- TOO FAR → MOVE CLOSER ---
	elif dist > preferred_distance:
		velocity.x = dir * move_speed
		sprite.flip_h = dir < 0
		play_anim("Forward")

	# --- HOLD POSITION ---
	else:
		velocity.x = 0
		play_anim("Idle")

	move_and_slide()


# ======================
# ATTACK LOGIC
# ======================

func start_attack():
	attacking = true
	can_attack = false
	velocity.x = 0
	play_anim("Fire")

	await sprite.animation_finished

	# small delay before moving again
	await get_tree().create_timer(attack_cooldown).timeout

	attacking = false
	can_attack = true


# ======================
# ANIMATION HELPER
# ======================

func play_anim(name: String):
	if sprite.animation != name:
		sprite.play(name)


# ======================
# DETECTION
# ======================

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body


func _on_body_exited(body):
	if body == player:
		player = null
