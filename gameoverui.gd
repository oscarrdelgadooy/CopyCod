extends CanvasLayer

@onready var boton_menu = $BotonVolverMenu # Ajusta la ruta a tu botón en el editor

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Importante para funcionar en pausa
	if boton_menu:
		boton_menu.pressed.connect(_on_volver_menu_pressed)

func mostrar_game_over() -> void:
	print("¡EL MENÚ DE MUERTE SE ESTÁ MOSTRANDO!") # Si esto sale, el código va bien
	self.visible = true
	get_tree().paused = true

func _on_volver_menu_pressed() -> void:
	get_tree().paused = false # Despausamos antes de cambiar
	get_tree().change_scene_to_file("res://MenuInicio.tscn")
