extends Node2D

@onready var label_ayuda = $Label
@onready var tienda = get_tree().current_scene.find_child("TiendaUI", true, false)

var jugador_cerca: bool = false

func _ready():
	$ZonaInteraccion.body_entered.connect(_on_body_entered)
	$ZonaInteraccion.body_exited.connect(_on_body_exited)
	label_ayuda.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		label_ayuda.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		label_ayuda.visible = false

func _process(_delta):
	# Solo abrimos si está cerca, pulsamos E, y la tienda NO está ya abierta
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if tienda and not tienda.visible:
			tienda.abrir()
