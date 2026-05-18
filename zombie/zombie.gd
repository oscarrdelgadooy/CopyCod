extends CharacterBody2D

# --- VARIABLES CONFIGURABLES ---
@export var speed: float = 90.0      # Más lento que el jugador para que puedas huir
@export var health: int = 1          # Muere de 1 tiro (puedes subirlo en el Inspector)
@export var damage_amount: int = 2   # Cuánta vida le quita al jugador por mordisco
@export var attack_cooldown: float = 1.0 # Tiempo entre mordiscos (en segundos)

# --- VARIABLES DE ESTADO INTERNO ---
var player: CharacterBody2D = null
var is_dead: bool = false
var attack_timer: float = 0.0

# --- REFERENCIAS A NODOS ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	# Buscamos al jugador en la escena principal de forma automática
	# Usamos 'get_tree().get_first_node_in_group' o lo buscamos por nombre
	player = get_tree().current_scene.find_child("Player", true, false)
	
	if sprite:
		sprite.play("walk")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Controlar el temporizador del ataque
	if attack_timer > 0.0:
		attack_timer -= delta

	# 1. IA DE PERSECUCIÓN
	if player and not player.is_dead: # Solo persigue si el jugador existe y está vivo
		# Calcular vector hacia el jugador
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		# 2. GIRAR EL SPRITE (FLIP) HACIA DONDE CAMINA EL ZOMBI
		if sprite:
			if velocity.x > 0:
				sprite.flip_h = false # Mira a la derecha
			elif velocity.x < 0:
				sprite.flip_h = true  # Mira a la izquierda
	else:
		# Si el jugador muere, el zombi se queda deambulando o quieto
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		if sprite and sprite.animation != "idle" and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")

	# Mover al zombi gestionando colisiones con los muros PNG automáticamente
	move_and_slide()

	# 3. LÓGICA DE DAÑO CONTINUO (Morder al jugador si está en la Hitbox)
	if attack_timer <= 0.0:
		check_attack()

# --- RECIBIR DAÑO (Llamado por la bala) ---
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	health -= amount
	print("Zombi herido. Vida restante: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO # Frenazo total del zombi
	
	# 🛡️ CONTROL DE SEGURIDAD 1: Solo borramos la colisión si existe en el árbol
	if has_node("CollisionShape2D"):
		$CollisionShape2D.queue_free()
	
	# 🛡️ CONTROL DE SEGURIDAD 2: Solo borramos la hitbox si no es nula
	if hitbox:
		hitbox.queue_free()
		
	print("¡Zombi eliminado!")
	
	# 🛡️ CONTROL DE SEGURIDAD 3: Comprobamos qué nombre tiene tu animación de muerte
	if sprite:
			sprite.play("dead")
	# Esperar 1 segundo enseñando el cadáver y luego borrarlo de la memoria
	await get_tree().create_timer(0.8).timeout
	queue_free()

# --- COMPROBAR SI PUEDE MORDER ---
func check_attack() -> void:
	if hitbox:
		var overlapping_bodies = hitbox.get_overlapping_bodies()
		for body in overlapping_bodies:
			# Si lo que está dentro de nuestra Hitbox es el jugador...
			if body == player and not player.is_dead:
				# Le llamamos a su función de recibir daño que programamos antes
				body.take_damage(damage_amount)
				attack_timer = attack_cooldown # Activamos el cooldown de mordisco
				break
