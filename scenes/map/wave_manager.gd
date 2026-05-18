extends Node2D

# --- CONFIGURACIÓN DE ESCENAS ---
@export var zombie_normal: PackedScene
@export var zombie_fast: PackedScene

# --- TUS PUNTOS DE SPAWN (Marker2D o Node2D del mapa) ---
@export var spawn_points: Array[Node2D] = []

# --- AJUSTE DE TIEMPO FIJO ---
@export var spawn_cooldown: float = 0.8 # Tiempo exacto entre zombis

# --- VARIABLES DE CONTROL ---
var current_round: int = 1
const MAX_ROUNDS: int = 10

var total_zombies_this_round: int = 0
var zombies_spawned_so_far: int = 0
var zombies_alive: int = 0
var is_round_active: bool = false

func _ready() -> void:
	# 2 segundos de margen al empezar la partida para que el jugador respire
	await get_tree().create_timer(2.0).timeout
	start_next_round()

func start_next_round() -> void:
	if current_round > MAX_ROUNDS:
		win_game()
		return
		
	is_round_active = true
	zombies_spawned_so_far = 0
	
	# 📈 CURVA DE DIFICULTAD: Cada ronda se suman 4 zombis más
	total_zombies_this_round = 2 + (current_round * 4) 
	zombies_alive = total_zombies_this_round
	
	# Probabilidad de zombi rápido (Ronda 1 = 10% | va subiendo hasta el 80% en la ronda 10)
	var fast_chance = min(0.8, current_round * 0.08)
	
	print("=== INICIA LA RONDA ", current_round, " === Enemigos: ", total_zombies_this_round)
	
	# Bucle para ir soltando los zombis uno a uno con el retraso de 0.8s
	while zombies_spawned_so_far < total_zombies_this_round:
		if not is_round_active: break # Por si acaso
		spawn_zombie(fast_chance)
		zombies_spawned_so_far += 1
		
		# ⏱️ Espera los 0.8 segundos clavados antes del siguiente
		await get_tree().create_timer(spawn_cooldown).timeout

func spawn_zombie(fast_chance: float) -> void:
	if spawn_points.size() == 0:
		print("⚠️ Alerta: ¡No has metido puntos de spawn en el WaveManager!")
		return
		
	# 1. Elegir un punto de spawn del mapa al azar
	var random_point = spawn_points[randi() % spawn_points.size()]
	
	# 2. Decidir el tipo de zombi según la ronda
	var zombie_scene = zombie_normal
	if randf() < fast_chance and zombie_fast:
		zombie_scene = zombie_fast
		
	# 3. Instanciarlo en el mapa
	if zombie_scene:
		var new_enemy = zombie_scene.instantiate()
		new_enemy.global_position = random_point.global_position
		get_tree().current_scene.add_child(new_enemy)

# --- FUNCIÓN CONECTADA CON LA MUERTE DEL ZOMBI ---
func zombie_killed() -> void:
	zombies_alive -= 1
	print("Zombis que quedan en la ronda: ", zombies_alive)
	
	# Si limpiamos la oleada completa... ¡Siguiente ronda!
	if zombies_alive <= 0 and is_round_active:
		is_round_active = false
		print("=== ¡RONDA ", current_round, " SUPERADA! ===")
		current_round += 1
		
		# 4 segundos de descanso para ir a comprar al Mercader tranquilamente
		await get_tree().create_timer(4.0).timeout
		start_next_round()

func win_game() -> void:
	print("🏆 ¡BRUTAL! Has sobrevivido a las 10 rondas de la mazmorra 🏆")
	get_tree().paused = true # Congela el juego al ganar
