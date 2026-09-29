# Classes & datatypes

> The Roblox classes, properties and types Matcha supports. Anything else reads as nil.

| Class | What works |
| --- | --- |
| DataModel (game) | `PlaceId`, `GameId`, `JobId`, `:GetService(name)`, `:HttpGet(url)`, `:IsLoaded()` |
| Instance (all) | `Name`, `ClassName`, `Parent` (writable), `Address`; `:FindFirstChild(name, recursive?)`, `:FindFirstChildOfClass`, `:FindFirstChildWhichIsA`, `:WaitForChild`, `:GetChildren`, `:GetDescendants`, `:IsA`, `:IsDescendantOf`, `:GetFullName`, `:GetAttribute`, `:GetAttributes`, `:SetAttribute` |
| Players | `LocalPlayer`, `:GetPlayers()`, `PlayerAdded`, `PlayerRemoving` |
| Player | `Name`, `Character`, `Team`, `:GetMouse()` |
| Mouse | `X`, `Y` (screen pixels) |
| Workspace | `CurrentCamera` |
| Camera | `ViewportSize`, `FieldOfView`, `Position`, `lookAt(at, target)` |
| BasePart / MeshPart | `Size`, `Position`, `Transparency`, `Color`, `Velocity`, `AssemblyLinearVelocity`, `CanCollide`; MeshPart `MeshId`, `TextureId` |
| Model / Humanoid | `PrimaryPart`; `Health`, `MaxHealth` |
| ValueBase (IntValue, StringValue...) | `Value` |
| GuiObject / TextLabel | `AbsoluteSize`, `AbsolutePosition`; TextLabel `Text` can be read, not written |
| HttpService | `:JSONEncode`, `:JSONDecode`, `:GenerateGUID` |
| UserInputService | `InputBegan`, `InputEnded` (no `InputChanged`, so no mouse wheel) |
| RunService | `Heartbeat`, `RenderStepped` connections |

## Datatypes

| Type | Constructors and fields |
| --- | --- |
| Vector3 | `Vector3.new(x, y, z)`; `X`, `Y`, `Z` |
| Vector2 | `Vector2.new(x, y)`; `X`, `Y` |
| Color3 | `Color3.new(r, g, b)` (0-1), `fromRGB`, `fromHSV`, `fromHex`; `R`, `G`, `B` |

> **Note:** Check before you rely on something: read it and print it. `nil` where you expected a value means Matcha doesn't bind it.
