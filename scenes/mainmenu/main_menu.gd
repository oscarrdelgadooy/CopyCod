extends Node2D

# Buscamos los nodos dentro del VBoxContainer automáticamente
@onready var selector_dificultad = find_child("OptionButton", true, false)
@onready var boton_jugar = find_child("BotonJugar", true, false)
@onready var boton_salir = find_child("BotonSalir", true, false)

func _ready() -> void:
	if selector_dificultad:
		selector_dificultad.clear()
		
		# Añadimos las opciones en orden estricto
		selector_dificultad.add_item("Fácil")   # Posición 0
		selector_dificultad.add_item("Normal")  # Posición 1
		selector_dificultad.add_item("Difícil") # Posición 2
		
		# ¡Aquí está la magia! El 1 le dice a Godot que preseleccione "Normal"
		selector_dificultad.select(1)
		
	# Conexiones de tus botones...
	if boton_jugar:
		boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	if boton_salir:
		boton_salir.pressed.connect(_on_boton_salir_pressed)
func _on_boton_jugar_pressed() -> void:
	var multiplicador: float = 1.0
	
	if selector_dificultad:
		# Leemos cuál está seleccionado actualmente en el menú
		var indice = selector_dificultad.selected
		match indice:
			0: multiplicador = 0.7  # Fácil
			1: multiplicador = 1.0  # Normal
			2: multiplicador = 1.5  # Difícil
	
	# Guardamos de forma segura en el Autoload Global
	if has_node("/root/Global"):
		get_node("/root/Global").multiplicador_dificultad = multiplicador
		print("Dificultad guardada. Multiplicador: ", multiplicador)
	
	# Cambiamos a tu juego (Reemplaza con el nombre exacto de tu escena principal)
	get_tree().change_scene_to_file("res://EscenaPrincipal.tscn")

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
