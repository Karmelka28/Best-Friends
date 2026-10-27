extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Pobranie domyślnej grawitacji z ustawień projektu
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Pobranie referencji do kamery (upewnij się, że węzeł nazywa się Camera3D)
@onready var camera = $Camera3D

func _ready():
	# Ukrywa kursor myszy i zamyka go w oknie gry podczas startu
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Rozglądanie się za pomocą myszki
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		# Blokada obrotu kamery w górę/dół, żeby gracz nie zrobił fikołka (ograniczenie do 90 stopni)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	# Naciśnięcie ESCAPE uwalnia myszkę (przydatne do wyłączania gry)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# Grawitacja (kiedy postać jest w powietrzu)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Skok (domyślnie Spacja / akcja "ui_accept")
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Pobieranie kierunku z klawiatury (WASD / Strzałki)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Poruszanie postacią
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Zastosowanie ruchu
	move_and_slide()
