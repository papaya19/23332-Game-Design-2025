extends CharacterBody2D

var speed = 200.0
var jump_speed = -375.0
var double_jump_speed = -450.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_counter = 0  # Counts how many jumps performed (max 2)

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	# Reset jump counter when on floor
	if is_on_floor():
		jump_counter = 0

	# Handle jump input
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		if jump_counter == 0:
			# First jump
			velocity.y = jump_speed
		else:
			# Second jump (double jump)
			velocity.y = double_jump_speed
		jump_counter += 1

	# Get horizontal input
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	move_and_slide()
