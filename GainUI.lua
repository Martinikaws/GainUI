--[[
    GainUI - a drawn GUI library for Matcha
    Docs:   https://martinikaws.github.io/GainUI/
    Source: https://github.com/Martinikaws/GainUI

    Matcha can't create instances, so every window is Drawing objects redrawn
    each frame from a pool (only properties that changed are written). Input is
    polled: the mouse through LocalPlayer:GetMouse() and ismouse1pressed, keys
    through iskeypressed. Clicks count on release, so pressing and dragging a
    list scrolls it instead (Matcha can't read the mouse wheel).

    local GainUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/GainUI/main/GainUI.lua"))() or _G.GainUI
    local Window = GainUI:CreateWindow({Title = "My Script"})
    local Main = Window:Tab("Main")
    Main:Toggle({Name = "Enabled", Default = false, Callback = function(on) print(on) end})
]]

local GainUI = {Version = "1.0.0", Flags = {}, Windows = {}}

assert(Drawing and type(Drawing.new) == "function", "GainUI needs Matcha's Drawing library.")

local V2, RGB = Vector2.new, Color3.fromRGB
local RunService = game:GetService("RunService")
local log = warn or print
local HttpService = game:GetService("HttpService")

-- Keys -----------------------------------------------------------------------

-- Windows key codes by name (Roblox KeyCode names, plus a few short ones).
local VK = {
    Backspace = 0x08, Tab = 0x09, Return = 0x0D, Enter = 0x0D, CapsLock = 0x14, Escape = 0x1B,
    Space = 0x20, PageUp = 0x21, PageDown = 0x22, End = 0x23, Home = 0x24, Left = 0x25, Up = 0x26,
    Right = 0x27, Down = 0x28, Insert = 0x2D, Delete = 0x2E,
    LeftShift = 0xA0, RightShift = 0xA1, LeftControl = 0xA2, RightControl = 0xA3, LeftAlt = 0xA4, RightAlt = 0xA5,
    Semicolon = 0xBA, Equals = 0xBB, Comma = 0xBC, Minus = 0xBD, Period = 0xBE, Slash = 0xBF, Backquote = 0xC0,
    LeftBracket = 0xDB, BackSlash = 0xDC, RightBracket = 0xDD, Quote = 0xDE,
}
local DIGITS = {"Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"}
for i = 0, 25 do VK[string.char(65 + i)] = 0x41 + i end
for i = 0, 9 do
    VK[tostring(i)], VK[DIGITS[i + 1]] = 0x30 + i, 0x30 + i
    VK["Keypad" .. DIGITS[i + 1]] = 0x60 + i
end
for i = 1, 12 do VK["F" .. i] = 0x6F + i end

-- How each key is shown.
local KEY_LABEL = {
    [0x08] = "Backspace", [0x09] = "Tab", [0x0D] = "Enter", [0x14] = "Caps Lock", [0x1B] = "Escape",
    [0x20] = "Space", [0x21] = "Page Up", [0x22] = "Page Down", [0x23] = "End", [0x24] = "Home",
    [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down", [0x2D] = "Insert", [0x2E] = "Delete",
    [0xA0] = "Left Shift", [0xA1] = "Right Shift", [0xA2] = "Left Ctrl", [0xA3] = "Right Ctrl",
    [0xA4] = "Left Alt", [0xA5] = "Right Alt", [0xBA] = ";", [0xBB] = "=", [0xBC] = ",", [0xBD] = "-",
    [0xBE] = ".", [0xBF] = "/", [0xC0] = "`", [0xDB] = "[", [0xDC] = "\\", [0xDD] = "]", [0xDE] = "'",
}
for i = 0, 25 do KEY_LABEL[0x41 + i] = string.char(65 + i) end
for i = 0, 9 do KEY_LABEL[0x30 + i] = tostring(i); KEY_LABEL[0x60 + i] = "Num " .. i end
for i = 1, 12 do KEY_LABEL[0x6F + i] = "F" .. i end
-- The name a key is saved under.
local KEY_NAME = {}
for name, vk in pairs(VK) do
    local have = KEY_NAME[vk]
    -- Prefer "A"/"F1"/"RightShift"/"One" style names; stable across runs.
    if not have or (#name < #have and not name:match("^%d$")) then KEY_NAME[vk] = name end
end
for i = 0, 9 do KEY_NAME[0x30 + i] = DIGITS[i + 1] end
KEY_NAME[0x0D] = "Return"

-- A key given as a name ("RightShift", "F", "F1"), a key code, or an
-- Enum.KeyCode, as its key code (nil for none).
local function toVK(key)
    if key == nil or key == false or key == "None" or key == "" then return nil end
    if type(key) == "number" then return key end
    if type(key) ~= "string" then
        local ok, name = pcall(function() return key.Name end)
        key = ok and name or tostring(key)
    end
    key = key:gsub("^Enum%.KeyCode%.", "")
    return VK[key] or VK[key:gsub("%s", "")] or VK[key:upper()]
end
local function keyLabel(vk) return vk and (KEY_LABEL[vk] or ("Key " .. vk)) or "None" end
GainUI.KeyLabel = function(key) return keyLabel(toVK(key)) end

-- Characters typed into a text box: key code -> {plain, shifted}.
local TYPED = {}
for i = 0, 25 do TYPED[0x41 + i] = {string.char(97 + i), string.char(65 + i)} end
for i = 0, 9 do
    TYPED[0x30 + i] = {tostring(i), (")!@#$%^&*("):sub(i + 1, i + 1)}
    TYPED[0x60 + i] = {tostring(i), tostring(i)}
end
TYPED[0x20] = {" ", " "} TYPED[0xBA] = {";", ":"} TYPED[0xBB] = {"=", "+"} TYPED[0xBC] = {",", "<"}
TYPED[0xBD] = {"-", "_"} TYPED[0xBE] = {".", ">"} TYPED[0xBF] = {"/", "?"} TYPED[0xC0] = {"`", "~"}
TYPED[0xDB] = {"[", "{"} TYPED[0xDC] = {"\\", "|"} TYPED[0xDD] = {"]", "}"} TYPED[0xDE] = {"'", "\""}
TYPED[0x6E] = {".", "."}

-- Colors ---------------------------------------------------------------------

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
local function round(v) return math.floor(v + 0.5) end
local function hexToColor(hex)
    hex = tostring(hex or ""):gsub("^#", "")
    if #hex == 3 then hex = hex:gsub(".", "%0%0") end
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    return r and g and b and RGB(r, g, b) or nil
end
local function colorToHex(c)
    return string.format("%02x%02x%02x", round(clamp(c.R, 0, 1) * 255), round(clamp(c.G, 0, 1) * 255),
        round(clamp(c.B, 0, 1) * 255))
end
local function toHSV(c)
    local r, g, b = c.R, c.G, c.B
    local mx, mn = math.max(r, g, b), math.min(r, g, b)
    local d = mx - mn
    local h = 0
    if d > 0 then
        if mx == r then h = ((g - b) / d) % 6
        elseif mx == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, mx == 0 and 0 or d / mx, mx
end
local function fromHSV(h, s, v)
    h = (h % 1) * 6
    local i = math.floor(h)
    local f = h - i
    local p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    local r, g, b
    if i == 0 then r, g, b = v, t, p elseif i == 1 then r, g, b = q, v, p elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v elseif i == 4 then r, g, b = t, p, v else r, g, b = v, p, q end
    return Color3.new(r, g, b)
end
local function toColor(c)
    if typeof and typeof(c) == "Color3" then return c end
    if type(c) == "string" then return hexToColor(c) end
    if type(c) == "table" and c.R then return Color3.new(c.R, c.G, c.B) end
    return nil
end
GainUI.Hex = hexToColor

local ACCENTS = {"568cff", "8b5cf6", "ec4899", "ef4444", "f97316", "eab308", "22c55e", "14b8a6", "06b6d4", "e5e7eb"}
GainUI.Accents = ACCENTS

-- Saving ---------------------------------------------------------------------

-- Flags are saved as JSON: booleans, numbers, strings, lists of strings, and
-- colors (as {"color": "rrggbb"}).
local function encode(v)
    local t = type(v)
    if t == "boolean" or t == "number" then return tostring(v) end
    if t == "string" then
        return '"' .. v:gsub('[%c"\\]', function(ch)
            return ({['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\t"] = "\\t", ["\r"] = "\\r"})[ch]
                or string.format("\\u%04x", ch:byte())
        end) .. '"'
    end
    if typeof and typeof(v) == "Color3" then return '{"color":"' .. colorToHex(v) .. '"}' end
    if t == "table" then
        local parts = {}
        if #v > 0 or next(v) == nil then
            for _, item in ipairs(v) do parts[#parts + 1] = encode(item) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        for k, item in pairs(v) do parts[#parts + 1] = encode(tostring(k)) .. ":" .. encode(item) end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end
local function decode(text)
    local ok, v = pcall(function() return HttpService:JSONDecode(text) end)
    return ok and v or nil
end
local function fromSaved(v)
    if type(v) == "table" and type(v.color) == "string" then return hexToColor(v.color) end
    return v
end
local function hasFileApi() return type(writefile) == "function" and type(readfile) == "function" end

-- Window ---------------------------------------------------------------------

function GainUI:CreateWindow(opts)
    opts = opts or {}
    local Window = {Flags = {}, Tabs = {}}
    local title = tostring(opts.Title or "GainUI")
    local subtitle = opts.Subtitle and tostring(opts.Subtitle) or nil
    local configName = opts.ConfigName and tostring(opts.ConfigName):gsub("[^%w%-_ ]", "") or nil
    local folder = tostring(opts.Folder or "GainUI")
    local configFile = configName and (folder .. "/" .. configName .. ".json") or nil
    local toggleVK = toVK(opts.ToggleKey or "RightShift") or 0xA1
    local mouseOffset = tonumber(opts.MouseOffset) or 0
    local winW = math.max(460, tonumber(opts.Size and opts.Size[1]) or 620)
    local winH = math.max(320, tonumber(opts.Size and opts.Size[2]) or 460)
    local SIDEBAR = 150
    local alive, token = true, {}
    local open = opts.Open ~= false

    -- Saved flags, read once so elements made after this start from them.
    local saved = {}
    if configFile and hasFileApi() then
        local okF, has = pcall(isfile, configFile)
        if okF and has then
            local okR, body = pcall(readfile, configFile)
            local data = okR and decode(body)
            if type(data) == "table" then saved = data end
        end
    end
    if saved.__togglekey then toggleVK = toVK(saved.__togglekey) or toggleVK end
    if saved.__accent then opts.Accent = saved.__accent end
    if tonumber(saved.__mouseoffset) then mouseOffset = tonumber(saved.__mouseoffset) end

    -- Colors
    local C = {
        bg = RGB(15, 16, 21), side = RGB(19, 20, 27), panel = RGB(22, 24, 31), card = RGB(28, 30, 39),
        cardHover = RGB(35, 38, 49), line = RGB(44, 47, 60), text = RGB(226, 229, 236), dim = RGB(138, 144, 160),
        faint = RGB(90, 96, 112), good = RGB(80, 210, 120), bad = RGB(240, 90, 90), warn = RGB(240, 180, 70),
    }
    if type(opts.Theme) == "table" then
        for k, v in pairs(opts.Theme) do local c = toColor(v); if c and C[k] then C[k] = c end end
    end
    local accentHex
    local function applyAccent(value)
        local c = toColor(value) or hexToColor("568cff")
        accentHex = colorToHex(c)
        C.accent = c
        C.accentDim = Color3.new(c.R * 0.42, c.G * 0.42, c.B * 0.42)
        C.accentHot = Color3.new(math.min(1, c.R + 0.08), math.min(1, c.G + 0.08), math.min(1, c.B + 0.08))
        C.onAccent = (0.299 * c.R + 0.587 * c.G + 0.114 * c.B > 0.62) and RGB(20, 22, 28) or RGB(255, 255, 255)
    end
    applyAccent(opts.Accent or "568cff")

    -- Saving flags: a second after the last change.
    local saveAt
    local function markChanged() if configFile then saveAt = tick() + 1 end end
    local function saveNow()
        saveAt = nil
        if not configFile or not hasFileApi() then return end
        local data = {__togglekey = KEY_NAME[toggleVK], __accent = accentHex, __mouseoffset = mouseOffset}
        for flag, el in pairs(Window.Flags) do
            local v = el.Value
            if el.Kind == "Keybind" then v = v and KEY_NAME[v] or "None" end
            data[flag] = v
        end
        pcall(makefolder, folder)
        pcall(writefile, configFile, encode(data))
    end

    -- Drawing pool ----------------------------------------------------------
    local Fade = 1
    local Pool = {sq = {}, tx = {}, ln = {}, ci = {}}
    local Cache = {sq = {}, tx = {}, ln = {}, ci = {}}
    local Used = {sq = 0, tx = 0, ln = 0, ci = 0}
    local CLASS = {sq = "Square", tx = "Text", ln = "Line", ci = "Circle"}
    local FONT = (Drawing.Fonts and (Drawing.Fonts.System or Drawing.Fonts.UI)) or 1
    local FONT_BOLD = (Drawing.Fonts and Drawing.Fonts.SystemBold) or FONT
    local imageSlots, shownImages, drawnImages = {}, {}, {}

    local function take(kind)
        local i = Used[kind] + 1
        Used[kind] = i
        local obj = Pool[kind][i]
        if not obj then
            obj = Drawing.new(CLASS[kind])
            Pool[kind][i], Cache[kind][i] = obj, {}
            if kind == "tx" then pcall(function() obj.Outline = false end) end
        end
        return obj, Cache[kind][i]
    end
    local function put(o, c, k, v) if c[k] ~= v then c[k] = v; o[k] = v end end
    local function place(o, c, k, x, y)
        if c[k .. "x"] ~= x or c[k .. "y"] ~= y then c[k .. "x"], c[k .. "y"] = x, y; o[k] = V2(x, y) end
    end
    local function rect(x, y, w, h, color, z, corner, alpha)
        if w <= 0 or h <= 0 then return end
        local o, c = take("sq")
        place(o, c, "Position", x, y) place(o, c, "Size", w, h)
        put(o, c, "Color", color) put(o, c, "Filled", true) put(o, c, "Corner", corner or 0)
        put(o, c, "ZIndex", z or 1) put(o, c, "Transparency", (alpha or 1) * Fade) put(o, c, "Visible", true)
    end
    local function border(x, y, w, h, color, z, corner, thick)
        if w <= 0 or h <= 0 then return end
        local o, c = take("sq")
        place(o, c, "Position", x, y) place(o, c, "Size", w, h)
        put(o, c, "Color", color) put(o, c, "Filled", false) put(o, c, "Thickness", thick or 1)
        put(o, c, "Corner", corner or 0) put(o, c, "ZIndex", z or 1) put(o, c, "Transparency", Fade)
        put(o, c, "Visible", true)
    end
    local measurer, widths, widthCount = nil, {}, 0
    local function textWidth(s, size, bold)
        s = tostring(s)
        local key = s .. "\1" .. size .. (bold and "b" or "")
        local known = widths[key]
        if known then return known end
        local ok, w = pcall(function()
            measurer = measurer or Drawing.new("Text")
            measurer.Visible = false
            measurer.Size, measurer.Font, measurer.Text = size, bold and FONT_BOLD or FONT, s
            return measurer.TextBounds.X
        end)
        w = (ok and type(w) == "number" and w > 0) and w or #s * size * 0.58
        if widthCount > 4000 then widths, widthCount = {}, 0 end
        widths[key], widthCount = w, widthCount + 1
        return w
    end
    local function fitText(s, room, size, bold)
        s = tostring(s)
        if textWidth(s, size, bold) <= room then return s end
        local lo, hi = 0, #s
        while lo < hi do
            local mid = math.floor((lo + hi + 1) / 2)
            if textWidth(s:sub(1, mid) .. "..", size, bold) <= room then lo = mid else hi = mid - 1 end
        end
        return s:sub(1, math.max(1, lo)) .. ".."
    end
    local function wrapText(s, room, size)
        local lines = {}
        for para in (tostring(s) .. "\n"):gmatch("(.-)\n") do
            local cur = ""
            for word in para:gmatch("%S+") do
                local try = cur == "" and word or (cur .. " " .. word)
                if cur == "" or textWidth(try, size) <= room then cur = try
                else lines[#lines + 1] = cur; cur = word end
            end
            lines[#lines + 1] = cur
        end
        return lines
    end
    local function text(s, x, y, color, size, z, bold, center)
        s = tostring(s)
        if s == "" then return end
        local o, c = take("tx")
        size = size or 13
        put(o, c, "Text", s) put(o, c, "Size", size) put(o, c, "Font", bold and FONT_BOLD or FONT)
        -- Matcha draws text higher than its position by about a third of the
        -- size; this puts the letters where the layout expects them.
        put(o, c, "Center", center and true or false)
        place(o, c, "Position", math.floor(x + 0.5), math.floor(y + size * 0.3 + 0.5))
        put(o, c, "Color", color) put(o, c, "ZIndex", z or 5) put(o, c, "Transparency", Fade) put(o, c, "Visible", true)
    end
    -- Text whose letters are centred on the line `mid`, for text in a row or
    -- a box. (Measured in Matcha: left-aligned capitals start about a quarter
    -- of the size below the position and are ~0.68 of the size tall; centred
    -- text is centred on its position both ways.)
    local function mtext(s, x, mid, color, size, z, bold, center)
        size = size or 13
        if center then text(s, x, mid - size * 0.3, color, size, z, bold, true)
        else text(s, x, mid - size * 0.89, color, size, z, bold) end
    end
    local function line(x1, y1, x2, y2, color, z, thick)
        local o, c = take("ln")
        place(o, c, "From", x1, y1) place(o, c, "To", x2, y2)
        put(o, c, "Color", color) put(o, c, "Thickness", thick or 1) put(o, c, "ZIndex", z or 5)
        put(o, c, "Transparency", Fade) put(o, c, "Visible", true)
    end
    local function circle(x, y, r, color, z, filled, thick)
        local o, c = take("ci")
        place(o, c, "Position", x, y) put(o, c, "Radius", r) put(o, c, "Color", color)
        put(o, c, "Filled", filled and true or false) put(o, c, "Thickness", thick or 1)
        pcall(put, o, c, "NumSides", 32) put(o, c, "ZIndex", z or 5) put(o, c, "Transparency", Fade)
        put(o, c, "Visible", true)
    end
    -- An image from raw bytes (a PNG or JPG); `key` names the spot.
    local function picture(key, data, x, y, w, h, z)
        if not data then return false end
        local slot = imageSlots[key]
        if not slot or slot.data ~= data then
            if slot then pcall(function() slot.obj:Remove() end) end
            local ok, obj = pcall(Drawing.new, "Image")
            if not ok then return false end
            obj.Visible = false
            pcall(function() obj.Data = data end)
            slot = {obj = obj, cache = {}, data = data}
            imageSlots[key] = slot
        end
        local o, c = slot.obj, slot.cache
        place(o, c, "Position", x, y) place(o, c, "Size", w, h)
        put(o, c, "ZIndex", z or 4) put(o, c, "Transparency", Fade)
        if not c.Visible then c.Visible = true; o.Visible = true end
        drawnImages[key] = slot
        return true
    end
    local function beginFrame()
        for k in pairs(Used) do Used[k] = 0 end
        drawnImages = {}
    end
    local function endFrame()
        for kind, list in pairs(Pool) do
            for i = Used[kind] + 1, #list do
                local c = Cache[kind][i]
                if c.Visible ~= false then c.Visible = false; list[i].Visible = false end
            end
        end
        for key, slot in pairs(shownImages) do
            if not drawnImages[key] then slot.cache.Visible = false; slot.obj.Visible = false end
        end
        shownImages = drawnImages
    end
    local function wipe()
        for kind, list in pairs(Pool) do
            for _, o in ipairs(list) do pcall(function() o.Visible = false; o:Remove() end) end
            Pool[kind], Cache[kind], Used[kind] = {}, {}, 0
        end
        for _, slot in pairs(imageSlots) do pcall(function() slot.obj.Visible = false; slot.obj:Remove() end) end
        imageSlots, shownImages = {}, {}
        if measurer then pcall(function() measurer:Remove() end) measurer = nil end
    end

    -- Input -----------------------------------------------------------------
    local mouse, mouseAt = nil, 0
    local M = {x = 0, y = 0, down = false, press = false, release = false, px = 0, py = 0,
        dragged = false, took = false, claimed = false}
    -- Each key is read once a frame, however often it is asked about.
    local keyWas, keyNow, keyFrame = {}, {}, {}
    local frameNo = 0
    local function key(vk)
        if not vk then return false, false end
        if keyFrame[vk] ~= frameNo then
            keyFrame[vk] = frameNo
            keyWas[vk] = keyNow[vk]
            local ok, down = pcall(iskeypressed, vk)
            keyNow[vk] = ok and down == true
        end
        return keyNow[vk] and not keyWas[vk], keyNow[vk]
    end
    local function readInput()
        frameNo = frameNo + 1
        -- The player (and its mouse) is a new object after a server change.
        if not mouse or tick() - mouseAt > 2 then
            mouseAt = tick()
            pcall(function() mouse = game:GetService("Players").LocalPlayer:GetMouse() end)
        end
        local ok = pcall(function() M.x, M.y = mouse.X, mouse.Y + mouseOffset end)
        if not ok then M.x, M.y = -1, -1 end
        local active = not isrbxactive or isrbxactive() ~= false
        local down = active and ismouse1pressed() == true
        M.press = down and not M.down
        M.release = M.down and not down
        M.down = down
        if M.press then M.px, M.py, M.dragged = M.x, M.y, false end
        if M.down and (math.abs(M.x - M.px) > 5 or math.abs(M.y - M.py) > 5) then M.dragged = true end
        M.took, M.claimed = false, false
    end
    local function over(x, y, w, h) return M.x >= x and M.x < x + w and M.y >= y and M.y < y + h end
    local function inside(px, py, r) return r and px >= r.x and px < r.x + r.w and py >= r.y and py < r.y + r.h end

    -- A popup (dropdown list, color picker) sits over the page: clicks that
    -- start in it are its own.
    local popup, popupRect -- the open popup's owner id, and where it was drawn last frame
    local function clicked(x, y, w, h, isPopup)
        if M.took or not M.release or M.dragged then return false end
        if not isPopup and inside(M.px, M.py, popupRect) then return false end
        if over(x, y, w, h) and M.px >= x and M.px < x + w and M.py >= y and M.py < y + h then
            M.took = true
            return true
        end
        return false
    end
    local function pressed(x, y, w, h, isPopup)
        if not M.press or M.claimed then return false end
        if not isPopup and inside(M.x, M.y, popupRect) then return false end
        return over(x, y, w, h)
    end

    -- Text boxes: while one is focused, typing goes to it, not the game.
    local focus, focusValue, backspaceAt = nil, "", 0
    local focusCommit -- called with the text when the box loses focus
    local function blur()
        if focus and focusCommit then pcall(focusCommit, focusValue) end
        focus, focusCommit = nil, nil
    end
    local function typeKeys()
        local shift = select(2, key(0xA0)) or select(2, key(0xA1)) or select(2, key(0x10))
        for vk, chars in pairs(TYPED) do
            if key(vk) then focusValue = focusValue .. chars[shift and 2 or 1] end
        end
        local bsHit, bsDown = key(0x08)
        if bsHit then focusValue = focusValue:sub(1, -2); backspaceAt = tick() + 0.45
        elseif bsDown and tick() > backspaceAt then focusValue = focusValue:sub(1, -2); backspaceAt = tick() + 0.04 end
        if key(0x0D) or key(0x1B) then blur() end
    end

    -- Waiting for a key to bind: the keybind's id, or "__toggle".
    local binding, bindHeld = nil, {}
    local bindable = {}
    for vk in pairs(KEY_LABEL) do bindable[#bindable + 1] = vk end
    local function captureKey(onPick)
        for _, vk in ipairs(bindable) do
            local hit, down = key(vk)
            if hit and not bindHeld[vk] then
                binding = nil
                if vk == 0x1B then onPick(false) -- Escape: cancel
                elseif vk == 0x08 then onPick(nil) -- Backspace: none
                else onPick(vk) end
                return
            end
            if not down then bindHeld[vk] = nil end
        end
    end

    -- Scrolling a page in whole elements: drag it, drag its bar, or Page Up /
    -- Page Down and the arrow keys while pointing at it.
    local function scrollbar(s, x, y, w, h, total, visible)
        local maxFirst = math.max(0, total - visible)
        if over(x, y, w, h) and not focus then
            if key(0x22) or key(0x28) then s.first = s.first + (keyNow[0x22] and math.max(1, visible) or 1) end
            if key(0x21) or key(0x26) then s.first = s.first - (keyNow[0x21] and math.max(1, visible) or 1) end
        end
        if pressed(x, y, w, h) then s.grab, s.grabFirst = M.y, s.first end
        if not M.down then s.grab = nil end
        if s.grab and M.dragged then
            local rowH = h / math.max(1, visible)
            s.first = s.grabFirst - math.floor((M.y - s.grab) / rowH + 0.5)
        end
        s.first = clamp(s.first, 0, maxFirst)
        if maxFirst > 0 then
            local bx, bw = x + w + 4, 6
            local barH = math.max(28, h * visible / math.max(1, total))
            local barY = y + (h - barH) * s.first / maxFirst
            local onBar = over(bx - 3, y, bw + 6, h)
            rect(bx, y, bw, h, C.card, 3, 3)
            if pressed(bx - 3, y, bw + 6, h) then
                if M.y >= barY and M.y <= barY + barH then s.bar = M.y - barY
                else s.first = s.first + (M.y < barY and -visible or visible); s.grab = nil end
                M.claimed, M.dragged = true, true
            end
            if not M.down then s.bar = nil end
            if s.bar then
                s.first = math.floor((M.y - s.bar - y) / math.max(1, h - barH) * maxFirst + 0.5)
                s.grab, M.dragged = nil, true
            end
            s.first = clamp(s.first, 0, maxFirst)
            barY = y + (h - barH) * s.first / maxFirst
            rect(bx, barY, bw, barH, s.bar and C.accent or (onBar and C.dim or C.faint), 4, 3)
        end
    end

    -- Elements ---------------------------------------------------------------
    local drag -- the slider being dragged: {id}
    local ids = 0
    local function newId() ids = ids + 1; return ids end
    local popupDraw -- set by the element whose popup is open, drawn last

    local function callback(el, ...)
        if type(el.Callback) == "function" then
            local ok, err = pcall(el.Callback, ...)
            if not ok then log("[GainUI] " .. tostring(el.Name) .. ": " .. tostring(err)) end
        end
    end
    -- An element's starting value: its saved flag, else its default. With a
    -- saved value the callback runs once so the script picks it up.
    local function startValue(el, default, convert)
        if el.Flag and saved[el.Flag] ~= nil then
            local v = fromSaved(saved[el.Flag])
            if convert then v = convert(v) end
            if v ~= nil then el.Value = v; el.loaded = true; return end
        end
        el.Value = default
    end
    local pendingLoad = {}
    local function register(el)
        if el.Flag then Window.Flags[el.Flag] = el; GainUI.Flags[el.Flag] = el end
        -- (on the next frame, so the script has finished setting up)
        if el.loaded then pendingLoad[#pendingLoad + 1] = el end
    end

    local Element = {}
    Element.__index = Element
    function Element:Set(v, silent)
        if self.Kind == "Slider" then
            v = clamp(tonumber(v) or self.Min, self.Min, self.Max)
            local inc = self.Increment
            v = round((v - self.Min) / inc) * inc + self.Min
            v = tonumber(string.format("%.6g", v))
        elseif self.Kind == "Colorpicker" then
            v = toColor(v) or self.Value
        elseif self.Kind == "Keybind" then
            v = toVK(v)
        elseif self.Kind == "Toggle" then
            v = v and true or false
        end
        local changed = v ~= self.Value or type(v) == "table"
        self.Value = v
        if changed then
            if self.Flag then markChanged() end
            if not silent and self.Kind ~= "Keybind" then callback(self, v) end
        end
        return self
    end
    function Element:Get() return self.Value end
    function Element:SetText(s) self.Text = tostring(s); return self end
    function Element:SetName(s) self.Name = tostring(s); return self end
    function Element:SetVisible(v) self.Hidden = not v; return self end
    function Element:Refresh(options, keep)
        self.Options = options or {}
        if not keep then
            if self.Multi then self.Value = {} else self.Value = self.Options[1] end
        end
        return self
    end
    -- Aliases people know from other libraries.
    Element.SetValue, Element.GetValue = Element.Set, Element.Get

    -- Height of each kind of element, at a page width.
    local function heightOf(el, w)
        local k = el.Kind
        if el.Hidden then return 0 end
        if k == "Section" then return 30 end
        if k == "Label" then return math.max(1, #wrapText(el.Text, w - 16, 13)) * 17 + 8 end
        if k == "Paragraph" then return 42 + #wrapText(el.Content, w - 24, 13) * 17 + 8 end
        if k == "Slider" then return 54 end
        if k == "Dropdown" or k == "Textbox" then return 62 end
        if k == "Image" then return (el.Height or 120) + 8 end
        if k == "Divider" then return 14 end
        return 42 -- Toggle, Button, Keybind, Colorpicker
    end

    local function card(x, y, w, h, hot)
        rect(x, y, w, h, hot and C.cardHover or C.card, 3, 6)
    end

    local DRAW = {}
    function DRAW.Section(el, x, y, w)
        mtext(el.Name:upper(), x + 2, y + 17, C.accent, 12, 5, true)
        line(x + textWidth(el.Name:upper(), 12, true) + 12, y + 17, x + w, y + 17, C.line, 2, 1)
    end
    function DRAW.Divider(el, x, y, w) line(x, y + 6, x + w, y + 6, C.line, 2, 1) end
    function DRAW.Label(el, x, y, w)
        for i, l in ipairs(wrapText(el.Text, w - 16, 13)) do
            text(l, x + 8, y + 4 + (i - 1) * 17, el.Color or C.dim, 13, 5)
        end
    end
    function DRAW.Paragraph(el, x, y, w, h)
        card(x, y, w, h - 8)
        mtext(el.Name, x + 12, y + 18, C.text, 14, 5, true)
        for i, l in ipairs(wrapText(el.Content, w - 24, 13)) do
            text(l, x + 12, y + 32 + (i - 1) * 17, C.dim, 13, 5)
        end
    end
    function DRAW.Button(el, x, y, w)
        local hot = over(x, y, w, 34) and not inside(M.x, M.y, popupRect)
        card(x, y, w, 34, hot)
        if hot then border(x, y, w, 34, C.accent, 4, 6) end
        mtext(el.Name, x + w / 2, y + 17, C.text, 13, 5, true, true)
        if clicked(x, y, w, 34) then task.spawn(callback, el) end
    end
    function DRAW.Toggle(el, x, y, w)
        local hot = over(x, y, w, 34) and not inside(M.x, M.y, popupRect)
        card(x, y, w, 34, hot)
        mtext(fitText(el.Name, w - 80, 13), x + 12, y + 17, C.text, 13, 5)
        local sx, sy, sw, sh = x + w - 50, y + 8, 38, 18
        rect(sx, sy, sw, sh, el.Value and C.accent or C.line, 4, 9)
        circle(el.Value and (sx + sw - 9) or (sx + 9), sy + 9, 6, el.Value and C.onAccent or C.dim, 6, true)
        if clicked(x, y, w, 34) then el:Set(not el.Value) end
    end
    function DRAW.Slider(el, x, y, w)
        card(x, y, w, 46)
        mtext(fitText(el.Name, w - 110, 13), x + 12, y + 15, C.text, 13, 5)
        local shown = tostring(el.Value) .. (el.Suffix or "")
        mtext(shown, x + w - 12 - textWidth(shown, 13), y + 15, C.dim, 13, 5)
        local tx, ty, tw = x + 12, y + 31, w - 24
        local frac = (el.Value - el.Min) / math.max(1e-9, el.Max - el.Min)
        rect(tx, ty, tw, 5, C.line, 4, 3)
        rect(tx, ty, math.max(5, tw * frac), 5, C.accent, 5, 3)
        circle(tx + tw * frac, ty + 2, 6, C.text, 6, true)
        if pressed(tx - 6, ty - 8, tw + 12, 21) then drag = el.id; M.claimed = true end
        if drag == el.id then
            if M.down then
                M.claimed, M.dragged = true, true
                el:Set(el.Min + clamp((M.x - tx) / tw, 0, 1) * (el.Max - el.Min))
            else drag = nil end
        end
    end
    function DRAW.Textbox(el, x, y, w)
        card(x, y, w, 54)
        mtext(fitText(el.Name, w - 24, 13), x + 12, y + 14, C.text, 13, 5)
        local bx, by, bw, bh = x + 10, y + 25, w - 20, 22
        local focused = focus == el.id
        rect(bx, by, bw, bh, C.panel, 4, 5)
        border(bx, by, bw, bh, focused and C.accent or C.line, 4, 5)
        local value = focused and focusValue or tostring(el.Value or "")
        if value == "" and not focused then
            mtext(el.Placeholder or "", bx + 8, by + 11, C.faint, 13, 5)
        else
            local caret = focused and (tick() % 1 < 0.5) and "|" or ""
            mtext(fitText(value, bw - 20, 13) .. caret, bx + 8, by + 11, C.text, 13, 5)
        end
        if clicked(bx, by, bw, bh) and not focused then
            blur()
            focus, focusValue = el.id, tostring(el.Value or "")
            focusCommit = function(v)
                if el.Numeric then
                    v = v:gsub("[^%d%.%-]", "")
                    v = tonumber(v) and v or ""
                end
                if el.ClearOnFocusLost then el.Value = "" else el:Set(v, true) end
                callback(el, v)
            end
        end
    end
    function DRAW.Keybind(el, x, y, w)
        local hot = over(x, y, w, 34) and not inside(M.x, M.y, popupRect)
        card(x, y, w, 34, hot)
        mtext(fitText(el.Name, w - 130, 13), x + 12, y + 17, C.text, 13, 5)
        local label = binding == el.id and "..." or keyLabel(el.Value)
        local cw = math.max(44, textWidth(label, 12) + 18)
        local cx = x + w - 12 - cw
        rect(cx, y + 7, cw, 20, binding == el.id and C.accentDim or C.panel, 4, 5)
        border(cx, y + 7, cw, 20, binding == el.id and C.accent or C.line, 4, 5)
        mtext(label, cx + cw / 2, y + 17, C.text, 12, 5, false, true)
        if clicked(x, y, w, 34) then blur(); binding = el.id; bindHeld = {}; for vk in pairs(keyNow) do bindHeld[vk] = keyNow[vk] end end
    end

    -- The dropdown list, below its box (above it near the window's bottom).
    local function dropdownPopup(el, bx, by, bw, bottom)
        local rowH, maxRows = 26, 7
        local count = #el.Options
        local rows = math.min(maxRows, math.max(1, count))
        local ph = rows * rowH + 8
        local py = by + 26
        if py + ph > bottom and by - ph - 4 > 0 then py = by - ph - 4 end
        return function()
            rect(bx, py, bw, ph, C.panel, 20, 6)
            border(bx, py, bw, ph, C.line, 21, 6)
            el.scroll = el.scroll or {first = 0}
            local s = el.scroll
            local maxFirst = math.max(0, count - rows)
            if over(bx, py, bw, ph) then
                if key(0x28) or key(0x22) then s.first = s.first + 1 end
                if key(0x26) or key(0x21) then s.first = s.first - 1 end
            end
            if pressed(bx, py, bw, ph, true) then s.grab, s.grabFirst = M.y, s.first; M.claimed = true end
            if not M.down then s.grab = nil end
            if s.grab and M.dragged then s.first = s.grabFirst - math.floor((M.y - s.grab) / rowH + 0.5) end
            s.first = clamp(s.first, 0, maxFirst)
            for i = s.first + 1, math.min(count, s.first + rows) do
                local option = el.Options[i]
                local ry = py + 4 + (i - s.first - 1) * rowH
                local picked = el.Multi and table.find(el.Value, option) or (not el.Multi and el.Value == option)
                if over(bx + 4, ry, bw - 8, rowH) then rect(bx + 4, ry, bw - 8, rowH, C.cardHover, 22, 5) end
                if picked then rect(bx + 4, ry + 6, 2, rowH - 12, C.accent, 23, 1) end
                mtext(fitText(tostring(option), bw - 30, 13), bx + 14, ry + 13, picked and C.text or C.dim, 13, 24,
                    picked and true or false)
                if clicked(bx + 4, ry, bw - 8, rowH, true) then
                    if el.Multi then
                        local list = {}
                        for _, v in ipairs(el.Value) do if v ~= option then list[#list + 1] = v end end
                        if not picked then list[#list + 1] = option end
                        el:Set(list)
                    else
                        el:Set(option)
                        popup = nil
                    end
                end
            end
            if maxFirst > 0 then
                local barH = math.max(16, (ph - 8) * rows / count)
                rect(bx + bw - 6, py + 4 + (ph - 8 - barH) * s.first / maxFirst, 3, barH, C.faint, 23, 2)
            end
            if count == 0 then mtext("No options", bx + 12, py + 17, C.faint, 13, 24) end
            return {x = bx, y = py, w = bw, h = ph}
        end
    end
    function DRAW.Dropdown(el, x, y, w, _, bottom)
        card(x, y, w, 54)
        mtext(fitText(el.Name, w - 24, 13), x + 12, y + 14, C.text, 13, 5)
        local bx, by, bw, bh = x + 10, y + 25, w - 20, 22
        local isOpen = popup == el.id
        local hot = over(bx, by, bw, bh) and not inside(M.x, M.y, popupRect)
        rect(bx, by, bw, bh, hot and C.cardHover or C.panel, 4, 5)
        border(bx, by, bw, bh, isOpen and C.accent or C.line, 4, 5)
        local shown
        if el.Multi then shown = #el.Value == 0 and "None" or table.concat(el.Value, ", ")
        else shown = el.Value ~= nil and tostring(el.Value) or "None" end
        mtext(fitText(shown, bw - 36, 13), bx + 8, by + 11, C.text, 13, 5)
        -- a small arrow
        local ax, ay = bx + bw - 16, by + 11
        if isOpen then line(ax - 4, ay + 2, ax, ay - 2, C.dim, 6, 1); line(ax, ay - 2, ax + 4, ay + 2, C.dim, 6, 1)
        else line(ax - 4, ay - 2, ax, ay + 2, C.dim, 6, 1); line(ax, ay + 2, ax + 4, ay - 2, C.dim, 6, 1) end
        if clicked(bx, by, bw, bh) then blur(); popup = (not isOpen) and el.id or nil; el.scroll = nil end
        if popup == el.id then popupDraw = dropdownPopup(el, bx, by, bw, bottom) end
    end

    -- The color picker: hue, saturation and brightness bars, a hex box and
    -- the accent swatches.
    local function colorPopup(el, x, y, w, bottom)
        local pw, ph = math.min(260, w), 150
        local px = x + w - pw
        local py = y + 38
        if py + ph > bottom and y - ph - 4 > 0 then py = y - ph - 4 end
        return function()
            rect(px, py, pw, ph, C.panel, 20, 6)
            border(px, py, pw, ph, C.line, 21, 6)
            el.hsv = el.hsv or {toHSV(el.Value)}
            local hsv = el.hsv
            local bars = {
                {"H", function(f) return fromHSV(f, 1, 1) end},
                {"S", function(f) return fromHSV(hsv[1], f, math.max(hsv[3], 0.25)) end},
                {"V", function(f) return fromHSV(hsv[1], hsv[2], f) end},
            }
            local segs = 24
            for i, bar in ipairs(bars) do
                local bx, by, bw = px + 26, py + 12 + (i - 1) * 24, pw - 38
                mtext(bar[1], px + 10, by + 6, C.dim, 12, 24)
                for sgi = 0, segs - 1 do
                    rect(bx + bw * sgi / segs, by, math.ceil(bw / segs) + 1, 12, bar[2]((sgi + 0.5) / segs), 22, 0)
                end
                border(bx, by, bw, 12, C.line, 23, 2)
                local f = hsv[i]
                rect(bx + bw * f - 2, by - 2, 4, 16, C.text, 24, 1)
                if pressed(bx - 4, by - 4, bw + 8, 20, true) then drag = el.id .. ":" .. i; M.claimed = true end
                if drag == el.id .. ":" .. i then
                    if M.down then
                        M.claimed, M.dragged = true, true
                        hsv[i] = clamp((M.x - bx) / bw, 0, 1)
                        el:Set(fromHSV(hsv[1], hsv[2], hsv[3]))
                    else drag = nil end
                end
            end
            -- swatches
            local sw = (pw - 20 - 9 * 4) / 10
            for i, hex in ipairs(ACCENTS) do
                local sx, sy = px + 10 + (i - 1) * (sw + 4), py + 86
                rect(sx, sy, sw, 16, hexToColor(hex), 22, 3)
                if clicked(sx, sy, sw, 16, true) then
                    el:Set(hexToColor(hex))
                    el.hsv = {toHSV(el.Value)}
                end
            end
            -- hex box
            local hx, hy, hw = px + 10, py + 112, pw - 20
            local focused = focus == el.id
            rect(hx, hy, hw, 26, C.card, 22, 5)
            border(hx, hy, hw, 26, focused and C.accent or C.line, 23, 5)
            local hexText = focused and focusValue or ("#" .. colorToHex(el.Value))
            mtext(hexText .. (focused and (tick() % 1 < 0.5) and "|" or ""), hx + 8, hy + 13, C.text, 13, 24)
            rect(hx + hw - 30, hy + 5, 22, 16, el.Value, 24, 3)
            if clicked(hx, hy, hw, 26, true) and not focused then
                blur()
                focus, focusValue = el.id, ""
                focusCommit = function(v)
                    local c = hexToColor(v)
                    if c then el:Set(c); el.hsv = {toHSV(c)} end
                end
            end
            return {x = px, y = py, w = pw, h = ph}
        end
    end
    function DRAW.Colorpicker(el, x, y, w, _, bottom)
        local hot = over(x, y, w, 34) and not inside(M.x, M.y, popupRect)
        card(x, y, w, 34, hot)
        mtext(fitText(el.Name, w - 90, 13), x + 12, y + 17, C.text, 13, 5)
        rect(x + w - 50, y + 8, 38, 18, el.Value, 5, 5)
        border(x + w - 50, y + 8, 38, 18, popup == el.id and C.accent or C.line, 6, 5)
        if clicked(x, y, w, 34) then
            blur()
            popup = popup ~= el.id and el.id or nil
            el.hsv = {toHSV(el.Value)}
        end
        if popup == el.id then popupDraw = colorPopup(el, x, y, w, bottom) end
    end
    function DRAW.Image(el, x, y, w)
        local h = el.Height or 120
        if el.data then
            local iw = el.Width and math.min(w, el.Width) or w
            picture(el.id, el.data, x + (w - iw) / 2, y, iw, h, 5)
        else
            card(x, y, w, h)
            mtext(el.failed and "Image failed to load" or "Loading image...", x + w / 2, y + h / 2, C.faint, 13, 5, false, true)
        end
    end

    -- Tabs ---------------------------------------------------------------------
    local current
    -- Switching tabs: the page slides up and fades in, and the sidebar's
    -- highlight glides to the new tab.
    local SWITCH_SECONDS, SWITCH_SLIDE = 0.2, 10
    local switchAt, selY, frameDt = 0, nil, 0
    local Tab = {}
    Tab.__index = Tab
    local function add(tab, kind, o)
        o = type(o) == "table" and o or {Name = o}
        local el = setmetatable({}, Element)
        for k, v in pairs(o) do el[k] = v end
        el.Kind, el.id = kind, newId()
        el.Name = tostring(o.Name or o.Title or o.Text or kind)
        tab.elements[#tab.elements + 1] = el
        return el
    end
    function Tab:Section(name) return add(self, "Section", {Name = name}) end
    function Tab:Divider() return add(self, "Divider", {}) end
    function Tab:Label(o)
        local el = add(self, "Label", type(o) == "table" and o or {Text = o})
        el.Text = tostring((type(o) == "table" and (o.Text or o.Name)) or o or "")
        if type(o) == "table" and o.Color then el.Color = toColor(o.Color) end
        return el
    end
    function Tab:Paragraph(o)
        local el = add(self, "Paragraph", o)
        el.Content = tostring(o.Content or o.Text or "")
        function el:Set(t, c)
            if c then self.Name, self.Content = tostring(t), tostring(c) else self.Content = tostring(t) end
            return self
        end
        return el
    end
    function Tab:Button(o) return add(self, "Button", o) end
    function Tab:Toggle(o)
        local el = add(self, "Toggle", o)
        startValue(el, o.Default == true or o.CurrentValue == true, function(v) return v == true end)
        register(el)
        return el
    end
    function Tab:Slider(o)
        local el = add(self, "Slider", o)
        local range = o.Range or {}
        el.Min = tonumber(o.Min or range[1]) or 0
        el.Max = tonumber(o.Max or range[2]) or 100
        if el.Max <= el.Min then el.Max = el.Min + 1 end
        el.Increment = tonumber(o.Increment or o.Rounding) or 1
        if el.Increment <= 0 then el.Increment = 1 end
        el.Suffix = o.Suffix and tostring(o.Suffix) or nil
        startValue(el, clamp(tonumber(o.Default or o.CurrentValue) or el.Min, el.Min, el.Max), tonumber)
        el.Value = clamp(el.Value, el.Min, el.Max)
        register(el)
        return el
    end
    function Tab:Dropdown(o)
        local el = add(self, "Dropdown", o)
        el.Options = o.Options or o.Values or {}
        el.Multi = o.Multi == true or o.MultipleOptions == true
        local default = o.Default or o.CurrentOption
        if el.Multi then
            if type(default) ~= "table" then default = default ~= nil and {default} or {} end
        elseif type(default) == "table" then default = default[1] end
        startValue(el, default, function(v)
            if el.Multi then return type(v) == "table" and v or nil end
            return type(v) ~= "table" and v or nil
        end)
        register(el)
        return el
    end
    function Tab:Textbox(o)
        local el = add(self, "Textbox", o)
        el.Placeholder = o.Placeholder or o.PlaceholderText or ""
        el.Numeric = o.Numeric == true
        el.ClearOnFocusLost = o.ClearOnFocusLost == true or o.RemoveTextAfterFocusLost == true
        startValue(el, tostring(o.Default or ""), tostring)
        register(el)
        return el
    end
    function Tab:Keybind(o)
        local el = add(self, "Keybind", o)
        el.Mode = o.Mode or "Press" -- "Press", "Toggle" or "Hold"
        el.State = false
        startValue(el, toVK(o.Default or o.CurrentKeybind), toVK)
        if el.Flag and saved[el.Flag] == "None" then el.Value = nil end
        -- A saved key doesn't fire the callback (it isn't a key press).
        el.loaded = false
        register(el)
        return el
    end
    function Tab:Colorpicker(o)
        local el = add(self, "Colorpicker", o)
        startValue(el, toColor(o.Default or o.Color) or C.accent, toColor)
        register(el)
        return el
    end
    function Tab:Image(o)
        local el = add(self, "Image", type(o) == "table" and o or {Url = o})
        el.Height = tonumber(el.Height) or 120
        if el.Data then el.data = el.Data
        elseif el.Url then
            task.spawn(function()
                local ok, body = pcall(function() return game:HttpGet(el.Url) end)
                if ok and type(body) == "string" and #body > 8 then el.data = body else el.failed = true end
            end)
        end
        return el
    end
    -- Aliases people know from other libraries.
    for _, kind in ipairs({"Section", "Divider", "Label", "Paragraph", "Button", "Toggle", "Slider", "Dropdown",
        "Textbox", "Keybind", "Colorpicker", "Image"}) do
        Tab["Add" .. kind], Tab["Create" .. kind] = Tab[kind], Tab[kind]
    end
    Tab.AddInput, Tab.CreateInput, Tab.Input = Tab.Textbox, Tab.Textbox, Tab.Textbox
    Tab.AddColorPicker, Tab.CreateColorPicker, Tab.ColorPicker = Tab.Colorpicker, Tab.Colorpicker, Tab.Colorpicker

    function Window:Tab(name)
        local tab = setmetatable({Name = tostring(name or "Tab"), elements = {}, scroll = {first = 0}}, Tab)
        -- The built-in settings tab stays last.
        local at = #self.Tabs + 1
        if self.Tabs[#self.Tabs] and self.Tabs[#self.Tabs].builtin then at = #self.Tabs end
        table.insert(self.Tabs, at, tab)
        current = current or tab
        return tab
    end
    Window.CreateTab, Window.AddTab = Window.Tab, Window.Tab
    function Window:SelectTab(tab)
        if type(tab) == "string" then
            for _, t in ipairs(self.Tabs) do if t.Name == tab then tab = t break end end
        end
        if type(tab) == "table" and tab ~= current then current = tab; popup = nil; blur(); switchAt = tick() end
    end

    -- Notifications ------------------------------------------------------------
    local notes = {}
    function Window:Notify(o)
        o = type(o) == "table" and o or {Title = tostring(o)}
        notes[#notes + 1] = {title = tostring(o.Title or "Notice"), content = o.Content and tostring(o.Content) or nil,
            dur = tonumber(o.Duration) or 4, at = tick()}
        while #notes > 5 do table.remove(notes, 1) end
    end

    -- Window state ---------------------------------------------------------------
    local function viewport()
        local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
        return ok and vp or V2(1920, 1080)
    end
    local win = {w = winW, h = winH}
    do
        local vp = viewport()
        win.x = math.floor(math.max(10, (vp.X - winW) / 2))
        win.y = math.floor(math.max(40, (vp.Y - winH) / 2))
    end
    local grabbed

    function Window:SetAccent(c) applyAccent(c); markChanged() end
    function Window:GetAccent() return C.accent end
    function Window:SetToggleKey(k) toggleVK = toVK(k) or toggleVK; markChanged() end
    function Window:GetToggleKey() return KEY_NAME[toggleVK] end
    function Window:SetTitle(t, sub) title = tostring(t); if sub ~= nil then subtitle = tostring(sub) end end
    function Window:Toggle(v) if v == nil then open = not open else open = v and true or false end; if not open then blur(); popup = nil end end
    function Window:IsOpen() return open end
    function Window:Save() saveNow() end

    -- The built-in Settings tab.
    if opts.Settings ~= false then
        local settings = Window:Tab("Settings")
        settings.builtin = true
        settings:Section("Menu")
        local keyEl = settings:Keybind({Name = "Show / hide key", Default = toggleVK})
        keyEl.menuKey = true
        local accentEl = settings:Colorpicker({Name = "Accent color", Default = C.accent, Callback = function(c)
            applyAccent(c); markChanged()
        end})
        accentEl.menuAccent = true
        settings:Slider({Name = "Mouse offset (if clicks land off)", Min = -40, Max = 40, Default = mouseOffset,
            Suffix = " px", Callback = function(v) mouseOffset = v; markChanged() end})
        settings:Section("Script")
        if configFile then
            settings:Button({Name = "Reset saved settings", Callback = function()
                for _, el in pairs(Window.Flags) do el.loaded = nil end
                pcall(function() if delfile then delfile(configFile) end end)
                Window:Notify({Title = "Settings reset", Content = "Saved values are cleared for the next run."})
            end})
        end
        settings:Button({Name = "Unload", Callback = function() Window:Destroy() end})
        settings:Label({Text = "Made with GainUI " .. GainUI.Version, Color = C.faint})
        Window.SettingsTab = settings
        current = nil
    end

    -- Drawing a frame ------------------------------------------------------------
    local OPEN_SECONDS, CLOSE_SECONDS, SLIDE = 0.28, 0.2, 40
    local shown, lastFrame = 0, nil
    local lastGrab

    local function drawPage(tab, x, y, w, h)
        local s = tab.scroll
        local list = {}
        for _, el in ipairs(tab.elements) do if not el.Hidden then list[#list + 1] = el end end
        s.first = clamp(s.first, 0, math.max(0, #list - 1))
        local cy, count = y, 0
        local bottom = y + h
        for i = s.first + 1, #list do
            local el = list[i]
            local eh = heightOf(el, w)
            if cy + eh - 8 > bottom and count > 0 then break end
            local fn = DRAW[el.Kind]
            if fn then fn(el, x, cy, w, eh, bottom) end
            cy = cy + eh
            count = count + 1
        end
        if #list == 0 then text("Nothing here yet.", x + 4, y + 4, C.faint, 13, 5) end
        -- Visible count for the bar: how many fit from the end, so the last
        -- page ends flush.
        local fromEnd, room = 0, h
        for i = #list, 1, -1 do
            room = room - heightOf(list[i], w)
            if room < -8 then break end
            fromEnd = fromEnd + 1
        end
        scrollbar(s, x, y, w, h, #list, math.max(1, fromEnd))
    end

    local function drawWindow(slide)
        local vp = viewport()
        local w, h = math.min(win.w, vp.X - 10), math.min(win.h, vp.Y - 10)
        local x, y = win.x, win.y + math.floor(slide or 0)

        -- Drag by the title area.
        if pressed(x, y, SIDEBAR, 52) and not slide then grabbed = {M.x - x, M.y - y}; M.claimed = true end
        if not M.down then grabbed = nil end
        if grabbed then
            win.x = math.floor(clamp(M.x - grabbed[1], 0, vp.X - 60))
            win.y = math.floor(clamp(M.y - grabbed[2], 0, vp.Y - 40))
            x, y = win.x, win.y
            M.dragged = true
        end

        rect(x - 1, y - 1, w + 2, h + 2, C.line, 0, 11)
        rect(x, y, w, h, C.bg, 1, 10)
        rect(x, y, SIDEBAR, h, C.side, 1, 10)
        rect(x + SIDEBAR - 10, y, 10, h, C.side, 1, 0)
        line(x + SIDEBAR, y, x + SIDEBAR, y + h, C.line, 2, 1)

        -- Title
        text(fitText(title, SIDEBAR - 28, 16, true), x + 16, y + 14, C.text, 16, 5, true)
        if subtitle then text(fitText(subtitle, SIDEBAR - 28, 12), x + 16, y + 33, C.accent, 12, 5) end

        -- Tabs. The highlight is drawn once, where it is on its way to the
        -- selected tab (kept relative to the window, so dragging doesn't lag).
        current = current or Window.Tabs[1]
        local ty = y + 62
        for i, tab in ipairs(Window.Tabs) do
            if tab == current then
                local target = 62 + (i - 1) * 34
                selY = selY and (selY + (target - selY) * math.min(1, frameDt * 16)) or target
                if math.abs(target - selY) < 0.5 then selY = target end
            end
        end
        if selY then
            rect(x + 8, y + selY, SIDEBAR - 16, 30, C.card, 2, 6)
            rect(x + 8, y + selY + 8, 2, 14, C.accent, 3, 1)
        end
        for _, tab in ipairs(Window.Tabs) do
            local sel = tab == current
            local hot = over(x + 8, ty, SIDEBAR - 16, 30)
            if hot and not sel then
                rect(x + 8, ty, SIDEBAR - 16, 30, C.panel, 2, 6)
            end
            mtext(fitText(tab.Name, SIDEBAR - 40, 13), x + 22, ty + 15, sel and C.text or C.dim, 13, 5, sel)
            if clicked(x + 8, ty, SIDEBAR - 16, 30) then Window:SelectTab(tab) end
            ty = ty + 34
        end

        -- Footer: the key that hides the window.
        local hint = keyLabel(toggleVK) .. " hides"
        text(fitText(hint, SIDEBAR - 28, 12), x + 16, y + h - 26, C.faint, 12, 5)

        -- Page (sliding in after a switch)
        local px, py = x + SIDEBAR + 16, y + 16
        local pw, ph = w - SIDEBAR - 42, h - 32
        if current then
            local t = math.min(1, (tick() - switchAt) / SWITCH_SECONDS)
            local eased = 1 - (1 - t) ^ 3
            local fade = Fade
            Fade = fade * eased
            local slideY = math.floor((1 - eased) * SWITCH_SLIDE + 0.5)
            text(current.Name, px, py + slideY, C.text, 18, 5, true)
            drawPage(current, px, py + 34 + slideY, pw, ph - 34)
            Fade = fade
        end
        return over(x, y, w, h)
    end

    local function drawNotes()
        if #notes == 0 then return end
        local vp = viewport()
        local nw = 280
        local ny = vp.Y - 16
        local now = tick()
        for i = #notes, 1, -1 do
            local n = notes[i]
            local age = now - n.at
            if age > n.dur + 0.3 then
                table.remove(notes, i)
            else
                local lines = n.content and wrapText(n.content, nw - 28, 13) or {}
                local nh = 36 + #lines * 17
                local a = math.min(1, age / 0.2, (n.dur + 0.3 - age) / 0.3)
                local slide = (1 - math.min(1, age / 0.2)) * 30
                ny = ny - nh
                Fade = a
                local nx = vp.X - nw - 16 + slide
                rect(nx - 1, ny - 1, nw + 2, nh + 2, C.line, 40, 8)
                rect(nx, ny, nw, nh, C.bg, 41, 7)
                rect(nx, ny + 10, 3, nh - 20, C.accent, 42, 1)
                text(fitText(n.title, nw - 28, 14, true), nx + 14, ny + 10, C.text, 14, 43, true)
                for li, l in ipairs(lines) do text(l, nx + 14, ny + 30 + (li - 1) * 17, C.dim, 13, 43) end
                -- time left
                rect(nx + 14, ny + nh - 4, (nw - 28) * math.max(0, 1 - age / n.dur), 2, C.accentDim, 42, 1)
                Fade = 1
                ny = ny - 8
            end
        end
    end

    -- Keybinds fire whether the window is open or not.
    local function runKeybinds()
        if binding or focus then return end
        for _, tab in ipairs(Window.Tabs) do
            for _, el in ipairs(tab.elements) do
                if el.Kind == "Keybind" and el.Value and not el.menuKey then
                    local hit, down = key(el.Value)
                    if el.Mode == "Hold" then
                        if down ~= el.State then el.State = down; callback(el, down) end
                    elseif hit then
                        if el.Mode == "Toggle" then el.State = not el.State; callback(el, el.State)
                        else callback(el) end
                    end
                end
            end
        end
    end

    local function frame()
        readInput()
        -- Binding a key
        if binding then
            local el
            for _, tab in ipairs(Window.Tabs) do
                for _, e in ipairs(tab.elements) do if e.id == binding then el = e end end
            end
            captureKey(function(vk)
                if vk == false or not el then return end
                el.Value = vk
                if el.menuKey then toggleVK = vk or toggleVK; el.Value = toggleVK end
                if el.Flag or el.menuKey then markChanged() end
                if type(el.Changed) == "function" then pcall(el.Changed, vk and KEY_NAME[vk] or "None") end
                -- so the new key doesn't also fire on this press
                keyWas[vk or 0], keyNow[vk or 0] = true, true
            end)
        elseif not focus and key(toggleVK) then
            Window:Toggle()
        end
        runKeybinds()

        local now = tick()
        local dt = math.min(0.05, now - (lastFrame or now))
        lastFrame = now
        frameDt = dt
        if open then shown = math.min(1, shown + dt / OPEN_SECONDS)
        else shown = math.max(0, shown - dt / CLOSE_SECONDS) end

        beginFrame()
        local overWindow = false
        if shown > 0 then
            local eased = 1 - (1 - shown) ^ 3
            if open and focus then typeKeys() end
            -- Clicking anywhere else ends typing and closes a popup.
            if M.press and focus and not inside(M.x, M.y, popupRect) then
                -- (the click still reaches whatever it is on)
                blur()
            end
            if M.release and popup and not M.took and not inside(M.px, M.py, popupRect) then
                -- (the click only closes it, so clicking its box doesn't reopen it)
                popup, popupRect = nil, nil
                M.took = true
            end
            if shown < 1 then M.press, M.release = false, false end
            Fade = eased
            popupDraw = nil
            overWindow = drawWindow(shown < 1 and (1 - eased) * SLIDE or nil)
            if popupDraw and popup then
                popupRect = popupDraw()
                overWindow = overWindow or inside(M.x, M.y, popupRect)
            else
                popupRect = nil
            end
            Fade = 1
        end
        drawNotes()
        endFrame()
        if saveAt and tick() > saveAt then saveNow() end

        -- Keep clicks and typing on the window from reaching the game.
        local grab = open and (overWindow or focus ~= nil or binding ~= nil)
        if grab ~= lastGrab and type(setrobloxinput) == "function" then
            lastGrab = grab
            pcall(setrobloxinput, not grab)
        end
    end

    -- Keep the menu key element and accent picker in step with the window.
    local function syncSettings()
        if not Window.SettingsTab then return end
        for _, el in ipairs(Window.SettingsTab.elements) do
            if el.menuKey and binding ~= el.id then el.Value = toggleVK end
            if el.menuAccent and popup ~= el.id then el.Value = C.accent end
        end
    end

    -- Running --------------------------------------------------------------------
    local conn
    local lastError
    local function step()
        if not alive then return end
        syncSettings()
        if #pendingLoad > 0 then
            local list = pendingLoad
            pendingLoad = {}
            for _, el in ipairs(list) do callback(el, el.Value) end
        end
        local ok, err = pcall(frame)
        if not ok and tostring(err) ~= lastError then
            lastError = tostring(err)
            log("[GainUI] " .. lastError)
        end
    end
    -- A connection keeps firing after the script that made it has finished
    -- (a loop in a spawned thread may not, in Matcha).
    local okC = pcall(function() conn = RunService.RenderStepped:Connect(step) end)
    if not okC or not conn then
        task.spawn(function()
            while alive do step(); task.wait() end
        end)
    end

    function Window:Destroy()
        if not alive then return end
        alive = false
        if saveAt then saveNow() end
        if conn then pcall(function() conn:Disconnect() end) end
        pcall(wipe)
        if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
        for flag, el in pairs(self.Flags) do if GainUI.Flags[flag] == el then GainUI.Flags[flag] = nil end end
        for i, w in ipairs(GainUI.Windows) do if w == self then table.remove(GainUI.Windows, i) break end end
        if type(opts.OnUnload) == "function" then pcall(opts.OnUnload) end
    end
    Window.Unload = Window.Destroy
    -- What is on screen as text, for checking a layout from a script.
    function Window:Dump()
        local out = {}
        for i in ipairs(Pool.tx) do
            local c = Cache.tx[i]
            if c.Visible then out[#out + 1] = string.format("%d,%d %s", c.Positionx, c.Positiony, c.Text) end
        end
        return table.concat(out, "\n")
    end

    GainUI.Windows[#GainUI.Windows + 1] = Window
    return Window
end
GainUI.Window = GainUI.CreateWindow

function GainUI:Notify(o)
    local w = self.Windows[#self.Windows]
    if w then w:Notify(o) end
end
function GainUI:Destroy()
    for i = #self.Windows, 1, -1 do self.Windows[i]:Destroy() end
end

-- Matcha's loadstring drops return values, so the library is also left in
-- _G: `loadstring(...)() or _G.GainUI` works everywhere.
_G.GainUI = GainUI
return GainUI
