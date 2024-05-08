extends CharacterBody3D

@onready var cameraObject = $Camera3D
var counter = 0 # increments every frame, can be helpful to prevent spamming logs
var rotationDir = 0 # positive value rotates  camera left, negative rotates right
const ROTATION_SPEED = 2
const SPEED = 25.0 # player speed
const JUMP_VELOCITY = 10
const MIN_FOV = 30 # minimum FOV allowed for the camera
const FOV_STEPS = 5 # steps by which to increment the FOV
const MAX_FOV = 90 # maximum FOV allowed for the camera

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.5

func _ready():
	print(gravity)

func _process(delta):
	# handle camera rotation
	check_for_rotation()
	if rotationDir != 0:
		rotation.y += rotationDir * delta * ROTATION_SPEED
	# handle zooming in/out
	check_for_zooming()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# handle movement
	check_for_movement()
	move_and_slide() # after velocities are updated, call this to perform the movement

func check_for_rotation():
	# check inputs for camera rotating
	if Input.is_action_just_pressed("rotate_left"):
		rotationDir += 1
	if Input.is_action_just_released('rotate_left'):
		rotationDir -= 1
	if Input.is_action_just_pressed("rotate_right"):
		rotationDir -= 1
	if Input.is_action_just_released("rotate_right"):
		rotationDir += 1

func check_for_movement():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get lateral input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func check_for_zooming():
	if Input.is_action_just_pressed("zoom_in"):
		print("fov: ", cameraObject.get_fov())
		if (cameraObject.get_fov() > MIN_FOV):
			cameraObject.set_fov(cameraObject.get_fov() - FOV_STEPS)
	if Input.is_action_just_pressed("zoom_out"):
		print("fov: ", cameraObject.get_fov())
		if (cameraObject.get_fov() < MAX_FOV):
			cameraObject.set_fov(cameraObject.get_fov() + FOV_STEPS)
