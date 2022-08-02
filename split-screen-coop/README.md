# Split-screen co-op

This demo shows how to set up viewports and viewport containers for split-screen co-op gameplay.

The demo uses a 2D game as an example, but it works the same in 3D.

![](split-screen-screenshot.png)

The steps, in short:

- Use variables or resources instead of hard-coded input actions to control characters. That way, you can give each player different controls.
- Create a `Viewport` in a `ViewportContainer` for each player. The `ViewportContainer` allows you to display a viewport on the screen and resize it automatically.
- Instantiate your full game level as a child of the first viewport.
- Create one camera in each viewport to render different views of your game level.
- Viewports have a world property that controls what they render (`world` for 3D and `world_2d` for 2D). You need to share the first viewport's world with other viewports for every view to display the same level. You can do so with code.
- Finally, to control the different cameras, you create a remote transform node as a child of each character and make it target the matching camera.
