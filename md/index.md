# Getting Started

> A drawn GUI library for Matcha. Build a Gain-style window with tabs, toggles, sliders, dropdowns and keybinds in a few lines.

## Install

Load the library at the top of your script. There's nothing to download: it always runs the latest version from GitHub.

```lua
local GainUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/GainUI.lua"))() or _G.GainUI
```

> **Note:** Why `or _G.GainUI`? Matcha's `loadstring` drops return values, so GainUI also puts itself in `_G.GainUI`. This line works in Matcha and in executors that do return.

## Your first window

```lua
local GainUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/GainUI.lua"))() or _G.GainUI

local Window = GainUI:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0",
    ConfigName = "myscript", -- remembers every flagged value between runs
})

local Main = Window:Tab("Main")
Main:Section("General")

Main:Toggle({
    Name = "Enabled",
    Default = false,
    Flag = "Enabled",
    Callback = function(on)
        print("Enabled:", on)
    end,
})

Main:Slider({Name = "Walk speed", Min = 16, Max = 100, Default = 16, Suffix = " studs", Flag = "Speed",
    Callback = function(v) print(v) end})

Main:Button({Name = "Hello", Callback = function()
    Window:Notify({Title = "Hello!", Content = "It works."})
end})
```

Press `Right Shift` to show or hide the window. Drag it by the title. Every window also gets a **Settings** tab, where users can change the show/hide key and the accent color and unload the script.

## Next steps

- [Window](https://martinikaws.github.io/GainUI/md/window-create.md): Title, size, accent, keys and saving.
- [Elements](https://martinikaws.github.io/GainUI/md/elements-toggle.md): Every control you can put in a tab.
- [Matcha notes](https://martinikaws.github.io/GainUI/md/guides-matcha.md): What the library does for you, and its limits.
- [Full example](https://martinikaws.github.io/GainUI/md/start-example.md): Every element in one script.
