# Stores items' metadata. This kind of metadata will change during development (renaming items, giving them new sprites...)
# so you should never save it in the save game. Instead, you should always work with unique ids that will never change.
class_name ItemData
extends Resource

# We use this unique id to retrieve an item's data and, for example, display it in the inventory.
# See ItemDatabase.gd and Inventory.gd to see how we use this.
@export var unique_id := ""
@export var display_name := ""
@export var description := ""
@export var icon: Texture2D
