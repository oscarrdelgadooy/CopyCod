extends CanvasLayer

@onready var boton_menu = $BotonVolverMenu # Ajusta la ruta a tu botón en el editor

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Importante para funcionar en pausa
	if boton_menu:
		boton_menu.pressed.connect(_on_volver_menu_pressed)

func mostrar_game_over() -> void:
	self.visible = true
	get_tree().paused = true # Pausamos el mundo (zombis, jugador, físicas)

func _on_volver_menu_pressed() -> void:
	get_tree().paused = false # Despausamos antes de cambiar
	get_tree().change_scene_to_file("res://scenes/mainmenu/main_menu.tscn")
