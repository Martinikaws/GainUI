# Coming from Rayfield

> Most Rayfield-style scripts only need their window line changed.

```lua
-- Rayfield
local Window = Rayfield:CreateWindow({Name = "My Script"})
local Tab = Window:CreateTab("Main")
Tab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) end})
Tab:CreateSlider({Name = "Speed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) end})

-- Nova: same element calls, a different window line
local Window = Nova:CreateWindow({Title = "My Script"})
local Tab = Window:CreateTab("Main")
Tab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) end})
Tab:CreateSlider({Name = "Speed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) end})
```

| Rayfield | Nova |
| --- | --- |
| `CreateWindow({Name})` | `CreateWindow({Title})` |
| `ConfigurationSaving = {Enabled, FileName}` | `ConfigName` |
| `Rayfield:Notify({Title, Content, Duration})` | `Window:Notify` or `Nova:Notify` |
| `Flags[flag].CurrentValue` | `Flags[flag].Value` |
| `Element:Set(v)` | `Element:Set(v)` (same) |

> **Warning:** Icons, key systems and Discord invites aren't part of Nova.
