extends CharacterBody2D

var speed = 250.0
var jump_speed = -450.0
var can_jump = true



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func jump():
	velocity.y = jump_speed
	can_jump = false

func _on_coyote_timer_timeout():
	can_jump = false

func _physics_process(delta):
	if can_jump == false and is_on_floor():
		can_jump = true
	# Add the gravity.
	velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and can_jump:
		jump()
		
	if (is_on_floor() == false) and can_jump and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	
	
	if is_on_floor():
		if abs(velocity.x) > 10:
			$AnimatedSprite2D.play("walking")
		else:
			$AnimatedSprite2D.play("idle")
	
	if !is_on_floor():
		$AnimatedSprite2D.play("jumping")
	# Get the input direction.

	move_and_slide()
