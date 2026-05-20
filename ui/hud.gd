extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)
@onready var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)

@onready var barra_vida = $Interfaz/MarcoVida/BarraVida
@onready var label_monedas = $Interfaz/ContenedorMonedas/LabelMonedas
@onready var icono_moneda = $Interfaz/ContenedorMonedas/EspacioIcono/IconoMoneda
@onready var label_anuncio_ronda = $Interfaz/LabelAnuncioRonda

# --- REFERENCIAS DE LAS ESTADÍSTICAS ---
@onready var label_kills = $Interfaz/PanelEstadisticas/VBoxContainer/FilaKills/LabelKills
@onready var label_tiempo = $Interfaz/PanelEstadisticas/VBoxContainer/FilaTiempo/LabelTiempo
@onready var label_daño =  $"Interfaz/PanelEstadisticas/VBoxContainer/FilaDaño/LabelDaño"
@onready var label_velocidad = $Interfaz/PanelEstadisticas/VBoxContainer/FilaVelocidad/LabelVelocidad
@onready var label_cadencia = $Interfaz/PanelEstadisticas/VBoxContainer/FilaCadencia/LabelCadencia
@onready var label_municion = $Interfaz/LabelMunicion

var monedas_visuales: int = 0
var tiempo_partida: float = 0.0 

func _ready() -> void:
	if jugador:
		if barra_vida:
			barra_vida.max_value = jugador.max_health
			barra_vida.value = jugador.current_health
		monedas_visuales = jugador.coins
		label_monedas.text = str(monedas_visuales)
	
	if label_anuncio_ronda:
		label_anuncio_ronda.modulate.a = 0.0

func _process(delta: float) -> void:
	if jugador:
		if barra_vida:
			barra_vida.value = jugador.current_health

		
		if jugador.coins != monedas_visuales:
			monedas_visuales = jugador.coins
			actualizar_monedas_con_animacion()
			
		# --- ACTUALIZACIÓN DE ESTADÍSTICAS CON TUS VARIABLES REALES ---
		if label_kills:
			label_kills.text = "ZOMBIS: " + str(jugador.kills)
			
		if label_tiempo:
			tiempo_partida += delta 
			var minutos = int(tiempo_partida) / 60
			var segundos = int(tiempo_partida) % 60
			label_tiempo.text = "TIEMPO: %02d:%02d" % [minutos, segundos]
			
		if label_daño:
			# Usamos tu variable 'damage'
			label_daño.text = "DAÑO: " + str(jugador.damage)
			
		if label_velocidad:
			# Usamos tu variable 'speed'
			label_velocidad.text = "VEL: " + str(jugador.speed)
			
		if label_cadencia:
			# Muestra las balas que puedes disparar por segundo (1 dividido entre el cooldown)
			var balas_por_segundo = 1.0 / jugador.shoot_cooldown
			label_cadencia.text = "CADENCIA: %.1f b/s" % balas_por_segundo
			
		if label_municion:
			label_municion.text = str(jugador.current_ammo) + " / " + str(jugador.MAX_AMMO)

func actualizar_monedas_con_animacion() -> void:
	label_monedas.text = str(monedas_visuales)

func animar_nueva_ronda(numero_ronda: int) -> void:
	if not label_anuncio_ronda: return
	label_anuncio_ronda.text = "RONDA " + str(numero_ronda)
	label_anuncio_ronda.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(label_anuncio_ronda, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.4)
	tween.tween_property(label_anuncio_ronda, "modulate:a", 0.0, 0.3)
