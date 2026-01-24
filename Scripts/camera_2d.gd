extends Camera2D


@export var look_ahead_distance := 80.0    # How far ahead to look in the direction of movement
@export var horizontal_smooth_speed := 3.0 # How fast the camera follows horizontally
@export var vertical_smooth_speed := 3.0   # How fast the camera follows vertically
@export var vertical_offset := -20.0       # Slight offset above player center

var player_velocity := Vector2.ZERO
var target_offset := Vector2.ZERO


func _process(delta: float):
	# Get player velocity from parent (the player node)
	if "velocity" in get_parent():
		player_velocity = get_parent().velocity
	else:
		player_velocity = Vector2.ZERO

	# Determine the target horizontal offset based on player's movement direction
	target_offset.x = look_ahead_distance * sign(player_velocity.x) if player_velocity.x != 0 else 0
	# Target vertical offset stays slightly above player
	target_offset.y = vertical_offset

	# Smoothly interpolate the offset
	offset.x = lerp(offset.x, target_offset.x, delta * horizontal_smooth_speed)
	offset.y = lerp(offset.y, target_offset.y, delta * vertical_smooth_speed)
