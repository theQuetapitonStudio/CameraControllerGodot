extends Camera

export var move_speed := 0.5
export var mouse_sensitivity := 0.2

var rotating := false
var yaw := 0.0
var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yaw = rotation.y
	pitch = rotation.x

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			rotating = event.pressed

	elif event is InputEventMouseMotion and rotating:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01
		# Limita só a vertical leve (estilo Poppy)
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

	dir = dir.normalized()
	translation += dir * move_speed * delta
