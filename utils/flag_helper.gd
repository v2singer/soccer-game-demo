class_name FlagHelper

static var flag_textures : Dictionary[String, Texture2D]= {}


static func get_texture(country: String) -> Texture2D:
	if not flag_textures.has(country):
		var flag_path = "res://assets/art/ui/flags/flag-%s.png" % [country.to_lower()]
		flag_textures.set(country, load(flag_path))
	return flag_textures[country]
