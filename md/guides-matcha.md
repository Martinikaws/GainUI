# How Nova handles Matcha

> What Nova does for you about Matcha's quirks, and its limits. For Matcha itself, see the Matcha section.

## Everything is drawn

Matcha can't create instances, so there are no ScreenGuis. Every window is made of Drawing objects: squares, text, lines, circles and images. They're redrawn every frame from a pool, and a property is only written when it changes, so an idle window costs almost nothing.

## Input

- **No mouse wheel.** Matcha can't read it. Pages scroll by dragging them, dragging the scrollbar, or with `Page Up` / `Page Down` and the arrow keys while pointing at them.
- **Clicks count on release.** So pressing and dragging scrolls instead of clicking whatever you started on.
- **The game doesn't get your clicks.** While the mouse is over the window, or you're typing or binding a key, Nova calls `setrobloxinput(false)`, and gives input back afterwards.
- **Clicks land off?** Some setups report the mouse a few pixels away from where it's drawn. Users can fix it in **Settings → Mouse offset**, or you can set `MouseOffset`. The value is saved.
- **Roblox must be focused.** Keys and clicks are read with `iskeypressed` and `ismouse1pressed`. They're ignored while another window is in front.

## Callbacks

The window runs from a `RenderStepped` connection. That keeps it alive after your script finishes (in Matcha, a loop in a spawned thread can stop resuming). Callbacks run inside that step and are wrapped in `pcall`: an error is printed and the window keeps going.

> **Note:** Keep callbacks short. For anything that waits or loops, start your own thread: `Callback = function(on) task.spawn(doLongThing, on) end`. Button callbacks already get their own thread.

## Text

Matcha draws text a little higher than its position. Nova shifts it back, and measures text with `TextBounds` so long labels get trimmed with ".." instead of overflowing.

## Unloading

`Window:Destroy()` (or **Settings → Unload**) removes every drawing, disconnects the render step, gives input back to the game, saves flags and calls your `OnUnload`. Disconnect your own connections there.

```lua
local conn = game:GetService("RunService").Heartbeat:Connect(function() ... end)

local Window = Nova:CreateWindow({
    Title = "My Script",
    OnUnload = function()
        conn:Disconnect()
    end,
})
```
