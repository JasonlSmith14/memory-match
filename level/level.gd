extends Control

var rune_scene = preload("res://rune/rune.tscn")

@export var number_of_runes = 4
var number_of_slots = number_of_runes * 2

const RUNE_THEMES = {
	BLACK = "Black",
	GREY = "Grey",
	BLUE = "Blue"
}

@export var rune_theme := RUNE_THEMES.BLACK

const RUNE_STYLE = {
	RECTANGLE = "Rectangle",
	RECTANGLE_OUTLINE = "Rectangle (outline)",
	SLAB = "Slab",
	SLAB_OUTLINE = "Slab (outline)",
	TILE = "Tile",
	TILE_OUTLINE = "Tile (outline)"
}

@export var rune_style := RUNE_STYLE.RECTANGLE_OUTLINE

var rune_asset_path_placeholder = "res://resources/{rune_theme}/{rune_style}/"
var rune_asset_path = rune_asset_path_placeholder.format({"rune_theme": rune_theme, "rune_style": rune_style})

var back_of_rune_path = rune_asset_path + "back.png"

@onready var back_of_rune_texture = load(back_of_rune_path)

var runes: Array

var previous_rune: TextureButton
var previous_rune_texture: Texture2D
var rune_texture: Texture2D

var score: int = 0
var multiplier: float = 1

func get_files(path: String):
	var dir = DirAccess.open(path)
	if dir:
		return dir.get_files()

func _create_runes(rune):
	var first_rune = rune_scene.instantiate()
	var second_rune = rune_scene.instantiate()
	
	var texture = load(rune_asset_path + rune)
	
	first_rune.front_texture = texture
	second_rune.front_texture = texture
	
	first_rune.back_texture = back_of_rune_texture
	second_rune.back_texture = back_of_rune_texture
	
	runes.append(first_rune)
	runes.append(second_rune)
	
func _ready() -> void:
	$GridContainer.columns = number_of_slots / 4
	$GridContainer.position = get_viewport().get_visible_rect().size  / 2
		
	var file_list = Array(get_files(rune_asset_path)) # These are the images we want to use
	var png_files = file_list.filter(func(f):return f.get_extension().to_lower() == "png" and "back" not in f)
	
	while len(runes) != number_of_slots:
		var rune = png_files[randi_range(0, len(png_files)) - 1]
		if rune not in runes:
			_create_runes(rune)
		#
	runes.shuffle()
	for rune in runes:
		rune.facing_up.connect(_check_runes_match.bind(rune))
		$GridContainer.add_child(rune)
		
func _check_runes_match(rune: TextureButton):
	if previous_rune is not TextureButton:
		previous_rune = rune
		return
	
	previous_rune_texture = previous_rune.texture_normal
	rune_texture = rune.texture_normal
		
	if previous_rune_texture == rune_texture:
		await get_tree().create_timer(0.5).timeout
		previous_rune.disabled = true
		rune.disabled = true
		
		previous_rune.modulate = Color(1, 1, 1, 0.1)
		rune.modulate = Color(1, 1, 1, 0.1)
	
		score += 1 * multiplier
		multiplier *= 2
	elif previous_rune_texture != rune_texture:
		await get_tree().create_timer(0.5).timeout
		previous_rune._on_pressed()
		rune._on_pressed()
		
		multiplier = 1
			
	previous_rune = null

func _process(_delta: float) -> void:
	$ScoreLabel.text = "Score: " + str(score)
	$MultiplierLabel.text = "Multiplier: " + str(multiplier)
