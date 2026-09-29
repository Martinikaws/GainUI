# Label & Paragraph

> Text that explains things. Both wrap to the page's width.

## Label

```lua
Tab:Label(text | {Text, Color?}) -> Element
```

```lua
local Status = Main:Label("Waiting...")
Status:SetText("Ready!")

Main:Label({Text = "Something went wrong", Color = "f05a5a"})
```

## Paragraph

```lua
Tab:Paragraph({Title, Content}) -> Element
```

```lua
local Info = Main:Paragraph({
    Title = "How to use",
    Content = "Turn on Enabled, then pick a mode. Your choices are saved.",
})
Info:Set("New content")               -- content only
Info:Set("New title", "New content")  -- both
```
