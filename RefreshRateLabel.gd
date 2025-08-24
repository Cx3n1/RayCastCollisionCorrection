extends Label


func _process(delta):
	text = "%s HZ" % Engine.physics_ticks_per_second
