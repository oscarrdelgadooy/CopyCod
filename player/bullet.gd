extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 5.0

func _ready() -> void:
	# Crear un temporizador para que la bala se limpie sola si no toca nada
	await get_tree().create_timer(lifetime).timeout
	queue_free() # Borra la bala del juego de forma segura

func _physics_process(delta: float) -> void:
	# En Godot, Vector2.RIGHT (1, 0) es la dirección "hacia adelante".
	# Al multiplicarlo por la rotación del objeto, viaja recto hacia donde apunta.
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	# Conectar el choque con los muros del mapa PNG
	# Nota: Más adelante añadiremos aquí la lógica para hacer daño a los zombis
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "MapObstacles": # Si choca contra las colisiones invisibles del mapa
			queue_free() # La bala desaparece al impactar con el muro
