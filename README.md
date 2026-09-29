# GainUI

A drawn GUI library for [Matcha](https://matcha-latte.gitbook.io/matcha). Windows, tabs, toggles, sliders, dropdowns, text boxes, keybinds, color pickers, notifications and saved settings, all made from Drawing objects (Matcha can't create instances).

**Docs:** https://martinikaws.github.io/GainUI/

**Use with AI:** add `https://martinikaws.gitmcp.io/GainUI` as a custom MCP server in Claude, Cursor or VS Code and your assistant can read these docs. Plain-text copies: [`llms.txt`](https://martinikaws.github.io/GainUI/llms.txt), [`llms-full.txt`](https://martinikaws.github.io/GainUI/llms-full.txt).

```lua
local GainUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/GainUI.lua"))() or _G.GainUI

local Window = GainUI:CreateWindow({Title = "My Script", ConfigName = "myscript"})
local Main = Window:Tab("Main")

Main:Toggle({Name = "Enabled", Default = false, Flag = "Enabled", Callback = function(on)
    print(on)
end})
```

See everything working: run the showcase in Matcha.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/showcase.lua"))()
```

`example.lua` is a shorter script that uses every element once.

## Why

Writing a GUI with Drawing means solving the same Matcha quirks every time:

- no mouse wheel;
- text drawn a little higher than its position;
- clicks leaking into the game;
- a changed property costing a write every frame.

GainUI handles these once:

- clicks count on release, so dragging a page scrolls it, with a scrollbar and Page Up / Page Down as well;
- only properties that changed are written;
- `setrobloxinput` keeps clicks and typing on the window out of the game;
- a mouse-offset setting fixes setups where clicks land off.

## Credits

- **Martinikaws**: GainUI.
- **mr.vage**: the Rivals Skin Changer GUI it grew out of.
- Style inspired by Gain's external.
