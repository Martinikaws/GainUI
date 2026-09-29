# Colorpicker

> Picks a color with hue, saturation and brightness bars, swatches, or a hex code.

```lua
Tab:Colorpicker({Name, Default?, Flag?, Callback?}) -> Element
```

```lua
Main:Colorpicker({
    Name = "Box color",
    Default = Color3.fromRGB(255, 80, 80), -- or "ff5050"
    Flag = "BoxColor",
    Callback = function(color)
        print(color)
    end,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Default` | Color3 / hex | the accent | The starting color. |
| `Flag` | string | none | Saves the color. |
| `Callback` | function(Color3) | none | Runs with each new color while picking. |

Clicking the swatch opens the picker: drag the **H**, **S** and **V** bars, click one of the ten swatches, or click the hex box and type a code like `ff5050` (then `Enter`). Alias: `ColorPicker`.

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).
