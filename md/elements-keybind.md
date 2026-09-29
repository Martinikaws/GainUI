# Keybind

> A key users can rebind, which runs your function when pressed.

```lua
Tab:Keybind({Name, Default?, Mode?, Flag?, Callback?, Changed?}) -> Element
```

```lua
Main:Keybind({
    Name = "Toggle fly",
    Default = "F",
    Mode = "Toggle",
    Flag = "FlyKey",
    Callback = function(state)
        print("Fly:", state)
    end,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Default` | key | none | The starting key, like `"F"` or `"LeftAlt"`. See [Key names](https://martinikaws.github.io/GainUI/md/guides-keys.md). |
| `Mode` | string | `"Press"` | `"Press"`: runs on each press. `"Toggle"`: flips a state on each press and passes it. `"Hold"`: passes `true` on press and `false` on release. |
| `Flag` | string | none | Saves the key. |
| `Callback` | function(state?) | none | Runs on the key, as described in Mode. |
| `Changed` | function(keyName) | none | Runs when the user rebinds it, with the new key's name (or `"None"`). |

## Rebinding

Click the key chip, then press a key. `Esc` cancels and `Backspace` clears it to None. Keybinds work while the window is hidden, but not while typing in a text box.

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).
