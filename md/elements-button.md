# Button

> Runs a function when clicked.

```lua
Tab:Button({Name, Callback})
```

```lua
Main:Button({
    Name = "Teleport to spawn",
    Callback = function()
        print("clicked")
    end,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Callback` | function() | none | Runs on click, in its own thread, so it can wait. |

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).
