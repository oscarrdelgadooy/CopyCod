extends CharacterBody2D

# --- VARIABLES CONFIGURABLES ---
@export var speed: float = 250.0
@export var max_health: int = 100
@export var reload_time: float = 1.5
@export var shoot_cooldown: float = 0.25
@export var bullet_scene: PackedScene
@export var bullet_spawn_distance: float = 35.0
@export var bullet_y_offset: float = 25.0 # Pixeles hacia abajo para centrar el arma

# --- VARIABLES DE ESTADO INTERNO ---
var current_health: int = max_health
var current_ammo: int = 8
const MAX_AMMO: int = 8
var coins: int = 0

var damage: int = 10

var is_reloading: bool = false
var is_dead: bool = false
var is_hurting: bool = false
var shoot_timer: float = 0.0
var kills: int = 0 # Guarda cuántos zombis ha matado el jugador

# --- VARIABLES DE AGARRE ZOMBI ---
var is_grabbed: bool = false
var is_invincible: bool = false

# --- REFERENCIAS A NODOS ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	current_health = max_health
	current_ammo = MAX_AMMO
	if sprite:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. ESTADO DE AGARRE (Prioridad absoluta)
	if is_grabbed:
		velocity = Vector2.ZERO
		if sprite and sprite.sprite_frames.has_animation("hurt"):
			sprite.play("hurt")
		move_and_slide()
		return

	# Si está herido (is_hurting), YA NO congelamos la velocity a cero.
	# Dejamos que el código de abajo calcule la dirección para que puedas huir.

	# 2. MOVIMIENTO
	if shoot_timer > 0.0:
		shoot_timer -= delta
		
	if Input.is_key_pressed(KEY_R) and not is_reloading and current_ammo < MAX_AMMO:
		start_reload()

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_D): direction.x += 1
	direction = direction.normalized()
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()

	# 3. DISPARO Y GIRO
	var shoot_dir := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):    shoot_dir.y -= 1
	if Input.is_action_pressed("ui_down"):  shoot_dir.y += 1
	if Input.is_action_pressed("ui_left"):  shoot_dir.x -= 1
	if Input.is_action_pressed("ui_right"): shoot_dir.x += 1
	shoot_dir = shoot_dir.normalized()

	if sprite:
		if shoot_dir != Vector2.ZERO and not is_reloading:
			if shoot_dir.x > 0: sprite.flip_h = false
			elif shoot_dir.x < 0: sprite.flip_h = true
			
			if shoot_timer <= 0.0:
				shoot(shoot_dir)
				shoot_timer = shoot_cooldown
		elif direction != Vector2.ZERO:
			if direction.x > 0: sprite.flip_h = false
			elif direction.x < 0: sprite.flip_h = true

	update_animations(direction, shoot_dir)

func shoot(dir: Vector2) -> void:
	if is_reloading: 
		return
	if current_ammo <= 0:
		start_reload()
		return

	current_ammo -= 1
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.damage = damage
		bullet.rotation = dir.angle()
		# Calculamos el origen bajando unos píxeles en el eje Y
		var origen_arma = global_position + Vector2(0, bullet_y_offset)
		
		# Movemos la bala hacia la dirección de disparo desde ese nuevo origen
		bullet.global_position = origen_arma + (dir * bullet_spawn_distance)
		
		get_tree().current_scene.add_child(bullet)

func start_reload() -> void:
	if is_reloading or current_ammo == MAX_AMMO or is_dead:
		return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_ammo = MAX_AMMO
	is_reloading = false

func take_grab_damage(amount: int) -> void:
	if is_dead: return
	
	current_health -= amount
	is_grabbed = false
	is_invincible = true
	
	# --- CORRECCIÓN: Avisamos al HUD INMEDIATAMENTE antes de que el código se pause con el await ---
	var hud = get_tree().current_scene.find_child("HUD", true, false)
	if hud and hud.has_method("mostrar_daño"):
		hud.mostrar_daño()
		
	if current_health <= 0: 
		die()
	else:
		is_hurting = true
		if sprite: 
			sprite.stop() # Reiniciamos la animación a la fuerza por si se había quedado congelada
			sprite.play("hurt")
			
		# Nos quedamos aturdidos estos 0.8 segundos
		await get_tree().create_timer(0.8).timeout
		
		is_invincible = false
		is_hurting = false

func die() -> void:
	is_dead = true
	if sprite: sprite.play("dead")

func update_animations(direction: Vector2, shoot_dir: Vector2) -> void:
	if not sprite or is_dead:
		return

	# PRIORIDAD 1: Si estamos heridos, forzamos la animación de daño aunque nos movamos
	if is_hurting:
		if sprite.animation != "hurt":
			sprite.play("hurt")
		return # Corta aquí: impide que se reproduzcan 'run' o 'idle'

	# PRIORIDAD 2: Recarga
	if is_reloading:
		sprite.play("reload")
		return

	# PRIORIDAD 3: Movimiento y Disparo normal
	if shoot_dir != Vector2.ZERO: 
		sprite.play("shoot")
	elif direction != Vector2.ZERO: 
		sprite.play("run")
	else: 
		sprite.play("idle")

func upgrade_damage(amount: int):
	var _daño_anterior = damage # Se añade el guion bajo para eliminar el warning de la consola
	damage += amount
