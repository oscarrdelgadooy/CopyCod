extends Node

@export var zombie_scene: PackedScene  # Arrastra aquí tu zombie.tscn
@export var zombie_rapido_scene: PackedScene  # Arrastra aquí tu zombie_fast.tscn@export var tiempo_compra: float = 30.0 # Tiempo que se queda el mercader (30 segundos)

@onready var spawn_timer = $SpawnTimer
@onready var prep_timer = $PrepTimer

# Referencias a la tienda, mercader y interfaz
@onready var mercader = get_parent().find_child("Mercader", true, false)
@onready var tienda_ui = get_parent().find_child("TiendaUI", true, false)
@onready var label_ronda = get_parent().find_child("LabelRonda", true, false) # Ajusta el nombre de tu Label de rondas

var ronda_actual: int = 0
var zombies_por_spawnear: int = 0
var zombies_vivos: int = 0

func _ready():
	# Conectamos las señales de los Timers por código para evitar fallos
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	prep_timer.timeout.connect(_on_prep_timer_timeout)
	
	# Al empezar el juego, el mercader y la tienda están totalmente ocultos
	if mercader: mercader.visible = false
	if tienda_ui: tienda_ui.visible = false
	
	# Configuramos el timer de preparación para que solo se ejecute una vez por ronda
	prep_timer.one_shot = true
	
	# Arrancamos la primera ronda con un pequeño retraso inicial
	await get_tree().create_timer(2.0).timeout
	iniciar_nueva_ronda()

func iniciar_nueva_ronda():
	ronda_actual += 1
	# Fórmula matemática simple: Ronda 1 = 5 zombis, Ronda 2 = 10, Ronda 3 = 15...
	zombies_por_spawnear = ronda_actual * 5 
	zombies_vivos = 0
	
	print("--- INICIANDO RONDA ", ronda_actual, " ---")
	
	# 1. Mostrar el número de la ronda en pantalla
	if label_ronda:
		label_ronda.text = "RONDA " + str(ronda_actual)
		label_ronda.visible = true
		await get_tree().create_timer(3.0).timeout # Se muestra durante 3 segundos
		label_ronda.visible = false
	
	# Por seguridad, nos aseguramos de que el mercader ya no esté
	if mercader: mercader.visible = false
	if tienda_ui: tienda_ui.visible = false
	
	# 2. Empezar a spawnear zombis
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if zombies_por_spawnear > 0:
		spawn_un_zombi()
		zombies_por_spawnear -= 1
	else:
		spawn_timer.stop() # Ya han salido todos los zombis programados

func spawn_un_zombi():
	# Comprobamos que al menos la escena normal esté asignada
	if not zombie_scene:
		return
		
	var zombi: CharacterBody2D = null
	
	# Generamos un número aleatorio entre 0 y 100
	var probabilidad = randf_range(0, 100)
	
	# Si sale más de 70 y tenemos configurado el zombi rápido, lo spawneamos
	if probabilidad > 70.0 and zombie_rapido_scene:
		zombi = zombie_rapido_scene.instantiate()
	else:
		zombi = zombie_scene.instantiate()
		
	# --- POSICIONAMIENTO (Cerca del jugador para testear) ---
	var player = get_tree().current_scene.find_child("Player", true, false)
	if player:
		zombi.global_position = player.global_position + Vector2(300, randf_range(-100, 100))
	else:
		zombi.global_position = Vector2(500, 400)
		
	# Lo añadimos al juego y conectamos su muerte
	get_tree().current_scene.add_child(zombi)
	zombies_vivos += 1
	zombi.tree_exited.connect(_on_zombi_destruido)

func _on_zombi_destruido():
	zombies_vivos -= 1
	print("Zombi eliminado. Vivos restantes: ", zombies_vivos)
	
	# 3. Comprobar si ya no quedan más zombis ni por spawnear ni vivos
	if zombies_por_spawnear <= 0 and zombies_vivos <= 0:
		iniciar_tiempo_compra()

func iniciar_tiempo_compra():
	print("¡Mapa limpio! El mercader ha llegado.")
	
	# Aparece el mercader en el mapa
	if mercader:
		mercader.visible = true
	
	# Iniciamos la cuenta atrás de 30 segundos
	prep_timer.start(prep_timer)

func _on_prep_timer_timeout():
	print("Se acabó el tiempo de compra. El mercader se marcha.")
	
	# Desaparece el mercader y cerramos la interfaz de la tienda por la fuerza
	if mercader: mercader.visible = false
	if tienda_ui: tienda_ui.visible = false
	
	# Saltamos a la siguiente ronda de forma automática
	iniciar_nueva_ronda()
