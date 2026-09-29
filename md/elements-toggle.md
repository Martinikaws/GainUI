# Toggle

> An on/off switch.

```lua
Tab:Toggle({Name, Default?, Flag?, Callback?}) -> Element
```

```lua
local Esp = Main:Toggle({
    Name = "Show names",
    Default = false,
    Flag = "ShowNames",
    Callback = function(on)
        print("Show names:", on)
    end,
})

Esp:Set(true)       -- turn it on from code
print(Esp.Value)    -- true
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Default` | boolean | `false` | The starting state. |
| `Flag` | string | none | Saves the state. See [Saving](https://martinikaws.github.io/GainUI/md/window-saving.md). |
| `Callback` | function(on) | none | Runs with the new state when it changes. |

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).
