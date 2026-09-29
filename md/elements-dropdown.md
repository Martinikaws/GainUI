# Dropdown

> Picks one option, or several, from a list.

```lua
Tab:Dropdown({Name, Options, Default?, Multi?, Flag?, Callback?}) -> Element
```

```lua
local Mode = Main:Dropdown({
    Name = "Mode",
    Options = {"Legit", "Balanced", "Chaos"},
    Default = "Balanced",
    Flag = "Mode",
    Callback = function(option)
        print("Mode:", option)
    end,
})

-- pick several
Main:Dropdown({
    Name = "Parts",
    Options = {"Head", "Torso", "Arms", "Legs"},
    Multi = true,
    Default = {"Head"},
    Callback = function(list)
        print(table.concat(list, ", "))
    end,
})

-- new options later (for example a player list)
Mode:Refresh({"A", "B", "C"})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | none | The label. |
| `Options` | {string} | `{}` | The choices. |
| `Default` | string / {string} | none | The starting choice (a list with Multi). |
| `Multi` | boolean | `false` | Let users pick several. The value becomes a list. |
| `Flag` | string | none | Saves the choice. |
| `Callback` | function(value) | none | Runs with the choice (or the list) when it changes. |

## Refresh

```lua
Dropdown:Refresh(options: {string}, keep: boolean?)
```

Replaces the options. Unless `keep` is true, the value resets to the first option (or an empty list with Multi).

> **Note:** The list opens under the box (above it near the bottom of the window) and shows seven rows at a time. Drag it or use the arrow keys to scroll. Clicking outside closes it.
