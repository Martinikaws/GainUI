# CreateWindow

> Makes a window and returns it. A script can make more than one.

```lua
Nova:CreateWindow(options: table) -> Window
```

```lua
local Window = Nova:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0",
    ConfigName = "myscript",
    ToggleKey = "RightShift",
    Accent = "eab308",
    Size = {620, 460},
})
```

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | string | `"Nova"` | Shown at the top of the sidebar. |
| `Subtitle` | string | none | A smaller line under the title, in the accent color. |
| `ConfigName` | string | none | Saves flagged elements to `Folder/ConfigName.json`. Without it nothing is saved. See [Saving](https://martinikaws.github.io/Nova/md/window-saving.md). |
| `Folder` | string | `"Nova"` | The workspace folder settings are saved in. |
| `ToggleKey` | key | `"RightShift"` | The key that shows and hides the window. See [Key names](https://martinikaws.github.io/Nova/md/guides-keys.md). |
| `Accent` | hex / Color3 | `"eab308"` (yellow) | The highlight color. Users can change it in Settings. |
| `Size` | {w, h} | `{620, 460}` | Window size in pixels (at least 460 × 320). It shrinks to fit small screens. |
| `Open` | boolean | `true` | Start shown. With `false`, the window waits for the toggle key. |
| `Settings` | boolean | `true` | Add the built-in Settings tab (show/hide key, accent, mouse offset, reset, unload). |
| `MouseOffset` | number | `0` | Pixels added to the mouse's y. Users can adjust it in Settings if clicks land off. |
| `Theme` | table | none | Override colors: `bg`, `side`, `panel`, `card`, `cardHover`, `line`, `text`, `dim`, `faint` (hex strings or Color3). |
| `OnUnload` | function | none | Runs when the window is destroyed (from code or Settings → Unload). Clean up your connections here. |

> **Note:** The window starts centered. Users can drag it by the title area, and it remembers where it was until the script ends.
