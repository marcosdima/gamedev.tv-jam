extends CharacterBody2D

# Parámetros físicos configurables
const VELOCIDAD_HORIZONTAL = 150.0
const FUERZA_SALTO = -300.0

# Obtener la gravedad configurada por defecto en el proyecto Godot
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

var slime: AnimatedSprite2D
var direccion = 1 # 1: Derecha, -1: Izquierda

func _ready():
	# 1. Configurar la posición inicial en pantalla
	position = Vector2(500, 200)
	
	# 2. Crear y configurar el nodo de animación
	slime = AnimatedSprite2D.new()
	add_child(slime)
	slime.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slime.scale = Vector2(6, 6)
	
	# 3. Generar las texturas de la criatura
	var frame_normal = crear_frame_slime(1)
	var frame_aplastado = crear_frame_slime(2)
	var frame_estirado = crear_frame_slime(3)
	
	# 4. Configurar el set de animaciones
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("bucle_slime")
	sprite_frames.add_frame("bucle_slime", frame_normal)
	sprite_frames.add_frame("bucle_slime", frame_aplastado)
	sprite_frames.add_frame("bucle_slime", frame_normal)
	sprite_frames.add_frame("bucle_slime", frame_estirado)
	sprite_frames.set_animation_speed("bucle_slime", 0.0) # Controlamos la animación por código
	sprite_frames.set_animation_loop("bucle_slime", true)
	
	slime.sprite_frames = sprite_frames
	slime.play("bucle_slime")

# Bucle físico de actualización (Se ejecuta unas 60 veces por segundo)
func _physics_process(delta):
	# Aplicar gravedad si el slime está en el aire
	if not is_on_floor():
		velocity.y += gravedad * delta
		# Si está subiendo, usar el frame estirado. Si cae, el frame normal.
		if velocity.y < 0:
			slime.frame = 3 # Frame estirado
		else:
			slime.frame = 0 # Frame normal
	else:
		# Si toca el suelo, frena el movimiento horizontal por un instante
		velocity.x = 0
		slime.frame = 1 # Frame aplastado (preparando el impacto/impulso)
		
		# Esperar un instante en el suelo y volver a saltar de forma automática
		await get_tree().create_timer(0.15).timeout
		if is_on_floor(): # Re-verificar que siga en el suelo
			velocity.y = FUERZA_SALTO
			velocity.x = VELOCIDAD_HORIZONTAL * direccion

	# Cambiar de dirección si choca con los límites laterales de la pantalla
	if position.x > 1100:
		direccion = -1
		slime.flip_h = true # Voltea el pixel art hacia la izquierda
	elif position.x < 50:
		direccion = 1
		slime.flip_h = false # Voltea el pixel art hacia la derecha

	# Mover el cuerpo procesando colisiones con el suelo virtual del motor
	move_and_slide()

# Función de dibujo pixel art (Mantenemos el mismo diseño del Venom-Slime)
func crear_frame_slime(fase: int) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var negro_venom = Color(0.04, 0.04, 0.06, 1.0)
	var blanco = Color.WHITE
	
	if fase == 1:
		for x in range(5, 11):
			for y in range(7, 13): img.set_pixel(x, y, negro_venom)
		img.set_pixel(6, 6, negro_venom); img.set_pixel(7, 6, negro_venom); img.set_pixel(8, 6, negro_venom); img.set_pixel(9, 6, negro_venom)
		img.set_pixel(6, 8, blanco); img.set_pixel(5, 7, blanco)
		img.set_pixel(9, 8, blanco); img.set_pixel(10, 7, blanco)
	elif fase == 2:
		for x in range(3, 13):
			for y in range(9, 13): img.set_pixel(x, y, negro_venom)
		img.set_pixel(4, 8, negro_venom); img.set_pixel(11, 8, negro_venom)
		img.set_pixel(5, 10, blanco); img.set_pixel(4, 9, blanco)
		img.set_pixel(10, 10, blanco); img.set_pixel(11, 9, blanco)
	elif fase == 3:
		for x in range(6, 10):
			for y in range(4, 12): img.set_pixel(x, y, negro_venom)
		img.set_pixel(7, 3, negro_venom); img.set_pixel(8, 3, negro_venom)
		img.set_pixel(6, 6, blanco); img.set_pixel(6, 5, blanco)
		img.set_pixel(9, 6, blanco); img.set_pixel(9, 5, blanco)
		
	return ImageTexture.create_from_image(img)
