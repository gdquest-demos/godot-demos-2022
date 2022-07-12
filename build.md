# Build the Demos

## Requirements

The build system finds all the `project.godot` files in sub-directories, then:

- extracts `title` and `description` from `project.godot`.
- extracts longer description from co-located `README.md`.
- uses `icon.png` as the project's icon.
- Optional: checks and loads a `videos.yaml` file if it exists.

The `videos.yaml` file looks like so:

```yaml
videos:
 - id
 - id
 - ...
```

where "id" is a youtube video id.

You also need a `demos-cover.png` image at the root.

Once all of this is ready, running `./run build` will create the files in the `./build` directory.

## Templates

The build system uses `pandoc`, and the template are found in `.github/templates`.

Additionally to traditional pandoc variables, we add:

- `type`: `listing` or `project`.
- `is_project`: a boolean set to `true` if we're generating a project.
- `url`: the website's url.
- `favicon`: the favicon's location.
- `description`: a short description for embeds.
- `image`: an image for embeds.
- `filename`: filename of the project's zip file.


## Itch Support

Suppose your repository is `gdquest.itch.io/demos2022`.

To upload to itch, you need the following env variables:

- `ITCHIO_USERNAME="gdquest"`
- `ITCHIO_GAME="demos2022"`
- `BUTLER_API_KEY="<api key >"`
  
The api key can be found on https://itch.io/user/settings/api-keys.

To build and push to itch, run `./run build itch`.
