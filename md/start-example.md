# Example

> See every element working: run the showcase, or read a short script that uses each one.

## Showcase

One line in Matcha opens a window that demonstrates everything: every element, the methods that change them from code, the window's own methods, labels and images, and scrolling. What you change shows up live, and the values are saved between runs.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Nova/main/showcase.lua"))()
```

> **Note:** Right Shift shows and hides it. Its source is [showcase.lua](https://github.com/Martinikaws/Nova/blob/main/showcase.lua), a good place to copy from.

## A short example

```lua
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Nova/main/Nova.lua"))() or _G.Nova

local Window = Nova:CreateWindow({Title = "Nova", Subtitle = "Example", ConfigName = "example"})

local Main = Window:Tab("Main")
Main:Section("Basics")
Main:Label("Everything here is drawn with Matcha's Drawing library.")
Main:Toggle({Name = "Enabled", Default = false, Flag = "Enabled", Callback = function(on) print("Enabled:", on) end})
Main:Slider({Name = "Walk speed", Min = 16, Max = 100, Default = 16, Suffix = " studs", Flag = "Speed",
    Callback = function(v) print("Speed:", v) end})
Main:Button({Name = "Say hi", Callback = function()
    Window:Notify({Title = "Hi!", Content = "Buttons run their callback when clicked.", Duration = 3})
end})

Main:Section("Choices")
Main:Dropdown({Name = "Mode", Options = {"Legit", "Balanced", "Chaos"}, Default = "Balanced", Flag = "Mode",
    Callback = function(opt) print("Mode:", opt) end})
Main:Dropdown({Name = "Parts", Options = {"Head", "Torso", "Arms", "Legs"}, Multi = true, Default = {"Head"},
    Flag = "Parts", Callback = function(list) print(table.concat(list, ", ")) end})
Main:Textbox({Name = "Player name", Placeholder = "Type and press Enter", Flag = "Target",
    Callback = function(text) print("Target:", text) end})

local Extra = Window:Tab("Extra")
Extra:Keybind({Name = "Say something", Default = "G", Flag = "SayKey", Callback = function()
    Window:Notify({Title = "Keybind", Content = "You pressed the key."})
end})
Extra:Keybind({Name = "Hold to show", Default = "H", Mode = "Hold", Callback = function(held) print(held) end})
Extra:Colorpicker({Name = "Box color", Default = Color3.fromRGB(255, 80, 80), Flag = "BoxColor",
    Callback = function(c) print(c) end})
Extra:Paragraph({Title = "About", Content = "Long tabs scroll: drag the page or its bar, or use Page Up / Page Down."})

print("Speed is", Nova.Flags.Speed.Value)
```

The same file is in the repository as [example.lua](https://github.com/Martinikaws/Nova/blob/main/example.lua).
