# Window methods

> Everything a window can do after it's made.

| Method | Description |
| --- | --- |
| `Window:Tab(name) -> Tab` | Adds a tab to the sidebar. Aliases: `CreateTab`, `AddTab`. |
| `Window:SelectTab(tab \| name)` | Switches to a tab. |
| `Window:Notify(options)` | Shows a notification. See [Notifications](https://martinikaws.github.io/GainUI/md/window-notify.md). |
| `Window:Toggle(open?)` | Shows or hides the window. Without an argument, it flips. |
| `Window:IsOpen() -> boolean` | Whether the window is shown. |
| `Window:SetAccent(color)` | Changes the accent (hex string or Color3). |
| `Window:GetAccent() -> Color3` | The current accent. |
| `Window:SetToggleKey(key)` | Changes the show/hide key. |
| `Window:GetToggleKey() -> string` | The show/hide key's name, like `"RightShift"`. |
| `Window:SetTitle(title, subtitle?)` | Changes the title (and subtitle). |
| `Window:Save()` | Saves flags right away (normally a second after the last change). |
| `Window:Destroy()` | Removes the window and everything it drew, and gives input back to the game. Alias: `Unload`. |
| `Window:Dump() -> string` | Every text on screen with its position. Handy for checking a layout from a script. |

## Fields

| Field | Description |
| --- | --- |
| `Window.Flags` | This window's flagged elements, by flag. |
| `Window.Tabs` | The tabs, in order. |
| `Window.SettingsTab` | The built-in Settings tab. Add your own elements to it if you like. |

## Library functions

| Function | Description |
| --- | --- |
| `GainUI:CreateWindow(options)` | Makes a window. Alias: `GainUI:Window`. |
| `GainUI:Notify(options)` | A notification on the newest window. |
| `GainUI:Destroy()` | Destroys every window. |
| `GainUI.Flags` | Every flagged element from every window. |
| `GainUI.Hex(hex) -> Color3` | `"ff5050"` to a Color3. |
| `GainUI.KeyLabel(key) -> string` | How a key is shown, like `"Right Shift"`. |
| `GainUI.Version` | The library version. |
