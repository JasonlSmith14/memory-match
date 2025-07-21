extends TextureButton

signal facing_up

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var front_texture: Texture2D
@export var back_texture: Texture2D

func _ready():
	texture_normal = back_texture
	
func _on_pressed() -> void:
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("flip")
		
func swap_texture():
	match texture_normal:
		front_texture:
			texture_normal = back_texture
		back_texture:
			texture_normal = front_texture
			emit_signal("facing_up")
