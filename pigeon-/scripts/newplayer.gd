extends CharacterBody2D

# REMEMBER THAT control + / IS A COMMENT
var speed = 250.0
var is_dead = false
var jump_speed = -375.0
var double_jump_speed = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_counter = 0  # Counts how many jumps performed (max 2)

func death():
	if is_dead: # Prevent multiple death calls
		return

	is_dead = true
	$AnimatedSprite2D.play("death")
	set_physics_process(false) # Stop character movement and physics

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	# Get horizontal input
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	# Flip sprite based on direction
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false



	
	if is_on_floor():
		if abs(velocity.x) > 10:
			$AnimatedSprite2D.play("walking")
		else:
			$AnimatedSprite2D.play("idle")
	
	if !is_on_floor():
		$AnimatedSprite2D.play("jumping")
	# Reset jump counter when on floor
	if is_on_floor():
		jump_counter = 0

	# Handle jump input
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		if jump_counter == 0:
			velocity.y = jump_speed  # First jump
		else:
			velocity.y = double_jump_speed  # Second jump
		jump_counter += 1

	# Move and slide with UP as the floor direction
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('spikes'):
		death()
