class_name Projectile
extends Area2D
# This class extends the Area2D node because we don't need advanced
# physics or player-controlled movement.
# It also uses a VisibleOnScreenEnabler2D node to disable this scene 
# when the projectile exits the screen.
# WARN: this is probably not optimal due to the presence of a camera
# Its parameters, such as collision_mask, speed and damage are passed to
# the "start" method by parent Shooter scenes.


var speed: int
var damage: int
var velocity: Vector2
var target  # homing missiles only

@onready var sprite := $Sprite2D as Sprite2D
@onready var hit_vfx := $HitVfx as AnimatedSprite2D
@onready var collision_shape := $CollisionShape2D as CollisionShape2D


func _ready() -> void:
	hit_vfx.hide()


func _physics_process(delta: float) -> void:
	global_position += velocity * delta


# Called by the turret, which instantiates a projectile and (optionally)
# gives it a target
func start(_position: Vector2, _rotation: float, _speed: int, _damage: int, _target=null) -> void:
	global_position = _position
	rotation = _rotation
	speed = _speed
	damage = _damage
	target = _target
	velocity = Vector2.RIGHT.rotated(_rotation) * speed


# Each child of this scene will have a different collision mask.
# Thus we can be sure the right method will be triggered by each instance
func _on_projectile_body_entered(body: Node2D) -> void:
	if body is Enemy:
		(body.get_fsm() as EnemyFSM).is_hit(damage)
		_explode()
	elif body.has_method("take_damage"):
		body.take_damage(damage)
		_explode()


# See comment on the method above
func _on_projectile_area_entered(area: Area2D) -> void:
	if area is Objective:
		(area as Objective).take_damage(damage)
		_explode()


func _explode() -> void:
	# stop the bullet and disable collision
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	# play vfx
	sprite.hide()
	hit_vfx.frame = 0
	hit_vfx.show()
	hit_vfx.play("hit")


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func _on_hit_vfx_animation_finished() -> void:
	queue_free()
