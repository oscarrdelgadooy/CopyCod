extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)
@onready var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)

@onready var barra_vida = $MarcoVida/BarraVida
@onready var barra_municion = $BarraMunicion
@onready var label_monedas = $Interfaz/ContenedorMonedas/LabelMonedas
@onready var icono_moneda = $Interfaz/ContenedorMonedas/EspacioIcono/IconoMoneda
@onready var label_anuncio_ronda = $Interfaz/LabelAnuncioRonda

# Guardamos las monedas actuales para saber cuándo cambia el valor y animar
var monedas_visuales: int = 0

func _ready() -> void:
	if jugador:
		if barra_vida:
			barra_vida.max_value = jugador.max_health
			barra_vida.value = jugador.current_health
		monedas_visuales = jugador.coins
		label_monedas.text = str(monedas_visuales)
	
	# Forzamos que el cartel empiece invisible nada más cargar el juego
	if label_anuncio_ronda:
		label_anuncio_ronda.modulate.a = 0.0

func _process(_delta: float) -> void:
	if jugador:
		if barra_vida:
			barra_vida.value = jugador.current_health
		if barra_municion:
			barra_municion.value = jugador.current_ammo
		
		# Si las monedas del jugador cambian, lanzamos la animación del latido
		if jugador.coins != monedas_visuales:
			monedas_visuales = jugador.coins
			actualizar_monedas_con_animacion()

# --- ANIMACIÓN DEL ICONO DE LA MONEDA ---
func actualizar_monedas_con_animacion() -> void:
	label_monedas.text = str(monedas_visuales)
	var tween = create_tween()
	tween.parallel().tween_property(icono_moneda, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icono_moneda, "rotation", deg_to_rad(10), 0.1)
	tween.parallel().tween_property(icono_moneda, "scale", Vector2(1.0, 1.0), 0.15)
	tween.parallel().tween_property(icono_moneda, "rotation", 0.0, 0.15)

# --- ANIMACIÓN DE 3 SEGUNDOS PARA LA RONDA ---
func animar_nueva_ronda(numero_ronda: int) -> void:
	print("!!! EL HUD RECIBE LA ORDEN DE ANIMAR LA RONDA: ", numero_ronda) # <--- AÑADE ESTO
	if not label_anuncio_ronda: 
		return
	
	# Cambiamos el texto al de la ronda actual
	label_anuncio_ronda.text = "RONDA " + str(numero_ronda)
	
	# Aseguramos que empiece invisible
	label_anuncio_ronda.modulate.a = 0.0
	
	var tween = create_tween()
	
	# 1. APARECE: Se vuelve opaco de forma suave en 0.3 segundos
	tween.tween_property(label_anuncio_ronda, "modulate:a", 1.0, 0.3)
	
	# 2. ESPERA: Se queda estático en pantalla durante 2.4 segundos
	tween.tween_interval(2.4)
	
	# 3. DESAPARECE: Se desvanece por completo en 0.3 segundos (Total: 3.0 segundos)
	tween.tween_property(label_anuncio_ronda, "modulate:a", 0.0, 0.3)
