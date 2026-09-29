# Saving & Flags

> Give an element a Flag and its value is saved and restored between runs.

```lua
local Window = GainUI:CreateWindow({Title = "My Script", ConfigName = "myscript"})
local Main = Window:Tab("Main")

Main:Toggle({Name = "Enabled", Flag = "Enabled", Callback = function(on) ... end})

-- anywhere later:
if GainUI.Flags.Enabled.Value then ... end
```

## How it works

- With a `ConfigName`, flagged values are written to `GainUI/<ConfigName>.json` in Matcha's workspace, a second after the last change and when the window is destroyed.
- When the script runs again, each flagged element starts from its saved value instead of its `Default`.
- For a restored value, the element's `Callback` runs once on the first frame, so your script applies it just like a click would. Keybinds are the exception: they only fire on a key press.
- The show/hide key, the accent and the mouse offset from the Settings tab are saved too.

## Reading flags

`GainUI.Flags[flag]` (and `Window.Flags[flag]`) is the element itself, so you can read `.Value` or call `:Set()` from anywhere.

```lua
GainUI.Flags.Speed:Set(50)          -- moves the slider and runs its callback
print(GainUI.Flags.Mode.Value)      -- "Balanced"
```

> **Note:** Flags must be unique across windows. Use a prefix like `"MyScript_Speed"` if several scripts share a session.

## What gets saved

| Element | Saved as |
| --- | --- |
| Toggle | true / false |
| Slider | number |
| Dropdown | string, or a list for Multi |
| Textbox | string |
| Keybind | key name, like `"G"` or `"None"` |
| Colorpicker | `{"color": "ff5050"}` |
