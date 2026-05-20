extends Node2D

var selector_dificultad: OptionButton = null
var boton_jugar: Button = null
var boton_salir: Button = null

func _ready() -> void:
	# 1. Recuperamos las referencias de los nodos de la interfaz
	selector_dificultad = find_child("OptionDifficulty", true, false) as OptionButton
	boton_jugar = find_child("BotonJugar", true, false) as Button
	boton_salir = find_child("BotonSalir", true, false) as Button
	
	# 2. Inicialización del selector de dificultad
	if selector_dificultad:
		selector_dificultad.clear()
		selector_dificultad.add_item("Fácil")   # Índice 0
		selector_dificultad.add_item("Normal")  # Índice 1
		selector_dificultad.add_item("Difícil") # Índice 2
		
		# Selección por defecto (Normal) y configuración inicial en el Autoload
		selector_dificultad.selected = 1
		_actualizar_dificultad_global(1)
		
		# Conexión del evento de cambio de opción
		if not selector_dificultad.item_selected.is_connected(_on_opcion_cambiada):
			selector_dificultad.item_selected.connect(_on_opcion_cambiada)

	# 3. Conexión de los eventos de los botones
	if boton_jugar and not boton_jugar.pressed.is_connected(_on_jugar_pulsado):
		boton_jugar.pressed.connect(_on_jugar_pulsado)
		
	if boton_salir and not boton_salir.pressed.is_connected(_on_salir_pulsado):
		boton_salir.pressed.connect(_on_salir_pulsado)

func _on_opcion_cambiada(index: int) -> void:
	_actualizar_dificultad_global(index)

func _actualizar_dificultad_global(index: int) -> void:
	var valor_multiplicador: float = 1.0
	match index:
		0: valor_multiplicador = 0.7  # Fácil
		1: valor_multiplicador = 1.0  # Normal
		2: valor_multiplicador = 1.5  # Difícil
		
	if has_node("/root/Global"):
		get_node("/root/Global").multiplicador_dificultad = valor_multiplicador

func _on_jugar_pulsado() -> void:
	# Cambia a la escena principal para iniciar la partida
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func _on_salir_pulsado() -> void:
	# Cierra la aplicación de forma segura
	get_tree().quit()
