# Matcha basics

> Matcha is an external Luau VM for Roblox. It works differently from a normal executor, and scripts have to be written for that.

## What Matcha is

Matcha runs **outside** the Roblox client. It doesn't hook the engine; it reads and writes the game's memory and emulates the Roblox API on top of that. So it only has the classes, properties and functions it implements. The [official docs](https://matcha-latte.gitbook.io/matcha) list them, and the pages here add what we found in practice.

## Rules that break scripts

- **Bindings are a fixed list.** Reading a property Matcha doesn't support doesn't error: it falls back to `FindFirstChild` and gives `nil`. An unexplained `nil` usually means "unsupported". **Writing** an unsupported property errors (`Unknown property`).
- **No instances.** There is no `Instance.new`, so no ScreenGuis, parts or sounds of your own. Draw UI with the [Drawing library](https://martinikaws.github.io/GainUI/md/matcha-drawing.md) (that's what GainUI does).
- **`loadstring` drops return values.** `loadstring("return 5")()` gives nothing, even through `pcall`. Share values through `_G` instead; there is no `getgenv` or `shared`. That's why GainUI loads with `... or _G.GainUI`.
- **Threads can stop.** A `task.spawn` loop that waits with `task.wait` can stop resuming once the script that started it has finished. For anything that must keep running, connect to `RunService.Heartbeat` or `RenderStepped` and throttle inside it.
- **No mouse wheel.** `UserInputService.InputChanged` is `nil`; only `InputBegan` and `InputEnded` exist. Poll input instead: `iskeypressed`, `ismouse1pressed` and `Player:GetMouse()` (`Mouse.X` / `Mouse.Y`).
- **Roblox must be focused** for key and mouse input, including `keypress` and `mouse1click`. Check `isrbxactive()`.
- **Your clicks also reach the game.** Call `setrobloxinput(false)` while the mouse is over your UI, and `setrobloxinput(true)` afterwards.
- **Autoexec runs before the game exists.** `game.GameId` is `0` until it loads, and yielding at the top level of an autoexec script errors. Wait inside `task.spawn` for `game:IsLoaded()` and `LocalPlayer`, then check `game.GameId` before doing anything game-specific.
- **Files:** `writefile` refuses some extensions (`.png` among them). Save binary data with another extension such as `.dat`.
- **Memory functions** need unsafe Luau execution enabled in Matcha. A bad `memory_write` can crash the game.

## Patterns that work

```lua
-- only in one game, and only once it has loaded (safe in autoexec)
local GAME_ID = 6035872082
task.spawn(function()
    while not (game:IsLoaded() and game:GetService("Players").LocalPlayer) do task.wait(0.5) end
    if game.GameId ~= GAME_ID then return end
    -- ...
end)

-- something that keeps running: a connection, throttled
local last = 0
local conn = game:GetService("RunService").Heartbeat:Connect(function()
    if tick() - last < 0.5 then return end
    last = tick()
    -- ...
end)

-- a value another script can reach (loadstring can't return it)
_G.MyScript = {stop = function() conn:Disconnect() end}
```

> **Note:** The Matcha-specific files: [official docs as one text file](https://matcha-latte.gitbook.io/matcha/llms-full.txt). Everything on these pages is also in GainUI's [llms.txt](llms.txt).
