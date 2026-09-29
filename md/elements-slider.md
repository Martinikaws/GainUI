# Slider

> Picks a number in a range by dragging.

```lua
Tab:Slider({Name, Min, Max, Default?, Increment?, Suffix?, Flag?, Callback?}) -> Element
```

```lua
Main:Slider({
    Name = "Field of view",
    Min = 70,
    Max = 120,
    Default = 90,
    Increment = 1,
    Suffix = "°",
    Flag = "FOV",
    Callback = function(v)
        print("FOV:", v)
    end,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Min` | number | `0` | The lowest value. `Range = {min, max}` works too. |
| `Max` | number | `100` | The highest value. |
| `Default` | number | `Min` | The starting value. |
| `Increment` | number | `1` | Step size. Use `0.1` or `0.01` for decimals. |
| `Suffix` | string | none | Shown after the value, like `" studs"` or `"%"`. |
| `Flag` | string | none | Saves the value. |
| `Callback` | function(value) | none | Runs with each new value while dragging. |

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).

> **Note:** `:Set(v)` clamps to the range and rounds to the increment.
