extends KinematicBody # MUDANÇA: O script deve estender KinematicBody

export var move_speed := 3.5
export var mouse_sensitivity := 0.2
export var gravity := -20.0
export var jump_force := 7.5

var rotating := false
var yaw := 0.0
var pitch := 0.0

var velocity := Vector3() # Usaremos 'velocity' para move_and_slide

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# A rotação é feita no próprio KinematicBody
	yaw = rotation.y 
	pitch = rotation.x
	
	# IMPORTANTE: Remova ground_y e a detecção de chão simples. 
	# move_and_slide fará isso por você!

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			rotating = event.pressed

	elif event is InputEventMouseMotion and rotating:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01
		
		# O Pitch (cabeça para cima/baixo) geralmente é feito no nó Camera filho,
		# mas para manter a simplicidade, faremos tudo no KinematicBody por enquanto.
		pitch = clamp(pitch, deg2rad(-90), deg2rad(90)) # Use deg2rad para limites
		rotation_degrees.x = rad2deg(pitch) # Ajusta o pitch
		rotation_degrees.y = rad2deg(yaw) # Ajusta o yaw
		rotation.z = 0

func _physics_process(delta): # MUDANÇA: O movimento deve ser em _physics_process
	var input_dir = Vector3()

	# O forward e right agora usam o transform do KinematicBody
	var forward = -transform.basis.z
	var right = transform.basis.x

	# 1. Obter a direção de Input
	if Input.is_action_pressed("ui_up"):
		input_dir += forward
	if Input.is_action_pressed("ui_down"):
		input_dir -= forward
	if Input.is_action_pressed("ui_left"):
		input_dir -= right
	if Input.is_action_pressed("ui_right"):
		input_dir += right

	# Manter a velocidade Y atual (gravidade/pulo)
	var y_vel = velocity.y
	
	# 2. Calcular a nova velocidade horizontal (velocidade de entrada normalizada)
	# A velocidade horizontal é separada da Y.
	velocity = input_dir.normalized() * move_speed
	
	# Restaurar a velocidade Y
	velocity.y = y_vel

	# 3. GRAVIDADE
	velocity.y += gravity * delta

	# 4. PULO
	# O método 'is_on_floor()' é fornecido pelo KinematicBody!
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force

	# 5. MOVER E COLIDIR (O CRUCIAL)
	# A função move_and_slide() move o corpo e o impede de atravessar colisões.
	# O segundo parâmetro (Vector3.UP) informa qual é o "chão" para que ele calcule is_on_floor()
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# Você não precisa mais do código de detecção de chão e ground_y!
