# We use this script to illustrate how someone could upload a save game with
# injected code on a shady website and how that could run code on the users' 
# computers.
#
# That is, if your users download save files on shady websites and then put them
# in your game.
#
# We're adding this example for the sake of being thorough in our presentation
# of resources. It's at least good to know that resources can embed and run code.
# This includes scene files and other resources in Godot and plugins, of course.
#
# This script also shows a way to prevent loading a save in which someo 
# one injected code and reduce risks.
class_name ProtectedSaveGame
extends Resource

const SAVE_GAME_PATH := "user://save.tres"


# The next three functions are just to keep the save API inside of the SaveGame resource.
func write_savegame() -> void:
	ResourceSaver.save(SAVE_GAME_PATH, self)


static func load_savegame(check_for_code_when_loading := false) -> Resource:
	# This block will check for code injected in the file.
	if check_for_code_when_loading:
		var file := File.new()
		if file.open(SAVE_GAME_PATH, File.READ) != OK:
			return null

		# Loading the file as text doesn't parse the code.
		# You can then check the content for code trying to run.
		var content_as_plain_text := file.get_as_text()
		file.close()

		# This is the simplest check I could find, as to run code automatically,
		# it seems you need to make a Resource script with an _init() function.
		# But you may need to check for other patterns like 'type="GDScript"' 
		# or loading of other sub-resources. I'll let you do your research.
		if "_init" in content_as_plain_text:
			# You'd probably want to display a popup in-game instead.
			printerr("This save file has been modified to run code. This could potentially harm your computer. Aborting loading.")
			return null

	return ResourceLoader.load(SAVE_GAME_PATH, "", true)
