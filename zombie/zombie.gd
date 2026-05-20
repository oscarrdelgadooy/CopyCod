extends CharacterBody2D

# --- VARIABLES CONFIGURABLES ---
@export var speed: float = 90.0      # (En zombie_fast cambia esto a 160.0)
@export var attack_cooldown: float = 1.0 

# --- VARIABLES DE ESTADO INTERNO ---
var player: CharacterBody2D = null
var is_dead: bool = false
var is_currently_grabbing: bool = false 

@onready var sfx_muerte = $SfxMuerte

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

# --- SISTEMA DE ESCALADO DE ESTADÍSTICAS ---
var vida_maxima: float = 30.0
var vida_actual: float = 30.0
var daño_zombi: float = 10.0

func _ready() -> void:
	# 1. Buscamos al WaveManager asegurando su tipo
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false) 
	
	var ronda = 1
	if wave_manager:
		ronda = wave_manager.ronda_actual

	# 2. Matemáticas de escalado por ronda
	vida_maxima = 30.0 * pow(1.15, ronda - 1) * Global.multiplicador_dificultad
	daño_zombi = 10.0 * pow(1.10, ronda - 1) * Global.multiplicador_dificultad
	
	# Sincronizamos la vida inicial con la escalada
	vida_actual = vida_maxima
		
	# 3. ¡SOLUCIÓN AL MOVIMIENTO! 
	# Si la variable 'player' no viene asignada desde fuera, la buscamos nosotros en el mapa
	if not player:
		player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D


func _physics_process(_delta: float) -> void:
	if is_dead or is_currently_grabbing:
		return

	if player and not player.is_dead:
		# 1. ¿ESTOY LO SUFICIENTEMENTE CERCA?
		if is_player_in_range():
			
			# 2. ¿PUEDO MORDERLE?
			if not player.is_grabbed and not player.is_invincible:
				start_grab_sequence() # ¡ÑAM!
			else:
				# El jugador es invencible o está ocupado. Esperamos quietos al lado.
				velocity = Vector2.ZERO
				if sprite and sprite.sprite_frames.has_animation("idle"):
					sprite.play("idle")
		
		# 3. SI NO ESTOY CERCA, CORRO HACIA ÉL
		else:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			
			if sprite:
				sprite.play("walk")
				sprite.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO
		if sprite and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")

	move_and_slide()

# --- FUNCIONES DE ATAQUE ---
func is_player_in_range() -> bool:
	if hitbox:
		for body in hitbox.get_overlapping_bodies():
			if body == player:
				return true
	return false

func start_grab_sequence() -> void:
	is_currently_grabbing = true
	velocity = Vector2.ZERO
	
	# Bloqueamos al jugador
	player.is_grabbed = true 
	
	# Animación de ataque
	if sprite and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		
	# Duración de la animación (1 segundo agarrado)
	await get_tree().create_timer(1.0).timeout
	
	# Aplicamos el daño si seguimos vivos (usando la variable escalada 'daño_zombi')
	if not is_dead and player:
		if player.has_method("take_grab_damage"):
			# Convertimos a int por si tu función del jugador espera un entero estricto
			player.take_grab_damage(int(daño_zombi))
			
	is_currently_grabbing = false

# --- RECIBIR DAÑO Y MORIR ---
# Cambiado para que tus balas resten de la vida flotante escalada (vida_actual)
func take_damage(amount: float) -> void:
	if is_dead: return
	
	vida_actual -= amount
	print("Zombi herido. Vida restante: ", vida_actual)
	
	if vida_actual <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	
	# Soltamos al jugador si lo teníamos agarrado
	if is_currently_grabbing and player and player.is_grabbed:
		player.is_grabbed = false
		
	if sfx_muerte:
		sfx_muerte.play()
	# Damos las monedas y sumamos la Kill de forma segura
	if player: 
		if "coins" in player:
			player.coins += 2 
		if "kills" in player:
			player.kills += 1
		print("¡Zombi muerto! Monedas: ", player.coins, " | Kills: ", player.kills)
	
	# Borramos las colisiones para que no estorben en el suelo
	if has_node("CollisionShape2D"): $CollisionShape2D.queue_free()
	if hitbox: hitbox.queue_free()
		
	# Reproducimos animación de muerte
	if sprite and sprite.sprite_frames.has_animation("dead"):
		sprite.play("dead")
		
	# Esperamos un poco y nos borramos (el Wave Manager lo detectará automáticamente)
	await get_tree().create_timer(0.8).timeout
	queue_free()
