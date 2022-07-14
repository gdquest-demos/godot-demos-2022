# Save game with resources

This project goes with two youtube videos about managing save game data with resources.

It shows how to save and load character stats, the player's position on the map, and an inventory, with two approaches:

1. The first demo uses the built-in resource saving and loading mechanism. This has security limitations, meaning if players download a save file shared on the internet, it could contain malicious code.
2. In the second demo, we use a similar setup using resources at runtime, but we save and load the data using JSON files.

This shows you all the techniques you need to then save and load more complex data.

1. [Godot makes saves so easy!](https://youtu.be/wSq1QJ-g91M)
2. [The Easy Way to Save Games in Godot](https://youtu.be/TGdQ57qCCF0)

![](screenshot.png)

## Who this is for

To read this demo's code, you need to be comfortable with Godot and GDScript.

Resources simplify saving and loading player data, but they also have limitations and security issues, as explained below.

We can recommend the code we use in the saving with JSON demo to indie developers, especially solo ones or small teams.

The larger and more complex the game, the more you may want to design your own save data format or perhaps use a database instead.

## How this demo works

You'll find all the resources we save as part of the `SameGame` in the `resources/` folder.

We use the `GameSaveAsResourceDemo.gd` and `SaveAsJSONDemo.gd` scripts to pass resources like the `Inventory` or the `Character` to relevant nodes.

Then, when the inventory UI or the character stats UI change a value, it automatically affects the player and the save game simultaneously.

## JSON or not JSON

In the first video, we recommend against using JSON for saved game data.

But in the end, it turned out that almost every built-in mechanism to save and load data isn't secure. 

And so if you care about preventing arbitrary code execution (including `ConfigFile` in Godot 3), you must save and load the game using formats like JSON, XML, or your own. 

In any of those cases, you shouldn't use functions like `var2str` and `str2var` as they have this issue, but you may use their binary equivalent `var2bytes` and `bytes2var`, which prevent code execution by default.

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
4. You have to be careful with versioning and backward compatibility.

If you do any of the above, you will get errors when trying to load the saved data.

You can prevent those issues with the following techniques:

- You can store all resource scripts in a folder and never move or rename them. That's how we do it typically.

- Instead of nesting resources, you can use dictionaries and arrays to save data, reducing the number of referenced resource scripts. But you'll lose some auto-completion and error reporting. See this project's `Inventory` resource for an example.

- For versioning, you should try not to change existing variable names but only extend resources. Otherwise, you'll get loading errors. If you absolutely need to make breaking changes to your save game data, you'll want to keep the old script, make a new one, and write some conversion code.

- You should never save any resource that directly holds game data that could change, like file names, the display name of things in the game, and so on. You should use unique ids instead. See the `ItemData` resources in this project for an example. The exception is the resource script files, which we recommend keeping in a fixed directory, like `resources/` or `savegame/`

The last point holds regardless of the data format you use. You should always use unique ids you're certain won't change in your players' saved data.

## Arbitrary code execution

Resources, like scene files, can include GDScript code, and they'll run it on instantiation.

It's OK if the file lives on the player's computer, but you should not send them over a network for security reasons.

It also means players downloading resources from untrusted sources and putting them into the game expose themselves to security issues. Someone could purposefully add malicious code to a resource file and share it online.

Considering that, we can recommend resources for plugins and generating data files in the game project, but we would recommend using a safer data format for player saves or settings.

We included a scene that shows how to use JSON in the demo.

## How's the performance?

It's plenty fast.

Godot's scene files (tscn) are resources. If you've ever made a huge 2D level, you know that Godot can save and load large resource files like this in a split second.

## Bug in Godot 3.4

In Godot 3.4, resources have a [bug when loading nested resources](https://github.com/godotengine/godot/issues/59686), like for our save game file. Godot will not reload sub-resources as it considers them cached.

Our teammate's already [coded a fix](https://github.com/godotengine/godot/pull/62408), and we're waiting for it to get merged.

In the meantime, you need a workaround you'll find in this demo.

This caching system is what allows you to load resources from anywhere in your projects and only have them loaded once and shared.

There are two workarounds until this bug is fixed:

1. *Don't use sub-resources.* If your game isn't too big, you may consider having all the properties you need in the SaveGame resource, or you could save a handful of resources separately. I haven't pushed this approach, but it could be nice, as it'd allow you to save and load the inventory from the inventory menu, etc. But your save data would be split into multiple files.
2. *Copy the save game file's content* to a temporary file to avoid Godot's cache and force it to load everything.

In this project, we use the second trick, copying the save game file's content. See `SaveGame.gd`'s `load_savegame()` function for the code. Despite this bug, I'd say it's still worth using resources for the code it saves you in the long run and how easy it is to share them in memory.

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

Another safer option would be to save your data as binary using `var2bytes`.

### Using encryption?

Encrypting is another option to prevent editing user files.

First, while saving as binary will improve loading speed, using encryption in your game will make things slower because you add an encryption and decryption step to saving and loading. 

This won't be noticeable in a small game, but as your projects and files start to grow in size, you may want to be aware of that.

You cannot directly encrypt and decrypt a resource like plain text files in Godot.

When saving JSON or plain text data with a `File` object, you need to call `File.open_encrypted()` instead of `File.open()`.

You pass the function a key to encrypt and decrypt the data.

Now, that key will be in your scripts, so anyone who looks beyond the save file can find it.

You could take it a step further and compile a custom Godot build with script encryption, making it harder to find the encryption key (but not impossible).

Learn more: https://docs.godotengine.org/en/stable/development/compiling/compiling_with_script_encryption_key.html
