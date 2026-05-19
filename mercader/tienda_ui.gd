extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)
@onready var close_button = $FondoTienda/CloseButton

func _ready():
	self.visible = false
	# Conectamos el botón de cierre por código
	close_button.pressed.connect(cerrar)

func _input(event):
	# Se cierra con la tecla que definiste en 'ui_close' (Esc)
	if self.visible and event.is_action_pressed("ui_close"):
		cerrar()

func abrir():
	self.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func cerrar():
	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

# Funciones de botones (conéctalas desde el editor a estas funciones)
func _on_BotonDaño_pressed():
	if jugador and jugador.coins >= 50:
		jugador.coins -= 50
		jugador.damage_amount += 10 # Asegúrate de que esta variable exista en Player
		print("¡Daño mejorado!")
	else:
		print("No tienes suficientes monedas")

func _on_BotonVida_pressed():
	if jugador and jugador.coins >= 30:
		jugador.coins -= 30
		jugador.current_health = min(jugador.current_health + 20, jugador.max_health)
		print("¡Vida recuperada!")
	else:
		print("No tienes suficientes monedas")
