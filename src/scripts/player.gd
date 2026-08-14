extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

const PITCH_MIN = -80.0  # degrees, looking down
const PITCH_MAX = 80.0   # degrees, looking up

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Yaw: rotate the whole body left/right
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		# Pitch: rotate only the camera up/down, clamped
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		var rot := camera.rotation
		rot.x = clamp(rot.x, deg_to_rad(PITCH_MIN), deg_to_rad(PITCH_MAX))
		camera.rotation = rot

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
