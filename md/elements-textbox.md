# Textbox

> Lets users type text.

```lua
Tab:Textbox({Name, Placeholder?, Default?, Numeric?, ClearOnFocusLost?, Flag?, Callback?}) -> Element
```

```lua
Main:Textbox({
    Name = "Player name",
    Placeholder = "Type and press Enter",
    Flag = "Target",
    Callback = function(text)
        print("Target:", text)
    end,
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Placeholder` | string | `""` | Grey text while it's empty. |
| `Default` | string | `""` | The starting text. |
| `Numeric` | boolean | `false` | Only keep a number (anything else becomes empty). |
| `ClearOnFocusLost` | boolean | `false` | Empty the box after each entry, for command-style input. |
| `Flag` | string | none | Saves the text. |
| `Callback` | function(text) | none | Runs when typing ends: `Enter`, `Esc`, or clicking somewhere else. |

Returns the element. Keep it to change it later: `:Set(value)`, `:Get()`, `.Value`; see [Element methods](https://martinikaws.github.io/GainUI/md/elements-methods.md).

> **Note:** While a box is focused, typing goes to it and not to the game, and the show/hide key doesn't work. Letters, digits, space and common symbols are supported, with `Shift` for capitals; hold `Backspace` to delete quickly.
