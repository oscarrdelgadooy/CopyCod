extends CanvasLayer

# --- REFERENCIAS A LOS TEXTOS DE LA INTERFAZ ---
# Asegúrate de que las rutas coinciden con cómo llamaste a los nodos
@onready var label_vida: Label = $Interfaz/LabelVida
@onready var label_monedas: Label = $Interfaz/LabelMonedas
@onready var label_municion: Label = $Interfaz/LabelMunicion
@onready var label_ronda: Label = $Interfaz/LabelRonda

# --- VARIABLES PARA GUARDAR AL JUGADOR Y AL MÁNAGER ---
var player: CharacterBody2D = null
var wave_manager: Node2D = null

func _ready() -> void:
	# Buscamos a los "jefes" de los datos en cuanto arranca el nivel
	player = get_tree().current_scene.find_child("Player", true, false)
	wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)

func _process(_delta: float) -> void:
	# 1. ACTUALIZAR TEXTOS DEL JUGADOR
	if player:
		if label_vida:
			label_vida.text = "❤️ VIDA: " + str(player.current_health)
		if label_monedas:
			label_monedas.text = "🪙 MONEDAS: " + str(player.coins)
		if label_municion:
			label_municion.text = "💥 BALAS: " + str(player.current_ammo) + " / " + str(player.MAX_AMMO)

	# 2. ACTUALIZAR TEXTOS DE LAS RONDAS
	if wave_manager:
		# Comprobamos si el juego sigue activo o ya ganaste
		if wave_manager.current_round <= wave_manager.MAX_ROUNDS:
			if label_ronda:
				label_ronda.text = "🚩 RONDA: " + str(wave_manager.current_round) + " / 10"
		else:
			if label_ronda:
				label_ronda.text = "🏆 ¡VICTORIA TOTAL! 🏆"dswad
