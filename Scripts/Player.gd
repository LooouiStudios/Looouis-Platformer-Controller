# Loui Platformer Controller
# Assets: https://arks.itch.io/dino-characters

# Hi! This is a platformer controller I recently made which I think feels really good to play.
# It has a lot of variables to play around with to make your movement feel as good as possible.
# If you use this feel free to credit me. Use this as you wish :D
extends CharacterBody2D

@onready var sprite_flip = get_node("Flip")
@onready var sprite_anim = get_node("Animation Players/Sprite")
@onready var squash_stretch_anim = get_node("Animation Players/Squash-Stretch")

var move_speed = 80
var acceleration = 400
var friction = 400

var gravity = 15
var up_gravity_multiplier = 0.8
var down_gravity_multiplier = 1.6

var jump_height = 320

var hit_floor = false

var cayote_time = 0.1
var jump_buffer = 0.12

var last_grounded = 1.0
var last_jump = 1.0

func _physics_process(delta):
	apply_horizontal_movement(delta)
	apply_gravity()
	squash_stretch()
	check_jump(delta)
	
	move_and_slide()

func apply_horizontal_movement(delta):
	var horizontal_input = Input.get_axis("move_left", "move_right")
	if horizontal_input != 0:
		velocity = velocity.move_toward(Vector2(horizontal_input, 0) * move_speed, acceleration * delta)
		sprite_anim.play("walk")
		
		var tween = get_tree().create_tween()
		tween.tween_property(sprite_flip, "scale:x", horizontal_input, 0.05)
	else:
		velocity = velocity.move_toward(Vector2(), friction * delta)
		sprite_anim.play("idle")

func apply_gravity():
	var multiplier = up_gravity_multiplier if velocity.y < 0 else down_gravity_multiplier
	var anim = "jump" if velocity.y < 0 else "fall"
	if !is_on_floor(): sprite_anim.play(anim)
	velocity.y += gravity * multiplier 
	

func check_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor(): velocity.y -= jump_height
		elif last_grounded < cayote_time: velocity.y -= jump_height
		else: last_jump = 0
	
	if is_on_floor():
		if last_jump < jump_buffer: velocity.y -= jump_height
		last_grounded = 0
	
	last_grounded += delta
	last_jump += delta

func squash_stretch():
	if is_on_floor():
		if !hit_floor:
			squash_stretch_anim.play("squash")
			hit_floor = true
	else:
		var anim = "jump" if velocity.y < 0 else "stretch"
		squash_stretch_anim.play(anim)
		hit_floor = false
