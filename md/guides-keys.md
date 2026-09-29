# Key names

> Keys can be given by name, key code, or Enum.KeyCode.

```lua
ToggleKey = "RightShift"       -- name
ToggleKey = Enum.KeyCode.Insert -- Enum.KeyCode
ToggleKey = 0x2D               -- Windows key code
```

| Keys | Names |
| --- | --- |
| Letters | `"A"` to `"Z"` |
| Numbers | `"One"` ... `"Nine"`, `"Zero"` (or `"1"` ... `"0"`); keypad: `"KeypadOne"` ... |
| Function keys | `"F1"` to `"F12"` |
| Modifiers | `"LeftShift"`, `"RightShift"`, `"LeftControl"`, `"RightControl"`, `"LeftAlt"`, `"RightAlt"` |
| Navigation | `"Insert"`, `"Delete"`, `"Home"`, `"End"`, `"PageUp"`, `"PageDown"`, `"Up"`, `"Down"`, `"Left"`, `"Right"` |
| Other | `"Space"`, `"Tab"`, `"Return"`, `"Backspace"`, `"CapsLock"`, `"Escape"`, `"Minus"`, `"Equals"`, `"Comma"`, `"Period"`, `"Slash"`, `"Semicolon"`, `"Quote"`, `"LeftBracket"`, `"RightBracket"`, `"BackSlash"`, `"Backquote"` |
| None | `"None"`, `nil` or `false` |
