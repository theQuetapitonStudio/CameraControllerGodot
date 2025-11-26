extends Camera3D

@export var move_speed: float = 3.5
@export var mouse_sensitivity: float = 0.2
@export var gravity: float = -20.0
@export var jump_force: float = 7.5

var rotating: bool = false
var yaw: float = 0.0
var pitch: float = 0.0

var vertical_vel: float = 0.0
var is_grounded: bool = false
var ground_y: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yaw = rotation.x
	pitch = rotation.y
	ground_y = position.y


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	elif event is InputEventMouseMotion and rotating:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01
		pitch = clamp(pitch, -10, 10)
		rotation = Vector3(pitch, yaw, 0)


func _process(delta):
	var dir := Vector3.ZERO

	var forward := -transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var right := transform.basis.x
	right.y = 0
	right = right.normalized()


	if Input.is_action_pressed("ui_up"):
		dir += forward
	if Input.is_action_pressed("ui_down"):
		dir -= forward
	if Input.is_action_pressed("ui_left"):
		dir -= right
	if Input.is_action_pressed("ui_right"):
		dir += right


	dir = dir.normalized()
	position += dir * move_speed * delta

	# gravidade
	vertical_vel += gravity * delta

	# pulo
	if is_grounded and Input.is_action_just_pressed("ui_accept"):
		vertical_vel = jump_force
		is_grounded = false

	position.y += vertical_vel * delta

	# chão simples
	if position.y <= ground_y:
		position.y = ground_y
		vertical_vel = 0
		is_grounded = true

