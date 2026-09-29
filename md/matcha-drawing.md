# Drawing

> Matcha's only way to put things on screen. Everything GainUI shows is made of these.

```lua
Drawing.new(kind: string) -> DrawingObject
```

```lua
local box = Drawing.new("Square")
box.Position = Vector2.new(20, 20)
box.Size = Vector2.new(200, 120)
box.Color = Color3.fromRGB(86, 140, 255)
box.Filled = true
box.Corner = 8
box.Visible = true

task.wait(5)
box:Remove()
```

## Kinds and properties

| Kind | Properties |
| --- | --- |
| All | `Visible`, `Color`, `Transparency` (1 = solid), `ZIndex`, `Position`; `:Remove()` |
| Square | `Size`, `Filled`, `Thickness`, `Corner` (rounded corners) |
| Line | `From`, `To`, `Thickness` |
| Circle | `Radius`, `NumSides`, `Filled`, `Thickness` |
| Triangle / Quad | `PointA`, `PointB`, `PointC` (Quad: `PointD`), `Filled` |
| Text | `Text`, `Size`, `Font`, `Center`, `Outline`; `TextBounds` (read: the drawn size) |
| Image | `Data` (the file's bytes, PNG or JPG), `Size`, `Rounding`. Not in the official docs. |

## Fonts

`Drawing.Fonts.UI`, `Drawing.Fonts.System`, `Drawing.Fonts.SystemBold`, `Drawing.Fonts.Minecraft`, `Drawing.Fonts.Monospace`, `Drawing.Fonts.Pixel`, `Drawing.Fonts.Fortnite`, `Drawing.Fonts.ProximaSoftBold`

## Tips

- **Reuse objects.** Keep a pool and hide what you don't draw this frame instead of making new ones every frame.
- **Only write what changed.** Each property write costs something; compare with the last value first.
- **Text sits high.** Matcha draws text about a third of its size above its Position; add `size * 0.3` to line it up.
- **Measure text** with a hidden Text object's `TextBounds` to trim or center it.
- **Images** come from bytes: `game:HttpGet(url)` or `readfile`. Cache downloads with a non-.png extension.
- **Clean up.** Remove every object when your script unloads, or it stays on screen.
