extends Node

@export var zombie_scene: PackedScene 
@export var zombie_rapido_scene: PackedScene
@export var tiempo_compra: float = 30.0

@onready var spawn_timer = $SpawnTimer
@onready var prep_timer = $PrepTimer

@onready var mercader = get_parent().find_child("Mercader", true, false)
@onready var tienda_ui = get_parent().find_child("TiendaUI", true, false)

# Buscamos el nodo principal de tu interfaz para mandarle la orden de animar
@onready var huds = get_parent().find_child("Hud", true, false) 

var ronda_actual: int = 0
var zombies_por_spawnear: int = 0
var zombies_vivos: int = 0

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	prep_timer.timeout.connect(_on_prep_timer_timeout)
	
	if mercader and mercader.has_method("desaparecer"): 
		mercader.desaparecer()
		
	if tienda_ui: 
		tienda_ui.visible = false
	
	prep_timer.one_shot = true
	
	# Cortesía de 2 segundos de espera al iniciar la partida antes de lanzar la Ronda 1
	await get_tree().create_timer(2.0).timeout
	iniciar_nueva_ronda()

func iniciar_nueva_ronda():
	ronda_actual += 1
	zombies_por_spawnear = ronda_actual * 5 
	zombies_vivos = 0
	
	print("--- INICIANDO RONDA ", ronda_actual, " ---")
	
	# --- LLAMADA AL HUD ANIMADO (DURA 3 SEGUNDOS EN PANTALLA) ---
	if huds and huds.has_method("animar_nueva_ronda"):
		huds.animar_nueva_ronda(ronda_actual)
	
	# El mercader y la tienda se cierran al empezar la acción
	if mercader and mercader.has_method("desaparecer"): 
		mercader.desaparecer()
			
	if tienda_ui: 
		tienda_ui.visible = false
	
	# Los zombis empiezan a salir ya mismo en segundo plano mientras se ve el cartel
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if zombies_por_spawnear > 0:
		spawn_un_zombi()
		zombies_por_spawnear -= 1
	else:
		spawn_timer.stop()

func spawn_un_zombi():
	if not zombie_scene: 
		return
		
	var zombi: CharacterBody2D = null
	
	var probabilidad = randf_range(0, 100)
	if probabilidad > 70.0 and zombie_rapido_scene:
		zombi = zombie_rapido_scene.instantiate()
	else:
		zombi = zombie_scene.instantiate()
		
	var carpeta_spawners = get_tree().current_scene.find_child("SpawnPoints", true, false)
	
	if carpeta_spawners and carpeta_spawners.get_child_count() > 0:
		var lista_puntos = carpeta_spawners.get_children()
		var punto_elegido = lista_puntos.pick_random()
		zombi.global_position = punto_elegido.global_position
	else:
		zombi.global_position = Vector2(500, 400)
		
	get_tree().current_scene.add_child(zombi)
	zombies_vivos += 1
	zombi.tree_exited.connect(_on_zombi_destruido)

func _on_zombi_destruido():
	zombies_vivos -= 1
	print("Zombi eliminado. Vivos restantes: ", zombies_vivos)    
	
	if zombies_por_spawnear <= 0 and zombies_vivos <= 0:
		iniciar_tiempo_compra()

func iniciar_tiempo_compra():
	print("¡Mapa limpio! El mercader ha llegado.")
	
	if mercader and mercader.has_method("aparecer"): 
		mercader.aparecer()
			
	prep_timer.start(tiempo_compra)

func _on_prep_timer_timeout():
	print("Se acabó el tiempo de compra. El mercader se marcha.")
	
	if mercader and mercader.has_method("desaparecer"): 
		mercader.desaparecer()
			
	if tienda_ui: 
		tienda_ui.visible = false
	
	iniciar_nueva_ronda()
