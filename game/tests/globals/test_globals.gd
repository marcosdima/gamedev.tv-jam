extends Control

func _on_globals_pressed() -> void:
	print("Globals:")
	print("Screen Size: " + str(Globals.score))
	print("OS Name: " + str(Globals.player_name))


func _on_palette_pressed() -> void:
	print("Palette Colors:")
	print("BG: " + str(Palette.BG))
	print("Accent: " + str(Palette.PRIMARY))
	print("Highlight: " + str(Palette.ACCENT))
	print("Text: " + str(Palette.TEXT))
