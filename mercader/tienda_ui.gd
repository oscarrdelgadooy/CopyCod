extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)
@onready var close_button = $Panel/CloseButton

func _ready():
	self.visible = false
	# Conectamos el botón por código (o hazlo desde el editor)
	if close_button:
		close_button.pressed.connect(cerrar)

func _input(event):
	# Si la tienda está abierta y pulsamos la tecla de cerrar (ESC)
	if self.visible and event.is_action_pressed("ui_close"):
		cerrar()

func abrir():
	self.visible = true

func cerrar():
	self.visible = false

# Funciones de compra
func _on_BotonDaño_pressed():
	if jugador and jugador.coins >= 50:
		jugador.coins -= 50
		jugador.damage_amount += 10
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
