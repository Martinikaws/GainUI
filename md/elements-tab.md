# Tabs & Sections

> Tabs are the pages in the sidebar. Sections and dividers group the elements inside one.

```lua
Window:Tab(name: string) -> Tab
```

```lua
local Main = Window:Tab("Main")
Main:Section("Movement")
Main:Toggle({Name = "Fly"})
Main:Divider()
Main:Toggle({Name = "Noclip"})
```

Elements stack from top to bottom in the order you add them. When a tab gets longer than the window, it scrolls: drag the page, drag its scrollbar, or use `Page Up` / `Page Down` and the arrow keys while pointing at it.

## Section

```lua
Tab:Section(name: string)
```

A small accent heading with a line, to split a tab into groups.

## Divider

```lua
Tab:Divider()
```

A thin line with no text.

> **Note:** The Settings tab always stays last, even for tabs you add after the window is made.
