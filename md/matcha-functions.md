# Functions

> Every global function Matcha has, including the ones the official docs don't list yet.

## Scripts and globals

| Function | Description |
| --- | --- |
| `loadstring(source, chunkname?) -> function?, error?` | Compiles code. The function it gives back runs, but its return values are lost (see Matcha basics). |
| `require(path) -> table` | Runs a workspace file ending in .lua or .luau. |
| `decompile(script) -> string` | Decompiles a LocalScript or ModuleScript. |
| `getscripts() -> {Instance}` | All scripts in the game. |
| `getscriptbytecode(script) -> string` | A script's bytecode. |
| `getscripthash(script) -> string` | A hash of a script's bytecode, to tell versions apart. |
| `getgc() / findgc(...)` | Garbage-collector access. Not documented; findgc is slow (tens of seconds). |
| `identifyexecutor() -> string` | The executor name and version, like "Matcha 1.0.0". |
| `notify(message, title, seconds)` | A Matcha notification. |
| `WorldToScreen(position) -> Vector2, boolean` | A 3D point on screen, and whether it's visible. |
| `base64encode(s) / base64decode(s)` | Base64 conversion. |
| `setfflag(name, value) / getfflag(name)` | Fast flags (unfinished in Matcha). |
| `print / printl / warn / error` | Console output. |

## Input

| Function | Description |
| --- | --- |
| `iskeypressed(keycode) -> boolean` | Whether a key is held. Key codes are Windows virtual-key codes (0x41 = "A", 0xA1 = Right Shift). |
| `ismouse1pressed() / ismouse2pressed() -> boolean` | Whether the left / right mouse button is held. |
| `keypress(keycode) / keyrelease(keycode)` | Presses / releases a key (Roblox must be focused). |
| `mouse1press() / mouse1release() / mouse1click()` | The left button. mouse2... for the right one. |
| `mousemoveabs(x, y) / mousemoverel(dx, dy)` | Moves the cursor. |
| `mousescroll(amount)` | Scrolls the wheel (sending works; reading it doesn't). |
| `setrobloxinput(enabled)` | false stops the game from receiving your input; true gives it back. |
| `isrbxactive() -> boolean` | Whether the Roblox window is focused. |
| `setclipboard(text)` | Copies text. (There is no getclipboard.) |

## Files

All paths are relative to Matcha's workspace folder. Not in the official docs, but all present:

| Function | Description |
| --- | --- |
| `readfile(path) -> string` | A file's contents. |
| `writefile(path, text)` | Writes a file (some extensions, like .png, are refused). |
| `appendfile(path, text)` | Adds to the end of a file. |
| `isfile(path) / isfolder(path) -> boolean` | Whether it exists. |
| `makefolder(path) / delfolder(path) / delfile(path)` | Folders and deleting. |
| `listfiles(path) -> {string}` | A folder's contents. |

## Memory

| Function | Description |
| --- | --- |
| `getbase() -> number` | RobloxPlayerBeta.exe's base address. |
| `memory_read(type, address) -> any` | Reads "int", "float", "double", "byte", "string" or "uintptr_t". |
| `memory_write(type, address, value)` | Writes one. Wrong types or addresses can crash the game. |

> **Note:** `Instance.Address` gives any instance's address in memory. Memory functions need unsafe Luau execution enabled in Matcha's settings.

## Threads and time

| Function | Description |
| --- | --- |
| `task.spawn(fn, ...) / task.defer(fn, ...)` | Runs a function in a new thread. |
| `task.wait(seconds?) / task.delay(seconds, fn)` | Waits, or runs later. (Plain wait, spawn and tick exist too.) |

## Not available

`Instance.new`, `getgenv`, `getrenv`, `shared`, `hookfunction`, `getrawmetatable`, `newcclosure`, `request / http_request`, `getcustomasset`, `cloneref`, `gethui`, `fireclickdetector`, `firetouchinterest`, `loadfile`, `getclipboard`. Use `game:HttpGet(url)` for web requests and `_G` for shared state.
