extends CharacterBody2D

# --- VARIABLES CONFIGURABLES ---
@export var speed: float = 90.0      # (En zombie_fast cambia esto a 160.0)
@export var health: int = 1          
@export var damage_amount: int = 2   
@export var attack_cooldown: float = 1.0 

# --- VARIABLES DE ESTADO INTERNO ---
var player: CharacterBody2D = null
var is_dead: bool = false
var is_currently_grabbing: bool = false 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	# Buscamos al jugador automáticamente en el mapa
	player = get_tree().current_scene.find_child("Player", true, false)
	if sprite:
		sprite.play("walk")

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
	
	# Aplicamos el daño si seguimos vivos
	if not is_dead and player:
		if player.has_method("take_grab_damage"):
			player.take_grab_damage(damage_amount)
			
	is_currently_grabbing = false

# --- RECIBIR DAÑO Y MORIR ---
func take_damage(amount: int) -> void:
	if is_dead: return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	
	if is_currently_grabbing and player and player.is_grabbed:
		player.is_grabbed = false
	
	var manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if manager: manager.zombie_killed()
	
	if player: player.coins += 2 
	
	if has_node("CollisionShape2D"): $CollisionShape2D.queue_free()
	if hitbox: hitbox.queue_free()
		
	if sprite and sprite.sprite_frames.has_animation("dead"):
		sprite.play("dead")
		
	await get_tree().create_timer(0.8).timeout
	queue_free()
