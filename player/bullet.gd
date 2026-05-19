extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 5.0

var damage: int = 10

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Mover la bala hacia adelante
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

	# Detectar impactos
	var bodies = get_overlapping_bodies()
	for body in bodies:
		# Si choca contra el jugador, la bala lo ignora (para no autolesionarse)
		if body.name == "Player":
			continue
			
		# SI EL CUERPO TIENE LA FUNCIÓN 'take_damage' (como el Zombi), LE PEGAMOS UN TIRO
		if body.has_method("take_damage"):
			body.take_damage(1) # Le quita 1 de vida (el zombi tiene 1 por defecto)
			queue_free()        # La bala desaparece al impactar
			break
			
		# Si choca contra las colisiones invisibles del mapa PNG
		elif body.name == "MurosInvisibles":
			queue_free()
			break

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage) # La bala aplica el daño actual
	queue_free() # La bala desaparece al impactar
