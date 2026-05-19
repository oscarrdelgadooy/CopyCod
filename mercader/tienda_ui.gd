extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)

func _ready():
	self.visible = false # Empieza oculta

func abrir():
	self.visible = true
	# IMPORTANTE: Liberar el ratón para poder clicar
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func cerrar():
	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_BotonDaño_pressed():
	if jugador and jugador.coins >= 50:
		jugador.coins -= 50
		print("¡Daño mejorado!")
	else:
		print("No hay dinero")

func _on_BotonVida_pressed():
	if jugador and jugador.coins >= 30:
		jugador.coins -= 30
		jugador.current_health = min(jugador.current_health + 20, jugador.max_health)
		print("¡Vida recuperada!")
	else:
		print("No hay dinero")
