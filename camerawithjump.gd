extends Camera

export var move_speed := 3.5
export var mouse_sensitivity := 0.2
export var gravity := -20.0
export var jump_force := 7.5

var rotating := false
var yaw := 0.0
var pitch := 0.0

var vertical_vel := 0.0
var is_grounded := false
var ground_y := 0.0   # altura do chão (ajuste isso pra sua cena)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yaw = rotation.y
	pitch = rotation.x
	ground_y = translation.y  # câmera começa no chão

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			rotating = event.pressed

	elif event is InputEventMouseMotion and rotating:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01
		pitch = clamp(pitch, -10, 10)
		rotation = Vector3(pitch, yaw, 0)

func _process(delta):
	var dir = Vector3()

	var forward = -transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var right = transform.basis.x
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

	# === MOVIMENTO HORIZONTAL ===
	dir = dir.normalized()
	translation += dir * move_speed * delta

	# === GRAVIDADE ===
	vertical_vel += gravity * delta

	# === PULO ===
	if is_grounded and Input.is_action_just_pressed("ui_accept"): # espaço por padrão
		vertical_vel = jump_force
		is_grounded = false

	# Aplica movimento vertical
	translation.y += vertical_vel * delta

	# Detecta chão simples
	if translation.y <= ground_y:
		translation.y = ground_y
		vertical_vel = 0
		is_grounded = true
