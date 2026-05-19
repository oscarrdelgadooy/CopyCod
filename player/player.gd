extends CharacterBody2D

# --- VARIABLES CONFIGURABLES ---
@export var speed: float = 250.0
@export var max_health: int = 100
@export var reload_time: float = 1.5
@export var shoot_cooldown: float = 0.25
@export var bullet_scene: PackedScene
@export var bullet_spawn_distance: float = 35.0

# --- VARIABLES DE ESTADO INTERNO ---
var current_health: int = max_health
var current_ammo: int = 8
const MAX_AMMO: int = 8
var coins: int = 0

var is_reloading: bool = false
var is_dead: bool = false
var is_hurting: bool = false
var shoot_timer: float = 0.0

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

	# 2. MOVIMIENTO
	if shoot_timer > 0.0:
		shoot_timer -= delta

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_D): direction.x += 1
	direction = direction.normalized()
	
	if direction != Vector2.ZERO and not is_hurting:
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

	if not is_hurting and sprite:
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
	if is_reloading or is_hurting:
		return
	if current_ammo <= 0:
		start_reload()
		return

	current_ammo -= 1
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(0, 32) + (dir * bullet_spawn_distance)
		bullet.global_rotation = dir.angle() 
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
	if current_health <= 0: die()
	else:
		is_hurting = true
		if sprite: sprite.play("hurt")
		await get_tree().create_timer(2.0).timeout
		is_invincible = false
		is_hurting = false

func die() -> void:
	is_dead = true
	if sprite: sprite.play("dead")

func update_animations(direction: Vector2, shoot_dir: Vector2) -> void:
	if not sprite or is_dead or is_hurting or is_reloading:
		if is_reloading and sprite: sprite.play("reload")
		return
	if shoot_dir != Vector2.ZERO: sprite.play("shoot")
	elif direction != Vector2.ZERO: sprite.play("run")
	else: sprite.play("idle")
