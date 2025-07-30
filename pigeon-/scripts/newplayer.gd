extends CharacterBody2D
var is_dashing = false
var dash_timer = Timer.new()
var dash_speed = 700.0
var dash_direction = Vector2.ZERO
# REMEMBER THAT control + / IS A COMMENT
var speed = 250.0
var is_dead = false
var jump_speed = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_counter = 0
var has_dashed_in_air = false

var dash_duration = 0.3
var diagonal_dash_speed_modifier = 0.75

var dash_deceleration_rate = 3000.0
var dash_end_velocity = Vector2.ZERO

var _has_ground_dashed_since_last_land = false
var dash_restriction_active = false

var coyote_time_duration = 0.1
var coyote_timer = Timer.new()

func _ready():
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_duration
	dash_timer.connect("timeout", Callable(self, "_on_DashTimer_timeout"))

	add_child(coyote_timer)
	coyote_timer.one_shot = true

func death():
	if is_dead:
		return

	is_dead = true
	$AnimatedSprite2D.play("death")
	set_physics_process(false)

func _physics_process(delta):
	if is_dead:
		return

	var current_velocity = velocity
	var input_direction = Input.get_axis("left", "right")

	if not is_dashing:
		# Apply gravity
		current_velocity.y += gravity * delta

		# Handle dash deceleration if there's residual momentum
		if dash_end_velocity.x != 0:
			current_velocity.x = move_toward(current_velocity.x, 0, dash_deceleration_rate * delta)
			# If horizontal momentum is nearly zero, clear the dash_end_velocity
			if abs(current_velocity.x) < 5: # Small threshold
				dash_end_velocity.x = 0

		# Allow normal horizontal movement only if not dashing AND (no dash residual x-momentum OR player provides input)
		# This is the key change: player input should override deceleration
		if dash_end_velocity.x == 0 or input_direction != 0:
			current_velocity.x = input_direction * speed

	# Character orientation
	if input_direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif input_direction > 0:
		$AnimatedSprite2D.flip_h = false

	# Grounding and state resets
	if is_on_floor():
		if abs(current_velocity.x) > 10:
			$AnimatedSprite2D.play("walking")
		else:
			$AnimatedSprite2D.play("idle")
		has_dashed_in_air = false
		_has_ground_dashed_since_last_land = false
		dash_restriction_active = false
		jump_counter = 0
		coyote_timer.stop()
		dash_end_velocity = Vector2.ZERO # Clear all residual velocity when grounded
	else:
		if !is_dashing:
			$AnimatedSprite2D.play("jumping")
		if coyote_timer.is_stopped():
			coyote_timer.wait_time = coyote_time_duration
			coyote_timer.start()

	# Update dash restriction flag
	if _has_ground_dashed_since_last_land and not is_on_floor():
		dash_restriction_active = true

	# Jump Logic
	if Input.is_action_just_pressed("jump") and jump_counter < 1 and not dash_restriction_active:
		if is_on_floor() or not coyote_timer.is_stopped():
			current_velocity.y = jump_speed
			jump_counter += 1
			coyote_timer.stop()
			if is_dashing:
				_on_DashTimer_timeout()

	# Dash Initiation Logic
	if Input.is_action_just_pressed("dash") and not is_dashing and not dash_restriction_active:
		var can_initiate_dash = false
		if is_on_floor():
			can_initiate_dash = true
		elif not is_on_floor():
			if not has_dashed_in_air:
				can_initiate_dash = true

		if can_initiate_dash:
			var current_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
			if current_input_dir == Vector2.ZERO:
				dash_direction = Vector2(-1 if $AnimatedSprite2D.flip_h else 1, 0)
			else:
				dash_direction = current_input_dir

			is_dashing = true
			if not is_on_floor():
				has_dashed_in_air = true
			else:
				_has_ground_dashed_since_last_land = true

			var actual_dash_speed = dash_speed
			if dash_direction.x != 0.0 and dash_direction.y != 0.0:
				actual_dash_speed *= diagonal_dash_speed_modifier

			dash_timer.start()
			current_velocity = dash_direction * actual_dash_speed
			dash_end_velocity = Vector2.ZERO # Clear residual from *previous* dash when starting a *new* one
			$AnimatedSprite2D.play("dash")

	# Apply Dash Velocity (Overrides Gravity/Normal Movement)
	if is_dashing:
		var actual_dash_speed = dash_speed
		if dash_direction.x != 0.0 and dash_direction.y != 0.0:
			actual_dash_speed *= diagonal_dash_speed_modifier
		current_velocity = dash_direction * actual_dash_speed

	velocity = current_velocity
	move_and_slide()

func _on_DashTimer_timeout():
	is_dashing = false
	dash_end_velocity = velocity # Store velocity to start deceleration

	# Handle specific up-dash ending: kill vertical velocity instantly
	if dash_direction.y < 0:
		velocity.y = 0
		dash_end_velocity.y = 0 # Ensure no lingering Y deceleration if it was an up-dash

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('spikes'):
		death()
