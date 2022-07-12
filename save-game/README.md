# Save game with resources

This project goes with two youtube videos dedicated to saving game data with resources. It shows how to save and load character stats, the player's position on the map, and an inventory. This shows you all the techniques you need to then save and load more complex data.

1. [Godot makes saves so easy!](https://youtu.be/wSq1QJ-g91M)
2. [The Easy Way to Save Games in Godot](https://youtu.be/TGdQ57qCCF0)

![](screenshot.png)

## Who this is for

To read this demo's code, you need to be comfortable with Godot and GDScript.

Resources simplify saving and loading player data, but they also have limitations, as explained below.

Using resources for saving games is something we can recommend to indie developers, especially solo ones or small teams.

The larger and more complex the game, the more you may want to design your own save data format instead.

## How this demo works

You'll find all the resources we save as part of the `SameGame` in the `resources/` folder.

We use the `Game.gd` script to pass resources like the `Inventory` or the `Character` to relevant nodes. Then, when the inventory UI or the character stats UI change a value, it automatically affects the player and the `SaveGame` resource.

## Why not JSON

In the first video, we recommend against using JSON for saved game data. The reason is simple: Godot has really nice built-in features to save and load structured data.

`ConfigFile` or simple text files with the functions `var2str` and `str2var` can do the job for you.

Then, you have the `Resource` file format.

## Using resources for save games

Resources make your save game code really short and offer several advantages over other data formats.

They're powerful when your save data gets a little big and you need some structure.

Advantages over other formats:

- You need little code to make your save game work.
- You get types for better error checks and auto-completion in Godot.
- You can load the data from multiple places in your game, Godot will only load it once.
- You can change data from another place in your code, and it will automatically update in the save game resource.
- You can save the data as text in debug builds and binary in release builds.

Resources have some limitations at the moment.

Caveats:

1. The save file will store paths to the resource scripts to load them back later. So you need to be careful not to move these script files in your project.
2. The same will happen if you reference images and the other resources from your projects. You shouldn't store images or sounds in your save game resources.
3. In Godot 3, there are no typed arrays and dictionaries. If you save an array of resources, you need to be careful when loading them back. You can't use strong typing anymore with the loaded values.
4. Resources, like scene files, can include GDScript code, and they'll run it on instantiation. It's OK if the file lives on the player's computer, but you should not send them over a network for security reasons.
5. You have to be careful with versioning and backwards compatibility.

If you do any of the above, you will get errors when trying to load the saved data.

You can prevent those issues with the following techniques:

- You can store all resource scripts in a folder and never move or rename them. That's how we do it typically.

- Instead of nesting resources, you can use dictionaries and arrays to save data, reducing the number of referenced resource scripts. But you'll lose some auto-completion and error reporting. See this project's `Inventory` resource for an example.

- For versioning, you should try not to change existing variable names but only extend resources. Otherwise, you'll get loading errors. If you absolutely need to make breaking changes to your save game data, you'll want to keep the old script, make a new one, and write some conversion code.

- You should never save any resource that directly holds game data that could change, like file names, the display name of things in the game, and so on. You should use unique ids instead. See the `ItemData` resources in this project for an example. The exception is the resource script files, which we recommend to keep in a fixed directory, like `resources/` or `savegame/`

The last point holds regardless of the data format you use. You should always use unique ids you're certain won't change in your players' saved data.

## How's the performance?

It's plenty fast.

Godot's scene files (tscn) are resources. If you've ever made a huge 2D level, you know that Godot can save and load large resource files like this in a split second.

## Bug in Godot 3.4

In Godot 3.4, resources have a [bug when loading nested resources](https://github.com/godotengine/godot/issues/59686), like for our save game file. Godot will not reload sub-resources as it considers them cached.

Our teammate's already [coded a fix](https://github.com/godotengine/godot/pull/62408) and we're waiting for it to get merged.

In the meantime, you need a workaround you'll find in this demo.

This caching system is what allows you to load resources from anywhere in your projects and only have them loaded once and shared.

There are two workarounds until this bug is fixed:

1. *Don't use sub-resources.* If your game isn't too big, you may consider having all the properties you need in the SaveGame resource, or you could save a handful of resources separately. I haven't pushed this approach, but it could be nice, as it'd allow you to save and load the inventory from the inventory menu, etc. But your save data would be split into multiple files.
2. *Copy the save game file's content* to a temporary file to avoid Godot's cache and force it to load everything.

In this project, we use the second trick, copying the save game file's content. See `SaveGame.gd`'s `load_savegame()` function for the code. Despite this bug, I'd say it's still worth using resources for the code it saves you in the long run and how easy it is to share them in memory.

## Security of resources

Because resources can contain and run code, one last concern is that players could go on the web and download a file with malicious code. Suppose they look for a save game on an untrusted website, download it, and replace their save game with it. That file could technically harm their computer.

The same is true of game mods, which people download massively (Minecraft, Skyrim, The Sims). They can technically run any code on your computer. In that case, the terms of use of your game should just make it clear that the responsibility of modifying the game in any way from non-official sources is at the user's risk. Like most games do.

If, however, you want to ensure your save game and any other user file generated by your player can't run any code, you'll want to use a different format, for instance, your own format using Godot's `ConfigFile`, the `File` API, or a custom resource loader. You shouldn't use any resources, scene files, and perhaps not even the handy `var2str` and `str2var` functions.

Or, if you still want to use resources but guard against code, you could:

1. Open the resource as text first. It won't be able to execute any code like that.
2. Check that the resource has no sub-resource of type GDScript, a script/source property, or an _init() function.
3. If it does, display an error message to the player.

The code would be something like that:

``` gdscript
var file := File.new()
if file.open(SAVE_GAME_PATH, File.READ) != OK:
    return null

var content_as_plain_text := file.get_as_text()
file.close()

if "_init" in content_as_plain_text:
    # You'd probably want to display a popup in-game instead.
    printerr("This save file has been modified to run code. This could potentially harm your computer. Aborting loading.")
    return null
```

Any GDScript code in a resource needs to run through the GDScript compiler to execute. That only happens when loading via Godot's resource loader.

## Preventing the player from editing the save file

Many developers want to prevent players from messing with save files. 

First, please note that there is always a way for tech-savvy people to mess with your game files. People manage to extract data from AAA games with proprietary security. So as a small team or a solo independent developer, you will never be able to prevent that entirely.

Instead of trying to prevent editing save files, what you *can* do is prevent the average player from editing the save file too easily.

There's a simple way to do this with resources: save as binary in the release builds instead of text. All you have to do is change the file extension to `.res` instead of `.tres`.

You can use the `OS.is_debug_build()` function to know if you should save as `.tres` or `.res`:

``` gdscript
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return "user://save" + extension
```

### What about encryption?

Encrypting is another option to prevent editing user files. First, while saving as binary will improve loading speed, using encryption in your game will make things slower because you add an encryption and decryption step to saving and loading. 

This won't be noticeable in a small game, but as your projects and files start to grow in size, you want to be aware of that.

You cannot directly encrypt and decrypt a resource like plain text files in Godot. You have to make a copy of it in a text file. So your code would have to be like:

- Save the resource with `ResourceSaver.save()`.
- Open the saved file with a `File` object.
- Get the file's content and encrypt it with `Crypto.encrypt()`.
- Write the encrypted content to a new file.
- Delete the resource file.

You would have to do something similar when loading. If you really want encryption, perhaps saving and loading the data with `ConfigFile` or another format would be simpler. You can still use resources in your game to achieve that, but delegate the saving and loading part to `ConfigFile`.

Note that encrypting a file doesn't protect it from being opened, and that even if you make a custom Godot build with encrypted scripts. Why? Because to encrypt and decrypt, you need a key (typically a string) and it has to be in a code file somewhere. 

Now, the point is not that encryption isn't useful or good for security reasons, just that in this context, it may not add much benefit to saving the save file as binary.

Learn more: https://docs.godotengine.org/en/stable/development/compiling/compiling_with_script_encryption_key.html

## Rewriting resource paths

In the worst-case scenario, if you **must** move files the save game depends on, you can still fix it.

You can load the player's save as text and rewrite file paths.

Godot's resources have all dependency paths stored at the top, so if you saved the player's save game as text, you could always rewrite faulty paths.

Though we highly recommend never to move the resource files stored in your save game.

This limitation should not be much of an issue in indie game projects. 

For larger teams and game projects, you may want to design your own data format using the built-in functions `str2var()` and `var2str()` instead.
