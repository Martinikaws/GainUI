# Image

> Shows a picture, downloaded from a link or given as bytes.

```lua
Tab:Image({Url | Data, Height?, Width?}) -> Element
```

```lua
Main:Image({
    Url = "https://example.com/banner.png",
    Height = 120,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Url` | string | none | Downloaded with `game:HttpGet` when the element is made. It shows "Loading..." until the download finishes. |
| `Data` | string | none | The image's bytes, if you already have them (for example from readfile). |
| `Height` | number | `120` | Height in pixels. |
| `Width` | number | page width | Width in pixels, centered. |

> **Warning:** Use PNG or JPG. Matcha's `writefile` refuses the .png extension, so if you cache images in the workspace, save them with another extension like .dat.
