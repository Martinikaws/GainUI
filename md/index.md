# Getting Started

> A drawn GUI library for Matcha. Build a clean, modern window with tabs, toggles, sliders, dropdowns and keybinds in a few lines.

## Install

Load the library at the top of your script. There's nothing to download: it always runs the latest version from GitHub.

```lua
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Nova/main/Nova.lua"))() or _G.Nova
```

> **Note:** Why `or _G.Nova`? Matcha's `loadstring` drops return values, so Nova also puts itself in `_G.Nova`. This line works in Matcha and in executors that do return.

## Your first window

```lua
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Nova/main/Nova.lua"))() or _G.Nova

local Window = Nova:CreateWindow({
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

- [Window](https://martinikaws.github.io/Nova/md/window-create.md): Title, size, accent, keys and saving.
- [Elements](https://martinikaws.github.io/Nova/md/elements-toggle.md): Every control you can put in a tab.
- [Matcha](https://martinikaws.github.io/Nova/md/matcha.md): What Matcha supports, and the quirks that break scripts.
- [Full example](https://martinikaws.github.io/Nova/md/start-example.md): Every element in one script.
