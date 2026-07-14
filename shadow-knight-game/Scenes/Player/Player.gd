class_name Player


extends CharacterBody2D


# Constants
#const RUN_SPEED: float = 100.0
#const JUMP_SPEED: float = -280.0
#const MAX_FALL_SPEED: float = 300.0
const GRAVITY: float = 690.0


# Export Variables
@export var run_speed: float = 100.0
@export var jump_speed: float = -280.0
@export var max_fall_speed: float = 300.0
@export var hurt_velocity: Vector2 = Vector2(0.0, -140.0)
@export var camera_left: int = -10000
@export var camera_right: int = 10000
@export var camera_top: int = -10000
@export var camera_bottom: int = 10000


# Onready
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_cam: Camera2D = $PlayerCam
@onready var hurt_timer: Timer = $HurtTimer


# Variables
var _jumped: bool = false
var _start_position: Vector2
var _is_hurt: bool = false


# Variables for animation tree
var is_hurt: bool:
	get: return _is_hurt
var is_still: bool:
	get: return is_zero_approx(velocity.x)
var is_falling: bool:
	get: return velocity.y > 0
var is_ground: bool:
	get: return is_on_floor()


# Manage input unhandled by UI
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		_jumped = true


func _ready() -> void:
	_start_position = position
	set_camera_limits()
	

func set_camera_limits() -> void:
	player_cam.limit_bottom = camera_bottom
	player_cam.limit_left = camera_left
	player_cam.limit_right = camera_right
	player_cam.limit_top = camera_top


# This function is calleble frame by frame
func _physics_process(delta: float) -> void:
	# For the play fall down with gravity
	velocity.y += GRAVITY * delta
	# Func for moviment of the player
	handle_moviment()
	# Func for flip the sprite of the player
	flip_sprite()
	# This native func of godot app a linear velocity in the character/object and move that. if 
	# the character collid in other object, the method move_and_slide detect this too.
	move_and_slide()


func handle_moviment() -> void:
	if _is_hurt: return
	horizontal_moviment()
	vertical_moviment()
	
	# Velocity in Y receive the minf
	velocity.y = minf(velocity.y, max_fall_speed)


# Manage the horizontal moviment
func horizontal_moviment() -> void:
	# Velocity in x receivei Input.get_axis -> negative and positive values
	# this code is responsable for direction of the character
	var input_direction = Input.get_axis("left", "right")
	velocity.x = input_direction * run_speed


# Manage the vertical moviment
func vertical_moviment() -> void:
	# If the player is in the on the floor and the variable _jumped is true, so JUMP!
	if is_on_floor() and _jumped:
		# Velocity in y receive the const JUMP_SPEED
		velocity.y = jump_speed
		# the variable _jumped receive the original pattern
		_jumped = false


func flip_sprite() -> void:
	# if my velocity in x is different 0 or almost 0, flip the image
	if not is_zero_approx(velocity.x):
		sprite_2d.flip_h = velocity.x < 0


func fell_off() -> void:
	position = _start_position
	set_position.call_deferred(_start_position)


func apply_hurt_jump() -> void:
	if _is_hurt: return
	_is_hurt = true
	hurt_timer.start()
	velocity = hurt_velocity
	

func _on_hit_area_entered(area: Area2D) -> void:
	apply_hurt_jump.call_deferred()
	

func _on_hurt_timer_timeout() -> void:
	_is_hurt = false
