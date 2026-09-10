extends Node3D
class_name SmashProjectile

var target = null
var ammo_type = 0
var controller = null
var destination = Vector3.ZERO
var direction = Vector3.ZERO

func launch(start_position, end_position, shot_color, hit_target, kind, owner_controller):
	global_position = start_position
	destination = end_position
	target = hit_target
	ammo_type = kind
	controller = owner_controller
	direction = (end_position - start_position).normalized()
	look_at(end_position, Vector3.UP)
	_build_visual(shot_color)
	var distance = start_position.distance_to(end_position)
	var duration = clamp(distance / 32.0, 0.12, 0.24)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", end_position, duration)
	tween.tween_callback(_impact)

func _build_visual(color):
	var glow = OmniLight3D.new()
	glow.light_color = color
	glow.light_energy = 2.2
	glow.omni_range = 2.0
	add_child(glow)

	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.2
	mat.roughness = 0.18
	mesh.material_override = mat
	add_child(mesh)

	for i in range(4):
		var tail = MeshInstance3D.new()
		var tail_sphere = SphereMesh.new()
		tail_sphere.radius = 0.07 - float(i) * 0.010
		tail_sphere.height = tail_sphere.radius * 2.0
		tail.mesh = tail_sphere
		tail.position = Vector3(0, 0, 0.17 + float(i) * 0.12)
		if ammo_type == 3:
			var wild_mat = StandardMaterial3D.new()
			var rainbow = [Color("ff6a67"),Color("ffcb52"),Color("58c7ff"),Color("ad63ff")]
			wild_mat.albedo_color = rainbow[i % rainbow.size()]
			wild_mat.emission_enabled = true
			wild_mat.emission = wild_mat.albedo_color
			wild_mat.emission_energy_multiplier = 2.0
			tail.material_override = wild_mat
		else:
			tail.material_override = mat
		add_child(tail)

func _impact():
	if controller:
		controller.on_projectile_impact(destination, ammo_type)
	if is_instance_valid(target) and target.has_method("shoot"):
		target.shoot(ammo_type, destination, direction)
	queue_free()
