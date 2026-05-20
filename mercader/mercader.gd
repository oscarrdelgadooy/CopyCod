extends Node2D

@onready var label_ayuda = $Label
@onready var tienda = get_tree().current_scene.find_child("TiendaUI", true, false)

# Importante: Asegúrate de que el nodo de tus animaciones se llama así en tu escena
@onready var sprite = $AnimatedSprite2D 

var jugador_cerca: bool = false

func _ready():
	if has_node("ZonaInteraccion"):
		$ZonaInteraccion.body_entered.connect(_on_body_entered)
		$ZonaInteraccion.body_exited.connect(_on_body_exited)
	
	# Por defecto, nos aseguramos de que empiece apagado al cargar el mapa
	desaparecer()

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		if label_ayuda:
			label_ayuda.visible = true
			
		# ¡Saluda al jugador cuando entra en su zona!
		if sprite:
			sprite.play("dialogue")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		if label_ayuda:
			label_ayuda.visible = false
			
		# Vuelve a su estado de espera cuando el jugador se aleja
		if sprite:
			sprite.play("idle")

func _process(_delta):
	# Si no somos visibles, bloqueamos interacciones
	if not self.visible:
		return
		
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if tienda and not tienda.visible:
			tienda.abrir()
			
			# ¡Hace una animación de aprobación cuando le vas a comprar algo!
			if sprite:
				sprite.play("approval")

# --- INTERRUPTORES DE CONTROL SEGUROS ---

func aparecer():
	self.visible = true
	
	# Encendemos las colisiones físicas de forma segura
	if has_node("ZonaInteraccion"):
		$ZonaInteraccion.set_deferred("monitoring", true)
		$ZonaInteraccion.set_deferred("monitorable", true)
		
	# Seleccionamos un "Idle" aleatorio cada vez que aparece en una nueva ronda
	if sprite:
		var animaciones_idle = ["idle", "idle_2", "idle_3"]
		sprite.play(animaciones_idle.pick_random())
		
	print("Mercader activo en el mapa.")

func desaparecer():
	self.visible = false 
	
	# Apagamos las colisiones físicas por completo
	if has_node("ZonaInteraccion"):
		$ZonaInteraccion.set_deferred("monitoring", false)
		$ZonaInteraccion.set_deferred("monitorable", false)
		
	# Limpiamos el estado
	jugador_cerca = false
	if label_ayuda:
		label_ayuda.visible = false
		
	# Detenemos la animación para ahorrar recursos mientras está invisible
	if sprite:
		sprite.stop()
		
