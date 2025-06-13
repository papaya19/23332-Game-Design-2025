extends CharacterBody2D

var speed = 200.0
var jump_speed = -375.0
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

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and can_jump:
		jump()
		
	if (is_on_floor() == false) and can_jump and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	
	# Get the input direction.
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

	move_and_slide()
