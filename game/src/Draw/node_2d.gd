extends Node2D

func _draw():
	# COLORES DE LA TERMINAL DE TU IMAGEN
	var verde_cyber = Color(0.0, 0.8, 0.1, 1.0)      # Verde neón de los textos
	var verde_fondo = Color(0.0, 0.15, 0.02, 0.2)     # Fondo de ventana traslúcido oscuro
	var gris_oscuro = Color(0.05, 0.05, 0.05, 1.0)
	
	# Caja principal de la ventana de comandos (X=541 a X=611, Alto 160)
	var rect_panel = Rect2(576 - 35, 348, 70, 160)
	draw_rect(rect_panel, verde_fondo, true)
	draw_rect(rect_panel, verde_cyber, false, 2.0) # Borde fino característico
	
	# Barra superior de la ventana (Estilo consola)
	var rect_barra = Rect2(576 - 35, 348, 70, 16)
	draw_rect(rect_barra, gris_oscuro, true)
	draw_rect(rect_barra, verde_cyber, false, 1.5)
	
	# Tres botones clásicos de cerrar/minimizar de la interfaz (Rojo, Amarillo, Verde)
	# Los escalamos en tamaño miniatura para que entren en tu cápsula compacta
	draw_circle(Vector2(576 + 15, 356), 2.0, Color(1.0, 0.2, 0.2)) # Rojo
	draw_circle(Vector2(576 + 22, 356), 2.0, Color(1.0, 0.8, 0.2)) # Amarillo
	draw_circle(Vector2(576 + 29, 356), 2.0, Color(0.2, 1.0, 0.2)) # Verde
