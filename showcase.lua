-- GainUI showcase: every element and method, live, in one window.
-- Run it in Matcha:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/showcase.lua"))()
-- Right Shift shows and hides it. Settings (last tab) has the accent, key and Unload.

local GainUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/GainUI.lua"))() or _G.GainUI

-- A second run replaces the first.
if _G.GainUIShowcase then pcall(function() _G.GainUIShowcase:Destroy() end) end

local connections = {}
local Window = GainUI:CreateWindow({
    Title = "GainUI",
    Subtitle = "Showcase",
    ConfigName = "showcase", -- flagged values are saved to GainUI/showcase.json
    ToggleKey = "RightShift",
    Accent = "568cff",
    Size = {680, 500},
    OnUnload = function()
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        _G.GainUIShowcase = nil
        print("[GainUI showcase] unloaded")
    end,
})
_G.GainUIShowcase = Window

local function hex(c)
    return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- Welcome ----------------------------------------------------------------------
local Home = Window:Tab("Welcome")
Home:Paragraph({
    Title = "Welcome to GainUI",
    Content = "Each tab shows part of the library. Click, drag, type and rebind things: everything here works. "
        .. "Right Shift hides the window, and the Settings tab at the bottom changes the accent and the key.",
})
Home:Section("Live")
local fpsLabel = Home:Label("FPS: ...")
local mouseLabel = Home:Label("Mouse: ...")
Home:Label("Executor: " .. (identifyexecutor and table.concat({identifyexecutor()}, " ") or "unknown") .. "  -  GainUI " .. GainUI.Version)
Home:Section("Try it")
Home:Button({Name = "Send a notification", Callback = function()
    Window:Notify({Title = "Hello!", Content = "Notifications stack at the bottom right and fade out on their own.", Duration = 4})
end})
Home:Button({Name = "Go to the Controls tab", Callback = function() Window:SelectTab("Controls") end})

-- Controls: every input element --------------------------------------------------
local Controls = Window:Tab("Controls")
local status = Controls:Label({Text = "What you change shows up here.", Color = "7aa8ff"})
local function show(text) status:SetText(text) end

Controls:Section("Toggle")
Controls:Toggle({Name = "A toggle", Default = false, Flag = "Showcase_Toggle", Callback = function(on)
    show("Toggle: " .. (on and "on" or "off"))
end})

Controls:Section("Slider")
Controls:Slider({Name = "Whole numbers", Min = 0, Max = 100, Default = 50, Suffix = "%", Flag = "Showcase_Slider",
    Callback = function(v) show("Slider: " .. v .. "%") end})
Controls:Slider({Name = "Decimals", Min = 0, Max = 1, Default = 0.5, Increment = 0.05,
    Callback = function(v) show("Decimal slider: " .. v) end})

Controls:Section("Dropdown")
Controls:Dropdown({Name = "Pick one", Options = {"Apple", "Banana", "Cherry", "Dragonfruit"}, Default = "Banana",
    Flag = "Showcase_Fruit", Callback = function(option) show("Picked: " .. tostring(option)) end})
Controls:Dropdown({Name = "Pick several", Options = {"Red", "Green", "Blue", "Gold"}, Multi = true, Default = {"Red"},
    Callback = function(list) show("Picked: " .. (#list > 0 and table.concat(list, ", ") or "none")) end})

Controls:Section("Textbox")
Controls:Textbox({Name = "Type something", Placeholder = "Type, then press Enter", Flag = "Showcase_Text",
    Callback = function(text) show("You typed: " .. text) end})
Controls:Textbox({Name = "Numbers only", Placeholder = "e.g. 42", Numeric = true,
    Callback = function(text) show(text ~= "" and ("Number: " .. text) or "That wasn't a number") end})

Controls:Section("Keybind (click the key to rebind it)")
Controls:Keybind({Name = "Press mode", Default = "G", Mode = "Press", Flag = "Showcase_Press", Callback = function()
    Window:Notify({Title = "Press mode", Content = "The keybind fired."})
end, Changed = function(key) show("Press keybind is now " .. key) end})
Controls:Keybind({Name = "Toggle mode", Default = "H", Mode = "Toggle", Callback = function(state)
    show("Toggle keybind: " .. (state and "on" or "off"))
end})
Controls:Keybind({Name = "Hold mode", Default = "J", Mode = "Hold", Callback = function(held)
    show(held and "Holding the key..." or "Let go")
end})

Controls:Section("Colorpicker")
Controls:Colorpicker({Name = "A color", Default = Color3.fromRGB(255, 80, 80), Flag = "Showcase_Color",
    Callback = function(c) show("Color: " .. hex(c)) end})
Controls:Button({Name = "Use that color as the accent", Callback = function()
    Window:SetAccent(GainUI.Flags.Showcase_Color.Value)
end})

-- Methods: changing elements from code ---------------------------------------------
local Methods = Window:Tab("Methods")
Methods:Paragraph({Title = "Elements are objects",
    Content = "Every element returns an object. The buttons below change these four from code."})
local target = Methods:Toggle({Name = "Target toggle", Default = false})
local slider = Methods:Slider({Name = "Target slider", Min = 0, Max = 10, Default = 5})
local dropdown = Methods:Dropdown({Name = "Target dropdown", Options = {"One", "Two", "Three"}, Default = "One"})
local label = Methods:Label("Target label")

Methods:Section("Values")
Methods:Button({Name = "toggle:Set(not toggle.Value)", Callback = function() target:Set(not target.Value) end})
Methods:Button({Name = "slider:Set(math.random(0, 10))", Callback = function() slider:Set(math.random(0, 10)) end})
Methods:Button({Name = "dropdown:Refresh({\"Red\", \"Green\", \"Blue\"})", Callback = function()
    dropdown:Refresh({"Red", "Green", "Blue"})
    label:SetText("The dropdown has new options")
end})
Methods:Section("Looks")
Methods:Button({Name = "label:SetText(the time)", Callback = function() label:SetText("It is " .. os.date("%H:%M:%S")) end})
Methods:Button({Name = "toggle:SetName(...)", Callback = function() target:SetName("Renamed at " .. os.date("%H:%M:%S")) end})
Methods:Button({Name = "slider:SetVisible(on / off)", Callback = function() slider:SetVisible(slider.Hidden == true) end})
Methods:Section("Flags")
Methods:Button({Name = "Print every saved flag", Callback = function()
    for flag, element in pairs(Window.Flags) do
        local v = element.Value
        if typeof and typeof(v) == "Color3" then v = hex(v)
        elseif type(v) == "table" then v = "{" .. table.concat(v, ", ") .. "}"
        elseif element.Kind == "Keybind" then v = GainUI.KeyLabel(v) end
        print(("[GainUI showcase] %s = %s"):format(flag, tostring(v)))
    end
    Window:Notify({Title = "Printed", Content = "Every flag is in the console."})
end})

-- Window: the window's own methods --------------------------------------------------
local Win = Window:Tab("Window")
Win:Section("Look")
local titles, t = {"GainUI", "My Script", "Showcase", "Hello"}, 1
Win:Button({Name = "Window:SetTitle(...)", Callback = function()
    t = t % #titles + 1
    Window:SetTitle(titles[t], "Title " .. t .. " of " .. #titles)
end})
local accent = 1
Win:Button({Name = "Window:SetAccent(next color)", Callback = function()
    accent = accent % #GainUI.Accents + 1
    Window:SetAccent(GainUI.Accents[accent])
end})
Win:Section("Keys and visibility")
Win:Button({Name = "Window:SetToggleKey(\"Insert\")", Callback = function()
    Window:SetToggleKey("Insert")
    Window:Notify({Title = "Show / hide key", Content = "It's Insert now. Change it back in Settings."})
end})
Win:Button({Name = "Window:Toggle(false)  (press the key to come back)", Callback = function() Window:Toggle(false) end})
Win:Section("Saving")
Win:Button({Name = "Window:Save()", Callback = function()
    Window:Save()
    Window:Notify({Title = "Saved", Content = "Flags written to GainUI/showcase.json in the workspace."})
end})
Win:Button({Name = "Window:Dump()  (prints what's on screen)", Callback = function() print(Window:Dump()) end})

-- Text & images ------------------------------------------------------------------------
local Media = Window:Tab("Text & images")
Media:Section("Labels")
Media:Label("A plain label.")
Media:Label({Text = "A colored label.", Color = "6fdc9a"})
Media:Label("Long labels wrap to the width of the page, so you can write whole sentences without worrying about where the edge is.")
Media:Divider()
Media:Paragraph({Title = "A paragraph", Content = "A title and wrapped text on a card. Handy for instructions, credits or changelogs."})
Media:Section("Image")
Media:Image({Url = "https://martinikaws.github.io/rivals-skins/assets/images/wrapicons/arcane.png", Height = 110, Width = 110})
Media:Label({Text = "Downloaded with game:HttpGet when the tab is made.", Color = "8a96ab"})

-- A long tab, to show scrolling --------------------------------------------------------
local Long = Window:Tab("Scrolling")
Long:Paragraph({Title = "Scrolling", Content = "Matcha can't read the mouse wheel. Drag the page, drag the bar on the right, "
    .. "or point at the page and use Page Up / Page Down or the arrow keys."})
for i = 1, 30 do
    Long:Toggle({Name = "Row " .. i})
end

-- Live labels, from a connection (a loop in a spawned thread can stop in Matcha) --------
local frames, since = 0, tick()
pcall(function()
    connections[#connections + 1] = game:GetService("RunService").Heartbeat:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - since < 0.5 then return end
        fpsLabel:SetText(("FPS: %d"):format(math.floor(frames / (now - since) + 0.5)))
        frames, since = 0, now
        pcall(function()
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            mouseLabel:SetText(("Mouse: %d, %d"):format(mouse.X, mouse.Y))
        end)
    end)
end)

Window:Notify({Title = "GainUI showcase", Content = "Right Shift shows and hides the window.", Duration = 5})
