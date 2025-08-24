extends Node3D

@export var main_body: RigidBody3D
@export var collision_ray : RayCast3D

@export var detection_ball : MeshInstance3D
@export var label : Label3D

var given_collision_point : Vector3
var corrected_collision_point : Vector3

func _input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		Engine.time_scale = 3
	elif event.is_action_released("ui_accept"):
		Engine.time_scale = 1


func _process(delta) -> void:
	if given_collision_point == null || corrected_collision_point == null:
		return
	DebugDraw3D.draw_line(collision_ray.global_position, given_collision_point, Color.RED)
	DebugDraw3D.draw_line(collision_ray.global_position, corrected_collision_point, Color.GREEN)
	detection_ball.global_position = given_collision_point
	label.text = "Speed: %s m/s\nDelta: %s" % [
			round_to_significant_digits(main_body.linear_velocity.length(), 2),
			round_to_significant_digits((corrected_collision_point-given_collision_point).length(), 2)]



func _physics_process(delta) -> void:
	if collision_ray.is_colliding():
		var collision_point = collision_ray.get_collision_point()
		var collision_point_to_body = collision_ray.global_position - collision_point
		
		var ray_normal = collision_ray.to_global(Vector3.DOWN) - collision_ray.global_position
		
		var projected_length = ray_normal.dot(-collision_point_to_body)
		var corrected_point = projected_length*ray_normal + collision_ray.global_position
		
		given_collision_point = collision_point
		corrected_collision_point = corrected_point
	
	var input = get_input_direction()
	var input_force = Vector3(input, 0, 0)*1000
	
	main_body.apply_central_force(input_force*delta)


## function form
## given collision_ray it will calculate corrected collision point aligned to ray cast
static func get_corrected_collision_point(collision_ray: RayCast3D) -> Vector3:
	var collision_point_to_body = collision_ray.global_position - collision_ray.get_collision_point()
	
	var ray_normal = collision_ray.to_global(Vector3.DOWN) - collision_ray.global_position
	
	var projected_length = ray_normal.dot(-collision_point_to_body)
	var corrected_point = projected_length*ray_normal + collision_ray.global_position
	
	return corrected_point


func round_to_significant_digits(value: float, digits: int) -> float:
	if value == 0:
		return 0.0
	var scale = pow(10, digits - ceil(log(abs(value))/log(10)))
	return round(value * scale) / scale


func get_input_direction() -> float:
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	return dir
