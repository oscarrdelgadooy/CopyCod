extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 5.0

# El Player sobrescribirá este valor al disparar
var damage: int = 10 

func _ready() -> void:
	# Temporizador para que la bala muera si no toca nada
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Mover la bala hacia adelante en base a su rotación
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

# USAMOS SOLO LA SEÑAL (Mucho más limpio y eficiente)
func _on_body_entered(body: Node2D) -> void:
	# Si choca contra el jugador, la bala lo ignora
	if body.name == "Player":
		return
		
	# Si choca contra el Mercader, también lo ignora para no matarlo
	if body.name == "Mercader":
		return

	# Si el cuerpo tiene la función de recibir daño (como el Zombi)
	if body.has_method("take_damage"):
		body.take_damage(damage) # <--- ¡AQUÍ USAMOS EL DAÑO REAL DE LA TIENDA!
		queue_free()
		return

	# Si choca contra los muros del mapa
	if body.name == "MurosInvisibles":
		queue_free()
		return
