# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D


## Can we move around?
@export var can_move : bool = true

## Are we affected by gravity?
@export var has_gravity : bool = true

## Can we press to jump?
@export var can_jump : bool = true

## Can we hold to run?
@export var can_sprint : bool = false

## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false


@export_group("Speeds")

## Look around rotation speed.
@export var look_speed : float = 0.002

## Normal speed.
@export var base_speed : float = 7.0

## Speed of jump.
@export var jump_velocity : float = 4.5

## How fast do we run?
@export var sprint_speed : float = 10.0

## How fast do we freefly?
@export var freefly_speed : float = 25.0

## Arrow key turning speed
@export var rotation_speed: float = 0.8


@export_group("Input Actions")

@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_freefly : String = "freefly"


# ==================================================
# PLAYER VARIABLES
# ==================================================

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false


# ==================================================
# REFERENCES
# ==================================================

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider


# ==================================================
# READY
# ==================================================

func _ready() -> void:
	check_input_mappings()

	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

	# Start with the mouse visible.
	# Click inside the game to begin looking around.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


# ==================================================
# PROCESS
# ==================================================

func _process(delta: float) -> void:

	# Arrow keys can also rotate the player
	var turn_direction: float = Input.get_axis("ui_right", "ui_left")

	if turn_direction != 0:
		rotate_y(turn_direction * rotation_speed * delta)

		# Keep mouse-look rotation synchronized
		look_rotation.y = rotation.y


# ==================================================
# INPUT
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	# Left click inside game = capture mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not mouse_captured:
				capture_mouse()

	# ESC = release mouse
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			release_mouse()

	# Mouse look
	# This controls BOTH:
	# left/right AND up/down
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):

		if not freeflying:
			enable_freefly()

		else:
			disable_freefly()


# ==================================================
# MOVEMENT
# ==================================================

func _physics_process(delta: float) -> void:

	# FREEFLY
	if can_freefly and freeflying:

		var input_dir := Input.get_vector(
			input_left,
			input_right,
			input_forward,
			input_back
		)

		var motion := (
			head.global_basis *
			Vector3(input_dir.x, 0, input_dir.y)
		).normalized()

		motion *= freefly_speed * delta

		move_and_collide(motion)

		return


	# GRAVITY
	if has_gravity:

		if not is_on_floor():
			velocity += get_gravity() * delta


	# JUMP
	if can_jump:

		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity


	# SPRINT
	if can_sprint and Input.is_action_pressed(input_sprint):

		move_speed = sprint_speed

	else:

		move_speed = base_speed


	# MOVEMENT
	if can_move:

		var input_dir := Input.get_vector(
			input_left,
			input_right,
			input_forward,
			input_back
		)

		var move_dir := (
			transform.basis *
			Vector3(input_dir.x, 0, input_dir.y)
		).normalized()


		if move_dir:

			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed

		else:

			velocity.x = move_toward(
				velocity.x,
				0,
				move_speed
			)

			velocity.z = move_toward(
				velocity.z,
				0,
				move_speed
			)

	else:

		velocity.x = 0
		velocity.z = 0


	move_and_slide()


# ==================================================
# MOUSE LOOK
# ==================================================

func rotate_look(rot_input : Vector2):

	# UP / DOWN
	look_rotation.x -= rot_input.y * look_speed

	# Stop player from flipping camera upside down
	look_rotation.x = clamp(
		look_rotation.x,
		deg_to_rad(-85),
		deg_to_rad(85)
	)


	# LEFT / RIGHT
	look_rotation.y -= rot_input.x * look_speed


	# Rotate player left/right
	transform.basis = Basis()
	rotate_y(look_rotation.y)


	# Rotate head up/down
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


# ==================================================
# MOUSE CAPTURE
# ==================================================

func capture_mouse():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	mouse_captured = true


func release_mouse():

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	mouse_captured = false


# ==================================================
# FREEFLY
# ==================================================

func enable_freefly():

	collider.disabled = true

	freeflying = true

	velocity = Vector3.ZERO


func disable_freefly():

	collider.disabled = false

	freeflying = false


# ==================================================
# INPUT MAPPING CHECK
# ==================================================

func check_input_mappings():

	if can_move and not InputMap.has_action(input_left):

		push_error(
			"Movement disabled. No InputAction found for input_left: "
			+ input_left
		)

		can_move = false


	if can_move and not InputMap.has_action(input_right):

		push_error(
			"Movement disabled. No InputAction found for input_right: "
			+ input_right
		)

		can_move = false


	if can_move and not InputMap.has_action(input_forward):

		push_error(
			"Movement disabled. No InputAction found for input_forward: "
			+ input_forward
		)

		can_move = false


	if can_move and not InputMap.has_action(input_back):

		push_error(
			"Movement disabled. No InputAction found for input_back: "
			+ input_back
		)

		can_move = false


	if can_jump and not InputMap.has_action(input_jump):

		push_error(
			"Jumping disabled. No InputAction found for input_jump: "
			+ input_jump
		)

		can_jump = false


	if can_sprint and not InputMap.has_action(input_sprint):

		push_error(
			"Sprinting disabled. No InputAction found for input_sprint: "
			+ input_sprint
		)

		can_sprint = false


	if can_freefly and not InputMap.has_action(input_freefly):

		push_error(
			"Freefly disabled. No InputAction found for input_freefly: "
			+ input_freefly
		)

		can_freefly = false



var score = 0

@onready var score_label: Label = $"Score Label"

var items_reached = 0

@onready var items_label: Label = $"Items Label"


func add_score():

	score += 1

	score_label.text = (
		"Scores: "
		+ str(score)
		+ "/5"
	)


func add_item():

	items_reached += 1

	items_label.text = (
		"Items: "
		+ str(items_reached)
		+ "/5"
	)

	check_items()


var clear_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_clear/clear_tiles.dialogue"
)

var clear_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_clear/balloon.tscn"
)


var clues4_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_4clues/4clues_tiles.dialogue"
)

var clues4_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_4clues/balloon.tscn"
)


var clues3_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_3clues/3clues_tiles.dialogue"
)

var clues3_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_3clues/balloon.tscn"
)


var clues2_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_2clues/2clues.dialogue"
)

var clues2_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_2clues/balloon.tscn"
)


var clues1_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_1clue/1clue.dialogue"
)

var clues1_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_1clue/balloon.tscn"
)


var clues0_dialogue_resource = preload(
	"res://scenes/tiles_dialogue/tiles_0clue/0clue.dialogue"
)

var clues0_balloon_scene = preload(
	"res://scenes/tiles_dialogue/tiles_0clue/balloon.tscn"
)



@onready var correct_hole: CSGBox3D = $"../Floor/Correct Hole Bottom"

@onready var correct_border: CSGBox3D = $"../Floor/Hole Border"


@onready var clues1_hole: CSGBox3D = $"../Floor/InCorrect Hole #1"
@onready var clues1_border: CSGBox3D = $"../Floor/Hole Border1"


@onready var clues2_hole: CSGBox3D = $"../Floor/InCorrect Hole #2"
@onready var clues2_border: CSGBox3D = $"../Floor/Hole Border2"


@onready var clues3_hole: CSGBox3D = $"../Floor/InCorrect Hole #3"
@onready var clues3_border: CSGBox3D = $"../Floor/Hole Border3"


@onready var clues4_hole: CSGBox3D = $"../Floor/InCorrect Hole #4"
@onready var clues4_border: CSGBox3D = $"../Floor/Hole Border4"


@onready var clues5_hole: CSGBox3D = $"../Floor/InCorrect Hole #5"
@onready var clues5_border: CSGBox3D = $"../Floor/Hole Border5"



func check_items():

	# Player hasn't completed all challenges yet
	if items_reached != 5:
		return


	# Wait until the final challenge dialogue ends
	await DialogueManager.dialogue_ended


	# Correct hole always appears
	correct_hole.visible = true
	correct_border.visible = true


	match score:


		# 5 / 5
		5:

			var balloon = clear_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clear_dialogue_resource,
				"start"
			)


		# 4 / 5
		4:

			var balloon = clues4_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clues4_dialogue_resource,
				"start"
			)

			clues5_hole.visible = true
			clues5_border.visible = true


		# 3 / 5
		3:

			var balloon = clues3_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clues3_dialogue_resource,
				"start"
			)

			clues4_hole.visible = true
			clues4_border.visible = true

			clues5_hole.visible = true
			clues5_border.visible = true


		# 2 / 5
		2:

			var balloon = clues2_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clues2_dialogue_resource,
				"start"
			)

			clues3_hole.visible = true
			clues3_border.visible = true

			clues4_hole.visible = true
			clues4_border.visible = true

			clues5_hole.visible = true
			clues5_border.visible = true


		# 1 / 5
		1:

			var balloon = clues1_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clues1_dialogue_resource,
				"start"
			)

			clues2_hole.visible = true
			clues2_border.visible = true

			clues3_hole.visible = true
			clues3_border.visible = true

			clues4_hole.visible = true
			clues4_border.visible = true

			clues5_hole.visible = true
			clues5_border.visible = true


		# 0 / 5
		0:

			var balloon = clues0_balloon_scene.instantiate()

			get_tree().current_scene.add_child(balloon)

			balloon.start(
				clues0_dialogue_resource,
				"start"
			)

			clues1_hole.visible = true
			clues1_border.visible = true

			clues2_hole.visible = true
			clues2_border.visible = true

			clues3_hole.visible = true
			clues3_border.visible = true

			clues4_hole.visible = true
			clues4_border.visible = true

			clues5_hole.visible = true
			clues5_border.visible = true
