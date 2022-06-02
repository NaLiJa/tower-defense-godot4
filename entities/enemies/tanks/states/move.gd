extends "res://entities/enemies/states/move.gd"


func update(delta: float) -> void:
	super.update(delta)
	(owner as Tank).shooter.gun.rotation = lerp_angle(
			(owner as Tank).shooter.gun.rotation, 
			(owner as Tank).velocity.angle(),
			(owner as Tank).shooter.rot_speed * delta)
	if (owner as Tank).is_raycast_colliding():
		emit_signal("finished", "idle")


# Called both when areas and bodies enter the detection radius
func _on_detector_entity_entered(entity: Node2D) -> void:
	if not entity in (owner as Tank).shooter.targets:
		(owner as Tank).shooter.targets.append(entity)
		emit_signal("finished", "shoot")
