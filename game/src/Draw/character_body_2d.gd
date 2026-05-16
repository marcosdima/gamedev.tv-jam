extends CharacterBody2D

const FUERZA_SALTO = -210.0 # Salto levemente calibrado al tamaño de la consola

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
var slime: AnimatedSprite2D
var hud_cara: TextureRect
var marco_hud: ColorRect
var texto_vida: Label

var vida_porcentaje: int = 100
var esta_parpadeando: bool = false

func _ready():
	position = Vector2(576, 483) 
	
	slime = AnimatedSprite2D.new()
	add_child(slime)
	slime.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slime.scale = Vector2(6, 6)
	
	slime.centered = true
	slime.offset = Vector2(0, 0) 
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("bucle_slime")
	sprite_frames.add_frame("bucle_slime", crear_frame_slime(1))
	sprite_frames.add_frame("bucle_slime", crear_frame_slime(2))
	sprite_frames.add_frame("bucle_slime", crear_frame_slime(1))
	sprite_frames.add_frame("bucle_slime", crear_frame_slime(3))
	sprite_frames.set_animation_speed("bucle_slime", 0.0)
	slime.sprite_frames = sprite_frames
	slime.play("bucle_slime")
	
	var canvas_layer = get_parent().get_node("CanvasLayer")
	if canvas_layer:
		configurar_hud_doom(canvas_layer)

func _physics_process(delta):
	# Detección del piso de la ventana de comandos
	if position.y >= 483 and velocity.y >= 0:
		velocity.y = 0
		position.y = 483
		
		if slime.frame != 1:
			slime.frame = 1 
			actualizar_cara_hud(2) # Cambia a cara de alerta/glitch
			recibir_danio(10)
		
		await get_tree().create_timer(0.15).timeout
		if position.y >= 483:
			velocity.y = FUERZA_SALTO
	else:
		velocity.y += gravedad * delta
		if velocity.y < 0:
			slime.frame = 3 
			if vida_porcentaje > 0: actualizar_cara_hud(3)
		else:
			slime.frame = 0 
			if vida_porcentaje > 0: actualizar_cara_hud(1)

	move_and_slide()

func recibir_danio(cantidad: int):
	if vida_porcentaje <= 0: return
	vida_porcentaje -= cantidad
	if vida_porcentaje < 0: vida_porcentaje = 0
	
	if texto_vida != null:
		texto_vida.text = "%d%%" % vida_porcentaje
	
	ejecutar_glitch_estatico()
	
	if vida_porcentaje == 0:
		actualizar_cara_hud(4) # Sistema Apagado / Crash
		await get_tree().create_timer(1.2).timeout
		reincorporar_slime()

func reincorporar_slime():
	vida_porcentaje = 100
	if texto_vida != null:
		texto_vida.text = "%d%%" % vida_porcentaje
	actualizar_cara_hud(1)

# Efecto de parpadeo estilo monitor CRT perdiendo señal
func ejecutar_glitch_estatico():
	if esta_parpadeando: return
	esta_parpadeando = true
	for i in range(3):
		slime.modulate = Color(0.0, 0.2, 0.0, 0.4) # El sprite casi se apaga (píxeles muertos)
		await get_tree().create_timer(0.05).timeout
		slime.modulate = Color(0.2, 1.0, 0.4, 1.0) # Vuelve con brillo verde intenso
		await get_tree().create_timer(0.05).timeout
	slime.modulate = Color.WHITE
	esta_parpadeando = false

func configurar_hud_doom(capa_ui: CanvasLayer):
	# Marco inferior integrado al negro de tu interfaz principal
	marco_hud = ColorRect.new()
	marco_hud.color = Color(0.02, 0.04, 0.02, 1.0) # Verde ultra oscuro de fondo de terminal
	marco_hud.custom_minimum_size = Vector2(1152, 100)
	marco_hud.position = Vector2(0, 548)
	capa_ui.add_child(marco_hud)
	
	# Borde fino verde superior para el HUD
	var linea_borde = ColorRect.new()
	linea_borde.color = Color(0.0, 0.8, 0.1, 1.0)
	linea_borde.custom_minimum_size = Vector2(1152, 2)
	marco_hud.add_child(linea_borde)
	
	# Contenedor de la cara digital
	var fondo_cara = ColorRect.new()
	fondo_cara.color = Color(0.0, 0.1, 0.01, 1.0)
	fondo_cara.custom_minimum_size = Vector2(80, 80)
	fondo_cara.position = Vector2(536, 10)
	marco_hud.add_child(fondo_cara)
	
	hud_cara = TextureRect.new()
	hud_cara.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud_cara.custom_minimum_size = Vector2(80, 80)
	fondo_cara.add_child(hud_cara)
	actualizar_cara_hud(1)
	
	# Texto de vida en el verde exacto de tu menú "CYBER"
	texto_vida = Label.new()
	texto_vida.text = "100%"
	texto_vida.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_vida.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto_vida.position = Vector2(380, 25)
	texto_vida.scale = Vector2(2.5, 2.5)
	texto_vida.modulate = Color(0.0, 1.0, 0.3, 1.0) # Verde fósforo fosforescente
	marco_hud.add_child(texto_vida)

func actualizar_cara_hud(estado: int):
	if hud_cara == null: return
	hud_cara.texture = crear_textura_cara_doom(estado)

# CARA ESTILO CODIGO BINARIO INFECTADO
func crear_textura_cara_doom(estado: int) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var verde_brillante = Color(0.0, 1.0, 0.3, 1.0)
	var verde_oscuro = Color(0.0, 0.3, 0.05, 1.0)
	
	# Fondo de la pantalla del rostro (Con líneas de comandos simuladas)
	for x in range(3, 13):
		for y in range(3, 13): img.set_pixel(x, y, verde_oscuro)
		
	if estado == 1: # OPERATIVO (Normal)
		# Ojos cuadriculados de datos
		img.set_pixel(5, 6, verde_brillante); img.set_pixel(6, 6, verde_brillante)
		img.set_pixel(9, 6, verde_brillante); img.set_pixel(10, 6, verde_brillante)
		# Boca estilo cursor de texto `_`
		img.set_pixel(7, 10, verde_brillante); img.set_pixel(8, 10, verde_brillante)
	elif estado == 2: # WARNING (Impacto)
		# La pantalla de la cara dibuja un signo de exclamación `!` por el golpe
		img.set_pixel(7, 5, verde_brillante); img.set_pixel(8, 5, verde_brillante)
		img.set_pixel(7, 6, verde_brillante); img.set_pixel(8, 6, verde_brillante)
		img.set_pixel(7, 7, verde_brillante); img.set_pixel(8, 7, verde_brillante)
		img.set_pixel(7, 9, verde_brillante); img.set_pixel(8, 9, verde_brillante)
	elif estado == 3: # EJECUTANDO PROCESO (Salto)
		# Ojos mirando arriba saltando líneas de código
		img.set_pixel(5, 4, verde_brillante); img.set_pixel(10, 4, verde_brillante)
	elif estado == 4: # SYSTEM FAILURE (Muerto)
		# Se borra la cara y muestra bloques negros de sectores defectuosos
		img.fill(Color(0.0, 0.0, 0.0, 1.0))
		img.set_pixel(4, 4, verde_brillante); img.set_pixel(11, 11, verde_brillante)
		
	return ImageTexture.create_from_image(img)

# SLIME CYBER: Cuerpo verde brillante con ojos oscuros integrados a la terminal
func crear_frame_slime(fase: int) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var verde_cyber = Color(0.0, 1.0, 0.3, 1.0)
	var negro_consola = Color(0.02, 0.05, 0.02, 1.0) # Ojos vacíos transparentes al fondo
	
	if fase == 1:
		for x in range(5, 11):
			for y in range(7, 13): img.set_pixel(x, y, verde_cyber)
		img.set_pixel(6, 6, verde_cyber); img.set_pixel(7, 6, verde_cyber)
		img.set_pixel(8, 6, verde_cyber); img.set_pixel(9, 6, verde_cyber)
		
		# Ojos integrados al fondo de la pantalla
		img.set_pixel(6, 8, negro_consola); img.set_pixel(5, 7, negro_consola)
		img.set_pixel(9, 8, negro_consola); img.set_pixel(10, 7, negro_consola)
		
	elif fase == 2:
		for x in range(4, 12):
			for y in range(9, 13): img.set_pixel(x, y, verde_cyber)
		img.set_pixel(5, 8, verde_cyber); img.set_pixel(10, 8, verde_cyber)
		
		img.set_pixel(5, 10, negro_consola); img.set_pixel(6, 10, negro_consola)
		img.set_pixel(9, 10, negro_consola); img.set_pixel(10, 10, negro_consola)
		
	elif fase == 3:
		for x in range(6, 10):
			for y in range(4, 12): img.set_pixel(x, y, verde_cyber)
		img.set_pixel(7, 3, verde_cyber); img.set_pixel(8, 3, verde_cyber)
		
		img.set_pixel(6, 6, negro_consola); img.set_pixel(6, 5, negro_consola)
		img.set_pixel(9, 6, negro_consola); img.set_pixel(9, 5, negro_consola)
		
	return ImageTexture.create_from_image(img)
