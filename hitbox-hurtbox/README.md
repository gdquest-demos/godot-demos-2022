# Hit and hurt boxes

This demo shows how to work with what we call hit and hurt boxes.

To detect interactions in games, we generally use simple geometry: boxes, capsules, circles, polygons. In godot, we achieve that with area nodes.

You can use area nodes for many tasks like interacting with a door, a chest, collecting a pick-up, or dealing and receiving damage. 

The role of a hit box is to deal damage to something that has one or more hurt boxes. The hit box represents the part of a weapon that deals damage while the hurt box represents the part of a character that can receive damage.

## Controls

- <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>: move the sword.
- <kbd>Space</kbd>: attack.
- Click and drag on collision shapes to move them.
- Click and drag on the speed slider to change the animation speed.
