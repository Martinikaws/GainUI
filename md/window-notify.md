# Notifications

> Short messages that slide in at the bottom right, even while the window is hidden.

```lua
Window:Notify({Title, Content?, Duration?})
```

```lua
Window:Notify({
    Title = "Saved",
    Content = "Your settings were saved.",
    Duration = 4, -- seconds
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | string | `"Notice"` | The bold first line. |
| `Content` | string | none | More text. It wraps. |
| `Duration` | number | `4` | Seconds before it fades out. A thin bar shows the time left. |

Up to five show at once; the oldest goes first. `Window:Notify("Text")` works too, using the text as the title.
