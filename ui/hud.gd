extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)
@onready var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)

# Referencias a tus nuevos nodos visuales
@onready var barra_vida = $Interfaz/MarcoVida/BarraVida
@onready var barra_municion = $BarraMunicion
@onready var label_monedas = $Interfaz/LabelMonedas
@onready var label_ronda = $Interfaz/LabelRonda

func _ready() -> void:
	if barra_vida:
		print("HUD: ¡He encontrado la barra de vida! Su nombre es: ", barra_vida.name)
		print("HUD: Su valor actual es: ", barra_vida.value)
	else:
		print("HUD: ¡ERROR! No encuentro ninguna barra de vida.")
	if jugador:
		barra_vida.value = jugador.current_health
		# Comprobamos si el nodo existe antes de intentar cambiarle el valor
		if barra_vida:
			barra_vida.max_value = jugador.max_health
			barra_vida.value = jugador.current_health
		else:
			push_error("¡Cuidado! No encontré el nodo BarraVida en la escena.")
			
		if barra_municion:
			barra_municion.max_value = jugador.MAX_AMMO
			barra_municion.value = jugador.current_ammo
		else:
			push_error("¡Cuidado! No encontré el nodo BarraMunicion en la escena.")

func _process(_delta: float) -> void:
	if jugador:
		# Actualizamos las barras de forma fluida
		barra_vida.value = jugador.current_health
		barra_municion.value = jugador.current_ammo
		
		# Actualizamos texto de monedas
		label_monedas.text = "MONEDAS: " + str(jugador.coins)

	if wave_manager:
		label_ronda.text = "RONDA: " + str(wave_manager.ronda_actual)
		
# Llámalo desde el script del jugador cuando reciba daño
func mostrar_daño():
	var tween = create_tween()
	# Guardamos el color rojo original que le hayas puesto en el editor
	var color_original = Color(1, 0, 0) # Ajusta este color al rojo exacto de tu barra
	# Parpadea a blanco brillante/dorado instantáneamente
	barra_vida.modulate = Color(2, 2, 2) # Multiplicar por encima de 1 da un efecto de brillo (HDR)
	# Vuelve suavemente a su color rojo en 0.2 segundos
	tween.tween_property(barra_vida, "modulate", color_original, 0.2)
