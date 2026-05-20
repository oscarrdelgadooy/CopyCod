extends Node2D

@onready var label_ayuda = $Label
@onready var tienda = get_tree().current_scene.find_child("TiendaUI", true, false)

var jugador_cerca: bool = false

func _ready():
	$ZonaInteraccion.body_entered.connect(_on_body_entered)
	$ZonaInteraccion.body_exited.connect(_on_body_exited)
	
	# Por defecto, nos aseguramos de que empiece apagado al cargar el mapa
	desaparecer()

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		label_ayuda.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		label_ayuda.visible = false

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if tienda and not tienda.visible:
			tienda.abrir()

# --- INTERRUPTORES DE CONTROL ABSOLUTO ---

func aparecer():
	self.visible = true
	# PROCESS_MODE_INHERIT vuelve a encender el nodo, sus físicas y su código
	self.process_mode = Node.PROCESS_MODE_INHERIT 
	
func desaparecer():
	self.visible = false
	# PROCESS_MODE_DISABLED congela el nodo al 100%. Las colisiones dejan de existir.
	self.process_mode = Node.PROCESS_MODE_DISABLED 
	
	# Limpiamos el estado por si el jugador estaba al lado justo cuando desapareció
	jugador_cerca = false
	if label_ayuda:
		label_ayuda.visible = false
