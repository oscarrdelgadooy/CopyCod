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

var is_reloading: bool = false
var is_dead: bool = false
var is_hurting: bool = false
var shoot_timer: float = 0.0

# --- REFERENCIAS A NODOS ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	current_health = max_health
	current_ammo = MAX_AMMO
	if sprite:
		sprite.play("idle")
		sprite.rotation = 0

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if shoot_timer > 0.0:
		shoot_timer -= delta

	# 1. MOVIMIENTO CON WASD
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

	# 2. DIRECCIÓN DE DISPARO CON LAS FLECHAS
	var shoot_dir := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):    shoot_dir.y -= 1
	if Input.is_action_pressed("ui_down"):  shoot_dir.y += 1
	if Input.is_action_pressed("ui_left"):  shoot_dir.x -= 1
	if Input.is_action_pressed("ui_right"): shoot_dir.x += 1
	
	shoot_dir = shoot_dir.normalized()

	# 3. CONTROL DEL GIRO (FLIP) DEL SPRITE
	if not is_hurting and sprite:
		# Prioridad 1: Si dispara (y no está recargando), gira hacia las flechas
		if shoot_dir != Vector2.ZERO and not is_reloading:
			if shoot_dir.x > 0:
				sprite.flip_h = false
			elif shoot_dir.x < 0:
				sprite.flip_h = true
			
			if shoot_timer <= 0.0:
				shoot(shoot_dir)
				shoot_timer = shoot_cooldown
				
		# Prioridad 2: Si camina (o si está recargando y moviéndose), gira hacia el movimiento
		elif direction != Vector2.ZERO:
			if direction.x > 0:
				sprite.flip_h = false
			elif direction.x < 0:
				sprite.flip_h = true

	# 4. ENVIAR LOS DATOS A LA MÁQUINA DE ANIMACIONES
	update_animations(direction, shoot_dir)

func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		start_reload()

# --- MECÁNICA DE DISPARO ---
func shoot(dir: Vector2) -> void:
	if is_reloading or is_hurting:
		return
		
	if current_ammo <= 0:
		start_reload()
		return

	current_ammo -= 1
	print("¡PUM! Munición: ", current_ammo, "/", MAX_AMMO)

	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		
		# Aplicamos el cálculo final con el ajuste personalizado de este frame
		bullet.global_position = global_position + Vector2(0, 32) + (dir * bullet_spawn_distance)
		bullet.global_rotation = dir.angle() 
		get_tree().current_scene.add_child(bullet)

# --- MECÁNICA DE RECARGA ---
func start_reload() -> void:
	if is_reloading or current_ammo == MAX_AMMO or is_dead:
		return
		
	is_reloading = true
	print("Recargando...")
	
	# El cambio de animación a "reload" ocurre automáticamente gracias a update_animations()
	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = MAX_AMMO
	is_reloading = false
	print("¡Recargado!")

# --- SISTEMA DE DAÑO Y MUERTE ---
func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount
	print("¡Daño! Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
	else:
		is_hurting = true
		if sprite:
			sprite.play("hurt")
		await get_tree().create_timer(0.2).timeout
		is_hurting = false

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	print("--- MUERTO ---")
	if sprite:
		sprite.play("dead")

# --- MÁQUINA DE ESTADOS VISUAL (Jerarquía Definitiva) ---
# --- MÁQUINA DE ESTADOS VISUAL (Solo este bloque modificado) ---
func update_animations(direction: Vector2, shoot_dir: Vector2) -> void:
	if not sprite:
		return

	# 1. Muerte (Prioridad máxima)
	if is_dead:
		if sprite.animation != "dead":
			sprite.play("dead")
		return
		
	# 2. Daño / Dolor
	if is_hurting:
		return

	# 3. RESTICCIÓN DE RECARGA: Si está recargando, se muestra 'reload' obligatoriamente
	# e ignoramos por completo cualquier intento de disparo ('shoot') o carrera ('run')
	if is_reloading:
		if sprite.animation != "reload":
			sprite.play("reload")
		return

	# 4. Estados de acción comunes (Solo si NO está recargando)
	if shoot_dir != Vector2.ZERO:
		sprite.play("shoot")
	elif direction != Vector2.ZERO:
		sprite.play("run")
	else:
		sprite.play("idle")
