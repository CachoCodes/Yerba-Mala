extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003

@export var max_stamina: float = 100.0
@export var stamina_regen: float = 20.0
@export var stamina_drain: float = 30.0

var stamina: float
var camera_pitch := 0.0

@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $Character_06/AnimationPlayer
@onready var stamina_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina

	if animation_player.has_animation("idle"):
		animation_player.play("idle")


func _unhandled_input(event):

	if event is InputEventMouseMotion:

		# Rotación horizontal (jugador)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotación vertical (cámara)
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = camera_pitch

	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta):

	# Gravedad
	if !is_on_floor():
		velocity += get_gravity() * delta

	# Movimiento relativo a la cámara/jugador
	var input := Input.get_vector("A", "D", "W", "S")

	var forward := -transform.basis.z
	var right := transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var direction := (forward * input.y + right * input.x).normalized()

	var speed := walk_speed

	if direction != Vector3.ZERO:

		if Input.is_action_pressed("Shift") and stamina > 0:
			speed = run_speed
			stamina -= stamina_drain * delta
		else:
			stamina += stamina_regen * delta

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if animation_player.current_animation != "walk":
			animation_player.play("walk")

	else:

		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 10 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 10 * delta)

		stamina += stamina_regen * delta

		if animation_player.current_animation != "idle":
			animation_player.play("idle")

	stamina = clamp(stamina, 0.0, max_stamina)
	stamina_bar.value = stamina

	move_and_slide()
