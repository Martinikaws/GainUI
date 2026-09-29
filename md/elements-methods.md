# Element methods

> Every element returns an object you can read and change later.

| Method / field | Description |
| --- | --- |
| `el.Value` | The current value (state, number, option, text, key code or Color3). |
| `el:Set(value, silent?)` | Changes the value and runs the callback (unless `silent` is true). Aliases: `SetValue`. |
| `el:Get()` | The value. Alias: `GetValue`. |
| `el:SetName(text)` | Changes the label. |
| `el:SetVisible(bool)` | Hides or shows the element. The elements below move up. |
| `el:SetText(text)` | Labels only: changes the text. |
| `el:Refresh(options, keep?)` | Dropdowns only: new options. |
| `el.Name / el.Flag / el.Kind` | The label, the flag, and the kind (`"Toggle"`, `"Slider"`, ...). |

## Aliases

If you're coming from another library, the familiar names work too:

| Nova | Also works |
| --- | --- |
| `Tab:Toggle` | `AddToggle`, `CreateToggle` |
| `Tab:Textbox` | `Input`, `AddInput`, `CreateInput`, `AddTextbox` |
| `Tab:Colorpicker` | `ColorPicker`, `AddColorPicker`, `CreateColorPicker` |
| `(every element)` | `Add<Kind>` and `Create<Kind>` |
| `Slider options` | `Range = {min, max}`, `Rounding` for Increment, `CurrentValue` for Default |
| `Dropdown options` | `Values` for Options, `MultipleOptions` for Multi, `CurrentOption` for Default |
