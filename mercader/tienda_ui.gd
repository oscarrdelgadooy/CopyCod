extends CanvasLayer

@onready var jugador = get_tree().current_scene.find_child("Player", true, false)

# --- RUTAS A LOS BOTONES DE COMPRA (DERECHA) ---
@onready var panel = $FondoTienda
@onready var boton_cerrar = $FondoTienda/CloseButton
@onready var boton_dano = $FondoTienda/VBoxContainer/FilaDamage/BotonDamage
@onready var boton_velocidad = $FondoTienda/VBoxContainer/FilaVelocidad/BotonVelocidad
@onready var boton_cadencia = $FondoTienda/VBoxContainer/FilaCadencia/BotonCadencia
@onready var boton_vida = $FondoTienda/VBoxContainer/FilaVida/BotonVida

# --- NUEVAS RUTAS A LOS TEXTOS DE DESCRIPCIÓN (IZQUIERDA) ---
@onready var label_dano = $FondoTienda/VBoxContainer/FilaDamage/LabelDamage
@onready var label_velocidad = $FondoTienda/VBoxContainer/FilaVelocidad/LabelVelocidad
@onready var label_cadencia = $FondoTienda/VBoxContainer/FilaCadencia/LabelCadencia
@onready var label_vida = $FondoTienda/VBoxContainer/FilaVida/LabelVida

# --- PRECIOS BASE ---
var precio_dano: int = 10
var precio_velocidad: int = 8
var precio_cadencia: int = 12
var precio_vida: int = 5

func _ready() -> void:
	self.visible = false
	
	# Conexión automática de señales por código
	if boton_cerrar: boton_cerrar.pressed.connect(cerrar)
	if boton_dano: boton_dano.pressed.connect(_on_boton_dano_pressed)
	if boton_velocidad: boton_velocidad.pressed.connect(_on_boton_velocidad_pressed)
	if boton_cadencia: boton_cadencia.pressed.connect(_on_boton_cadencia_pressed)
	if boton_vida: boton_vida.pressed.connect(_on_boton_vida_pressed)
		
	actualizar_textos()

func abrir() -> void:
	self.visible = true
	actualizar_textos()

func cerrar() -> void:
	self.visible = false

func _input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed("ui_cancel"):
		cerrar()

# --- LÓGICA VISUAL CO COORDINADA ---
func actualizar_textos() -> void:
	# 1. Rellenamos las descripciones de la izquierda
	if label_dano: label_dano.text = "Balas de Punta Hueca (+5 Daño)"
	if label_velocidad: label_velocidad.text = "Zapatillas Ligeras (+20 Vel.)"
	if label_cadencia: label_cadencia.text = "Gatillo Sensible (-0.04s Cooldown)"
	if label_vida: label_vida.text = "Botiquín Médico (Curar al 100%)"

	# 2. Rellenamos los precios dentro de los botones de la derecha
	if boton_dano:
		boton_dano.text = str(precio_dano) + " Monedas"
	if boton_velocidad:
		boton_velocidad.text = str(precio_velocidad) + " Monedas"
	if boton_vida:
		boton_vida.text = str(precio_vida) + " Monedas"
		
	if boton_cadencia:
		if jugador and jugador.shoot_cooldown > 0.06:
			boton_cadencia.text = str(precio_cadencia) + " Monedas"
		else:
			boton_cadencia.text = "MÁXIMO"
			boton_cadencia.disabled = true

# --- LÓGICA DE COMPRAS ---
func _on_boton_dano_pressed() -> void:
	if jugador and "coins" in jugador and jugador.coins >= precio_dano:
		jugador.coins -= precio_dano
		jugador.damage += 5
		precio_dano = int(precio_dano * 1.5)
		actualizar_textos()
	else:
		print("Monedas insuficientes.")

func _on_boton_velocidad_pressed() -> void:
	if jugador and "coins" in jugador and jugador.coins >= precio_velocidad:
		jugador.coins -= precio_velocidad
		jugador.speed += 20.0
		precio_velocidad = int(precio_velocidad * 1.5)
		actualizar_textos()
	else:
		print("Monedas insuficientes.")

func _on_boton_cadencia_pressed() -> void:
	if jugador and "coins" in jugador and "shoot_cooldown" in jugador:
		if jugador.shoot_cooldown > 0.06:
			if jugador.coins >= precio_cadencia:
				jugador.coins -= precio_cadencia
				jugador.shoot_cooldown -= 0.04
				precio_cadencia = int(precio_cadencia * 1.6)
				actualizar_textos()
			else:
				print("Monedas insuficientes.")

func _on_boton_vida_pressed() -> void:
	if jugador and "coins" in jugador and "current_health" in jugador:
		if jugador.current_health < jugador.max_health:
			if jugador.coins >= precio_vida:
				jugador.coins -= precio_vida
				jugador.current_health = jugador.max_health
				precio_vida += 2
				actualizar_textos()
			else:
				print("Monedas insuficientes.")
		else:
			print("Ya tienes la vida al máximo.")
