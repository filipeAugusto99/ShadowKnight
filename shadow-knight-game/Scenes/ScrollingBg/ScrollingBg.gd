extends Node2D


class_name Background


# Variáveis externas para melhor manipulação do jogo
@export var can_process: bool
@export var layer_speed: Array[int] = []


func _ready() -> void:
	# Se can_process for falso, physics_process para de atuar
	if !can_process:
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	# Para cada index no tamanho total de nós filhos
	for index in range(get_child_count()):
		# layer recebe esse nó e faz algo específico
		# depois itera novamente
		var layer := get_child(index)
		
		# Alterando a velocidade do parallax de cada nó filho
		if layer is Parallax2D:
			layer.autoscroll.x = -layer_speed[index]
