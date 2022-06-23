# Save game with resources

This project goes with two youtube videos dedicated to saving game data with resources.

1. [Godot makes saves so easy!](https://youtu.be/wSq1QJ-g91M)
2. [The easy and robust way to save games in Godot]()

## Who this is for

Resources simplify saving and loading player data, but they also have limitations, as explained below.

Using resources for save games is something we can recommend to indie developers, especially solo ones or small teams.

The larger and more complex the game, the more you may want to design your own save data format instead.

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

1. The save file will store paths to the resources' scripts to later load them back. So you need to be careful not to move these script files in your projects.
2. The same will happen if you reference images and the other resources from your projects. You shouldn't store images or sounds in your save game resources.
3. In Godot 3, there are no typed arrays and dictionaries. If you save an array of resources you need to be careful when loading them back. You can't use strong typing anymore with the loaded values.

If you do any of the above, you will get errors when trying to load the saved data.

You can prevent those issues with the following techniques:

- You can store all saved resources in a folder and never move or rename them. That's how we do it typically.

- Instead of nesting resources, you can use dictionaries and arrays to save data, reducing the number of referenced resource scripts. But you'll lose some auto-completion and error reporting. See this project's `Inventory` resource for an example.

- You should never save any resource that directly holds your game data, like file names, the display name of things in the game, and so on. You should use unique ids instead. See the `ItemData` resources in this project for an example.

The last point holds true regardless of the data format you use. You should always use unique ids you're certain won't change in your players' saved data.

## Rewriting resource paths

In the worst-case scenario, if you **must** move files the save game depends on, you can still fix it.

You can load the player's save as text and rewrite file paths.

Godot's resources have all dependency paths stored at the top, so if you saved the player's save game as text, you could always rewrite faulty paths.

Though we highly recommend never to move the resource files stored in your save game.

This limitation should not be much of an issue in indie game projects. 

For larger teams and game projects, you may want to design your own data format using the built-in functions `str2var()` and `var2str()` instead.
