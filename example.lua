-- Nova example: every element once. Run it in Matcha.
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/Nova/main/Nova.lua"))() or _G.Nova

local Window = Nova:CreateWindow({
    Title = "Nova",
    Subtitle = "Example",
    ConfigName = "example", -- saves every flagged element to Nova/example.json
    ToggleKey = "RightShift",
    Accent = "eab308",
})

local Main = Window:Tab("Main")
Main:Section("Basics")
Main:Label("Everything here is drawn with Matcha's Drawing library.")
Main:Toggle({Name = "Enabled", Default = false, Flag = "Enabled", Callback = function(on)
    print("Enabled:", on)
end})
Main:Slider({Name = "Walk speed", Min = 16, Max = 100, Default = 16, Increment = 1, Suffix = " studs",
    Flag = "Speed", Callback = function(v) print("Speed:", v) end})
Main:Button({Name = "Say hi", Callback = function()
    Window:Notify({Title = "Hi!", Content = "Buttons run their callback when clicked.", Duration = 3})
end})

Main:Section("Choices")
Main:Dropdown({Name = "Mode", Options = {"Legit", "Balanced", "Chaos"}, Default = "Balanced", Flag = "Mode",
    Callback = function(opt) print("Mode:", opt) end})
Main:Dropdown({Name = "Parts", Options = {"Head", "Torso", "Arms", "Legs"}, Multi = true, Default = {"Head"},
    Flag = "Parts", Callback = function(list) print("Parts:", table.concat(list, ", ")) end})
Main:Textbox({Name = "Player name", Placeholder = "Type and press Enter", Flag = "Target",
    Callback = function(text) print("Target:", text) end})

local Extra = Window:Tab("Extra")
Extra:Keybind({Name = "Say something", Default = "G", Mode = "Press", Flag = "SayKey", Callback = function()
    Window:Notify({Title = "Keybind", Content = "You pressed the key."})
end})
Extra:Keybind({Name = "Hold to show", Default = "H", Mode = "Hold", Callback = function(held) print("Held:", held) end})
Extra:Colorpicker({Name = "Box color", Default = Color3.fromRGB(255, 80, 80), Flag = "BoxColor",
    Callback = function(c) print("Color:", c) end})
Extra:Paragraph({Title = "About", Content = "Tabs scroll when they get long: drag the page or its bar, "
    .. "or use Page Up / Page Down while pointing at it (Matcha can't read the mouse wheel)."})

-- Read a value anywhere with the flag:
print("Speed is", Nova.Flags.Speed.Value)
