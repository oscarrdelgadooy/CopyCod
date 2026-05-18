extends CanvasLayer

# --- REFERENCIAS DE LA INTERFAZ ---
@onready var label_vida: Label = $Interfaz/LabelVida
@onready var label_monedas: Label = $Interfaz/LabelMonedas
@onready var label_municion: Label = $Interfaz/LabelMunicion
@onready var label_ronda: Label = $Interfaz/LabelRonda

# 🆕 REFERENCIA AL PANEL DE GAME OVER
@onready var game_over_panel: Panel = $Interfaz/GameOverPanel

var player: CharacterBody2D = null
var wave_manager: Node2D = null

func _ready() -> void:
	player = get_tree().current_scene.find_child("Player", true, false)
	wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	
	# Nos aseguramos de que el panel empiece oculto al reiniciar
	if game_over_panel:
		game_over_panel.visible = false

func _process(_delta: float) -> void:
	# 1. ACTUALIZAR JUGADOR Y COMPROBAR MUERTE
	if player:
		if label_vida:
			label_vida.text = "❤️ VIDA: " + str(player.current_health)
		if label_monedas:
			label_monedas.text = "🪙 MONEDAS: " + str(player.coins)
		if label_municion:
			label_municion.text = "💥 BALAS: " + str(player.current_ammo) + " / " + str(player.MAX_AMMO)

		# 💀 SI EL JUGADOR SE QUEDA SIN VIDA: Activamos el Game Over
		if player.current_health <= 0 and game_over_panel and not game_over_panel.visible:
			activa_game_over()

	# 2. ACTUALIZAR RONDAS
	if wave_manager:
		if wave_manager.current_round <= wave_manager.MAX_ROUNDS:
			if label_ronda:
				label_ronda.text = "🚩 RONDA: " + str(wave_manager.current_round) + " / 10"
		else:
			if label_ronda:
				label_ronda.text = "🏆 ¡VICTORIA TOTAL! 🏆"

# 🆕 FUNCIÓN QUE DETIENE EL JUEGO AL MORIR
func activa_game_over() -> void:
	game_over_panel.visible = true
	get_tree().paused = true # Pausamos el motor para que los zombis no sigan moviéndose

# 🆕 FUNCIÓN PARA EL BOTÓN DE REINICIAR
func _on_button_pressed() -> void:
	get_tree().paused = false # Despausamos el juego indispensablemente
	get_tree().change_scene_to_file("res://menu_inicio.tscn")
