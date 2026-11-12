local Binger = {
Version = "1.0.0",
Flags = {},
Windows = {},
Tabs = {},
_binds = {},
_conns = {},
_drag = nil,
_listen = nil,
}
local Svc = setmetatable({}, {
__index = function(t, k)
local s = game:GetService(k)
rawset(t, k, s)
return s
end,
})
local LP = Svc.Players.LocalPlayer
local GENV = (getgenv and getgenv()) or _G
if type(GENV.__hh_ui_unload) == "function" then
pcall(GENV.__hh_ui_unload)
end
GENV.__hh_ui_unload = function()
Binger:Unload()
end
local UDim2new, UDim2off, UDim2sc, V2, C3 = UDim2.new, UDim2.fromOffset, UDim2.fromScale, Vector2.new, Color3.fromRGB
local AutoY, AutoX, AutoXY = Enum.AutomaticSize.Y, Enum.AutomaticSize.X, Enum.AutomaticSize.XY
local LEFT, RIGHT, CENTER = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right, Enum.TextXAlignment.Center
local UIT = Enum.UserInputType
local FS = {}
do
local function fn(f)
return type(f) == "function"
end
FS.can = fn(writefile) and fn(readfile) and fn(isfile)
function FS.dir(p)
if fn(isfolder) and fn(makefolder) then
pcall(function()
if not isfolder(p) then
makefolder(p)
end
end)
end
end
function FS.read(p)
if not FS.can then
return nil
end
local ok, r = pcall(function()
if isfile(p) then
return readfile(p)
end
end)
return ok and r or nil
end
function FS.write(p, d)
if FS.can then
pcall(writefile, p, d)
end
end
function FS.json(p)
local r = FS.read(p)
if r then
local ok, t = pcall(Svc.HttpService.JSONDecode, Svc.HttpService, r)
if ok and type(t) == "table" then
return t
end
end
return nil
end
function FS.saveJson(p, t)
local ok, r = pcall(Svc.HttpService.JSONEncode, Svc.HttpService, t)
if ok then
FS.write(p, r)
end
end
function FS.list(p)
if fn(listfiles) then
local ok, r = pcall(function()
if fn(isfolder) and not isfolder(p) then
return {}
end
return listfiles(p)
end)
if ok and type(r) == "table" then
return r
end
end
return {}
end
function FS.del(p)
if fn(delfile) then
pcall(delfile, p)
end
end
FS.dir("BingerUI")
FS.dir("BingerUI/assets")
FS.dir("BingerUI/configs")
end
Binger.FS = FS
local Assets = {}
do
local B64 = {
}
local decode = (crypt and (crypt.base64decode or crypt.base64_decode or (crypt.base64 and crypt.base64.decode)))
or base64_decode
or (base64 and base64.decode)
if not decode then
local map = {}
local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
for i = 1, 64 do
map[string.byte(chars, i)] = i - 1
end
decode = function(s)
s = string.gsub(s, "[^%w%+/]", "")
local len = #s
local out = buffer.create((len * 3) // 4)
local bits, nbits, o = 0, 0, 0
for i = 1, len do
bits = bit32.bor(bit32.lshift(bits, 6), map[string.byte(s, i)])
nbits += 6
if nbits >= 8 then
nbits -= 8
buffer.writeu8(out, o, bit32.band(bit32.rshift(bits, nbits), 255))
o += 1
bits = bit32.band(bits, bit32.lshift(1, nbits) - 1)
end
end
return buffer.tostring(out)
end
end
local BASE = "https://raw.githubusercontent.com/FreakazoidBingah/bx-core/main/"
local gca = getcustomasset or getsynasset
if gca and FS.can then
local missing = 0
for _, name in ipairs({ "icons", "glow", "shadow", "petal" }) do
local path = "BingerUI/assets/b2_" .. name .. ".png"
pcall(function()
if not isfile(path) and B64[name] then
writefile(path, decode(B64[name]))
end
if isfile(path) then
Assets[name] = gca(path)
end
end)
if not Assets[name] and BASE then
missing += 1
task.spawn(function()
local ok, body = pcall(game.HttpGet, game, BASE .. "b2_" .. name .. ".png")
if ok and type(body) == "string" and string.sub(body, 2, 4) == "PNG" then
pcall(function()
writefile(path, body)
Assets[name] = gca(path)
end)
end
missing -= 1
end)
end
end
local t0 = os.clock()
while missing > 0 and os.clock() - t0 < 6 do
task.wait()
end
end
end
Binger.Assets = Assets
local ICON_NAMES = {"home", "zap", "gauge", "cpu", "eye", "user", "users", "sword", "target", "settings", "palette", "star", "play", "check", "x", "search", "chevdown", "chevright", "minus", "keyboard", "save", "folder", "trash", "refresh", "bell", "info", "alert", "shield", "layers", "image", "feather", "globe", "monitor", "sparkles", "grip", "mappin", "sliders", "power", "moon", "sun", "lock", "crown", "heart", "code", "plus", "wind", "move", "clock", "copy", "map", "swords", "party", "castle", "bot", "clapper", "package", "packageopen", "webhook", "skull", "listordered", "timer", "userminus", "gift", "repeat", "undo", "store", "bag", "flame", "crosshair", "arrowup", "cloud", "cloudsun", "dices", "wrench", "gem", "bird", "footprints", "grid", "ban", "chart", "ticket", "gamepad", "shirt", "activity", "languages", "hash", "share", "edit"
}
local ICON_INDEX = {}
for i, n in ipairs(ICON_NAMES) do
ICON_INDEX[n] = i - 1
end
do
local alias = {
["party-popper"] = "party", clapperboard = "clapper", ["package-open"] = "packageopen",
["list-ordered"] = "listordered", list = "listordered", ["user-minus"] = "userminus",
["rotate-ccw"] = "undo", ["shopping-bag"] = "bag", ["arrow-up"] = "arrowup", ["cloud-sun"] = "cloudsun",
["grid-3x3"] = "grid", ["chart-line"] = "chart", ["gamepad-2"] = "gamepad", gamepad2 = "gamepad",
["trash-2"] = "trash", ["share-2"] = "share", ["chevron-down"] = "chevdown", ["chevron-right"] = "chevright",
["map-pin"] = "mappin", pencil = "edit", ["sliders-horizontal"] = "sliders", sword = "sword",
["alert-triangle"] = "alert", ["triangle-alert"] = "alert", ["circle-help"] = "info", ["log-out"] = "power",
["refresh-cw"] = "refresh", ["rotate-cw"] = "refresh", ["mouse-pointer"] = "move", timer = "timer",
}
for k, v in pairs(alias) do
if ICON_INDEX[v] and not ICON_INDEX[k] then
ICON_INDEX[k] = ICON_INDEX[v]
end
end
end
Binger.Icons = ICON_NAMES
local function hex(h)
return Color3.fromHex(h)
end
local THEMES = {
{ Id = "crimson", Name = "Crimson Sovereign", bg = hex("#0c0609"), surface = hex("#1c0b12"), text = hex("#f6ebe0"), accent = hex("#e3b54f"), accent2 = hex("#c3203e") },
{ Id = "ivory", Name = "Ivory Abyss", bg = hex("#09080d"), surface = hex("#17141f"), text = hex("#f2efe8"), accent = hex("#c3a6ff"), accent2 = hex("#5b2a86") },
{ Id = "sakura", Name = "Sakura Night", bg = hex("#0d0912"), surface = hex("#1b1424"), text = hex("#fbeef6"), accent = hex("#ff8fc4"), accent2 = hex("#7b5cff") },
{ Id = "neon", Name = "Neon Tokyo", bg = hex("#05060d"), surface = hex("#0e1222"), text = hex("#e9f6ff"), accent = hex("#2ef2ff"), accent2 = hex("#ff2bd6") },
{ Id = "moon", Name = "Moonlit Shrine", bg = hex("#070b12"), surface = hex("#111a28"), text = hex("#e8eef7"), accent = hex("#9fd4ff"), accent2 = hex("#ff6b6b") },
{ Id = "black", Name = "Pure Black", bg = hex("#000000"), surface = hex("#0b0b0c"), text = hex("#ececec"), accent = hex("#f2f2f2"), accent2 = hex("#7c7c80") },
{ Id = "storm", Name = "Stormy Night", bg = hex("#080b10"), surface = hex("#131a23"), text = hex("#dfe7ef"), accent = hex("#7fa8d1"), accent2 = hex("#46566b") },
{ Id = "galaxy", Name = "Galaxy", bg = hex("#06030e"), surface = hex("#130b25"), text = hex("#efe9ff"), accent = hex("#a86bff"), accent2 = hex("#3f8cff") },
}
Binger.Themes = THEMES
local T = {}
local function derive(th)
T.bg, T.surface, T.text, T.accent, T.accent2 = th.bg, th.surface, th.text, th.accent, th.accent2
T.navIcon = th.navIcon
T.muted = th.text:Lerp(th.bg, 0.42)
T.faint = th.text:Lerp(th.bg, 0.66)
T.line = th.bg:Lerp(th.text, 0.11)
T.lineStrong = th.bg:Lerp(th.accent, 0.42)
T.panel = th.bg:Lerp(th.surface, 0.9)
T.field = th.bg:Lerp(th.surface, 0.35)
T.hover = th.surface:Lerp(th.text, 0.07)
T.accentMix = th.accent:Lerp(th.accent2, 0.45)
local a = th.accent
T.onAccent = (0.299 * a.R + 0.587 * a.G + 0.114 * a.B) > 0.6 and th.bg:Lerp(Color3.new(0, 0, 0), 0.6) or Color3.new(1, 1, 1)
T.ok = hex("#4ade80")
T.warn = hex("#fbbf24")
T.err = hex("#f87171")
T.white = Color3.new(1, 1, 1)
T.black = Color3.new(0, 0, 0)
end
derive(THEMES[1])
Binger.Palette = T
local Reg = {}
local function resolve(key)
if type(key) == "function" then
return key(T)
end
return T[key]
end
local InfoCache = {}
local function TI(t, style, dir)
local k = tostring(t) .. tostring(style) .. tostring(dir)
local i = InfoCache[k]
if not i then
i = TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
InfoCache[k] = i
end
return i
end
local function tween(obj, props, t, style, dir)
local tw = Svc.TweenService:Create(obj, TI(t or 0.22, style, dir), props)
tw:Play()
return tw
end
Binger.Tween = tween
local function bind(obj, prop, key)
local list = Reg[obj]
if not list then
list = {}
Reg[obj] = list
end
list[prop] = key
obj[prop] = resolve(key)
end
local function forget(inst)
if not inst then
return
end
Reg[inst] = nil
for _, d in ipairs(inst:GetDescendants()) do
Reg[d] = nil
end
end
local function refresh(obj, t)
local list = Reg[obj]
if not list then
return
end
local props
for p, k in pairs(list) do
local v = resolve(k)
local ty = typeof(v)
if not t or ty == "ColorSequence" or ty == "NumberSequence" or ty == "boolean" then
obj[p] = v
else
props = props or {}
props[p] = v
end
end
if props then
tween(obj, props, t)
end
end
local function seq(...)
local c = { ... }
if #c == 1 then
return ColorSequence.new(c[1])
end
local kps = {}
for i, col in ipairs(c) do
kps[i] = ColorSequenceKeypoint.new((i - 1) / (#c - 1), col)
end
return ColorSequence.new(kps)
end
local function grad(...)
local keys = { ... }
return function(t)
local cols = {}
for i, k in ipairs(keys) do
cols[i] = (type(k) == "string" and t[k]) or (type(k) == "function" and k(t)) or k
end
return seq(table.unpack(cols))
end
end
local function nseq(...)
local v = { ... }
local kps = {}
for i = 1, #v, 2 do
kps[#kps + 1] = NumberSequenceKeypoint.new(v[i], v[i + 1])
end
return NumberSequence.new(kps)
end
local function New(class, props, children)
local o = Instance.new(class)
local parent, theme
if props then
for k, v in pairs(props) do
if k == "Parent" then
parent = v
elseif k == "Theme" then
theme = v
else
o[k] = v
end
end
end
if theme then
for p, key in pairs(theme) do
bind(o, p, key)
end
end
if children then
for _, c in ipairs(children) do
c.Parent = o
end
end
if parent then
o.Parent = parent
end
return o
end
Binger.New = New
local function Corner(o, r)
return New("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = o })
end
local function Stroke(o, key, transp, thick)
return New("UIStroke", {
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Thickness = thick or 1,
Transparency = transp or 0,
Theme = key and { Color = key } or nil,
Parent = o,
})
end
local function Pad(o, t, r, b, l)
return New("UIPadding", {
PaddingTop = UDim.new(0, t or 0),
PaddingRight = UDim.new(0, r or t or 0),
PaddingBottom = UDim.new(0, b or t or 0),
PaddingLeft = UDim.new(0, l or r or t or 0),
Parent = o,
})
end
local function List(o, dir, pad, ha, va)
return New("UIListLayout", {
FillDirection = dir or Enum.FillDirection.Vertical,
Padding = UDim.new(0, pad or 0),
HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
VerticalAlignment = va or Enum.VerticalAlignment.Top,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = o,
})
end
local F = {
body = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular),
medium = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium),
semi = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold),
bold = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold),
display = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold),
}
Binger.Fonts = F
local function Label(p)
return New("TextLabel", {
BackgroundTransparency = 1,
FontFace = p.Font or F.body,
TextSize = p.Size or 14,
Text = p.Text or "",
TextXAlignment = p.AlignX or LEFT,
TextYAlignment = p.AlignY or Enum.TextYAlignment.Center,
TextWrapped = p.Wrap or false,
TextTruncate = p.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
RichText = p.Rich or false,
Size = p.Dim or UDim2new(1, 0, 0, (p.Size or 14) + 4),
AutomaticSize = p.Auto or Enum.AutomaticSize.None,
Position = p.Pos or UDim2new(),
AnchorPoint = p.Anchor or V2(0, 0),
LayoutOrder = p.Order or 0,
ZIndex = p.Z or 1,
Theme = { TextColor3 = p.Color or "text" },
Parent = p.Parent,
})
end
local function Icon(name, size, colorKey, parent)
local props = {
BackgroundTransparency = 1,
Size = UDim2off(size or 18, size or 18),
ScaleType = Enum.ScaleType.Fit,
Theme = { ImageColor3 = colorKey or "text" },
Parent = parent,
}
if type(name) == "string" and (name:find("^rbxasset") or name:find("^rbxthumb") or name:find("^http")) then
props.Image = name
else
local i = ICON_INDEX[name or ""]
if i and Assets.icons then
props.Image = Assets.icons
props.ImageRectSize = V2(64, 64)
props.ImageRectOffset = V2((i % 8) * 64, math.floor(i / 8) * 64)
else
props.Image = ""
end
end
return New("ImageLabel", props)
end
Binger.Icon = Icon
local function hover(obj, enter, leave)
obj.MouseEnter:Connect(enter)
obj.MouseLeave:Connect(leave)
end
Binger.Prefs = {
theme = "crimson",
accent = nil,
accent2 = nil,
scale = 1,
opacity = 0.04,
panel = 0.35,
petals = nil,
lite = nil,
button = nil,
buttonPos = nil,
watermark = false,
keylist = false,
blur = false,
key = nil,
autoload = nil,
}
do
local saved = FS.json("BingerUI/prefs.json")
if saved then
for k, v in pairs(saved) do
Binger.Prefs[k] = v
end
end
end
local prefToken = 0
Binger.Touch = Svc.UserInputService.TouchEnabled and not Svc.UserInputService.KeyboardEnabled
function Binger:IsLite()
if self.Prefs.lite == nil then
return self.Touch
end
return self.Prefs.lite == true
end
function Binger:ButtonMode()
return self.Prefs.button or "Always"
end
function Binger:SavePrefs()
prefToken += 1
local my = prefToken
task.delay(0.4, function()
if my == prefToken and not self._unloaded then
FS.saveJson("BingerUI/prefs.json", self.Prefs)
end
end)
end
local CUSTOM_KEYS = { "bg", "surface", "text", "accent", "accent2", "navIcon" }
function Binger:_themeData()
local P = self.Prefs
local base = THEMES[1]
for _, th in ipairs(THEMES) do
if th.Id == P.theme then
base = th
end
end
local copy = { bg = base.bg, surface = base.surface, text = base.text, accent = base.accent, accent2 = base.accent2 }
for _, k in ipairs(CUSTOM_KEYS) do
if type(P[k]) == "string" then
pcall(function()
copy[k] = hex(P[k])
end)
end
end
if P.flat then
copy.accent2 = copy.accent
end
return copy, base
end
function Binger:SetTheme(id, keepCustom)
self.Prefs.theme = id or self.Prefs.theme
if not keepCustom then
for _, k in ipairs(CUSTOM_KEYS) do
self.Prefs[k] = nil
end
end
derive((self:_themeData()))
for obj in pairs(Reg) do
if obj.Parent == nil then
Reg[obj] = nil
else
refresh(obj, not self:IsLite() and 0.35 or nil)
end
end
for _, fnc in ipairs(self._themeHooks or {}) do
task.spawn(fnc)
end
self:SavePrefs()
end
function Binger:SetAccent(which, color)
self.Prefs[which] = color:ToHex()
self:SetTheme(self.Prefs.theme, true)
end
derive((Binger:_themeData()))
local Gui = New("ScreenGui", {
Name = "BingerUI",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 500,
})
do
local ok = pcall(function()
Gui.Parent = gethui()
end)
if not ok or not Gui.Parent then
pcall(function()
Gui.Parent = Svc.CoreGui
end)
end
if not Gui.Parent then
Gui.Parent = LP:WaitForChild("PlayerGui")
end
end
local Root = New("Frame", { Name = "Root", BackgroundTransparency = 1, Parent = Gui })
local RootScale = New("UIScale", { Parent = Root })
Binger.Gui, Binger.Root, Binger.ScreenGui = Gui, Root, Gui
function Binger:_g(signal, f)
local c = signal:Connect(f)
table.insert(self._conns, c)
return c
end
function Binger:_applyScale()
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or V2(1920, 1080)
local base = self.Touch and 560 or 900
local s = math.clamp(vp.Y / base, 0.55, 2.2) * math.clamp(tonumber(self.Prefs.scale) or 1, 0.6, 1.6)
RootScale.Scale = s
Root.Size = UDim2sc(1 / s, 1 / s)
end
function Binger:_rootScale()
return RootScale.Scale
end
do
local camConn
local function hookCam()
if camConn then
camConn:Disconnect()
end
local cam = workspace.CurrentCamera
if cam then
camConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
Binger:_applyScale()
end)
table.insert(Binger._conns, camConn)
end
Binger:_applyScale()
end
Binger:_g(workspace:GetPropertyChangedSignal("CurrentCamera"), hookCam)
hookCam()
end
function Binger:_pointer(input)
if input and (input.UserInputType == UIT.MouseMovement or input.UserInputType == UIT.Touch or input.UserInputType == UIT.MouseButton1) then
return V2(input.Position.X, input.Position.Y)
end
local m = Svc.UserInputService:GetMouseLocation()
local tl = Svc.GuiService:GetGuiInset()
return V2(m.X - tl.X, m.Y - tl.Y)
end
function Binger:_toRoot(v)
return (v - Root.AbsolutePosition) / RootScale.Scale
end
local function isPress(input)
return input.UserInputType == UIT.MouseButton1 or input.UserInputType == UIT.Touch
end
function Binger:_beginDrag(input, move, ended)
self._drag = { move = move, ended = ended }
move(self:_pointer(input))
end
local function keyName(k)
if k == nil then
return "None"
end
if typeof(k) == "EnumItem" then
local short = {
LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
LeftAlt = "LAlt", RightAlt = "RAlt", MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
Backquote = "`", Return = "Enter", CapsLock = "Caps", PageUp = "PgUp", PageDown = "PgDn",
}
return short[k.Name] or k.Name
end
return tostring(k)
end
Binger.KeyName = keyName
local function toKey(v)
if typeof(v) == "EnumItem" then
return v
end
if type(v) == "string" and v ~= "" and v ~= "None" then
local ok, r = pcall(function()
return Enum.KeyCode[v]
end)
if ok and r then
return r
end
ok, r = pcall(function()
return Enum.UserInputType[v]
end)
if ok and r then
return r
end
end
return nil
end
Binger:_g(Svc.UserInputService.InputChanged, function(input)
local d = Binger._drag
if d and (input.UserInputType == UIT.MouseMovement or input.UserInputType == UIT.Touch) then
d.move(Binger:_pointer(input))
end
end)
Binger:_g(Svc.UserInputService.InputEnded, function(input)
if Binger._drag and isPress(input) then
local d = Binger._drag
Binger._drag = nil
Binger._dragEndAt = os.clock()
if d.ended then
d.ended()
end
end
for _, b in ipairs(Binger._binds) do
if b.Mode == "Hold" and b.State and (b.Key == input.KeyCode or b.Key == input.UserInputType) then
b:_trigger(false)
end
end
end)
Binger:_g(Svc.UserInputService.InputBegan, function(input, gp)
if Binger._listen then
local t = input.UserInputType
if t == UIT.Keyboard then
Binger._listen(input.KeyCode)
elseif t == UIT.MouseButton2 or t == UIT.MouseButton3 then
Binger._listen(t)
end
return
end
if Svc.UserInputService:GetFocusedTextBox() then
return
end
local key = input.KeyCode
if input.UserInputType == UIT.Keyboard then
local tk = Binger.ToggleKeybind
local menuKey = type(tk) == "table" and toKey(tk.Value) or nil
for _, w in ipairs(Binger.Windows) do
if (menuKey or w.ToggleKey) == key then
w:Toggle()
end
end
end
for _, b in ipairs(Binger._binds) do
if b.Key and (b.Key == key or b.Key == input.UserInputType) and not b.Disabled then
if b.Mode == "Hold" then
b:_trigger(true)
elseif b.Mode == "Press" then
b:_trigger(nil)
else
b:_trigger(not b.State)
end
end
end
end)
local Tip = New("Frame", {
Name = "Tooltip",
Visible = false,
AutomaticSize = AutoXY,
Size = UDim2off(0, 0),
ZIndex = 200,
BackgroundTransparency = 0.04,
Theme = { BackgroundColor3 = "surface" },
Parent = Root,
})
Corner(Tip, 8)
Stroke(Tip, "lineStrong", 0.2)
Pad(Tip, 6, 10, 6, 10)
New("UISizeConstraint", { MaxSize = V2(260, 400), Parent = Tip })
local TipText = Label({ Text = "", Size = 12, Color = "text", Dim = UDim2off(0, 0), Auto = AutoXY, Wrap = true, Z = 201, Parent = Tip })
local tipToken = 0
function Binger:_tooltip(obj, text)
if not text or text == "" then
return
end
obj.MouseEnter:Connect(function()
tipToken += 1
local my = tipToken
task.delay(0.45, function()
if my ~= tipToken then
return
end
local m = Binger:_toRoot(Binger:_pointer())
TipText.Text = text
Tip.Position = UDim2off(m.X + 14, m.Y + 16)
Tip.Visible = true
end)
end)
obj.MouseLeave:Connect(function()
tipToken += 1
Tip.Visible = false
end)
end
local NotifyHolder = New("Frame", {
Name = "Notifications",
AnchorPoint = V2(1, 0),
Position = UDim2new(1, -18, 0, 18),
Size = UDim2new(0, 320, 1, -36),
BackgroundTransparency = 1,
ZIndex = 150,
Parent = Root,
})
List(NotifyHolder, nil, 10, Enum.HorizontalAlignment.Right)
local notifyOrder = 0
Binger._notifyHolder = NotifyHolder
local KIND_ICON = { info = "info", ok = "check", warn = "alert", err = "x" }
local KIND_KEY = { info = "accent", ok = "ok", warn = "warn", err = "err" }
function Binger:Notify(o, time)
if type(o) == "string" then
o = { Title = o, Duration = time }
end
o = o or {}
o.Content = o.Content or o.Description
o.Duration = o.Duration or o.Time
local kind = KIND_KEY[o.Kind or "info"] and (o.Kind or "info") or "info"
local ck = KIND_KEY[kind]
local dur = o.Duration or 4
notifyOrder -= 1
local wrap = New("Frame", {
BackgroundTransparency = 1,
Size = UDim2new(1, 0, 0, 0),
AutomaticSize = AutoY,
LayoutOrder = notifyOrder,
Parent = NotifyHolder,
})
local card = New("TextButton", {
Text = "",
AutoButtonColor = false,
Size = UDim2new(1, 0, 0, 0),
AutomaticSize = AutoY,
Position = UDim2off(Binger._notifyLeft and -360 or 360, 0),
BackgroundTransparency = 0.04,
Theme = { BackgroundColor3 = "surface" },
Parent = wrap,
})
Corner(card, 12)
Stroke(card, "line", 0)
Pad(card, 12, 14, 14, 14)
local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = card })
local ic = Icon(o.Icon or KIND_ICON[kind], 18, ck, row)
ic.Position = UDim2off(0, 1)
local col = New("Frame", { BackgroundTransparency = 1, Position = UDim2off(28, 0), Size = UDim2new(1, -28, 0, 0), AutomaticSize = AutoY, Parent = row })
List(col, nil, 3)
Label({ Text = o.Title or "Notice", Font = F.semi, Size = 14, Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 1, Parent = col })
if o.Content and o.Content ~= "" then
Label({ Text = o.Content, Size = 13, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 2, Parent = col })
end
local timer = New("Frame", { AnchorPoint = V2(0, 1), Position = UDim2new(0, 0, 1, 8), Size = UDim2new(1, 0, 0, 2), BackgroundTransparency = 0.3, Theme = { BackgroundColor3 = ck }, Parent = card })
Corner(timer, 1)
tween(card, { Position = UDim2off(0, 0) }, 0.45)
local closed = false
local function close()
if closed then
return
end
closed = true
tween(card, { Position = UDim2off(Binger._notifyLeft and -360 or 360, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
task.delay(0.28, function()
if not wrap.Parent then
return
end
local h = wrap.AbsoluteSize.Y / RootScale.Scale
wrap.AutomaticSize = Enum.AutomaticSize.None
wrap.Size = UDim2new(1, 0, 0, h)
tween(wrap, { Size = UDim2new(1, 0, 0, 0) }, 0.22)
task.delay(0.24, function()
forget(wrap)
wrap:Destroy()
end)
end)
end
card.MouseButton1Click:Connect(close)
if dur > 0 then
tween(timer, { Size = UDim2new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)
task.delay(dur, close)
else
timer.Visible = false
end
local kids = {}
for _, c in ipairs(NotifyHolder:GetChildren()) do
if c:IsA("Frame") then
kids[#kids + 1] = c
end
end
if #kids > 5 then
table.sort(kids, function(a, b)
return a.LayoutOrder > b.LayoutOrder
end)
forget(kids[1])
kids[1]:Destroy()
end
return { Close = close }
end
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Container = {}
Container.__index = Container
local Element = {}
Element.__index = Element
Binger._classes = { Window = Window, Tab = Tab, Container = Container, Element = Element }
local SIDE = 214
local TOP = 66
local FOOT = 32
local function collapsible(win, clip, inner, open)
local c = { Open = open ~= false, anim = false }
local function h()
return inner.AbsoluteSize.Y / win:_eff()
end
local function sync()
if not c.anim then
clip.Size = UDim2new(1, 0, 0, c.Open and h() or 0)
end
end
inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
function c:Set(v, instant)
c.Open = v
if instant then
sync()
return
end
c.anim = true
local tw = tween(clip, { Size = UDim2new(1, 0, 0, v and h() or 0) }, 0.3)
tw.Completed:Connect(function()
c.anim = false
sync()
if c.OnDone then
c.OnDone()
end
end)
end
task.defer(sync)
return c
end
function Binger:Window(o)
o = o or {}
local W = setmetatable({}, Window)
W.Lib = self
W.Tabs = {}
W.Title = o.Title or "BINGER'S"
W.Subtitle = o.Subtitle or "script hub"
W.Version = o.Version or ("v" .. self.Version)
W.ToggleKey = toKey(self.Prefs.key) or o.Keybind or Enum.KeyCode.RightShift
W.Size = o.Size or V2(880, 570)
do
local vp = Root.AbsoluteSize / RootScale.Scale
if vp.X > 100 and vp.Y > 100 then
W.Size = V2(math.min(W.Size.X, vp.X - 24), math.min(W.Size.Y, vp.Y - 24))
end
end
W.Lite = self:IsLite()
W.Logo = o.Logo or o.Icon
W.TitleRich = o.TitleRich
W.TitleFont = o.TitleFont
W.Visible = false
W._loops = {}
W._order = 0
local Holder = New("Frame", {
Name = "BingerWindow",
BackgroundTransparency = 1,
AnchorPoint = V2(0.5, 0.5),
Position = UDim2sc(0.5, 0.5),
Size = UDim2off(W.Size.X, W.Size.Y),
Visible = false,
Parent = Root,
})
local Body = New("Frame", { BackgroundTransparency = 1, AnchorPoint = V2(0.5, 0.5), Position = UDim2sc(0.5, 0.5), Size = UDim2sc(1, 1), Parent = Holder })
W.BodyScale = New("UIScale", { Parent = Body })
W.Holder, W.Body = Holder, Body
New("ImageLabel", {
Name = "Halo",
BackgroundTransparency = 1,
Image = Assets.shadow or "",
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(48, 48, 80, 80),
ImageTransparency = 0.82,
Position = UDim2off(-46, -40),
Size = UDim2new(1, 92, 1, 92),
Theme = { ImageColor3 = "accent2" },
Parent = Body,
})
New("ImageLabel", {
Name = "Shadow",
BackgroundTransparency = 1,
Image = Assets.shadow or "",
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(48, 48, 80, 80),
ImageColor3 = Color3.new(0, 0, 0),
ImageTransparency = 0.25,
Position = UDim2off(-28, -20),
Size = UDim2new(1, 56, 1, 56),
Parent = Body,
})
local Main = New("Frame", {
Name = "Main",
Size = UDim2sc(1, 1),
BackgroundTransparency = tonumber(self.Prefs.opacity) or 0.04,
Theme = { BackgroundColor3 = "bg" },
Parent = Body,
})
Corner(Main, 14)
W.Main = Main
do
local st = Stroke(Main, nil, 0, 1)
st.Color = Color3.new(1, 1, 1)
New("UIGradient", {
Rotation = 38,
Theme = {
Color = function(t)
return ColorSequence.new({
ColorSequenceKeypoint.new(0, t.accent),
ColorSequenceKeypoint.new(0.32, t.lineStrong),
ColorSequenceKeypoint.new(1, t.lineStrong),
})
end,
},
Transparency = nseq(0, 0.15, 1, 0.1),
Parent = st,
})
end
local function aurora(key, r0, r1, a, time)
local f = New("Frame", { Name = "Aurora", Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = Main })
Corner(f, 14)
local g = New("UIGradient", {
Rotation = r0,
Theme = { Color = grad(key) },
Transparency = nseq(0, a, 0.5, 1, 1, 1),
Parent = f,
})
local tw = Svc.TweenService:Create(g, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = r1 })
if not W.Lite then
tw:Play()
table.insert(W._loops, tw)
end
end
aurora("accent2", 28, 62, 0.74, 15)
aurora("accent", 208, 242, 0.86, 21)
W.BgImage = New("ImageLabel", { Name = "BgImage", BackgroundTransparency = 1, Size = UDim2sc(1, 1), ScaleType = Enum.ScaleType.Crop, Visible = false, Parent = Main })
Corner(W.BgImage, 14)
W:_bgImage()
W._side = SIDE
local SideTint = New("Frame", { Name = "SideTint", Size = UDim2sc(1, 1), Theme = { BackgroundColor3 = "surface" }, Parent = Main })
Corner(SideTint, 14)
local SideGrad = New("UIGradient", { Parent = SideTint })
local function syncSide()
local w = math.max(Holder.Size.X.Offset, W._side + 10)
local r = math.clamp(W._side / w, 0.01, 0.98)
SideGrad.Transparency = nseq(0, 0.42, r, 0.42, math.min(r + 0.001, 0.999), 1, 1, 1)
end
syncSide()
W._syncSide = syncSide
Holder:GetPropertyChangedSignal("Size"):Connect(syncSide)
W.PetalLayer = New("Frame", { Name = "Petals", BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2sc(1, 1), Parent = Main })
W.SideLine = New("Frame", { Position = UDim2off(SIDE, 0), Size = UDim2new(0, 1, 1, 0), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = Main })
local Side = New("Frame", { Name = "Sidebar", BackgroundTransparency = 1, Size = UDim2new(0, SIDE, 1, 0), Parent = Main })
W.Side = Side
local Brand = New("Frame", { Name = "Brand", BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 72), Parent = Side })
do
local glow = New("ImageLabel", {
BackgroundTransparency = 1,
Image = Assets.glow or "",
ImageTransparency = 0.72,
AnchorPoint = V2(0.5, 0.5),
Position = UDim2off(35, 37),
Size = UDim2off(76, 76),
Theme = { ImageColor3 = "accent" },
Parent = Brand,
})
W.BrandGlow = glow
local em, spin = W:_logo(Brand, W.Logo and 38 or 34, 40)
em.Position = UDim2off(35, 37)
if spin and not W.Lite then
table.insert(W._loops, spin)
elseif spin then
spin:Cancel()
end
W.Emblem = em
local title = Label({ Text = W.TitleRich or W.Title, Rich = W.TitleRich ~= nil, Font = W.TitleFont or F.display, Size = 23, Pos = UDim2off(62, 15), Dim = UDim2new(1, -70, 0, 24), Truncate = true, Parent = Brand })
title.TextColor3 = Color3.new(1, 1, 1)
Reg[title] = nil
if not W.TitleRich then
New("UIGradient", { Theme = { Color = grad("accent", "text", "accent2") }, Parent = title })
end
local sub = Label({ Text = W.Subtitle, Size = 12, Color = "muted", Pos = UDim2off(63, 40), Dim = UDim2new(1, -70, 0, 16), Truncate = true, Parent = Brand })
W._wideOnly = { title, sub }
end
local Nav = New("ScrollingFrame", {
Name = "Nav",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2off(0, 76),
Size = UDim2new(1, 0, 1, -76 - 72),
CanvasSize = UDim2off(0, 0),
AutomaticCanvasSize = AutoY,
ScrollBarThickness = 2,
ScrollingDirection = Enum.ScrollingDirection.Y,
Theme = { ScrollBarImageColor3 = "lineStrong" },
Parent = Side,
})
local GliderLayer = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), Parent = Nav })
local NavList = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, ZIndex = 2, Parent = Nav })
List(NavList, nil, 2)
Pad(NavList, 0, 10, 10, 10)
W.Nav, W.NavList = Nav, NavList
local Glider = New("Frame", {
Name = "Glider",
Visible = false,
Position = UDim2off(10, 0),
Size = UDim2new(1, -20, 0, 38),
BackgroundColor3 = Color3.new(1, 1, 1),
Parent = GliderLayer,
})
Glider.BackgroundTransparency = 0.25
Reg[Glider] = { BackgroundColor3 = "hover" }
refresh(Glider)
Corner(Glider, 8)
W.Glider = Glider
local Card = New("TextButton", {
Name = "Player",
Text = "",
AutoButtonColor = false,
Position = UDim2new(0, 10, 1, -62),
Size = UDim2new(1, -20, 0, 52),
BackgroundTransparency = 0.35,
Theme = { BackgroundColor3 = "surface" },
Parent = Side,
})
Corner(Card, 12)
local cardStroke = Stroke(Card, "line")
do
local av = New("ImageLabel", { Position = UDim2off(9, 9), Size = UDim2off(34, 34), Theme = { BackgroundColor3 = "field" }, Parent = Card })
Corner(av, 17)
Stroke(av, "accent", 0.1, 1.5)
task.spawn(function()
local ok, img = pcall(function()
return Svc.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok and av.Parent then
av.Image = img
end
end)
local function mask(str, lo, hi)
return string.rep("•", math.clamp(utf8.len(str) or #str, lo, hi))
end
local nameL = Label({ Text = mask(LP.DisplayName, 6, 12), Font = F.semi, Size = 13, Pos = UDim2off(52, 9), Dim = UDim2new(1, -58, 0, 17), Truncate = true, Parent = Card })
local userL = Label({ Text = "@" .. mask(LP.Name, 5, 10), Size = 11, Color = "muted", Pos = UDim2off(52, 27), Dim = UDim2new(1, -58, 0, 15), Truncate = true, Parent = Card })
table.insert(W._wideOnly, nameL)
table.insert(W._wideOnly, userL)
local shown = false
Card.MouseButton1Click:Connect(function()
shown = not shown
nameL.TextTransparency, userL.TextTransparency = 1, 1
nameL.Text = shown and LP.DisplayName or mask(LP.DisplayName, 6, 12)
userL.Text = "@" .. (shown and LP.Name or mask(LP.Name, 5, 10))
tween(nameL, { TextTransparency = 0 }, 0.25)
tween(userL, { TextTransparency = 0 }, 0.3)
end)
hover(Card, function()
tween(Card, { BackgroundColor3 = T.hover, BackgroundTransparency = 0.15 }, 0.18)
tween(cardStroke, { Color = T.lineStrong }, 0.18)
end, function()
tween(Card, { BackgroundColor3 = T.surface, BackgroundTransparency = 0.35 }, 0.22)
refresh(cardStroke, 0.22)
end)
end
local Content = New("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2off(SIDE + 1, 0), Size = UDim2new(1, -SIDE - 1, 1, 0), Parent = Main })
W.Content = Content
local Top = New("Frame", { Name = "Top", BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, TOP), Parent = Content })
New("Frame", { Position = UDim2new(0, 0, 1, -1), Size = UDim2new(1, 0, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = Top })
W.PageTitle = Label({ Text = "", Font = F.display, Size = 25, Pos = UDim2off(24, 11), Dim = UDim2new(1, -350, 0, 28), Truncate = true, Parent = Top })
W.PageSub = Label({ Text = "", Size = 12, Color = "muted", Pos = UDim2off(24, 39), Dim = UDim2new(1, -350, 0, 16), Truncate = true, Parent = Top })
local DragZone = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, -330, 1, 0), Parent = Top })
local Search = New("Frame", {
AnchorPoint = V2(1, 0.5),
Position = UDim2new(1, -92, 0.5, 0),
Size = UDim2off(214, 34),
BackgroundTransparency = 0.2,
Theme = { BackgroundColor3 = "field" },
Parent = Top,
})
Corner(Search, 10)
local searchStroke = Stroke(Search, "line")
local sIc = Icon("search", 15, "muted", Search)
sIc.AnchorPoint = V2(0, 0.5)
sIc.Position = UDim2new(0, 11, 0.5, 0)
local SearchBox = New("TextBox", {
BackgroundTransparency = 1,
Position = UDim2off(34, 0),
Size = UDim2new(1, -42, 1, 0),
ClearTextOnFocus = false,
FontFace = F.body,
TextSize = 13,
Text = "",
PlaceholderText = "Search all menus",
TextXAlignment = LEFT,
Theme = { TextColor3 = "text", PlaceholderColor3 = "faint" },
Parent = Search,
})
SearchBox.Focused:Connect(function()
searchStroke.Color = T.accent
Reg[searchStroke].Color = "accent"
end)
SearchBox.FocusLost:Connect(function()
Reg[searchStroke].Color = "line"
refresh(searchStroke, 0.2)
end)
local searchToken = 0
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
searchToken += 1
local my = searchToken
task.delay(0.12, function()
if my == searchToken then
W:_search(SearchBox.Text)
end
end)
end)
SearchBox.FocusLost:Connect(function(enter)
if enter and W._firstHit then
W:_jumpTo(W._firstHit)
end
end)
W.SearchBox = SearchBox
local function topButton(icon, x, danger)
local b = New("TextButton", {
Text = "",
AutoButtonColor = false,
AnchorPoint = V2(1, 0.5),
Position = UDim2new(1, x, 0.5, 0),
Size = UDim2off(32, 32),
BackgroundTransparency = 1,
Theme = { BackgroundColor3 = danger and "err" or "hover" },
Parent = Top,
})
Corner(b, 9)
local ic = Icon(icon, 16, "muted", b)
ic.AnchorPoint = V2(0.5, 0.5)
ic.Position = UDim2sc(0.5, 0.5)
hover(b, function()
tween(b, { BackgroundTransparency = danger and 0.15 or 0.2 }, 0.15)
tween(ic, { ImageColor3 = danger and Color3.new(1, 1, 1) or T.text }, 0.15)
end, function()
tween(b, { BackgroundTransparency = 1 }, 0.2)
refresh(ic, 0.2)
end)
return b
end
topButton("minus", -52).MouseButton1Click:Connect(function()
if self.Windows[1] == W then
self:Toggle(false)
else
W:SetVisible(false)
end
end)
topButton("x", -14, true).MouseButton1Click:Connect(function()
W:Dialog({
Title = "Close " .. W.Title:lower():gsub("^%l", string.upper) .. "?",
Content = "This unloads the menu and stops every feature it runs. Run the script again to bring it back.",
Icon = "power",
Buttons = {
{ Name = "Keep open" },
{ Name = "Close menu", Style = "danger", Callback = function()
W.Lib:Unload()
end },
},
})
end)
local Pages = New("Frame", { Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2off(0, TOP), Size = UDim2new(1, 0, 1, -TOP - FOOT), Parent = Content })
W.Pages = Pages
W.Results = New("ScrollingFrame", {
Name = "SearchResults",
Visible = false,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2sc(1, 1),
CanvasSize = UDim2off(0, 0),
AutomaticCanvasSize = AutoY,
ScrollBarThickness = 3,
ScrollingDirection = Enum.ScrollingDirection.Y,
Theme = { ScrollBarImageColor3 = "lineStrong" },
Parent = Pages,
})
W.ResultsList = New("Frame", { BackgroundTransparency = 1, Position = UDim2off(16, 14), Size = UDim2new(1, -36, 0, 0), AutomaticSize = AutoY, Parent = W.Results })
List(W.ResultsList, nil, 6)
Pad(W.ResultsList, 0, 0, 18, 0)
local Foot = New("Frame", { Name = "Footer", BackgroundTransparency = 1, Position = UDim2new(0, 0, 1, -FOOT), Size = UDim2new(1, 0, 0, FOOT), Parent = Content })
New("Frame", { Size = UDim2new(1, 0, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = Foot })
W.Foot = Foot
local footText = o.Footer or (W.Title:sub(1, 1) .. W.Title:sub(2):lower() .. " UI")
W.FootLeft = Label({ Text = footText, Size = 12, Color = "faint", Pos = UDim2off(18, 0), Dim = UDim2new(0.3, 0, 1, 0), Truncate = true, Parent = Foot })
local footProbe = Label({ Text = footText, Size = 12, Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Parent = Foot })
footProbe.TextTransparency = 1
W.Hint = Label({ Text = "", Size = 12, Color = "muted", AlignX = RIGHT, Anchor = V2(1, 0), Pos = UDim2new(1, -110, 0, 0), Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Parent = Foot })
local footVer = Label({ Text = W.Version, Size = 12, Color = "faint", AlignX = RIGHT, Anchor = V2(1, 0), Pos = UDim2new(1, -40, 0, 0), Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Parent = Foot })
local function layoutFoot()
local k = Foot.AbsoluteSize.Y / FOOT
if k <= 0 then
return
end
local fw, need = Foot.AbsoluteSize.X / k, footProbe.AbsoluteSize.X / k
local right = 40 + footVer.AbsoluteSize.X / k + 18
W.Hint.Position = UDim2new(1, -right, 0, 0)
local hintW = W.Hint.AbsoluteSize.X / k
local showHint = W.Hint.Text ~= "" and 18 + need + 24 + hintW + right <= fw
W.Hint.Visible = showHint
if showHint then
right += hintW + 24
end
W.FootLeft.Size = UDim2new(0, math.max(0, fw - 18 - right), 1, 0)
end
for _, x in ipairs({ Foot, footProbe, W.Hint, footVer }) do
x:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutFoot)
end
W.FootLeft:GetPropertyChangedSignal("Text"):Connect(function()
footProbe.Text = W.FootLeft.Text
end)
task.defer(layoutFoot)
local Grip = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = V2(1, 1), Position = UDim2new(1, -4, 1, -4), Size = UDim2off(24, 24), Parent = Foot })
do
local gi = Icon("grip", 14, "faint", Grip)
gi.AnchorPoint = V2(0.5, 0.5)
gi.Position = UDim2sc(0.5, 0.5)
gi.Rotation = 45
hover(Grip, function()
tween(gi, { ImageColor3 = T.accent }, 0.15)
end, function()
refresh(gi, 0.2)
end)
end
local Overlay = New("Frame", { Name = "Overlay", BackgroundTransparency = 1, Size = UDim2sc(1, 1), ZIndex = 50, Parent = Main })
local Catcher = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2sc(1, 1), Visible = false, Parent = Overlay })
Catcher.MouseButton1Click:Connect(function()
if os.clock() - (W.Lib._dragEndAt or 0) < 0.2 then
return
end
local p = W._pop
if p and p.Frame and p.Frame.Parent then
local m = W.Lib:_pointer(nil)
local a, z = p.Frame.AbsolutePosition, p.Frame.AbsoluteSize
if m.X >= a.X and m.X <= a.X + z.X and m.Y >= a.Y and m.Y <= a.Y + z.Y then
return
end
end
W:_closePopup()
end)
W.Overlay, W.Catcher = Overlay, Catcher
local function dragFrom(zone)
zone.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = self:_pointer(input)
local startPos = Holder.Position
self:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
Holder.Position = UDim2new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end)
end)
end
dragFrom(Brand)
dragFrom(DragZone)
Grip.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = self:_pointer(input)
local s0 = Holder.Size
local p0 = Holder.Position
W:_closePopup()
self:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
local vp = Root.AbsoluteSize / RootScale.Scale
local w = math.clamp(s0.X.Offset + d.X, 720, vp.X - 20)
local h = math.clamp(s0.Y.Offset + d.Y, 460, vp.Y - 20)
Holder.Size = UDim2off(w, h)
Holder.Position = UDim2new(p0.X.Scale, p0.X.Offset + (w - s0.X.Offset) / 2, p0.Y.Scale, p0.Y.Offset + (h - s0.Y.Offset) / 2)
end)
end)
NavList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
W:_glide(false)
end)
W:_buildSigil()
W:SetToggleKey(W.ToggleKey)
local petals = self.Prefs.petals
if petals == nil then
petals = not W.Lite
end
W:_petals(petals)
table.insert(self.Windows, W)
if #self.Windows == 1 then
self.MainFrame = Holder
self.Toggled = false
end
self._themeHooks = self._themeHooks or {}
task.defer(function()
W:SetVisible(true)
W:_glide(false)
end)
if self.Prefs.watermark then
task.defer(function()
self:Watermark(true)
end)
end
return W
end
function Window:_logo(parent, size, spinTime, paused)
if self.Logo then
local img = New("ImageLabel", {
BackgroundTransparency = 1,
Image = self.Logo,
ScaleType = Enum.ScaleType.Crop,
AnchorPoint = V2(0.5, 0.5),
Size = UDim2off(size, size),
Parent = parent,
})
Corner(img, size)
Stroke(img, "accent", 0.35, 1.5)
return img, nil
end
local em = New("ImageLabel", {
BackgroundTransparency = 1,
Image = Assets.emblem or "",
AnchorPoint = V2(0.5, 0.5),
Size = UDim2off(size, size),
ImageColor3 = Color3.new(1, 1, 1),
Parent = parent,
})
New("UIGradient", { Rotation = 45, Theme = { Color = grad("accent", "accent2") }, Parent = em })
local spin = Svc.TweenService:Create(em, TweenInfo.new(spinTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 })
if not paused then
spin:Play()
end
return em, spin
end
function Window:_eff()
return RootScale.Scale * self.BodyScale.Scale
end
function Window:SetToggleKey(k)
self.ToggleKey = toKey(k) or self.ToggleKey
self.Hint.Text = keyName(self.ToggleKey) .. " toggles the menu"
end
function Window:Toggle()
if self.Lib.Windows[1] == self then
self.Lib:Toggle()
else
self:SetVisible(not self.Visible)
end
end
function Window:SetVisible(v)
if self._fading or v == self.Visible or self.Lib._unloaded then
return
end
self.Visible = v
if self.Lib.Windows[1] == self then
self.Lib.Toggled = v
end
self:_closePopup()
self:_syncButton()
local items = 0
for _, t in ipairs(self.Tabs) do
items += #t.Items
end
if self.Lite or self.Lib:IsLite() or items > 160 then
self.Holder.Visible = v
self:_setLoops(v)
self.Lib:_blur(v)
if v then
task.defer(function()
self:_glide(false)
end)
end
return
end
self._fading = true
local Holder, Body = self.Holder, self.Body
local pad = 110
local cg = New("CanvasGroup", {
BackgroundTransparency = 1,
AnchorPoint = V2(0.5, 0.5),
Position = Holder.Position,
Size = UDim2off(Holder.Size.X.Offset + pad * 2, Holder.Size.Y.Offset + pad * 2),
GroupTransparency = v and 1 or 0,
Parent = Root,
})
Body.Size = UDim2off(Holder.Size.X.Offset, Holder.Size.Y.Offset)
Body.Parent = cg
Holder.Visible = false
if v then
self.BodyScale.Scale = 0.955
tween(self.BodyScale, { Scale = 1 }, 0.42)
tween(cg, { GroupTransparency = 0 }, 0.32, Enum.EasingStyle.Quad)
self:_setLoops(true)
else
tween(self.BodyScale, { Scale = 0.955 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
tween(cg, { GroupTransparency = 1 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end
task.delay(v and 0.43 or 0.21, function()
if not Body.Parent then
return
end
Body.Parent = Holder
Body.Size = UDim2sc(1, 1)
Holder.Visible = v
self.BodyScale.Scale = 1
forget(cg)
cg:Destroy()
self._fading = false
if not v then
self:_setLoops(false)
end
self:_glide(false)
end)
self.Lib:_blur(v)
end
function Window:_bgImage()
local P = self.Lib.Prefs
local id = tonumber(P.bgImage)
local img = self.BgImage
if not img then
return
end
if id and id > 0 then
img.Image = ("rbxthumb://type=Asset&id=%d&w=768&h=432"):format(id)
img.ImageTransparency = 1 - math.clamp(tonumber(P.bgImageLight) or 0.3, 0.05, 1)
img.Visible = true
else
img.Visible = false
img.Image = ""
end
end
function Window:_setLoops(on)
for _, tw in ipairs(self._loops) do
if on then
tw:Play()
else
tw:Pause()
end
end
for _, p in ipairs(self._petalList or {}) do
if p.tw then
if on then
p.tw:Play()
else
p.tw:Pause()
end
end
end
end
function Window:_buildSigil()
local L = self.Lib
local SIZE = 56
local s = New("TextButton", {
Name = "MenuButton",
Text = "",
AutoButtonColor = false,
Visible = false,
AnchorPoint = V2(0.5, 0.5),
Position = UDim2new(0, 44, 0.5, 0),
Size = UDim2off(SIZE, SIZE),
BackgroundTransparency = 1,
ZIndex = 140,
Parent = Root,
})
New("ImageLabel", {
BackgroundTransparency = 1,
Image = Assets.shadow or "",
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(48, 48, 80, 80),
SliceScale = 0.6,
ImageColor3 = Color3.new(0, 0, 0),
ImageTransparency = 0.35,
AnchorPoint = V2(0.5, 0.5),
Position = UDim2new(0.5, 0, 0.5, 3),
Size = UDim2off(SIZE + 30, SIZE + 30),
ZIndex = 140,
Parent = s,
})
local halo = New("ImageLabel", {
BackgroundTransparency = 1,
Image = Assets.glow or "",
ImageTransparency = 0.78,
AnchorPoint = V2(0.5, 0.5),
Position = UDim2sc(0.5, 0.5),
Size = UDim2off(SIZE + 44, SIZE + 44),
ZIndex = 140,
Theme = { ImageColor3 = "accent2" },
Parent = s,
})
local disc = New("Frame", {
AnchorPoint = V2(0.5, 0.5),
Position = UDim2sc(0.5, 0.5),
Size = UDim2sc(1, 1),
BackgroundTransparency = 0.04,
ZIndex = 141,
Theme = { BackgroundColor3 = "bg" },
Parent = s,
})
Corner(disc, SIZE)
local ring = Stroke(disc, nil, 0, 2.5)
ring.Color = Color3.new(1, 1, 1)
New("UIGradient", { Rotation = 45, Theme = { Color = grad("accent", "accent2") }, Parent = ring })
local mark = self:_logo(disc, self.Logo and SIZE - 10 or 32, 0, true)
mark.Position = UDim2sc(0.5, 0.5)
mark.ZIndex = 142
for _, d in ipairs(mark:GetChildren()) do
if d:IsA("UIStroke") then
d:Destroy()
end
end
local pip = New("Frame", {
AnchorPoint = V2(0.5, 0.5),
Position = UDim2new(0.5, 0, 1, -1),
Size = UDim2off(14, 5),
ZIndex = 143,
Theme = { BackgroundColor3 = "accent" },
Parent = s,
})
Corner(pip, 3)
Stroke(pip, "bg", 0, 1.5)
local scale = New("UIScale", { Parent = s })
L:_tooltip(s, "Open or close the menu")
local saved = L.Prefs.buttonPos
s.AnchorPoint = V2(0.5, 0.5)
if type(saved) == "table" and tonumber(saved.x) and tonumber(saved.y) then
s.Position = UDim2sc(math.clamp(tonumber(saved.x), 0.02, 0.98), math.clamp(tonumber(saved.y), 0.04, 0.96))
elseif type(saved) == "table" and tonumber(saved.y) then
s.Position = UDim2new(saved.side == "right" and 1 or 0, saved.side == "right" and -42 or 42, math.clamp(tonumber(saved.y), 0.08, 0.92), 0)
else
s.Position = UDim2new(0, 42, 0.5, 0)
end
local moved = false
s.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
moved = false
tween(scale, { Scale = 0.9 }, 0.08, Enum.EasingStyle.Quad)
local start = L:_pointer(input)
local c0 = L:_toRoot(s.AbsolutePosition + s.AbsoluteSize / 2)
local view = Root.AbsoluteSize / RootScale.Scale
L:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
if not moved and d.Magnitude > 5 then
moved = true
end
if moved then
local c = c0 + d
s.Position = UDim2sc(c.X / math.max(view.X, 1), c.Y / math.max(view.Y, 1))
end
end, function()
tween(scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)
if not moved then
self:Toggle()
return
end
local view = Root.AbsoluteSize / RootScale.Scale
local c = V2(s.Position.X.Scale * view.X, s.Position.Y.Scale * view.Y)
local half = SIZE / 2 + 4
local x = math.clamp(c.X, half, math.max(view.X - half, half))
local y = math.clamp(c.Y, half, math.max(view.Y - half, half))
local fx, fy = x / math.max(view.X, 1), y / math.max(view.Y, 1)
s.Position = UDim2sc(fx, fy)
L.Prefs.buttonPos = { x = fx, y = fy }
L:SavePrefs()
end)
end)
if not L.Touch then
hover(s, function()
tween(scale, { Scale = 1.06 }, 0.15)
end, function()
tween(scale, { Scale = 1 }, 0.2)
end)
end
self.Sigil, self.SigilScale, self._btnHalo, self._btnPip, self._btnRing = s, scale, halo, pip, ring
end
function Window:_syncButton()
local s = self.Sigil
if not s then
return
end
local mode = self.Lib:ButtonMode()
local show = mode == "Always" or (mode == "Hidden" and not self.Visible)
local open = self.Visible
if show and not s.Visible then
s.Visible = true
if not self.Lib:IsLite() then
self.SigilScale.Scale = 0.6
tween(self.SigilScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
end
elseif not show then
s.Visible = false
end
local t = self.Lib:IsLite() and nil or 0.2
local function set(obj, props)
if t then
tween(obj, props, t)
else
for k, v in pairs(props) do
obj[k] = v
end
end
end
set(self._btnPip, { BackgroundTransparency = open and 0 or 1, Size = open and UDim2off(14, 5) or UDim2off(6, 5) })
set(self._btnHalo, { ImageTransparency = open and 0.62 or 0.8 })
set(self._btnRing, { Transparency = open and 0 or 0.3 })
end
function Window:_sigil()
self:_syncButton()
end
function Window:_petals(on)
self._petalsOn = on
for _, p in ipairs(self._petalList or {}) do
p.alive = false
if p.tw then
p.tw:Cancel()
end
forget(p.img)
p.img:Destroy()
end
self._petalList = {}
if not on or not Assets.petal then
return
end
local rnd = Random.new()
for i = 1, 9 do
local p = { alive = true }
p.img = New("ImageLabel", {
BackgroundTransparency = 1,
Image = Assets.petal,
ImageTransparency = rnd:NextNumber(0.5, 0.72),
Size = UDim2off(rnd:NextInteger(12, 17), rnd:NextInteger(8, 11)),
AnchorPoint = V2(0.5, 0.5),
Theme = { ImageColor3 = (i % 3 == 0) and "accent2" or "accent" },
Parent = self.PetalLayer,
})
local function fall(first)
if not p.alive or self.Lib._unloaded then
return
end
local x = rnd:NextNumber(0.02, 0.98)
local y0 = first and rnd:NextNumber(-0.05, 0.9) or -0.05
p.img.Position = UDim2sc(x, y0)
p.img.Rotation = rnd:NextNumber(0, 360)
local dur = rnd:NextNumber(11, 19) * (1.05 - y0)
p.tw = Svc.TweenService:Create(p.img, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
Position = UDim2sc(math.clamp(x + rnd:NextNumber(-0.18, 0.18), 0, 1), 1.05),
Rotation = p.img.Rotation + rnd:NextNumber(-220, 220),
})
p.tw.Completed:Connect(function(state)
if state == Enum.PlaybackState.Completed then
fall(false)
end
end)
if self.Visible or first then
p.tw:Play()
end
end
fall(true)
table.insert(self._petalList, p)
end
end
function Window:_popup(anchor, width, height)
self:_closePopup()
local ov = self.Overlay
local eff = self:_eff()
local rel = (anchor.AbsolutePosition - ov.AbsolutePosition) / eff
local aw, ah = anchor.AbsoluteSize.X / eff, anchor.AbsoluteSize.Y / eff
local ovs = ov.AbsoluteSize / eff
width = width or aw
local x = math.clamp(rel.X + aw - width, 8, ovs.X - width - 8)
local up = rel.Y + ah + 6 + height > ovs.Y - 8
local y = up and (rel.Y - 6) or (rel.Y + ah + 6)
local pop = New("Frame", {
Name = "Popup",
Active = true,
AnchorPoint = V2(0, up and 1 or 0),
Position = UDim2off(x, y),
Size = UDim2off(width, 0),
ClipsDescendants = true,
BackgroundTransparency = 0.02,
Theme = { BackgroundColor3 = "surface" },
ZIndex = 3,
Parent = ov,
})
Corner(pop, 10)
Stroke(pop, "lineStrong", 0.25)
tween(pop, { Size = UDim2off(width, height) }, 0.26)
self.Catcher.Visible = true
local p = { Frame = pop, Up = up, Width = width }
self._pop = p
return pop, p
end
function Window:_closePopup()
local p = self._pop
if not p then
return
end
self._pop = nil
self.Catcher.Visible = false
if p.OnClose then
pcall(p.OnClose)
end
local f = p.Frame
tween(f, { Size = UDim2off(p.Width, 0) }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
task.delay(0.17, function()
forget(f)
f:Destroy()
end)
end
function Window:Dialog(o)
o = o or {}
self:_closePopup()
local ov = self.Overlay
local dim = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2sc(1, 1), ZIndex = 10, Parent = ov })
Corner(dim, 14)
local card = New("Frame", {
AnchorPoint = V2(0.5, 0.5),
Position = UDim2sc(0.5, 0.5),
Size = UDim2off(o.Width or 400, 0),
AutomaticSize = AutoY,
BackgroundTransparency = 0.02,
Theme = { BackgroundColor3 = "surface" },
ZIndex = 11,
Parent = ov,
})
Corner(card, 16)
local st = Stroke(card, nil, 0, 1)
st.Color = Color3.new(1, 1, 1)
New("UIGradient", { Rotation = 90, Theme = { Color = grad("lineStrong", "line") }, Parent = st })
Pad(card, 22, 22, 20, 22)
List(card, nil, 14)
local sc = New("UIScale", { Scale = 0.92, Parent = card })
local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 30), LayoutOrder = 1, Parent = card })
local hasIcon = o.Icon ~= false
if hasIcon then
local ib = New("Frame", { Size = UDim2off(30, 30), BackgroundTransparency = 0.85, Theme = { BackgroundColor3 = o.Danger and "err" or "accent" }, Parent = head })
Corner(ib, 9)
local ic = Icon(o.Icon or "info", 16, o.Danger and "err" or "accent", ib)
ic.AnchorPoint = V2(0.5, 0.5)
ic.Position = UDim2sc(0.5, 0.5)
end
Label({ Text = o.Title or "Are you sure?", Font = F.display, Size = 22, Pos = UDim2off(hasIcon and 42 or 0, 0), Dim = UDim2new(1, hasIcon and -42 or 0, 1, 0), Parent = head })
if o.Content then
Label({ Text = o.Content, Size = 13, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 2, Parent = card })
end
local holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = 3, Visible = o.Build ~= nil, Parent = card })
List(holder, nil, 11)
local inner = Container._new(self, nil, holder, nil)
local d = { Container = inner }
local closed = false
function d.Close()
if closed then
return
end
closed = true
tween(sc, { Scale = 0.94 }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
tween(dim, { BackgroundTransparency = 1 }, 0.18)
card.Visible = false
task.delay(0.19, function()
forget(dim)
forget(card)
dim:Destroy()
card:Destroy()
end)
end
if o.Build then
o.Build(inner)
end
local btns = o.Buttons or { { Name = "OK", Style = "primary" } }
local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 36), LayoutOrder = 4, Parent = card })
List(row, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right)
for i, b in ipairs(btns) do
local btn = Container._button(row, b.Name, b.Style or (i == #btns and "primary" or nil), b.Icon, UDim2new(0, 0, 1, 0))
btn.AutomaticSize = AutoX
btn.LayoutOrder = i
Pad(btn, 0, 18, 0, 18)
btn.MouseButton1Click:Connect(function()
d.Close()
if b.Callback then
task.spawn(b.Callback)
end
end)
end
if o.CloseOnOutside ~= false then
dim.MouseButton1Click:Connect(d.Close)
end
tween(dim, { BackgroundTransparency = 0.45 }, 0.25)
tween(sc, { Scale = 1 }, 0.32, Enum.EasingStyle.Back)
return d
end
function Window:_navButton(o, parent)
self._order += 1
local btn = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 38), LayoutOrder = self._order, Parent = parent })
local ic = Icon(o.Icon or "chevright", 18, "muted", btn)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 13, 0.5, 0)
local lb = Label({ Text = o.Name or "Tab", Font = F.medium, Size = 14, Color = "muted", Pos = UDim2off(43, 0), Dim = UDim2new(1, -50, 1, 0), Truncate = true, Parent = btn })
return btn, ic, lb
end
function Window:Tab(o)
return self:_tab(o or {}, self.NavList, nil)
end
function Window:Category(name, collapsed)
local W = self
self._order += 1
local wrap = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = self._order, Parent = self.NavList })
List(wrap)
local head = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 30), LayoutOrder = 1, Parent = wrap })
Label({ Text = name, Font = F.semi, Size = 12, Color = "faint", Pos = UDim2off(13, 4), Dim = UDim2new(1, -40, 1, -4), Parent = head })
local chev = Icon("chevdown", 14, "faint", head)
chev.AnchorPoint = V2(1, 0.5)
chev.Position = UDim2new(1, -8, 0.5, 2)
local clip = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2new(1, 0, 0, 0), LayoutOrder = 2, Parent = wrap })
local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = clip })
List(inner, nil, 2)
local col = collapsible(self, clip, inner, not collapsed)
local cat = { Window = W, Tabs = {}, Open = not collapsed }
chev.Rotation = cat.Open and 0 or -90
col.OnDone = function()
W:_glide(false)
end
head.MouseButton1Click:Connect(function()
cat.Open = not cat.Open
col:Set(cat.Open)
tween(chev, { Rotation = cat.Open and 0 or -90 }, 0.25)
W:_glide(false)
end)
hover(head, function()
tween(chev, { ImageColor3 = T.text }, 0.15)
end, function()
refresh(chev, 0.2)
end)
function cat:Tab(to)
local t = W:_tab(to or {}, inner, cat)
table.insert(cat.Tabs, t)
return t
end
return cat
end
function Window:_tab(o, parent, category)
local W = self
local tab = setmetatable({ Window = W, Name = o.Name or "Tab", Subtitle = o.Subtitle or o.Description or "", Items = {}, Sections = {}, Groupboxes = {}, Category = category, _n = 0 }, Tab)
if self.Lib.Windows[1] == nil or self.Lib.Windows[1] == self then
self.Lib.Tabs[tab.Name] = self.Lib.Tabs[tab.Name] or tab
end
local btn, ic, lb = self:_navButton(o, parent)
tab.Button, tab.IconImg, tab.LabelText, tab.IconName = btn, ic, lb, o.Icon
Reg[lb].TextColor3 = function(t)
return W.Current == tab and t.text or t.muted
end
Reg[ic].ImageColor3 = function(t)
return t.navIcon or (W.Current == tab and t.accent or t.muted)
end
hover(btn, function()
if W.Current ~= tab then
tween(lb, { TextColor3 = T.text }, 0.15)
if not T.navIcon then
tween(ic, { ImageColor3 = T.text }, 0.15)
end
end
end, function()
refresh(lb, 0.2)
refresh(ic, 0.2)
end)
btn.MouseButton1Click:Connect(function()
W:Select(tab)
end)
local page = New("ScrollingFrame", {
Name = tab.Name,
Visible = false,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2sc(1, 1),
CanvasSize = UDim2off(0, 0),
AutomaticCanvasSize = AutoY,
ScrollBarThickness = 3,
ScrollingDirection = Enum.ScrollingDirection.Y,
Theme = { ScrollBarImageColor3 = "lineStrong" },
Parent = self.Pages,
})
page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
if W._pop then
W:_closePopup()
end
end)
tab.Page = page
local wrap = New("Frame", { BackgroundTransparency = 1, Position = UDim2off(16, 16), Size = UDim2new(1, -36, 0, 0), AutomaticSize = AutoY, Parent = page })
Pad(wrap, 0, 0, 18, 0)
tab.Wrap = wrap
if o.Columns == 1 then
tab.Left = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = wrap })
List(tab.Left, nil, 14)
else
tab.Left = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(0.5, -7, 0, 0), AutomaticSize = AutoY, Parent = wrap })
tab.Right = New("Frame", { BackgroundTransparency = 1, Position = UDim2new(0.5, 7, 0, 0), Size = UDim2new(0.5, -7, 0, 0), AutomaticSize = AutoY, Parent = wrap })
List(tab.Left, nil, 14)
List(tab.Right, nil, 14)
end
table.insert(self.Tabs, tab)
if not self.Current then
self:Select(tab, true)
end
return tab
end
function Window:Select(tab, instant)
if self.Current == tab then
return
end
local old = self.Current
self.Current = tab
self:_closePopup()
tab:_show()
if old then
old.Page.Visible = false
old.LabelText.FontFace = F.medium
refresh(old.LabelText, 0.2)
refresh(old.IconImg, 0.2)
end
tab.LabelText.FontFace = F.semi
refresh(tab.LabelText, 0.2)
refresh(tab.IconImg, 0.2)
tab.Page.Visible = true
if not instant then
tab.Page.Position = UDim2off(0, 14)
tween(tab.Page, { Position = UDim2off(0, 0) }, 0.38)
self.PageTitle.TextTransparency = 1
self.PageSub.TextTransparency = 1
tween(self.PageTitle, { TextTransparency = 0 }, 0.3)
tween(self.PageSub, { TextTransparency = 0 }, 0.4)
end
self.PageTitle.Text = tab.Name
self.PageSub.Text = tab.Subtitle
self.PageTitle.Position = UDim2off(24, tab.Subtitle == "" and 19 or 11)
if self.SearchBox.Text ~= "" or self.Results.Visible then
self.SearchBox.Text = ""
self.Results.Visible = false
end
if tab.Category and not tab.Category.Open then
end
self:_glide(not instant)
end
function Window:_glide(animate)
local tab = self.Current
local g = self.Glider
if not tab then
g.Visible = false
return
end
if tab.Category and not tab.Category.Open then
g.Visible = false
return
end
local eff = self:_eff()
if eff <= 0 then
return
end
local y = (tab.Button.AbsolutePosition.Y - self.NavList.AbsolutePosition.Y) / eff
local target = UDim2off(10, y)
if animate then
local nav = self.Nav
local view = nav.AbsoluteSize.Y / eff
local cy = nav.CanvasPosition.Y
local top, bottom = y * eff, (y + 38) * eff
if top < cy then
tween(nav, { CanvasPosition = Vector2.new(0, math.max(top - 8 * eff, 0)) }, 0.35)
elseif bottom > cy + view * eff then
tween(nav, { CanvasPosition = Vector2.new(0, bottom - view * eff + 8 * eff) }, 0.35)
end
end
if animate and g.Visible then
tween(g, { Position = target }, 0.36)
else
g.Position = target
end
g.Visible = true
end
local KIND_ICON_SEARCH = {
Toggle = "power", Slider = "sliders", Dropdown = "chevdown", Input = "keyboard", Keybind = "keyboard",
ColorPicker = "palette", Button = "play", Segmented = "layers", Group = "layers", Label = "info",
Text = "info", Progress = "clock", Image = "image", Theme = "palette",
}
function Window:_search(q)
q = string.lower((q or ""):gsub("^%s+", ""):gsub("%s+$", ""))
local list = self.ResultsList
for _, c in ipairs(list:GetChildren()) do
if c:IsA("GuiObject") then
forget(c)
c:Destroy()
end
end
self._firstHit = nil
local cur = self.Current
if q == "" then
self.Results.Visible = false
if cur then
cur.Page.Visible = true
self.PageTitle.Text = cur.Name
self.PageSub.Text = cur.Subtitle
self.PageTitle.Position = UDim2off(24, cur.Subtitle == "" and 19 or 11)
end
return
end
if cur then
cur.Page.Visible = false
end
self:_closePopup()
self.Results.Visible = true
self.Results.CanvasPosition = Vector2.zero
local hits, total, MAX = {}, 0, 80
for _, tab in ipairs(self.Tabs) do
local tabHit = string.find(string.lower(tab.Name), q, 1, true) ~= nil
for _, it in ipairs(tab.Items) do
if not it.Hidden and it.Kind ~= "Label" and it.Name ~= "" then
local secName = it.Section and it.Section.Name or ""
if string.find(it.Text, q, 1, true) or string.find(string.lower(secName), q, 1, true) or tabHit then
total += 1
if #hits < MAX then
table.insert(hits, it)
end
end
end
end
end
self.PageTitle.Text = "Search"
self.PageSub.Text = total == 0 and ("Nothing matches “" .. q .. "”") or (total .. (total == 1 and " match" or " matches") .. " across all menus" .. (total > MAX and (" · showing the first " .. MAX) or ""))
self.PageTitle.Position = UDim2off(24, 11)
if total == 0 then
local e = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 120), Parent = list })
Label({ Text = "Try a shorter word, or the name of a page or section.", Size = 13, Color = "muted", AlignX = CENTER, Dim = UDim2sc(1, 1), Parent = e })
return
end
local order, lastKey = 0, nil
for _, it in ipairs(hits) do
local key = it.Tab.Name .. "\0" .. (it.Section and it.Section.Name or "")
if key ~= lastKey then
lastKey = key
order += 1
local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 26), LayoutOrder = order, Parent = list })
local ic = Icon(it.Tab.IconName or "chevright", 14, "accent", head)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 2, 0.5, 2)
Label({
Text = it.Tab.Name .. (it.Section and ("   ›   " .. it.Section.Name) or ""),
Font = F.semi,
Size = 12,
Color = "muted",
Pos = UDim2off(24, 2),
Dim = UDim2new(1, -24, 1, 0),
Truncate = true,
Parent = head,
})
end
order += 1
local row = New("TextButton", {
Text = "",
AutoButtonColor = false,
Size = UDim2new(1, 0, 0, 40),
LayoutOrder = order,
BackgroundTransparency = 0.45,
Theme = { BackgroundColor3 = "panel" },
Parent = list,
})
Corner(row, 10)
local st = Stroke(row, "line")
local ic = Icon(KIND_ICON_SEARCH[it.Kind] or "chevright", 15, "faint", row)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 14, 0.5, 0)
Label({ Text = it.Name, Font = F.medium, Size = 14, Pos = UDim2off(40, 0), Dim = UDim2new(1, -120, 1, 0), Truncate = true, Parent = row })
local go = Label({ Text = "Open", Font = F.semi, Size = 12, Color = "faint", AlignX = RIGHT, Anchor = V2(1, 0), Pos = UDim2new(1, -16, 0, 0), Dim = UDim2new(0, 70, 1, 0), Parent = row })
hover(row, function()
tween(row, { BackgroundTransparency = 0.15 }, 0.12)
tween(st, { Color = T.lineStrong }, 0.12)
tween(go, { TextColor3 = T.accent }, 0.12)
end, function()
tween(row, { BackgroundTransparency = 0.45 }, 0.18)
refresh(st, 0.18)
refresh(go, 0.18)
end)
row.MouseButton1Click:Connect(function()
self:_jumpTo(it)
end)
if not self._firstHit then
self._firstHit = it
end
end
end
function Window:_jumpTo(it)
local tab = it.Tab
self.SearchBox.Text = ""
self:_search("")
if self.Current ~= tab then
self:Select(tab)
end
local opened = false
if it.Section and it.Section.Reveal then
it.Section:Reveal()
opened = true
end
local p = it.Parent
while p do
if p.Open then
p.Open()
opened = true
end
p = p.Parent
end
if it.Open then
it.Open()
end
if it.Section and it.Section._flush then
it.Section:_flush()
end
task.delay(opened and 0.36 or 0.05, function()
local row, page = it.Row, tab.Page
if not row or not row.Parent or not page.Parent then
return
end
local y = row.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
local target = math.max(0, y - page.AbsoluteSize.Y * 0.3)
local maxY = math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteSize.Y)
tween(page, { CanvasPosition = Vector2.new(0, math.min(target, maxY)) }, 0.4)
local flash = New("Frame", {
Size = UDim2new(1, 12, 1, 10),
Position = UDim2off(-6, -5),
BackgroundTransparency = 0.82,
ZIndex = 9,
Theme = { BackgroundColor3 = "accent" },
Parent = row,
})
Corner(flash, 10)
local fs = Stroke(flash, "accent", 0, 1.5)
task.delay(0.5, function()
tween(flash, { BackgroundTransparency = 1 }, 1.1, Enum.EasingStyle.Quad)
tween(fs, { Transparency = 1 }, 1.1, Enum.EasingStyle.Quad)
task.delay(1.15, function()
forget(flash)
flash:Destroy()
end)
end)
end)
end
function Window:_filter(q)
self:_search(q)
end
function Container._new(window, tab, body, section, parentItem)
return setmetatable({ Window = window, Tab = tab, Body = body, Section = section, ParentItem = parentItem, _o = 0 }, Container)
end
Container._lazySection = {
__index = function(t, k)
if k == "Body" or k == "Card" then
t._materialize()
return rawget(t, k)
end
return Container[k]
end,
}
function Container:_order()
local r = self._reserved
if r then
self._reserved = nil
return r
end
self._o += 1
return self._o
end
function Container:_reg(row, text, name, kind)
if not self.Tab then
return nil
end
local lazyItem = self._item
if lazyItem then
self._item = nil
lazyItem.Row = row
return lazyItem
end
local it = {
Row = row,
Text = string.lower(text or ""),
Name = name or text or "",
Kind = kind,
Tab = self.Tab,
Section = self.Section,
Parent = self.ParentItem,
}
table.insert(self.Tab.Items, it)
return it
end
function Tab:Section(o)
o = o or {}
local W = self.Window
local col
if o.Side == "Right" and self.Right then
col = self.Right
elseif o.Side == "Left" or not self.Right then
col = self.Left
else
self._n += 1
col = (self._n % 2 == 0) and self.Right or self.Left
end
local order = #self.Sections + 1
local open = not o.Collapsed
local sec = Container._new(W, self, nil, nil, nil)
sec.Name = o.Name or "Section"
sec.Section = sec
sec.Collapsed = not open
local col2, chev, sep
local function materialize()
if sec._mat then
return
end
sec._mat = true
setmetatable(sec, Container)
local card = New("Frame", {
Name = o.Name or "Section",
Size = UDim2new(1, 0, 0, 0),
AutomaticSize = AutoY,
BackgroundTransparency = tonumber(Binger.Prefs.panel) or 0.35,
Theme = { BackgroundColor3 = "panel" },
LayoutOrder = order,
Parent = col,
})
Corner(card, 13)
Stroke(card, "line")
List(card)
local head = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 46), LayoutOrder = 1, Parent = card })
local x = 16
if o.Icon ~= false then
local ic = Icon(o.Icon or "sparkles", 18, "accent", head)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 15, 0.5, 0)
x = 43
end
Label({ Text = o.Name or "Section", Font = F.semi, Size = 15, Pos = UDim2off(x, 0), Dim = UDim2new(1, -x - 40, 1, 0), Truncate = true, Parent = head })
chev = Icon("chevdown", 16, "faint", head)
chev.AnchorPoint = V2(1, 0.5)
chev.Position = UDim2new(1, -14, 0.5, 0)
sep = New("Frame", { Size = UDim2new(1, 0, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, LayoutOrder = 2, Parent = card })
local clip = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2new(1, 0, 0, 0), LayoutOrder = 3, Parent = card })
local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = clip })
List(inner, nil, 12)
Pad(inner, 14, 16, 16, 16)
col2 = collapsible(W, clip, inner, open)
chev.Rotation = open and 0 or -90
sep.Visible = open
sec.Body, sec.Card = inner, card
head.MouseButton1Click:Connect(function()
sec:SetFolded(open)
end)
hover(head, function()
tween(chev, { ImageColor3 = T.text }, 0.15)
end, function()
refresh(chev, 0.2)
end)
end
sec._materialize = materialize
if self.Groupboxes and sec.Name and self.Groupboxes[sec.Name] == nil then
self.Groupboxes[sec.Name] = sec
end
function sec:Reveal()
if not open then
sec:SetFolded(false)
end
end
sec._pending, sec._pi = {}, 1
sec._ready = self._shown == true and open
local draining = false
local function drain(budget)
local t0 = os.clock()
local q = sec._pending
while sec._pi <= #q do
local fn = q[sec._pi]
q[sec._pi] = false
sec._pi += 1
if fn then
local ok, err = pcall(fn)
if not ok then
warn("[Binger UI] lazy row failed: " .. tostring(err))
end
end
if budget and os.clock() - t0 >= budget then
return false
end
end
sec._pending, sec._pi = {}, 1
return true
end
function sec:_flush()
if drain(nil) then
Binger:_rowsBuilt()
end
end
function sec:_activate()
sec._ready = true
if draining or sec._pi > #sec._pending then
return
end
draining = true
task.spawn(function()
local budget = Binger.Touch and 0.006 or 0.008
while sec._ready and not Binger._unloaded do
if drain(budget) then
Binger:_rowsBuilt()
break
end
task.wait()
end
draining = false
end)
end
function sec:SetCollapsed(v)
open = not v
sec.Collapsed = v and true or false
if v then
sec._ready = false
elseif self.Tab and self.Tab._shown then
sec:_activate()
end
if not sec._mat then
return
end
col2:Set(open)
tween(chev, { Rotation = open and 0 or -90 }, 0.25)
if open then
sep.Visible = true
else
task.delay(0.28, function()
if not open then
sep.Visible = false
end
end)
end
end
if self._shown or not Binger.LazyRows then
materialize()
else
setmetatable(sec, Container._lazySection)
end
table.insert(self.Sections, sec)
return sec
end
function Tab:_show()
if self._shown then
return
end
self._shown = true
for _, sec in ipairs(self.Sections) do
if sec._materialize then
sec._materialize()
end
if not sec.Collapsed and sec._activate then
sec:_activate()
end
end
end
function Tab:_flush()
for _, sec in ipairs(self.Sections) do
if sec._flush then
sec:_flush()
end
end
end
function Container:Group(o)
o = o or {}
local W = self.Window
local box = New("Frame", {
Name = o.Name or "Group",
Size = UDim2new(1, 0, 0, 0),
AutomaticSize = AutoY,
BackgroundTransparency = 0.45,
Theme = { BackgroundColor3 = "field" },
LayoutOrder = self:_order(),
Parent = self.Body,
})
Corner(box, 10)
Stroke(box, "line")
List(box)
local head = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 38), LayoutOrder = 1, Parent = box })
local x = 12
if o.Icon then
local ic = Icon(o.Icon, 15, "accent", head)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 12, 0.5, 0)
x = 35
end
Label({ Text = o.Name or "Group", Font = F.semi, Size = 13, Pos = UDim2off(x, 0), Dim = UDim2new(1, -x - 36, 1, 0), Truncate = true, Parent = head })
local chev = Icon("chevdown", 14, "faint", head)
chev.AnchorPoint = V2(1, 0.5)
chev.Position = UDim2new(1, -12, 0.5, 0)
local clip = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2new(1, 0, 0, 0), LayoutOrder = 2, Parent = box })
local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = clip })
List(inner, nil, 11)
Pad(inner, 2, 12, 13, 12)
local open = not o.Collapsed
local c = collapsible(W, clip, inner, open)
chev.Rotation = open and 0 or -90
local item = self:_reg(box, (o.Name or "") .. " " .. (o.Description or ""), o.Name, "Group")
local g = Container._new(W, self.Tab, inner, self.Section, item)
g.Frame = box
if item then
item.Open = function()
if not open then
g:SetFolded(false)
end
end
end
function g:SetCollapsed(v)
open = not v
c:Set(open)
tween(chev, { Rotation = open and 0 or -90 }, 0.25)
end
head.MouseButton1Click:Connect(function()
g:SetFolded(open)
end)
return g
end
function Element.new(container, o, kind)
local lazy = o._el
if lazy then
o._el = nil
lazy.Kind, lazy.Opts, lazy.Container, lazy.Window = kind, o, container, container.Window
return lazy
end
local el = setmetatable({
Kind = kind,
Opts = o,
Container = container,
Window = container.Window,
Flag = o.Flag,
Callback = o.Callback or function() end,
Disabled = false,
}, Element)
if o.Flag then
Binger.Flags[o.Flag] = el
end
return el
end
function Element:_fire(...)
local ok, err = pcall(self.Callback, ...)
if not ok then
warn("[Binger UI] callback error in '" .. tostring(self.Opts.Name) .. "': " .. tostring(err))
end
if self._changed then
for _, fn in ipairs(self._changed) do
local ok2, err2 = pcall(fn, ...)
if not ok2 then
warn("[Binger UI] OnChanged error in '" .. tostring(self.Opts.Name) .. "': " .. tostring(err2))
end
end
end
end
function Element:SetVisible(v)
if self.Item then
self.Item.Hidden = not v
end
self.Row.Visible = v
end
function Element:SetDisabled(v)
self.Disabled = v and true or false
if self.Veil then
self.Veil.Visible = self.Disabled
end
if self.NameLabel then
tween(self.NameLabel, { TextTransparency = self.Disabled and 0.5 or 0 }, 0.2)
end
if self._onDisabled then
self._onDisabled(self.Disabled)
end
end
function Element:SetName(text)
if self.NameLabel then
self.NameLabel.Text = text
end
end
function Element:SetDescription(text)
if self.DescLabel then
self.DescLabel.Text = text
end
end
function Element:Destroy()
if self.Flag and Binger.Flags[self.Flag] == self then
Binger.Flags[self.Flag] = nil
end
if self.Kind == "Keybind" then
local i = table.find(Binger._binds, self)
if i then
table.remove(Binger._binds, i)
end
end
if self.Item and self.Container.Tab then
local items = self.Container.Tab.Items
local i = table.find(items, self.Item)
if i then
table.remove(items, i)
end
end
forget(self.Row)
self.Row:Destroy()
end
function Element:Serialize()
return self.Value
end
function Element:Deserialize(v)
return v
end
function Container:_base(el, o, spec)
spec = spec or {}
local row = New("Frame", { Name = o.Name or el.Kind, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = self:_order(), Parent = self.Body })
local stack = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = row })
List(stack, nil, spec.gap or 9)
local line = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = 1, Parent = stack })
local hit
if spec.hit then
hit = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2sc(1, 1), Parent = line })
end
local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = line })
List(inner, Enum.FillDirection.Horizontal, 10, nil, Enum.VerticalAlignment.Center)
local leftW = UDim2new(1, 0, 0, 0)
local used = 0
if spec.right then
used += spec.right.Offset + 10
end
if spec.lead then
used += spec.lead + 10
end
local rs = spec.right and spec.right.Scale or 0
leftW = UDim2new(1 - rs, -used, 0, 0)
local left = New("Frame", { BackgroundTransparency = 1, Size = leftW, AutomaticSize = AutoY, LayoutOrder = 2, Parent = inner })
List(left, nil, 3)
if o.Name and spec.noName ~= true then
el.NameLabel = Label({ Text = o.Name, Font = F.semi, Size = 14, Color = o.Risky and "err" or "text", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 1, Parent = left })
end
if o.Description and o.Description ~= "" then
el.DescLabel = Label({ Text = o.Description, Size = 12, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 2, Parent = left })
end
local veil = New("TextButton", {
Text = "",
AutoButtonColor = false,
Visible = false,
Size = UDim2new(1, 8, 1, 8),
Position = UDim2off(-4, -4),
BackgroundTransparency = 0.38,
Theme = { BackgroundColor3 = "panel" },
ZIndex = 8,
Parent = row,
})
Corner(veil, 8)
el.Row, el.Stack, el.Line, el.Inner, el.Left, el.Hit, el.Veil = row, stack, line, inner, left, hit, veil
el.Item = self:_reg(row, (o.Name or "") .. " " .. (o.Description or "") .. " " .. (o.SearchText or ""), o.Name, el.Kind)
if o.Tooltip then
Binger:_tooltip(row, o.Tooltip)
end
return row
end
function Container:_finish(el, o)
if o.Disabled then
el:SetDisabled(true)
end
if o.Visible == false then
el:SetVisible(false)
end
return el
end
function Container:_expander(el)
local clip = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2new(1, 0, 0, 0), LayoutOrder = 9, Parent = el.Stack })
local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = clip })
local box = New("Frame", { BackgroundTransparency = 0.5, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Theme = { BackgroundColor3 = "field" }, Parent = inner })
Corner(box, 10)
Stroke(box, "line")
local body = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Parent = box })
List(body, nil, 11)
Pad(body, 12, 12, 12, 12)
local c = collapsible(self.Window, clip, inner, false)
local sub = Container._new(self.Window, self.Tab, body, self.Section, el.Item)
sub._collapse = c
return sub, c
end
function Container:Toggle(o)
o = o or {}
local el = Element.new(self, o, "Toggle")
el.Value = o.Default == true
local checkbox = o.Style == "Checkbox"
local gearW = o.Settings and 30 or 0
self:_base(el, o, { hit = true, right = (not checkbox or o.Settings) and UDim.new(0, (checkbox and 0 or 44) + gearW) or nil, lead = checkbox and 22 or nil })
local onFill, knob, box, tick, tickScale
if checkbox then
box = New("Frame", { Size = UDim2off(22, 22), LayoutOrder = 1, Theme = { BackgroundColor3 = "field" }, Parent = el.Inner })
Corner(box, 7)
local bs = Stroke(box, "lineStrong", 0.1)
onFill = New("Frame", { Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = el.Value and 0 or 1, Parent = box })
Corner(onFill, 7)
New("UIGradient", { Rotation = 45, Theme = { Color = grad("accent", "accentMix") }, Parent = onFill })
tick = Icon("check", 15, "bg", box)
tick.AnchorPoint = V2(0.5, 0.5)
tick.Position = UDim2sc(0.5, 0.5)
tickScale = New("UIScale", { Scale = el.Value and 1 or 0, Parent = tick })
hover(el.Hit, function()
tween(bs, { Color = T.accent }, 0.15)
end, function()
refresh(bs, 0.2)
end)
end
local ctrl
if not checkbox or o.Settings then
ctrl = New("Frame", { BackgroundTransparency = 1, Size = UDim2off((checkbox and 0 or 44) + gearW, 24), LayoutOrder = 3, Parent = el.Inner })
end
if not checkbox then
local sw = New("Frame", { AnchorPoint = V2(1, 0.5), Position = UDim2new(1, 0, 0.5, 0), Size = UDim2off(44, 24), Theme = { BackgroundColor3 = "line" }, Parent = ctrl })
Corner(sw, 12)
local sst = Stroke(sw, "line", 0)
onFill = New("Frame", { Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = el.Value and 0 or 1, Parent = sw })
Corner(onFill, 12)
New("UIGradient", { Theme = { Color = grad("accent", "accent2") }, Parent = onFill })
knob = New("Frame", {
AnchorPoint = V2(0, 0.5),
Position = UDim2new(0, el.Value and 23 or 3, 0.5, 0),
Size = UDim2off(18, 18),
Theme = {
BackgroundColor3 = function(t)
return el.Value and t.onAccent or t.muted
end,
},
Parent = sw,
})
Corner(knob, 9)
hover(el.Hit, function()
tween(sst, { Color = T.lineStrong }, 0.15)
end, function()
refresh(sst, 0.2)
end)
end
if o.Settings then
local gear = New("ImageButton", {
BackgroundTransparency = 1,
Image = "",
AnchorPoint = V2(0, 0.5),
Position = UDim2new(0, checkbox and 6 or 0, 0.5, 0),
Size = UDim2off(22, 22),
Parent = ctrl,
})
local gi = Icon("settings", 16, "muted", gear)
gi.AnchorPoint = V2(0.5, 0.5)
gi.Position = UDim2sc(0.5, 0.5)
local sub, c = self:_expander(el)
el.Settings = sub
local open = false
gear.MouseButton1Click:Connect(function()
open = not open
c:Set(open)
tween(gi, { Rotation = open and 90 or 0 }, 0.3)
Reg[gi].ImageColor3 = open and "accent" or "muted"
refresh(gi, 0.2)
end)
Binger:_tooltip(gear, "More options")
end
function el:Set(v, silent)
v = v and true or false
local changed = v ~= el.Value
el.Value = v
tween(onFill, { BackgroundTransparency = v and 0 or 1 }, 0.22)
if knob then
tween(knob, { Position = UDim2new(0, v and 23 or 3, 0.5, 0) }, 0.32, Enum.EasingStyle.Back)
refresh(knob, 0.2)
end
if tickScale then
tween(tickScale, { Scale = v and 1 or 0 }, v and 0.3 or 0.15, v and Enum.EasingStyle.Back or Enum.EasingStyle.Quad)
end
if changed and not silent then
el:_fire(v)
end
end
function el:Toggle()
el:Set(not el.Value)
end
el.Hit.MouseButton1Click:Connect(function()
if not el.Disabled then
el:Set(not el.Value)
end
end)
if el.Value and o.FireOnLoad then
task.defer(el._fire, el, true)
end
return self:_finish(el, o)
end
function Container:Slider(o)
o = o or {}
local el = Element.new(self, o, "Slider")
local min, max = o.Min or 0, o.Max or 100
local step = o.Step or o.Increment or 1
local dec = o.Decimals
if not dec then
local s = tostring(step)
local frac = s:match("%.(%d+)")
dec = frac and #frac or 0
end
local function fmt(v)
return string.format("%." .. dec .. "f", v)
end
local function snap(v)
v = math.clamp(tonumber(v) or min, min, max)
v = min + math.floor((v - min) / step + 0.5) * step
return tonumber(fmt(math.clamp(v, min, max)))
end
local suffix = o.Suffix and ((o.Suffix:sub(1, 1) == "%" and "" or " ") .. o.Suffix) or ""
el.Value = snap(o.Default or min)
local barStyle = o.Style == "Bar"
local rightW = barStyle and 64 or (o.Suffix and 104 or 64)
self:_base(el, o, { right = UDim.new(0, rightW), gap = 8 })
local vb = New("TextBox", {
Size = UDim2off(rightW, 26),
ClearTextOnFocus = false,
FontFace = F.bold,
TextSize = 14,
TextXAlignment = barStyle and CENTER or RIGHT,
BackgroundTransparency = barStyle and 0.2 or 1,
Text = "",
LayoutOrder = 3,
Theme = { TextColor3 = barStyle and "text" or "accent", BackgroundColor3 = "field" },
Parent = el.Inner,
})
if barStyle then
Corner(vb, 7)
Stroke(vb, "line")
end
local trackHit, fill, knob, knobGlow, knobScale, barText
local function rel(v)
return (max == min) and 0 or (v - min) / (max - min)
end
if barStyle then
trackHit = New("Frame", { Size = UDim2new(1, 0, 0, 26), BackgroundTransparency = 0.2, LayoutOrder = 2, Theme = { BackgroundColor3 = "field" }, Parent = el.Stack })
Corner(trackHit, 8)
Stroke(trackHit, "line")
fill = New("Frame", { Size = UDim2sc(rel(el.Value), 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = trackHit })
Corner(fill, 8)
New("UIGradient", { Theme = { Color = grad("accent", "accent2") }, Transparency = nseq(0, 0.1, 1, 0.25), Parent = fill })
barText = Label({ Text = "", Font = F.semi, Size = 13, AlignX = CENTER, Dim = UDim2sc(1, 1), Z = 2, Parent = trackHit })
else
trackHit = New("Frame", { Size = UDim2new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 2, Parent = el.Stack })
local track = New("Frame", { AnchorPoint = V2(0, 0.5), Position = UDim2new(0, 0, 0.5, 0), Size = UDim2new(1, 0, 0, 6), Theme = { BackgroundColor3 = "line" }, Parent = trackHit })
Corner(track, 3)
fill = New("Frame", { Size = UDim2sc(rel(el.Value), 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track })
Corner(fill, 3)
New("UIGradient", { Theme = { Color = grad("accent", "accentMix") }, Parent = fill })
knobGlow = New("ImageLabel", { BackgroundTransparency = 1, Image = Assets.glow or "", ImageTransparency = 0.55, AnchorPoint = V2(0.5, 0.5), Position = UDim2new(rel(el.Value), 0, 0.5, 0), Size = UDim2off(34, 34), Theme = { ImageColor3 = "accent" }, Parent = trackHit })
knob = New("Frame", { AnchorPoint = V2(0.5, 0.5), Position = UDim2new(rel(el.Value), 0, 0.5, 0), Size = UDim2off(16, 16), Theme = { BackgroundColor3 = "white" }, Parent = trackHit })
Corner(knob, 8)
Stroke(knob, "accent", 0, 3)
knobScale = New("UIScale", { Parent = knob })
end
local presetBtns = {}
if o.Presets then
local pr = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 28), LayoutOrder = 3, Parent = el.Stack })
local n = #o.Presets
List(pr, Enum.FillDirection.Horizontal, 6)
for i, pv in ipairs(o.Presets) do
local b = New("TextButton", {
Text = fmt(pv),
AutoButtonColor = false,
FontFace = F.medium,
TextSize = 12,
BackgroundTransparency = 1,
Size = UDim2new(1 / n, -6 * (n - 1) / n, 1, 0),
LayoutOrder = i,
Theme = {
TextColor3 = function(t)
return el.Value == pv and t.accent or t.muted
end,
},
Parent = pr,
})
Corner(b, 8)
local bst = Stroke(b, nil, 0)
Reg[bst] = { Color = function(t)
return el.Value == pv and t.accent or t.line
end }
refresh(bst)
b.MouseButton1Click:Connect(function()
if not el.Disabled then
el:Set(pv)
end
end)
hover(b, function()
tween(b, { TextColor3 = T.text }, 0.12)
end, function()
refresh(b, 0.2)
end)
presetBtns[#presetBtns + 1] = { b, bst }
end
end
local function paint(animate)
local r = rel(el.Value)
local t = animate and 0.12 or nil
if t then
tween(fill, { Size = UDim2sc(r, 1) }, t, Enum.EasingStyle.Quad)
else
fill.Size = UDim2sc(r, 1)
end
if knob then
if t then
tween(knob, { Position = UDim2new(r, 0, 0.5, 0) }, t, Enum.EasingStyle.Quad)
tween(knobGlow, { Position = UDim2new(r, 0, 0.5, 0) }, t, Enum.EasingStyle.Quad)
else
knob.Position = UDim2new(r, 0, 0.5, 0)
knobGlow.Position = UDim2new(r, 0, 0.5, 0)
end
end
if barText then
barText.Text = fmt(el.Value) .. "/" .. fmt(max) .. suffix
vb.Text = fmt(el.Value)
elseif not vb:IsFocused() then
vb.Text = fmt(el.Value) .. suffix
end
for _, pb in ipairs(presetBtns) do
refresh(pb[1], 0.15)
refresh(pb[2], 0.15)
end
end
function el:Set(v, silent)
v = snap(v)
local changed = v ~= el.Value
el.Value = v
paint(true)
if changed and not silent then
el:_fire(v)
end
end
el.Min, el.Max = min, max
local function relimit()
local old = el.Value
el.Value = snap(el.Value)
paint(false)
if el.Value ~= old then
el:_fire(el.Value)
end
end
function el:SetMin(v)
min = tonumber(v) or min
max = math.max(max, min)
el.Min, el.Max = min, max
relimit()
end
function el:SetMax(v)
max = tonumber(v) or max
min = math.min(min, max)
el.Min, el.Max = min, max
relimit()
end
function el:SetSuffix(s)
suffix = (s and s ~= "") and (((s:sub(1, 1) == "%") and "" or " ") .. s) or ""
paint(false)
end
function el:SetPrefix() end
trackHit.InputBegan:Connect(function(input)
if not isPress(input) or el.Disabled then
return
end
if knobScale then
tween(knobScale, { Scale = 1.25 }, 0.18)
end
local startV = el.Value
el.Dragging = true
Binger:_beginDrag(input, function(p)
local a = trackHit.AbsolutePosition.X
local w = math.max(trackHit.AbsoluteSize.X, 1)
el:Set(min + math.clamp((p.X - a) / w, 0, 1) * (max - min))
end, function()
el.Dragging = false
if knobScale then
tween(knobScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
end
if el.Value ~= startV then
el:_fire(el.Value)
end
end)
end)
if knob then
hover(trackHit, function()
tween(knobGlow, { ImageTransparency = 0.3 }, 0.2)
end, function()
tween(knobGlow, { ImageTransparency = 0.55 }, 0.25)
end)
end
vb.Focused:Connect(function()
vb.Text = fmt(el.Value)
end)
vb.FocusLost:Connect(function()
local n = tonumber((vb.Text:gsub("[^%d%.%-]", "")))
if n and not el.Disabled then
el:Set(n)
end
paint(false)
end)
paint(false)
return self:_finish(el, o)
end
function Container:Dropdown(o)
o = o or {}
local el = Element.new(self, o, "Dropdown")
local W = self.Window
el.Options = table.clone(o.Options or o.Values or {})
el.Values = el.Options
el.Multi = o.Multi == true
local sel = {}
local function toList(v)
local out = {}
if type(v) == "table" then
if #v > 0 then
for _, x in ipairs(v) do
table.insert(out, x)
end
else
for _, x in ipairs(el.Options) do
if v[x] then
table.insert(out, x)
end
end
for k, on in pairs(v) do
if on == true and not table.find(out, k) then
table.insert(out, k)
end
end
end
end
return out
end
local function publish()
if o.Dict then
local d = {}
for _, x in ipairs(sel) do
d[x] = true
end
el.Value = d
else
el.Value = table.clone(sel)
end
end
if el.Multi then
sel = toList(o.Default)
publish()
else
el.Value = o.Default
end
self:_base(el, o, { right = UDim.new(0.5, 0) })
local field = New("TextButton", {
Text = "",
AutoButtonColor = false,
Size = UDim2new(0.5, 0, 0, 34),
LayoutOrder = 3,
BackgroundTransparency = 0.15,
Theme = { BackgroundColor3 = "field" },
Parent = el.Inner,
})
Corner(field, 9)
local fst = Stroke(field, "line")
local valueLbl = Label({ Text = "", Font = F.medium, Size = 13, Pos = UDim2off(12, 0), Dim = UDim2new(1, -40, 1, 0), Truncate = true, Parent = field })
local chev = Icon("chevdown", 15, "muted", field)
chev.AnchorPoint = V2(1, 0.5)
chev.Position = UDim2new(1, -11, 0.5, 0)
local function display()
local txt, has
if el.Multi then
has = #sel > 0
local names = {}
for i, x in ipairs(sel) do
names[i] = tostring(x)
end
txt = has and table.concat(names, ", ") or (o.Placeholder or "None")
else
has = el.Value ~= nil
txt = has and tostring(el.Value) or (o.Placeholder or (o.Nullable and "---" or "Select…"))
end
valueLbl.Text = txt
Reg[valueLbl].TextColor3 = has and "text" or "faint"
refresh(valueLbl)
end
local function isSel(v)
if el.Multi then
return table.find(sel, v) ~= nil
end
return el.Value == v
end
local open = false
local function openList()
if el.Disabled then
return
end
local opts = {}
if o.Nullable and not el.Multi then
table.insert(opts, { v = nil, label = "---" })
end
for _, v in ipairs(el.Options) do
table.insert(opts, { v = v, label = tostring(v) })
end
local searchable = o.Search or o.Searchable or #el.Options > 8
local rows = math.min(#opts, 7)
local height = rows * 32 + 10 + (searchable and 38 or 0)
local width = math.max(field.AbsoluteSize.X / W:_eff(), 170)
local pop, p = W:_popup(field, width, height)
open = true
Reg[fst].Color = "accent"
refresh(fst, 0.15)
tween(chev, { Rotation = p.Up and 0 or 180 }, 0.25)
p.OnClose = function()
open = false
Reg[fst].Color = "line"
refresh(fst, 0.2)
tween(chev, { Rotation = 0 }, 0.25)
end
local y = 5
local sb
if searchable then
local sf = New("Frame", { Position = UDim2off(5, 5), Size = UDim2new(1, -10, 0, 32), BackgroundTransparency = 0.1, Theme = { BackgroundColor3 = "field" }, ZIndex = 4, Parent = pop })
Corner(sf, 7)
local si = Icon("search", 13, "muted", sf)
si.AnchorPoint = V2(0, 0.5)
si.Position = UDim2new(0, 9, 0.5, 0)
si.ZIndex = 4
sb = New("TextBox", {
BackgroundTransparency = 1,
Position = UDim2off(28, 0),
Size = UDim2new(1, -34, 1, 0),
Text = "",
PlaceholderText = "Search",
ClearTextOnFocus = false,
FontFace = F.body,
TextSize = 13,
TextXAlignment = LEFT,
ZIndex = 4,
Theme = { TextColor3 = "text", PlaceholderColor3 = "faint" },
Parent = sf,
})
y = 43
end
local list = New("ScrollingFrame", {
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2off(0, y),
Size = UDim2new(1, 0, 1, -y - 5),
CanvasSize = UDim2off(0, 0),
AutomaticCanvasSize = AutoY,
ScrollBarThickness = 2,
ZIndex = 4,
Theme = { ScrollBarImageColor3 = "lineStrong" },
Parent = pop,
})
List(list, nil, 0)
Pad(list, 0, 5, 0, 5)
local BATCH = 40
local shown, rows, filtered = 0, {}, opts
local function makeRow(op, i)
local b = New("TextButton", {
Text = "",
AutoButtonColor = false,
Size = UDim2new(1, 0, 0, 32),
BackgroundTransparency = 1,
LayoutOrder = i,
ZIndex = 4,
Theme = { BackgroundColor3 = "hover" },
Parent = list,
})
Corner(b, 7)
local lbl = Label({ Text = op.label, Font = F.medium, Size = 13, Pos = UDim2off(10, 0), Dim = UDim2new(1, -36, 1, 0), Truncate = true, Z = 4, Parent = b })
local off = op.v ~= nil and el.DisabledValues and el.DisabledValues[op.v]
Reg[lbl].TextColor3 = function(t)
if op.v == nil or off then
return t.faint
end
return isSel(op.v) and t.accent or t.text
end
refresh(lbl)
local ck = Icon("check", 14, "accent", b)
ck.AnchorPoint = V2(1, 0.5)
ck.Position = UDim2new(1, -10, 0.5, 0)
ck.ZIndex = 4
ck.Visible = op.v ~= nil and isSel(op.v)
hover(b, function()
tween(b, { BackgroundTransparency = 0.35 }, 0.12)
end, function()
tween(b, { BackgroundTransparency = 1 }, 0.18)
end)
b.MouseButton1Click:Connect(function()
if off then
return
end
if el.Multi then
local idx = table.find(sel, op.v)
if idx then
table.remove(sel, idx)
else
table.insert(sel, op.v)
end
publish()
ck.Visible = idx == nil
refresh(lbl, 0.15)
display()
el:_fire(el.Value)
else
el:Set(op.v)
W:_closePopup()
end
end)
rows[#rows + 1] = b
end
local function more()
local stop = math.min(shown + BATCH, #filtered)
for i = shown + 1, stop do
makeRow(filtered[i], i)
end
shown = stop
end
local function reset()
for _, r in ipairs(rows) do
forget(r)
r:Destroy()
end
rows, shown = {}, 0
list.CanvasPosition = Vector2.zero
more()
end
more()
list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
if shown < #filtered and list.CanvasPosition.Y + list.AbsoluteSize.Y > list.AbsoluteCanvasSize.Y - 64 * W:_eff() then
more()
end
end)
if sb then
local token = 0
sb:GetPropertyChangedSignal("Text"):Connect(function()
token += 1
local my = token
task.delay(0.08, function()
if my ~= token or not list.Parent then
return
end
local q = string.lower(sb.Text)
if q == "" then
filtered = opts
else
filtered = {}
for _, op in ipairs(opts) do
if string.find(string.lower(op.label), q, 1, true) then
filtered[#filtered + 1] = op
end
end
end
reset()
end)
end)
task.defer(function()
if sb.Parent then
sb:CaptureFocus()
end
end)
end
end
field.MouseButton1Click:Connect(function()
if open then
W:_closePopup()
else
openList()
end
end)
hover(field, function()
if not open then
tween(fst, { Color = T.lineStrong }, 0.15)
end
end, function()
if not open then
refresh(fst, 0.2)
end
end)
function el:Set(v, silent)
if el.Multi then
sel = toList(v)
publish()
else
if type(v) == "table" then
v = toList(v)[1]
end
el.Value = v
end
display()
if not silent then
el:_fire(el.Value)
end
end
function el:Refresh(options, keep)
el.Options = table.clone(options or {})
el.Values = el.Options
if not keep then
el:Set(el.Multi and {} or nil, true)
end
display()
end
function el:Serialize()
return el.Multi and table.clone(sel) or el.Value
end
display()
return self:_finish(el, o)
end
function Container:Input(o)
o = o or {}
local el = Element.new(self, o, "Input")
el.Value = o.Default or ""
local inline = o.Inline == true
self:_base(el, o, { right = inline and UDim.new(0.5, 0) or nil, gap = 8 })
local box = New("Frame", {
Size = inline and UDim2new(0.5, 0, 0, 34) or UDim2new(1, 0, 0, 36),
BackgroundTransparency = 0.15,
LayoutOrder = inline and 3 or 2,
Theme = { BackgroundColor3 = "field" },
Parent = inline and el.Inner or el.Stack,
})
Corner(box, 9)
local st = Stroke(box, "line")
local x = 12
if o.Icon then
local ic = Icon(o.Icon, 15, "muted", box)
ic.AnchorPoint = V2(0, 0.5)
ic.Position = UDim2new(0, 11, 0.5, 0)
x = 34
end
local tb = New("TextBox", {
BackgroundTransparency = 1,
Position = UDim2off(x, 0),
Size = UDim2new(1, -x - 10, 1, 0),
ClearTextOnFocus = o.ClearOnFocus == true,
FontFace = F.body,
TextSize = 13,
Text = el.Value,
PlaceholderText = o.Placeholder or "Type here…",
TextXAlignment = LEFT,
TextTruncate = Enum.TextTruncate.AtEnd,
Theme = { TextColor3 = "text", PlaceholderColor3 = "faint" },
Parent = box,
})
el.TextBox = tb
tb.Focused:Connect(function()
Reg[st].Color = "accent"
refresh(st, 0.15)
end)
tb:GetPropertyChangedSignal("Text"):Connect(function()
local t = tb.Text
if o.Numeric then
local clean = t:gsub("[^%d%.%-]", "")
if clean ~= t then
tb.Text = clean
return
end
end
if o.MaxLength and #t > o.MaxLength then
tb.Text = t:sub(1, o.MaxLength)
return
end
if o.Live then
el.Value = t
el:_fire(t)
end
end)
tb.FocusLost:Connect(function(enter)
Reg[st].Color = "line"
refresh(st, 0.2)
if o.Live then
return
end
if o.EnterOnly and not enter then
return
end
local t = tb.Text
if o.Numeric and not o.Raw then
t = tonumber(t) or 0
end
if t ~= el.Value then
el.Value = t
el:_fire(t)
end
end)
hover(box, function()
if not tb:IsFocused() then
tween(st, { Color = T.lineStrong }, 0.15)
end
end, function()
if not tb:IsFocused() then
refresh(st, 0.2)
end
end)
function el:Set(v, silent)
el.Value = v
tb.Text = tostring(v or "")
if not silent then
el:_fire(v)
end
end
return self:_finish(el, o)
end
function Container:Keybind(o)
o = o or {}
local el = Element.new(self, o, "Keybind")
el.Key = toKey(o.Default)
el.Value = el.Key and el.Key.Name or nil
el.Mode = o.Mode or "Toggle"
el.State = false
self:_base(el, o, { right = UDim.new(0, 112) })
local holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2off(112, 30), LayoutOrder = 3, Parent = el.Inner })
local btn = New("TextButton", {
Text = "",
AutoButtonColor = false,
AnchorPoint = V2(1, 0.5),
Position = UDim2new(1, 0, 0.5, 0),
Size = UDim2off(0, 30),
AutomaticSize = AutoX,
BackgroundTransparency = 0.15,
Theme = { BackgroundColor3 = "field" },
Parent = holder,
})
Corner(btn, 8)
local st = Stroke(btn, "line")
Pad(btn, 0, 11, 0, 11)
New("UISizeConstraint", { MinSize = V2(58, 30), MaxSize = V2(112, 30), Parent = btn })
local lbl = Label({ Text = "", Font = F.semi, Size = 13, AlignX = CENTER, Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Parent = btn })
local function paint()
lbl.Text = el.Listening and "Press a key…" or keyName(el.Key)
Reg[lbl].TextColor3 = (el.Listening and "accent") or ((el.State and el.Mode ~= "Press") and "accent") or (el.Key and "text" or "faint")
refresh(lbl, 0.15)
end
el._paint = paint
btn.MouseButton1Click:Connect(function()
if el.Disabled or el.Listening then
return
end
el.Listening = true
Reg[st].Color = "accent"
refresh(st, 0.15)
paint()
task.wait()
Binger._listen = function(k)
Binger._listen = nil
el.Listening = false
Reg[st].Color = "line"
refresh(st, 0.2)
if k == Enum.KeyCode.Escape then
paint()
return
end
if k == Enum.KeyCode.Backspace or k == Enum.KeyCode.Delete then
k = nil
end
el:Set(k)
end
end)
function el:Set(k, silent)
if type(k) == "table" then
el.Mode = k[2] or el.Mode
k = k[1]
end
el.Key = toKey(k)
el.Value = el.Key and el.Key.Name or nil
paint()
if Binger.ToggleKeybind == el then
for _, w in ipairs(Binger.Windows) do
w:SetToggleKey(el.Key)
end
end
if o.Changed and not silent then
pcall(o.Changed, el.Key)
end
Binger:_refreshKeylist()
end
function el:_trigger(state)
if state == nil then
el:_fire()
else
el.State = state
paint()
el:_fire(state)
end
Binger:_refreshKeylist()
end
function el:Serialize()
return el.Value
end
function el:Deserialize(v)
return toKey(v)
end
table.insert(Binger._binds, el)
paint()
Binger:_refreshKeylist()
return self:_finish(el, o)
end
function Container:ColorPicker(o)
o = o or {}
local el = Element.new(self, o, "ColorPicker")
local W = self.Window
el.Value = o.Default or Color3.fromRGB(227, 181, 79)
self:_base(el, o, { right = UDim.new(0, 50) })
local sw = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2off(50, 26), BackgroundColor3 = el.Value, LayoutOrder = 3, Parent = el.Inner })
Corner(sw, 8)
local sst = Stroke(sw, "lineStrong", 0.2)
local h, s, v = el.Value:ToHSV()
local function openPicker()
if el.Disabled then
return
end
local pop, p = W:_popup(sw, 244, 214)
Reg[sst].Color = "accent"
refresh(sst, 0.15)
p.OnClose = function()
Reg[sst].Color = "lineStrong"
refresh(sst, 0.2)
end
local sv = New("Frame", { Position = UDim2off(12, 12), Size = UDim2off(184, 140), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 4, Parent = pop })
Corner(sv, 8)
local wht = New("Frame", { Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 4, Parent = sv })
Corner(wht, 8)
New("UIGradient", { Transparency = nseq(0, 0, 1, 1), Parent = wht })
local blk = New("Frame", { Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 4, Parent = sv })
Corner(blk, 8)
New("UIGradient", { Rotation = 90, Transparency = nseq(0, 1, 1, 0), Parent = blk })
local cur = New("Frame", { AnchorPoint = V2(0.5, 0.5), Size = UDim2off(14, 14), BackgroundTransparency = 1, ZIndex = 5, Parent = sv })
Corner(cur, 7)
local cst = Stroke(cur, "white", 0, 2)
local hue = New("Frame", { Position = UDim2off(206, 12), Size = UDim2off(26, 140), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 4, Parent = pop })
Corner(hue, 8)
local kps = {}
for i = 0, 6 do
kps[#kps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1))
end
New("UIGradient", { Rotation = 90, Color = ColorSequence.new(kps), Parent = hue })
local hcur = New("Frame", { AnchorPoint = V2(0.5, 0.5), Size = UDim2new(1, 6, 0, 6), Position = UDim2sc(0.5, h), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = hue })
Corner(hcur, 3)
Stroke(hcur, "black", 0.5)
local hexBox = New("TextBox", {
Position = UDim2off(12, 164),
Size = UDim2off(140, 36),
BackgroundTransparency = 0.1,
Text = "#" .. el.Value:ToHex():upper(),
FontFace = F.semi,
TextSize = 13,
ClearTextOnFocus = false,
ZIndex = 4,
Theme = { BackgroundColor3 = "field", TextColor3 = "text" },
Parent = pop,
})
Corner(hexBox, 8)
Stroke(hexBox, "line")
local prev = New("Frame", { Position = UDim2off(162, 164), Size = UDim2off(70, 36), BackgroundColor3 = el.Value, ZIndex = 4, Parent = pop })
Corner(prev, 8)
Stroke(prev, "line")
local function paint(skipHex)
sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
cur.Position = UDim2sc(s, 1 - v)
hcur.Position = UDim2sc(0.5, h)
prev.BackgroundColor3 = el.Value
cst.Color = v > 0.55 and s < 0.4 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
if not skipHex then
hexBox.Text = "#" .. el.Value:ToHex():upper()
end
end
local settle = 0
local function commit()
el:Set(Color3.fromHSV(h, s, v), true, true)
paint()
end
local function release()
settle += 1
local my = settle
task.delay(0.35, function()
if my == settle then
el:_fire(el.Value)
end
end)
end
sv.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
settle += 1
Binger:_beginDrag(input, function(pt)
local a, z = sv.AbsolutePosition, sv.AbsoluteSize
s = math.clamp((pt.X - a.X) / z.X, 0, 1)
v = 1 - math.clamp((pt.Y - a.Y) / z.Y, 0, 1)
commit()
end, release)
end)
hue.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
settle += 1
Binger:_beginDrag(input, function(pt)
h = math.clamp((pt.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
commit()
end, release)
end)
hexBox.FocusLost:Connect(function()
local ok, c = pcall(Color3.fromHex, (hexBox.Text:gsub("#", "")))
if ok and c then
h, s, v = c:ToHSV()
el:Set(c, false, true)
end
paint()
end)
paint()
end
sw.MouseButton1Click:Connect(openPicker)
function el:Set(c, silent, keepHSV)
if typeof(c) ~= "Color3" then
return
end
el.Value = c
sw.BackgroundColor3 = c
if not keepHSV then
h, s, v = c:ToHSV()
end
if not silent then
el:_fire(c)
end
end
function el:Serialize()
return el.Value:ToHex()
end
function el:Deserialize(x)
local ok, c = pcall(Color3.fromHex, x)
return ok and c or el.Value
end
return self:_finish(el, o)
end
function Container:Segmented(o)
o = o or {}
local el = Element.new(self, o, "Segmented")
local opts = o.Options or {}
local n = math.max(#opts, 1)
el.Value = o.Default or opts[1]
self:_base(el, o, { gap = 8 })
local track = New("Frame", { Size = UDim2new(1, 0, 0, 34), BackgroundTransparency = 0.15, LayoutOrder = 2, Theme = { BackgroundColor3 = "field" }, Parent = el.Stack })
Corner(track, 10)
Stroke(track, "line")
local idx = math.max(table.find(opts, el.Value) or 1, 1)
local glider = New("Frame", { Position = UDim2new((idx - 1) / n, 3, 0, 3), Size = UDim2new(1 / n, -6, 1, -6), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track })
Corner(glider, 8)
New("UIGradient", { Rotation = 20, Theme = { Color = grad("accent", "accentMix") }, Parent = glider })
local labels = {}
for i, opt in ipairs(opts) do
local b = New("TextButton", {
Text = tostring(opt),
AutoButtonColor = false,
BackgroundTransparency = 1,
FontFace = F.semi,
TextSize = 13,
Position = UDim2sc((i - 1) / n, 0),
Size = UDim2sc(1 / n, 1),
ZIndex = 2,
Theme = {
TextColor3 = function(t)
return el.Value == opt and t.onAccent or t.muted
end,
},
Parent = track,
})
labels[i] = b
b.MouseButton1Click:Connect(function()
if not el.Disabled then
el:Set(opt)
end
end)
hover(b, function()
if el.Value ~= opt then
tween(b, { TextColor3 = T.text }, 0.12)
end
end, function()
refresh(b, 0.2)
end)
end
function el:Set(v, silent)
local i = table.find(opts, v)
if not i then
return
end
local changed = el.Value ~= v
el.Value = v
tween(glider, { Position = UDim2new((i - 1) / n, 3, 0, 3) }, 0.35)
for _, b in ipairs(labels) do
refresh(b, 0.2)
end
if changed and not silent then
el:_fire(v)
end
end
return self:_finish(el, o)
end
function Container._button(parent, text, style, icon, size)
local btn = New("TextButton", {
Text = "",
AutoButtonColor = false,
Size = size or UDim2new(1, 0, 0, 36),
BackgroundTransparency = style == "danger" and 0.88 or (style == "primary" and 0 or 0.15),
Theme = { BackgroundColor3 = style == "primary" and "white" or (style == "danger" and "err" or "field") },
Parent = parent,
})
Corner(btn, 10)
local st
if style == "primary" then
New("UIGradient", { Rotation = 15, Theme = { Color = grad("accent", "accentMix") }, Parent = btn })
else
st = Stroke(btn, style == "danger" and "err" or "line", style == "danger" and 0.45 or 0)
end
local content = New("Frame", { BackgroundTransparency = 1, Size = UDim2sc(1, 1), Parent = btn })
List(content, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
local fg = style == "primary" and "onAccent" or (style == "danger" and "err" or "text")
if icon then
Icon(icon, 16, fg, content).LayoutOrder = 1
end
local lbl = Label({ Text = text or "Button", Font = F.semi, Size = 14, Color = fg, Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Order = 2, Parent = content })
local sheen = New("Frame", { Size = UDim2sc(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = btn })
Corner(sheen, 10)
local sc = New("UIScale", { Parent = btn })
hover(btn, function()
tween(sheen, { BackgroundTransparency = style == "primary" and 0.85 or 0.95 }, 0.15)
if st then
tween(st, { Color = style == "danger" and T.err or T.lineStrong }, 0.15)
end
end, function()
tween(sheen, { BackgroundTransparency = 1 }, 0.2)
if st then
refresh(st, 0.2)
end
end)
btn.MouseButton1Down:Connect(function()
tween(sc, { Scale = 0.97 }, 0.1, Enum.EasingStyle.Quad)
end)
btn.MouseButton1Up:Connect(function()
tween(sc, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
end)
btn.MouseLeave:Connect(function()
tween(sc, { Scale = 1 }, 0.2)
end)
return btn, lbl
end
local function wireButton(el, btn, lbl, o)
local armed = false
local token = 0
btn.MouseButton1Click:Connect(function()
if el.Disabled then
return
end
if o.Confirm and not armed then
armed = true
token += 1
local my = token
lbl.Text = type(o.Confirm) == "string" and o.Confirm or "Click again to confirm"
Reg[lbl].TextColor3 = "warn"
refresh(lbl, 0.15)
task.delay(2.5, function()
if my == token and armed then
armed = false
lbl.Text = o.Name or "Button"
Reg[lbl].TextColor3 = o.Style == "primary" and "onAccent" or (o.Style == "danger" and "err" or "text")
refresh(lbl, 0.2)
end
end)
return
end
if armed then
armed = false
token += 1
lbl.Text = o.Name or "Button"
Reg[lbl].TextColor3 = o.Style == "primary" and "onAccent" or (o.Style == "danger" and "err" or "text")
refresh(lbl, 0.2)
end
task.spawn(function()
el:_fire()
end)
end)
end
function Container:Button(o)
o = o or {}
local el = Element.new(self, o, "Button")
local row = New("Frame", { Name = o.Name or "Button", BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 36), LayoutOrder = self:_order(), Parent = self.Body })
local btn, lbl = Container._button(row, o.Name, o.Style, o.Icon)
local veil = New("TextButton", { Text = "", AutoButtonColor = false, Visible = false, Size = UDim2sc(1, 1), BackgroundTransparency = 0.38, ZIndex = 8, Theme = { BackgroundColor3 = "panel" }, Parent = row })
Corner(veil, 10)
el.Row, el.Veil, el.Button = row, veil, btn
el.Item = self:_reg(row, o.Name, o.Name, "Button")
if o.Tooltip or o.Description then
Binger:_tooltip(btn, o.Tooltip or o.Description)
end
wireButton(el, btn, lbl, o)
function el:SetName(t)
o.Name = t
lbl.Text = t
end
return self:_finish(el, o)
end
function Container:Buttons(list)
local row = New("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 36), LayoutOrder = self:_order(), Parent = self.Body })
List(row, Enum.FillDirection.Horizontal, 8)
local n = #list
local out = {}
local names = {}
for i, o in ipairs(list) do
local el = Element.new(self, o, "Button")
local btn, lbl = Container._button(row, o.Name, o.Style, o.Icon, UDim2new(1 / n, -8 * (n - 1) / n, 1, 0))
btn.LayoutOrder = i
el.Row, el.Button = btn, btn
if o.Tooltip then
Binger:_tooltip(btn, o.Tooltip)
end
wireButton(el, btn, lbl, o)
out[i] = el
names[i] = o.Name or ""
end
self:_reg(row, table.concat(names, " "), table.concat(names, " / "), "Button")
return table.unpack(out)
end
function Container:Label(text, o)
o = o or {}
local el = Element.new(self, o, "Label")
local lbl = Label({ Text = text or "", Size = o.Size or 13, Color = o.Color or "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Rich = o.Rich, AlignX = o.Center and CENTER or LEFT, Order = self:_order(), Parent = self.Body })
el.Row = lbl
el.Item = self:_reg(lbl, text, text, "Label")
function el:Set(t)
lbl.Text = t
end
return el
end
function Container:Paragraph(o)
o = o or {}
local el = Element.new(self, o, "Paragraph")
local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = self:_order(), Parent = self.Body })
List(f, nil, 4)
local t = Label({ Text = o.Title or "", Font = F.semi, Size = 14, Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 1, Parent = f })
local c = Label({ Text = o.Content or "", Size = 13, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Rich = o.Rich, Order = 2, Parent = f })
el.Row = f
el.Item = self:_reg(f, (o.Title or "") .. " " .. (o.Content or ""), o.Title or o.Content, "Text")
function el:Set(p)
if p.Title then
t.Text = p.Title
end
if p.Content then
c.Text = p.Content
end
end
return el
end
function Container:Divider(text)
local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, text and 18 or 9), LayoutOrder = self:_order(), Parent = self.Body })
if text then
local l = Label({ Text = text, Font = F.semi, Size = 12, Color = "faint", AlignX = CENTER, Anchor = V2(0.5, 0.5), Pos = UDim2sc(0.5, 0.5), Dim = UDim2new(0, 0, 1, 0), Auto = AutoX, Z = 2, Parent = f })
Pad(l, 0, 10, 0, 10)
New("Frame", { AnchorPoint = V2(0, 0.5), Position = UDim2sc(0, 0.5), Size = UDim2new(0.5, -50, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = f })
New("Frame", { AnchorPoint = V2(1, 0.5), Position = UDim2sc(1, 0.5), Size = UDim2new(0.5, -50, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = f })
else
New("Frame", { AnchorPoint = V2(0, 0.5), Position = UDim2sc(0, 0.5), Size = UDim2new(1, 0, 0, 1), BorderSizePixel = 0, Theme = { BackgroundColor3 = "line" }, Parent = f })
end
return f
end
function Container:Progress(o)
o = o or {}
local el = Element.new(self, o, "Progress")
local max = o.Max or 100
el.Value = math.clamp(o.Value or o.Default or 0, 0, max)
self:_base(el, o, { right = UDim.new(0, 70), gap = 8 })
local val = Label({ Text = "", Font = F.bold, Size = 13, Color = "accent", AlignX = RIGHT, Dim = UDim2off(70, 20), Order = 3, Parent = el.Inner })
local track = New("Frame", { Size = UDim2new(1, 0, 0, 8), LayoutOrder = 2, Theme = { BackgroundColor3 = "line" }, Parent = el.Stack })
Corner(track, 4)
local fill = New("Frame", { Size = UDim2sc(el.Value / max, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track })
Corner(fill, 4)
New("UIGradient", { Theme = { Color = grad("accent", "accent2") }, Parent = fill })
local function txt()
if o.Percent ~= false and not o.Suffix then
return math.floor(el.Value / max * 100 + 0.5) .. "%"
end
return tostring(el.Value) .. (o.Suffix and (" " .. o.Suffix) or "")
end
val.Text = txt()
function el:Set(v)
el.Value = math.clamp(v, 0, max)
tween(fill, { Size = UDim2sc(el.Value / max, 1) }, 0.5)
val.Text = txt()
end
return self:_finish(el, o)
end
function Container:Callout(o)
o = o or {}
local kind = KIND_KEY[o.Kind or "info"] and (o.Kind or "info") or "info"
local ck = KIND_KEY[kind]
local el = Element.new(self, o, "Callout")
local f = New("Frame", { Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, BackgroundTransparency = 0.9, LayoutOrder = self:_order(), Theme = { BackgroundColor3 = ck }, Parent = self.Body })
Corner(f, 10)
Stroke(f, ck, 0.65)
Pad(f, 11, 12, 12, 12)
local ic = Icon(o.Icon or KIND_ICON[kind], 17, ck, f)
ic.Position = UDim2off(0, 1)
local col = New("Frame", { BackgroundTransparency = 1, Position = UDim2off(28, 0), Size = UDim2new(1, -28, 0, 0), AutomaticSize = AutoY, Parent = f })
List(col, nil, 2)
if o.Title then
Label({ Text = o.Title, Font = F.semi, Size = 13, Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 1, Parent = col })
end
local c = Label({ Text = o.Content or "", Size = 12, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 2, Parent = col })
el.Row = f
el.Item = self:_reg(f, (o.Title or "") .. " " .. (o.Content or ""), o.Title or o.Content, "Text")
function el:Set(t)
c.Text = t
end
return el
end
function Container:Image(o)
o = o or {}
local el = Element.new(self, o, "Image")
local img = New("ImageLabel", {
Size = UDim2new(1, 0, 0, o.Height or 120),
Image = o.Image or "",
ScaleType = o.ScaleType or Enum.ScaleType.Crop,
BackgroundTransparency = 0.2,
LayoutOrder = self:_order(),
Theme = { BackgroundColor3 = "field" },
Parent = self.Body,
})
Corner(img, 10)
Stroke(img, "line")
el.Row = img
el.Item = self:_reg(img, o.Name or "image", o.Name or "Image", "Image")
function el:Set(id)
img.Image = id
end
return el
end
function Container:ThemePicker()
local el = Element.new(self, {}, "ThemePicker")
local grid = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = self:_order(), Parent = self.Body })
New("UIGridLayout", { CellSize = UDim2new(0.5, -5, 0, 66), CellPadding = UDim2off(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
for i, th in ipairs(THEMES) do
local tile = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), LayoutOrder = i, Parent = grid })
Corner(tile, 11)
New("UIGradient", { Rotation = 25, Color = seq(th.bg, th.bg:Lerp(th.accent2, 0.35), th.bg:Lerp(th.accent2, 0.75)), Parent = tile })
local st = Stroke(tile, nil, 0, 2)
Reg[st] = { Color = function(t)
return Binger.Prefs.theme == th.Id and t.accent or t.line
end, Transparency = function()
return Binger.Prefs.theme == th.Id and 0 or 0.3
end }
refresh(st)
local dots = New("Frame", { BackgroundTransparency = 1, Position = UDim2off(11, 10), Size = UDim2off(60, 12), Parent = tile })
List(dots, Enum.FillDirection.Horizontal, 4)
for j, c in ipairs({ th.accent, th.accent2, th.text }) do
local d = New("Frame", { Size = UDim2off(11, 11), BackgroundColor3 = c, LayoutOrder = j, Parent = dots })
Corner(d, 6)
end
local nm = New("TextLabel", {
BackgroundTransparency = 1,
Text = th.Name,
FontFace = F.display,
TextScaled = true,
TextColor3 = th.text,
TextXAlignment = LEFT,
Position = UDim2new(0, 11, 1, -29),
Size = UDim2new(1, -18, 0, 20),
Parent = tile,
})
New("UITextSizeConstraint", { MaxTextSize = 16, MinTextSize = 10, Parent = nm })
local sc = New("UIScale", { Parent = tile })
hover(tile, function()
tween(sc, { Scale = 1.03 }, 0.2)
end, function()
tween(sc, { Scale = 1 }, 0.25)
end)
tile.MouseButton1Click:Connect(function()
Binger:SetTheme(th.Id)
end)
local _ = nm
end
el.Row = grid
el.Item = self:_reg(grid, "theme themes colors appearance", "Themes", "Theme")
return el
end
Binger.Toggles = {}
Binger.Options = {}
Binger.Labels = {}
Binger.Buttons = {}
Binger.Unloaded = false
Binger._unloadFns = {}
local TYPE_NAME = {
Toggle = "Toggle",
Slider = "Slider",
Dropdown = "Dropdown",
Input = "Input",
Keybind = "KeyPicker",
ColorPicker = "ColorPicker",
Label = "Label",
Button = "Button",
Segmented = "Dropdown",
}
function Binger:OnUnload(fn)
table.insert(self._unloadFns, fn)
end
function Binger:Toggle(v)
local w = self.Windows[1]
if w then
if v == nil then
v = not w.Visible
end
w:SetVisible(v and true or false)
end
end
function Binger:GetTextBounds(text, font, size, width)
local v = Svc.TextService:GetTextSize(tostring(text):gsub("<[^>]->", ""), size or 14, typeof(font) == "EnumItem" and font or Enum.Font.Gotham, V2(width or 1e5, 1e5))
return v.X, v.Y
end
do
local TM = { Library = Binger, Folder = "BingerUI", DefaultTheme = "Crimson Sovereign", BuiltInThemes = {} }
for _, th in ipairs(THEMES) do
TM.BuiltInThemes[th.Name] = th.Id
end
function TM:SetLibrary(lib)
self.Library = lib
end
function TM:SetFolder(f)
self.Folder = f
end
function TM:SaveDefault() end
function TM:LoadDefault() end
function TM:GetCustomTheme()
return nil
end
function TM:ApplyTheme(name)
local id = self.BuiltInThemes[name]
if id then
Binger:SetTheme(id)
end
end
function TM:ApplyToTab(tab)
local w = Binger.Windows[1]
if w and tab then
w:BuildSettings(tab)
end
end
function TM:ApplyToGroupbox(box)
if Binger.LazyRows and box._ready == false and box._pending and not box._themeDeferred then
box._themeDeferred = true
local order = box:_order()
box._o += 20
table.insert(box._pending, function()
local keep = box._o
box._o = order - 1
local ok, err = pcall(TM.ApplyToGroupbox, TM, box)
box._o = math.max(keep, box._o)
if not ok then
error(err, 0)
end
end)
return
end
local P = Binger.Prefs
local w = Binger.Windows[1]
box:ThemePicker()
local names = {}
for _, th in ipairs(THEMES) do
names[#names + 1] = th.Name
end
local current
for _, th in ipairs(THEMES) do
if th.Id == P.theme then
current = th.Name
end
end
box:AddDropdown("ThemeManager_ThemeList", { Text = "Theme", Values = names, Default = current or names[1], Callback = function(v)
TM:ApplyTheme(v)
end })
local a1 = box:ColorPicker({ Name = "Accent", Default = T.accent, Callback = function(c)
Binger:SetAccent("accent", c)
end })
local a2 = box:ColorPicker({ Name = "Second accent", Default = T.accent2, Callback = function(c)
Binger:SetAccent("accent2", c)
end })
local bgC = box:ColorPicker({ Name = "Background", Default = T.bg, Callback = function(c)
Binger:SetAccent("bg", c)
end })
local pnC = box:ColorPicker({ Name = "Panels", Default = T.surface, Callback = function(c)
Binger:SetAccent("surface", c)
end })
local navC = box:ColorPicker({ Name = "Menu icons", Description = "One colour for every sidebar icon. Reset colours turns it off.", Default = T.navIcon or T.accent, Callback = function(c)
Binger:SetAccent("navIcon", c)
end })
box:Toggle({ Name = "Gradient buttons", Description = "Off: buttons and toggles use one solid colour (Accent).", Default = not P.flat, Callback = function(v)
if P.flat == not v then
return
end
P.flat = not v
Binger:SetTheme(P.theme, true)
end })
box:Input({ Name = "Background picture", Description = "Roblox image or decal id. Empty = none.", Default = P.bgImage and tostring(P.bgImage) or "", Placeholder = "image id", Callback = function(v)
local id = tonumber((tostring(v):match("%d+")))
P.bgImage = (id and id > 0) and id or nil
if w then
w:_bgImage()
end
Binger:SavePrefs()
end })
local picSlider
picSlider = box:Slider({ Name = "Picture brightness", Min = 10, Max = 100, Step = 5, Default = math.floor((tonumber(P.bgImageLight) or 0.3) * 100 + 0.5), Suffix = "%", Callback = function(v)
P.bgImageLight = v / 100
if picSlider and picSlider.Dragging then
return
end
if w then
w:_bgImage()
end
Binger:SavePrefs()
end })
box:Button({ Name = "Reset colours", Icon = "refresh", Callback = function()
Binger:SetTheme(P.theme)
end })
table.insert(Binger._themeHooks, function()
a1:Set(T.accent, true)
a2:Set(T.accent2, true)
bgC:Set(T.bg, true)
pnC:Set(T.surface, true)
navC:Set(T.navIcon or T.accent, true)
end)
local sizeSlider
sizeSlider = box:Slider({ Name = "Menu size", Min = 70, Max = 140, Step = 5, Default = math.floor((tonumber(P.scale) or 1) * 100 + 0.5), Suffix = "%", Presets = { 80, 100, 120 }, Callback = function(v)
P.scale = v / 100
if sizeSlider and sizeSlider.Dragging then
return
end
Binger:_applyScale()
Binger:SavePrefs()
end })
box:Segmented({ Name = "Menu button", Options = { "Always", "Hidden", "Never" }, Default = Binger:ButtonMode(), Callback = function(v)
P.button = v
if w then
w:_syncButton()
end
Binger:SavePrefs()
end })
box:Toggle({ Name = "Lite mode", Description = "For weak phones: no background motion or fades.", Default = Binger:IsLite(), Callback = function(v)
P.lite = v
if w then
w.Lite = v
if v then
P.petals = false
w:_petals(false)
w:_setLoops(false)
end
end
Binger:SavePrefs()
end })
box:Toggle({ Name = "Falling petals", Default = (P.petals == nil and not Binger:IsLite()) or P.petals == true, Callback = function(v)
P.petals = v
if w then
w:_petals(v)
end
Binger:SavePrefs()
end })
box:Toggle({ Name = "Watermark", Default = P.watermark == true, Callback = function(v)
Binger:Watermark(v)
end })
end
Binger.ThemeManager = TM
end
function Binger:SetWatermarkVisibility(v)
self:Watermark(v, self._wmText)
end
function Binger:SetWatermark(text)
self._wmText = text
if self._wm then
self:Watermark(true, text)
end
end
function Element:OnChanged(fn)
self._changed = self._changed or {}
table.insert(self._changed, fn)
return self
end
function Element:SetValue(v)
if self.Set then
if self.Deserialize ~= Element.Deserialize and type(v) == "string" and self.Kind == "ColorPicker" then
v = self:Deserialize(v)
end
self:Set(v)
end
end
function Element:SetValues(list)
if self.Refresh then
self:Refresh(list, true)
end
end
function Element:AddValues(list)
if self.Refresh then
local all = table.clone(self.Options or {})
for _, v in ipairs(type(list) == "table" and list or { list }) do
table.insert(all, v)
end
self:Refresh(all, true)
end
end
function Element:SetText(t)
self.Text = t
if self.Kind == "Label" or self.Kind == "Paragraph" then
self:Set(t)
elseif self.SetName then
self:SetName(t)
end
end
function Element:SetTitle(t)
self:SetText(t)
end
function Element:Display() end
function Element:SetTooltip(t)
if self.Row and t then
Binger:_tooltip(self.Row, t)
end
end
function Element:GetState()
return self.State == true
end
function Element:SetValueRGB(c)
if self.Set then
self:Set(c)
end
end
local function register(el, idx, kind)
el.Type = TYPE_NAME[kind] or kind
el.Text = el.Opts.Name
if idx ~= nil then
el.Idx = idx
el.Flag = el.Flag or idx
Binger.Flags[idx] = el
if kind == "Toggle" then
Binger.Toggles[idx] = el
elseif kind == "Label" then
Binger.Labels[idx] = el
Binger.Options[idx] = el
elseif kind == "Button" then
Binger.Buttons[idx] = el
else
Binger.Options[idx] = el
end
end
return el
end
local function args(idx, o)
if type(idx) == "table" then
return idx.Idx or idx.Id, idx
end
return idx, o or {}
end
Binger.LazyRows = true
Binger._builtHooks = {}
function Binger:OnRowsBuilt(fn)
table.insert(self._builtHooks, fn)
end
function Binger:_rowsBuilt()
if self._builtQueued then
return
end
self._builtQueued = true
task.delay(0.25, function()
self._builtQueued = false
if self._unloaded then
return
end
for _, fn in ipairs(self._builtHooks) do
task.spawn(pcall, fn)
end
end)
end
function Binger:BuildAll()
for _, w in ipairs(self.Windows) do
for _, t in ipairs(w.Tabs) do
t:_flush()
end
end
end
local STUB_FIELDS = { "Lazy", "Set", "Refresh", "SetVisible", "SetName", "SetDescription", "SetTooltip", "SetMin", "SetMax", "SetSuffix", "SetPrefix", "AddContextMenu", "Destroy", "Serialize", "_vis" }
local function lazySection(c)
local sec = c.Section
if Binger.LazyRows and sec and sec._ready == false and sec._pending then
return sec
end
return nil
end
local function stub(c, kind, spec, searchable)
local el = Element.new(c, spec, kind)
el.Lazy = true
local order = c:_order()
if searchable then
el.Item = c:_reg(nil, (spec.Name or "") .. " " .. (spec.Description or ""), spec.Name, kind)
end
if spec.Visible == false then
el._vis = false
if el.Item then
el.Item.Hidden = true
end
end
if spec.Disabled then
el.Disabled = true
end
function el:SetVisible(v)
self._vis = v and true or false
if self.Item then
self.Item.Hidden = not v
end
end
function el:SetName(t)
spec.Name = t
end
function el:SetDescription(t)
spec.Description = t
end
function el:SetTooltip(t)
spec.Tooltip = t
end
function el:AddContextMenu(items)
self._ctx = items
local lazyOpen
lazyOpen = function()
local s = c.Section
if s and s._flush then
s:_flush()
end
if self.OpenContextMenu ~= lazyOpen then
self.OpenContextMenu()
end
end
self.OpenContextMenu = lazyOpen
return self
end
function el:Destroy()
self._dead = true
if self.Flag and Binger.Flags[self.Flag] == self then
Binger.Flags[self.Flag] = nil
end
local items = self.Item and c.Tab and c.Tab.Items
local i = items and table.find(items, self.Item)
if i then
table.remove(items, i)
end
end
return el, order
end
local function defer(sec, c, el, order, build)
table.insert(sec._pending, function()
if el and el._dead then
return
end
c._reserved, c._item = order, el and el.Item or nil
local vis = el and el._vis
if el then
local spec = el.Opts
spec._el = el
spec.Visible = vis
spec.Disabled = el.Disabled or nil
for _, k in ipairs(STUB_FIELDS) do
el[k] = nil
end
end
local ok, err = pcall(build)
c._reserved, c._item = nil, nil
if not ok then
error(err, 0)
end
if vis == false and el.Row and el.Row.Visible then
el:SetVisible(false)
end
if el and el._ctx then
local items = el._ctx
el._ctx = nil
el:AddContextMenu(items)
end
end)
end
local function snapOf(o, v)
local min, max = o.Min or 0, o.Max or 100
local step = o.Step or o.Increment or 1
local dec = o.Decimals
if not dec then
local frac = tostring(step):match("%.(%d+)")
dec = frac and #frac or 0
end
v = math.clamp(tonumber(v) or min, min, max)
v = min + math.floor((v - min) / step + 0.5) * step
return tonumber(string.format("%." .. dec .. "f", math.clamp(v, min, max)))
end
function Container:AddToggle(idx, o)
idx, o = args(idx, o)
local spec = {
Name = o.Text,
Description = o.Description,
Default = o.Default == true,
Tooltip = o.Tooltip,
Risky = o.Risky,
Disabled = o.Disabled,
Visible = o.Visible,
Callback = o.Callback,
Style = (o.Checkbox or Binger.ForceCheckbox) and "Checkbox" or nil,
}
local sec = lazySection(self)
if not sec then
return register(self:Toggle(spec), idx, "Toggle")
end
local el, order = stub(self, "Toggle", spec, true)
el.Value = spec.Default
function el:Set(v, silent)
v = v and true or false
local changed = v ~= self.Value
self.Value = v
if changed and not silent then
self:_fire(v)
end
end
function el:Toggle()
self:Set(not self.Value)
end
defer(sec, self, el, order, function()
spec.Default = el.Value
self:Toggle(spec)
end)
return register(el, idx, "Toggle")
end
Container.AddCheckbox = function(self, idx, o)
idx, o = args(idx, o)
o.Checkbox = true
return self:AddToggle(idx, o)
end
function Container:AddSlider(idx, o)
idx, o = args(idx, o)
local step = o.Step or (o.Rounding and 10 ^ -o.Rounding) or 1
local suffix = o.Suffix and o.Suffix:gsub("^%s+", "") or nil
if suffix == "" then
suffix = nil
end
local spec = {
Name = o.Text,
Description = o.Description,
Min = o.Min or 0,
Max = o.Max or 100,
Default = o.Default,
Step = step,
Suffix = suffix,
Tooltip = o.Tooltip,
Disabled = o.Disabled,
Visible = o.Visible,
Callback = o.Callback,
Style = o.Compact and "Bar" or nil,
}
local sec = lazySection(self)
if not sec then
return register(self:Slider(spec), idx, "Slider")
end
local el, order = stub(self, "Slider", spec, true)
el.Value = snapOf(spec, spec.Default or spec.Min)
el.Min, el.Max = spec.Min, spec.Max
function el:Set(v, silent)
v = snapOf(spec, v)
local changed = v ~= self.Value
self.Value = v
if changed and not silent then
self:_fire(v)
end
end
local function relimit()
el.Min, el.Max = spec.Min, spec.Max
local old = el.Value
el.Value = snapOf(spec, old)
if el.Value ~= old then
el:_fire(el.Value)
end
end
function el:SetMin(v)
spec.Min = tonumber(v) or spec.Min
spec.Max = math.max(spec.Max, spec.Min)
relimit()
end
function el:SetMax(v)
spec.Max = tonumber(v) or spec.Max
spec.Min = math.min(spec.Min, spec.Max)
relimit()
end
function el:SetSuffix(s)
spec.Suffix = (s and s ~= "") and s or nil
end
function el:SetPrefix() end
defer(sec, self, el, order, function()
spec.Default = el.Value
self:Slider(spec)
end)
return register(el, idx, "Slider")
end
function Container:AddDropdown(idx, o)
idx, o = args(idx, o)
local values = o.Values or {}
if o.SpecialType == "Player" then
values = {}
for _, p in ipairs(Svc.Players:GetPlayers()) do
if not o.ExcludeLocalPlayer or p ~= LP then
table.insert(values, p.Name)
end
end
end
local spec = {
Name = o.Text,
Description = o.Description,
Options = values,
Default = type(o.Default) == "number" and values[o.Default] or o.Default,
Multi = o.Multi,
Dict = true,
Search = o.Searchable,
Nullable = o.AllowNull,
Placeholder = o.Placeholder,
Tooltip = o.Tooltip,
Disabled = o.Disabled,
Visible = o.Visible,
Callback = o.Callback,
}
local sec = lazySection(self)
if not sec then
return register(self:Dropdown(spec), idx, "Dropdown")
end
local el, order = stub(self, "Dropdown", spec, true)
el.Options = table.clone(values)
el.Values = el.Options
el.Multi = spec.Multi == true
local function toList(v)
local out = {}
if type(v) == "table" then
if #v > 0 then
for _, x in ipairs(v) do
table.insert(out, x)
end
else
for _, x in ipairs(el.Options) do
if v[x] then
table.insert(out, x)
end
end
for k, on in pairs(v) do
if on == true and not table.find(out, k) then
table.insert(out, k)
end
end
end
end
return out
end
local function asMap(list)
local d = {}
for _, x in ipairs(list) do
d[x] = true
end
return d
end
if el.Multi then
el.Value = asMap(toList(spec.Default))
else
el.Value = spec.Default
end
function el:Set(v, silent)
if self.Multi then
self.Value = asMap(toList(v))
else
if type(v) == "table" then
v = toList(v)[1]
end
self.Value = v
end
if not silent then
self:_fire(self.Value)
end
end
function el:Refresh(options, keep)
self.Options = table.clone(options or {})
self.Values = self.Options
if not keep then
self:Set(self.Multi and {} or nil, true)
end
end
function el:Serialize()
return self.Multi and toList(self.Value) or self.Value
end
defer(sec, self, el, order, function()
spec.Options = el.Options
spec.Default = el.Value
self:Dropdown(spec)
end)
return register(el, idx, "Dropdown")
end
function Container:AddInput(idx, o)
idx, o = args(idx, o)
local spec = {
Name = o.Text,
Description = o.Description,
Default = o.Default ~= nil and tostring(o.Default) or "",
Placeholder = o.Placeholder,
Numeric = o.Numeric,
Raw = true,
Live = not o.Finished,
EnterOnly = o.Finished,
ClearOnFocus = o.ClearTextOnFocus,
MaxLength = o.MaxLength,
Tooltip = o.Tooltip,
Disabled = o.Disabled,
Visible = o.Visible,
Callback = o.Callback,
}
local sec = lazySection(self)
if not sec then
return register(self:Input(spec), idx, "Input")
end
local el, order = stub(self, "Input", spec, true)
el.Value = spec.Default
function el:Set(v, silent)
self.Value = v
if not silent then
self:_fire(v)
end
end
defer(sec, self, el, order, function()
spec.Default = el.Value
self:Input(spec)
end)
return register(el, idx, "Input")
end
function Container:AddLabel(idx, o, wrap)
local text
if type(idx) == "table" then
o = idx
idx = o.Idx
text = o.Text
elseif type(o) == "table" then
text = o.Text
else
text = idx
idx = nil
end
local spec = { Color = "muted" }
local sec = lazySection(self)
local el
if sec then
local order
el, order = stub(self, "Label", spec, false)
el._text = tostring(text or "")
function el:Set(t)
self._text = t
end
defer(sec, self, el, order, function()
self:Label(el._text, spec)
el.TextLabel = el.Row
end)
else
el = self:Label(tostring(text or ""), spec)
el.TextLabel = el.Row
end
el.Opts.Name = text
register(el, idx, "Label")
return el
end
function Container:AddDivider()
local sec = lazySection(self)
if sec then
defer(sec, self, nil, self:_order(), function()
self:Divider()
end)
return nil
end
return self:Divider()
end
function Container:AddButton(o, fn)
if type(o) == "string" then
o = { Text = o, Func = fn }
end
o = o or {}
local spec = {
Name = o.Text,
Callback = o.Func or o.Callback,
Confirm = o.DoubleClick and "Click again to confirm" or nil,
Style = o.Risky and "danger" or nil,
Tooltip = o.Tooltip,
Disabled = o.Disabled,
Visible = o.Visible,
}
local sec = lazySection(self)
local el
if sec then
local order
el, order = stub(self, "Button", spec, true)
defer(sec, self, el, order, function()
self:Button(spec)
end)
else
el = self:Button(spec)
end
local container = self
function el:AddButton(o2, fn2)
return container:AddButton(o2, fn2)
end
return register(el, o.Idx, "Button")
end
function Element:AddKeyPicker(idx, o)
o = o or {}
local c = self.Container
local name = o.Text or self.Opts.Name or "Keybind"
if self.Kind == "Label" then
self:SetVisible(false)
name = self.Opts.Name or name
end
local host = self
local el = c:Keybind({
Name = name,
Default = o.Default,
Mode = (o.Mode == "Always" and "Toggle") or o.Mode,
Callback = function(state)
if o.SyncToggleState and host.Kind == "Toggle" and state ~= nil then
host:Set(state)
end
if o.Callback then
o.Callback(state)
end
end,
Changed = o.ChangedCallback,
})
register(el, idx, "Keybind")
return self
end
function Element:AddColorPicker(idx, o)
o = o or {}
local el = self.Container:ColorPicker({
Name = o.Title or o.Text or ((self.Opts.Name or "") .. " colour"),
Default = o.Default,
Callback = o.Callback,
})
register(el, idx, "ColorPicker")
return self
end
function Container:SetFolded(v)
if self.SetCollapsed then
self:SetCollapsed(v)
end
end
function Tab:AddLeftGroupbox(name, icon)
return self:Section({ Name = name, Icon = icon or false, Side = "Left" })
end
function Tab:AddRightGroupbox(name, icon)
return self:Section({ Name = name, Icon = icon or false, Side = "Right" })
end
Tab.AddLeftSection = Tab.AddLeftGroupbox
Tab.AddRightSection = Tab.AddRightGroupbox
function Tab:SetTabInfo(name, description)
self.Subtitle = description or self.Subtitle
if self.Window.Current == self then
self.Window.PageSub.Text = self.Subtitle
end
end
function Window:AddTab(name, icon, description)
if type(name) == "table" then
return self:Tab({ Name = name.Name or name.Title, Icon = name.Icon, Subtitle = name.Description })
end
return self:Tab({ Name = name, Icon = icon, Subtitle = description })
end
function Binger:CreateWindow(o)
o = o or {}
local size = o.Size
if typeof(size) == "UDim2" then
size = V2(math.max(size.X.Offset, 720), math.max(size.Y.Offset, 460))
end
local w = self:Window({
Title = o.Title or "Menu",
Subtitle = o.Subtitle or o.SubTitle or "",
Footer = o.Footer,
Logo = o.Logo or o.Icon,
TitleRich = o.TitleRich,
TitleFont = o.TitleFont,
Size = size,
Keybind = o.ToggleKeybind,
})
return w
end
function Tab:AddLeftTabbox(name)
return self:Tabbox({ Name = name, Side = "Left" })
end
function Tab:AddRightTabbox(name)
return self:Tabbox({ Name = name, Side = "Right" })
end
Tab.AddTabbox = function(self, name)
return self:Tabbox({ Name = type(name) == "table" and name.Name or name })
end
function Container:AddDependencyBox()
return self:DependencyBox()
end
function Container:AddSubSection(name)
return self:Group({ Name = type(name) == "table" and name.Name or name })
end
function Container:AddImage(idx, o)
idx, o = args(idx, o)
local el = self:Image({ Name = o.Text, Image = o.Image, Height = o.Height, ScaleType = o.ScaleType })
return register(el, idx, "Image")
end
function Container:AddVideo(idx, o)
idx, o = args(idx, o)
local el = self:Video({ Name = o.Text, Video = o.Video, Height = o.Height, Looped = o.Looped, Playing = o.Playing, Volume = o.Volume })
return register(el, idx, "Video")
end
function Container:AddViewport(idx, o)
idx, o = args(idx, o)
local el = self:Viewport({ Name = o.Text, Object = o.Object, Camera = o.Camera, Height = o.Height, Interactive = o.Interactive, Clone = o.Clone })
return register(el, idx, "Viewport")
end
function Container:AddProgressBar(idx, o)
idx, o = args(idx, o)
local el = self:Progress({ Name = o.Text, Value = o.Default or o.Value, Max = o.Max, Suffix = o.Suffix, Percent = o.Percent })
return register(el, idx, "Progress")
end
function Binger:_blur(on)
if not self.Prefs.blur then
on = false
end
if on then
if not self._blurFx or not self._blurFx.Parent then
self._blurFx = New("BlurEffect", { Name = "BingerBlur", Size = 0, Parent = Svc.Lighting })
end
tween(self._blurFx, { Size = 14 }, 0.35)
elseif self._blurFx then
local fx = self._blurFx
tween(fx, { Size = 0 }, 0.25)
task.delay(0.26, function()
if self._blurFx == fx and fx.Size < 0.5 then
fx:Destroy()
self._blurFx = nil
end
end)
end
end
function Binger:Watermark(on, text)
self.Prefs.watermark = on and true or false
if self._wm then
forget(self._wm)
self._wm:Destroy()
self._wm = nil
end
if self._wmConn then
self._wmConn:Disconnect()
self._wmConn = nil
end
if not on then
return
end
local w = New("Frame", {
Name = "Watermark",
Position = UDim2off(16, 16),
Size = UDim2off(0, 36),
AutomaticSize = AutoX,
BackgroundTransparency = 0.08,
ZIndex = 120,
Theme = { BackgroundColor3 = "surface" },
Parent = Root,
})
Corner(w, 11)
local st = Stroke(w, nil, 0, 1)
st.Color = Color3.new(1, 1, 1)
New("UIGradient", { Theme = { Color = grad("accent", "lineStrong", "line") }, Parent = st })
Pad(w, 0, 14, 0, 10)
List(w, Enum.FillDirection.Horizontal, 10, nil, Enum.VerticalAlignment.Center)
local win = self.Windows[1]
if win then
local em = win:_logo(w, 20, 0, true)
em.AnchorPoint = V2(0, 0)
em.LayoutOrder = 1
end
local rich = not text and win and win.TitleRich
local title = Label({ Text = text or rich or (win and win.Title) or "BINGER'S", Rich = rich ~= nil and rich ~= false, Font = (win and win.TitleFont) or F.display, Size = 17, Dim = UDim2new(0, 0, 0, 20), Auto = AutoX, Order = 2, Parent = w })
title.TextColor3 = Color3.new(1, 1, 1)
Reg[title] = nil
if not rich then
New("UIGradient", { Theme = { Color = grad("accent", "text", "accent2") }, Parent = title })
end
New("Frame", { Size = UDim2off(1, 16), BorderSizePixel = 0, LayoutOrder = 3, Theme = { BackgroundColor3 = "line" }, Parent = w })
local info = Label({ Text = "", Font = F.semi, Size = 13, Color = "muted", Dim = UDim2new(0, 0, 0, 20), Auto = AutoX, Order = 4, Parent = w })
self._wm = w
local frames, acc = 0, 0
self._wmConn = Svc.RunService.Heartbeat:Connect(function(dt)
frames += 1
acc += dt
if acc >= 0.5 then
local fps = math.floor(frames / acc + 0.5)
frames, acc = 0, 0
local ping = 0
pcall(function()
ping = math.floor(LP:GetNetworkPing() * 1000 + 0.5)
end)
info.Text = string.format("%d fps   %d ms   %s", fps, ping, os.date("%H:%M"))
end
end)
table.insert(self._conns, self._wmConn)
w.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = self:_pointer(input)
local p0 = w.Position
self:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
w.Position = UDim2new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
end)
end)
self:SavePrefs()
end
function Binger:KeybindList(on)
self.Prefs.keylist = on and true or false
if self._kl then
forget(self._kl)
self._kl:Destroy()
self._kl = nil
end
self:SavePrefs()
if not on then
return
end
local f = New("Frame", {
Name = "Keybinds",
AnchorPoint = V2(0, 0.5),
Position = UDim2new(0, 16, 0.42, 0),
Size = UDim2off(210, 0),
AutomaticSize = AutoY,
BackgroundTransparency = 0.08,
ZIndex = 120,
Theme = { BackgroundColor3 = "surface" },
Parent = Root,
})
Corner(f, 12)
Stroke(f, "line")
Pad(f, 10, 14, 12, 14)
List(f, nil, 6)
local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 22), LayoutOrder = 0, Parent = f })
Icon("keyboard", 15, "accent", head).Position = UDim2off(0, 3)
Label({ Text = "Keybinds", Font = F.display, Size = 17, Pos = UDim2off(22, 0), Dim = UDim2new(1, -22, 1, 0), Parent = head })
local body = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = 1, Parent = f })
List(body, nil, 4)
self._kl, self._klBody = f, body
f.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = self:_pointer(input)
local p0 = f.Position
self:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
f.Position = UDim2new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
end)
end)
self:_refreshKeylist()
end
function Binger:_refreshKeylist()
local body = self._klBody
if not body or not body.Parent then
return
end
for _, c in ipairs(body:GetChildren()) do
if c:IsA("Frame") then
forget(c)
c:Destroy()
end
end
local n = 0
for _, b in ipairs(self._binds) do
if b.Key then
n += 1
local r = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 18), LayoutOrder = n, Parent = body })
local active = b.State and b.Mode ~= "Press"
Label({ Text = b.Opts.Name or "Bind", Size = 12, Color = active and "text" or "muted", Font = active and F.semi or F.body, Dim = UDim2new(1, -60, 1, 0), Truncate = true, Parent = r })
Label({ Text = "[" .. keyName(b.Key) .. "]", Font = F.semi, Size = 12, Color = active and "accent" or "faint", AlignX = RIGHT, Anchor = V2(1, 0), Pos = UDim2sc(1, 0), Dim = UDim2new(0, 60, 1, 0), Parent = r })
end
end
if n == 0 then
local r = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 18), Parent = body })
Label({ Text = "No keys bound yet", Size = 12, Color = "faint", Dim = UDim2sc(1, 1), Parent = r })
end
end
local function configDir()
local dir = "BingerUI/configs/" .. tostring(game.PlaceId)
FS.dir(dir)
return dir
end
function Binger:SaveConfig(name)
name = tostring(name or ""):gsub("[^%w%s%-_]", ""):sub(1, 40)
if name == "" then
return false, "Type a name for the config first"
end
local out = {}
for flag, el in pairs(self.Flags) do
local ok, v = pcall(el.Serialize, el)
if ok and v ~= nil then
out[flag] = v
end
end
FS.saveJson(configDir() .. "/" .. name .. ".json", out)
return true
end
function Binger:LoadConfig(name)
local data = FS.json(configDir() .. "/" .. tostring(name) .. ".json")
if not data then
return false, "That config file couldn't be read"
end
for flag, v in pairs(data) do
local el = self.Flags[flag]
if el and el.Set then
pcall(function()
el:Set(el:Deserialize(v))
end)
end
end
return true
end
function Binger:DeleteConfig(name)
FS.del(configDir() .. "/" .. tostring(name) .. ".json")
end
function Binger:ListConfigs()
local out = {}
for _, p in ipairs(FS.list(configDir())) do
local n = tostring(p):match("([^/\\]+)%.json$")
if n then
table.insert(out, n)
end
end
table.sort(out)
return out
end
function Window:BuildSettings(tab)
local W, L = self, self.Lib
local P = L.Prefs
tab.Subtitle = tab.Subtitle ~= "" and tab.Subtitle or "Theme, scale, keybinds and saved configs"
if W.Current == tab then
W.PageSub.Text = tab.Subtitle
end
local look = tab:Section({ Name = "Theme", Icon = "palette", Side = "Left" })
look:ThemePicker()
local ac1 = look:ColorPicker({ Name = "Accent", Default = T.accent, Callback = function(c)
L:SetAccent("accent", c)
end })
local ac2 = look:ColorPicker({ Name = "Second accent", Default = T.accent2, Callback = function(c)
L:SetAccent("accent2", c)
end })
local bgC = look:ColorPicker({ Name = "Background", Default = T.bg, Callback = function(c)
L:SetAccent("bg", c)
end })
local pnC = look:ColorPicker({ Name = "Panels", Default = T.surface, Callback = function(c)
L:SetAccent("surface", c)
end })
local navC = look:ColorPicker({ Name = "Menu icons", Description = "One colour for every sidebar icon. Reset colours turns it off.", Default = T.navIcon or T.accent, Callback = function(c)
L:SetAccent("navIcon", c)
end })
look:Toggle({ Name = "Gradient buttons", Description = "Off: buttons and toggles use one solid colour (Accent).", Default = not P.flat, Callback = function(v)
if P.flat == not v then
return
end
P.flat = not v
L:SetTheme(P.theme, true)
end })
look:Input({ Name = "Background picture", Description = "Roblox image or decal id. Empty = none.", Default = P.bgImage and tostring(P.bgImage) or "", Placeholder = "image id", Callback = function(v)
local id = tonumber((tostring(v):match("%d+")))
P.bgImage = (id and id > 0) and id or nil
if W then
W:_bgImage()
end
L:SavePrefs()
end })
local picSlider
picSlider = look:Slider({ Name = "Picture brightness", Min = 10, Max = 100, Step = 5, Default = math.floor((tonumber(P.bgImageLight) or 0.3) * 100 + 0.5), Suffix = "%", Callback = function(v)
P.bgImageLight = v / 100
if picSlider and picSlider.Dragging then
return
end
if W then
W:_bgImage()
end
L:SavePrefs()
end })
look:Button({ Name = "Reset colours", Icon = "refresh", Callback = function()
L:SetTheme(P.theme)
end })
table.insert(L._themeHooks, function()
ac1:Set(T.accent, true)
ac2:Set(T.accent2, true)
bgC:Set(T.bg, true)
pnC:Set(T.surface, true)
navC:Set(T.navIcon or T.accent, true)
end)
local fx = tab:Section({ Name = "Look and feel", Icon = "sparkles", Side = "Left" })
fx:Slider({ Name = "Window opacity", Min = 60, Max = 100, Default = math.floor((1 - (tonumber(P.opacity) or 0.04)) * 100 + 0.5), Suffix = "%", Callback = function(v)
P.opacity = 1 - v / 100
W.Main.BackgroundTransparency = P.opacity
L:SavePrefs()
end })
fx:Toggle({ Name = "Lite mode", Description = "For weak phones: no background motion, no fades, instant theme changes. On by default on touch devices.", Default = L:IsLite(), Callback = function(v)
P.lite = v
W.Lite = v
if v then
P.petals = false
W:_petals(false)
W:_setLoops(false)
end
L:SavePrefs()
L:Notify({ Title = v and "Lite mode on" or "Lite mode off", Content = "Re-run the script to fully apply it.", Duration = 3 })
end })
fx:Toggle({ Name = "Falling petals", Description = "Drift behind the panels. Paused while the menu is hidden.", Default = (P.petals == nil and not L:IsLite()) or P.petals == true, Callback = function(v)
P.petals = v
W:_petals(v)
L:SavePrefs()
end })
fx:Toggle({ Name = "Blur the game behind the menu", Default = P.blur == true, Callback = function(v)
P.blur = v
L:_blur(v and W.Visible)
L:SavePrefs()
end })
local ui = tab:Section({ Name = "Interface", Icon = "monitor", Side = "Right" })
local sizeSlider
sizeSlider = ui:Slider({ Name = "Menu size", Min = 70, Max = 140, Step = 5, Default = math.floor((tonumber(P.scale) or 1) * 100 + 0.5), Suffix = "%", Presets = { 80, 100, 120 }, Callback = function(v)
P.scale = v / 100
if sizeSlider and sizeSlider.Dragging then
return
end
L:_applyScale()
L:SavePrefs()
end })
ui:Keybind({ Name = "Menu key", Description = "Shows or hides this window.", Default = W.ToggleKey, Changed = function(k)
if k then
W:SetToggleKey(k)
P.key = k.Name
L:SavePrefs()
end
end })
table.remove(L._binds, #L._binds)
L:_refreshKeylist()
ui:Segmented({ Name = "Menu button", Description = "The round button that opens and closes the menu. Drag it anywhere.", Options = { "Always", "Hidden", "Never" }, Default = L:ButtonMode(), Callback = function(v)
P.button = v
W:_syncButton()
L:SavePrefs()
end })
ui:Toggle({ Name = "Watermark", Description = "FPS, ping and time in the corner.", Default = P.watermark == true, Callback = function(v)
L:Watermark(v)
end })
ui:Toggle({ Name = "Keybind list", Description = "Shows every bound key and whether it's on.", Default = P.keylist == true, Callback = function(v)
L:KeybindList(v)
end })
local cfg = tab:Section({ Name = "Configs", Icon = "save", Side = "Right" })
if not FS.can then
cfg:Callout({ Kind = "warn", Title = "Saving is unavailable", Content = "Your executor doesn't support file access, so configs can't be stored." })
end
local nameIn = cfg:Input({ Name = "Config name", Placeholder = "e.g. farming", Icon = "feather" })
local list = cfg:Dropdown({ Name = "Saved configs", Options = L:ListConfigs(), Placeholder = "None saved yet" })
local function reload()
list:Refresh(L:ListConfigs(), true)
end
cfg:Buttons({
{ Name = "Save", Style = "primary", Icon = "save", Callback = function()
local name = (nameIn.Value ~= "" and nameIn.Value) or list.Value
local ok, err = L:SaveConfig(name)
if ok then
reload()
list:Set(tostring(name):gsub("[^%w%s%-_]", ""):sub(1, 40), true)
L:Notify({ Title = "Config saved", Content = "Saved as “" .. tostring(name) .. "”.", Kind = "ok" })
else
L:Notify({ Title = "Config not saved", Content = err, Kind = "warn" })
end
end },
{ Name = "Load", Icon = "folder", Callback = function()
if not list.Value then
return L:Notify({ Title = "Pick a config to load", Content = "Choose one from Saved configs first.", Kind = "warn" })
end
local ok, err = L:LoadConfig(list.Value)
L:Notify(ok and { Title = "Config loaded", Content = "“" .. list.Value .. "” is active.", Kind = "ok" } or { Title = "Config not loaded", Content = err, Kind = "err" })
end },
})
cfg:Buttons({
{ Name = "Refresh list", Icon = "refresh", Callback = reload },
{ Name = "Delete", Style = "danger", Icon = "trash", Confirm = "Click again to delete", Callback = function()
if list.Value then
local n = list.Value
L:DeleteConfig(n)
reload()
list:Set(nil, true)
L:Notify({ Title = "Config deleted", Content = "“" .. n .. "” was removed.", Kind = "info" })
end
end },
})
cfg:Toggle({ Name = "Load this config on start", Description = "Uses the config picked above the next time the script runs here.", Default = P.autoload ~= nil and P.autoload == tostring(game.PlaceId) .. ":" .. tostring(list.Value), Callback = function(v)
P.autoload = v and list.Value and (tostring(game.PlaceId) .. ":" .. list.Value) or nil
L:SavePrefs()
end })
local danger = tab:Section({ Name = "Session", Icon = "power", Side = "Left" })
danger:Paragraph({ Title = W.Title:sub(1, 1) .. W.Title:sub(2):lower() .. " UI " .. W.Version, Content = "Files live in your executor's workspace under BingerUI. Re-running the script replaces this window." })
danger:Button({ Name = "Unload menu", Style = "danger", Icon = "power", Confirm = "Click again to unload", Callback = function()
L:Unload()
end })
if P.autoload then
local place, name = tostring(P.autoload):match("^(%d+):(.+)$")
if place == tostring(game.PlaceId) and name then
task.defer(function()
if L:LoadConfig(name) then
list:Set(name, true)
L:Notify({ Title = "Config loaded", Content = "“" .. name .. "” was loaded automatically.", Kind = "ok" })
end
end)
end
end
return tab
end
function Binger:Unload()
if self._unloaded then
return
end
self._unloaded = true
for _, w in ipairs(self.Windows) do
pcall(function()
for _, tw in ipairs(w._loops) do
tw:Cancel()
end
for _, p in ipairs(w._petalList or {}) do
p.alive = false
if p.tw then
p.tw:Cancel()
end
end
if w._sigilSpin then
w._sigilSpin:Cancel()
end
end)
end
for _, c in ipairs(self._conns) do
pcall(function()
c:Disconnect()
end)
end
table.clear(self._conns)
if self._blurFx then
pcall(function()
self._blurFx:Destroy()
end)
self._blurFx = nil
end
self._drag, self._listen = nil, nil
pcall(function()
self.Gui:Destroy()
end)
for k in pairs(Reg) do
Reg[k] = nil
end
table.clear(self.Flags)
table.clear(self._binds)
for _, t in ipairs({ self.Toggles, self.Options, self.Labels, self.Buttons, self.Tabs }) do
if t then
table.clear(t)
end
end
table.clear(self.Windows)
if self._builtHooks then
table.clear(self._builtHooks)
end
self.Unloaded = true
for _, fn in ipairs(self._unloadFns or {}) do
pcall(fn)
end
GENV.__hh_ui_unload = nil
end
do
function Tab:Tabbox(o)
o = o or {}
local tabObj = self
local sec = self:Section({ Name = o.Name or "Tabs", Icon = o.Icon or false, Side = o.Side, Collapsed = o.Collapsed })
local bar = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 30), LayoutOrder = sec:_order(), Parent = sec.Body })
List(bar, Enum.FillDirection.Horizontal, 6)
local tb = { Tabs = {}, Section = sec }
local function pick(t)
for _, x in ipairs(tb.Tabs) do
local on = x == t
x.Frame.Visible = on
Reg[x.Btn].BackgroundColor3 = on and "hover" or "field"
Reg[x.Btn].TextColor3 = on and "accent" or "muted"
refresh(x.Btn, 0.15)
end
tb.Current = t
end
function tb:AddTab(name)
local btn = New("TextButton", {
Text = tostring(name),
AutoButtonColor = false,
FontFace = F.semi,
TextSize = 13,
Size = UDim2new(0, 0, 1, 0),
AutomaticSize = AutoX,
BackgroundTransparency = 0.2,
LayoutOrder = #tb.Tabs + 1,
Theme = { BackgroundColor3 = "field", TextColor3 = "muted" },
Parent = bar,
})
Corner(btn, 8)
Pad(btn, 0, 12, 0, 12)
local frame = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, Visible = false, LayoutOrder = sec:_order(), Parent = sec.Body })
List(frame, nil, 12)
local item = sec:_reg(frame, tostring(name), tostring(name), "Group")
local c = Container._new(sec.Window, tabObj, frame, sec, item)
local t = { Name = name, Btn = btn, Frame = frame, Container = c }
if item then
item.Open = function()
pick(t)
end
end
btn.MouseButton1Click:Connect(function()
pick(t)
end)
table.insert(tb.Tabs, t)
if #tb.Tabs == 1 then
pick(t)
end
c.Tabbox, c.Name = tb, name
function c:Show()
pick(t)
end
return c
end
function tb:SetTab(name)
for _, x in ipairs(tb.Tabs) do
if x.Name == name then
pick(x)
end
end
end
return tb
end
function Container:DependencyBox()
local frame = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = self:_order(), Parent = self.Body })
List(frame, nil, 12)
local box = Container._new(self.Window, self.Tab, frame, self.Section, self.ParentItem)
box.Frame = frame
local deps = {}
local function update()
local ok = true
for _, d in ipairs(deps) do
local el, want = d[1], d[2]
local v = el and el.Value
if type(want) == "function" then
ok = ok and want(v) == true
else
ok = ok and v == want
end
end
frame.Visible = ok
box.Visible = ok
end
function box:SetupDependencies(list)
deps = list or {}
for _, d in ipairs(deps) do
if type(d[1]) == "table" and d[1].OnChanged then
d[1]:OnChanged(update)
end
end
update()
end
box.Update = update
return box
end
function Element:AddContextMenu(items)
local W = self.Window
local row = self.Row
local function show()
if not (W and row and row.Parent) then
return
end
local list = type(items) == "function" and items() or items or {}
if #list == 0 then
return
end
local pop = W:_popup(row, 190, #list * 32 + 10)
local y = 5
for _, it in ipairs(list) do
local b = New("TextButton", { Text = "", AutoButtonColor = false, Position = UDim2off(5, y), Size = UDim2new(1, -10, 0, 30), BackgroundTransparency = 1, ZIndex = 4, Theme = { BackgroundColor3 = "hover" }, Parent = pop })
Corner(b, 7)
Label({ Text = tostring(it.Text or it.Name or "Option"), Font = F.medium, Size = 13, Color = it.Danger and "err" or "text", Pos = UDim2off(10, 0), Dim = UDim2new(1, -20, 1, 0), Truncate = true, Z = 4, Parent = b })
hover(b, function()
tween(b, { BackgroundTransparency = 0.35 }, 0.12)
end, function()
tween(b, { BackgroundTransparency = 1 }, 0.18)
end)
b.MouseButton1Click:Connect(function()
W:_closePopup()
local cb = it.Callback or it.Func
if cb then
task.spawn(cb)
end
end)
y += 32
end
end
row.InputBegan:Connect(function(input)
if input.UserInputType == UIT.MouseButton2 then
show()
end
end)
row.TouchLongPress:Connect(show)
for _, d in ipairs(row:GetDescendants()) do
if d:IsA("GuiButton") then
d.MouseButton2Click:Connect(show)
d.TouchLongPress:Connect(show)
end
end
self.OpenContextMenu = show
return self
end
function Element:SetDisabledValues(list)
local d = {}
for _, v in ipairs(list or {}) do
d[v] = true
end
self.DisabledValues = d
end
function Element:AddDisabledValues(list)
self.DisabledValues = self.DisabledValues or {}
for _, v in ipairs(type(list) == "table" and list or { list }) do
self.DisabledValues[v] = true
end
end
function Element:GetActiveValues()
local n = 0
if type(self.Value) == "table" then
for _, on in pairs(self.Value) do
if on then
n += 1
end
end
elseif self.Value ~= nil then
n = 1
end
return n
end
local Floats = New("Frame", { Name = "Floating", BackgroundTransparency = 1, Size = UDim2sc(1, 1), ZIndex = 90, Parent = Root })
local floatN = 0
local function floating(o, kind)
floatN += 1
local f = New("TextButton", {
Text = "",
AutoButtonColor = false,
Position = o.Position or UDim2off(24, 110 + floatN * 50),
Size = UDim2off(0, 40),
AutomaticSize = AutoX,
BackgroundTransparency = 0.06,
ZIndex = 91,
Theme = { BackgroundColor3 = "surface" },
Parent = Floats,
})
Corner(f, 12)
Stroke(f, "lineStrong", 0.2)
Pad(f, 0, 14, 0, 12)
List(f, Enum.FillDirection.Horizontal, 8, nil, Enum.VerticalAlignment.Center)
local w = { Frame = f, Kind = kind, Value = o.Default == true }
local dot
if kind == "Toggle" then
dot = New("Frame", { Size = UDim2off(10, 10), LayoutOrder = 1, ZIndex = 92, Theme = { BackgroundColor3 = "faint" }, Parent = f })
Corner(dot, 5)
end
local lbl = Label({ Text = tostring(o.Text or "Button"), Font = F.semi, Size = 14, Dim = UDim2off(0, 40), Auto = AutoX, Order = 2, Z = 92, Parent = f })
local function paint()
if dot then
Reg[dot].BackgroundColor3 = w.Value and "accent" or "faint"
refresh(dot, 0.15)
end
end
function w:SetText(t)
lbl.Text = tostring(t)
end
function w:SetVisible(v)
f.Visible = v and true or false
end
function w:SetValue(v)
w.Value = v and true or false
paint()
end
function w:Destroy()
forget(f)
f:Destroy()
end
paint()
f.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = Binger:_pointer(input)
local p0 = f.Position
local moved = false
Binger:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
if d.Magnitude > 6 then
moved = true
end
if moved then
f.Position = UDim2new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
end
end, function()
if moved or kind == "Label" then
return
end
if kind == "Toggle" then
w.Value = not w.Value
paint()
end
local cb = o.Callback or o.Func
if cb then
task.spawn(cb, w.Value)
end
end)
end)
return w
end
local function args(a, b, c)
if type(a) == "table" then
return a
end
local o = type(c) == "table" and c or {}
o.Text = a
if type(b) == "function" then
o.Callback = b
elseif type(b) == "boolean" then
o.Default = b
end
return o
end
function Binger:AddDraggableButton(text, fn, o)
return floating(args(text, fn, o), "Button")
end
function Binger:AddDraggableToggle(text, o, fn)
local opts = args(text, type(o) == "boolean" and o or fn, type(o) == "table" and o or nil)
if type(fn) == "function" then
opts.Callback = fn
end
return floating(opts, "Toggle")
end
function Binger:AddDraggableLabel(text, o)
return floating(args(text, nil, o), "Label")
end
function Binger:AddDraggableMenu(title, o)
o = o or {}
local W = self.Windows[1]
floatN += 1
local panel = New("Frame", {
Position = o.Position or UDim2off(24, 110 + floatN * 50),
Size = UDim2off(o.Width or 240, 0),
AutomaticSize = AutoY,
BackgroundTransparency = 0.04,
ZIndex = 91,
Theme = { BackgroundColor3 = "surface" },
Parent = Floats,
})
Corner(panel, 12)
Stroke(panel, "lineStrong", 0.2)
List(panel)
local head = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 34), LayoutOrder = 1, ZIndex = 92, Parent = panel })
Label({ Text = tostring(title or "Menu"), Font = F.semi, Size = 14, Pos = UDim2off(12, 0), Dim = UDim2new(1, -24, 1, 0), Truncate = true, Z = 92, Parent = head })
local body = New("Frame", { BackgroundTransparency = 1, Size = UDim2new(1, 0, 0, 0), AutomaticSize = AutoY, LayoutOrder = 2, Parent = panel })
List(body, nil, 10)
Pad(body, 4, 12, 12, 12)
head.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start = Binger:_pointer(input)
local p0 = panel.Position
Binger:_beginDrag(input, function(p)
local d = (p - start) / RootScale.Scale
panel.Position = UDim2new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
end)
end)
local c = Container._new(W, nil, body, nil, nil)
c.Frame = panel
function c:SetVisible(v)
panel.Visible = v and true or false
end
function c:Destroy()
forget(panel)
panel:Destroy()
end
return c
end
function Binger:CreateLoading(o)
o = o or {}
local dim = New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2sc(1, 1), ZIndex = 180, Parent = Root })
local card = New("Frame", {
AnchorPoint = V2(0.5, 0.5),
Position = UDim2sc(0.5, 0.5),
Size = UDim2off(o.Width or 360, 0),
AutomaticSize = AutoY,
BackgroundTransparency = 0.02,
ZIndex = 181,
Theme = { BackgroundColor3 = "surface" },
Parent = dim,
})
Corner(card, 16)
Stroke(card, "lineStrong", 0.2)
Pad(card, 20, 22, 20, 22)
List(card, nil, 10)
local title = Label({ Text = tostring(o.Title or "Loading"), Font = F.display, Size = 20, Dim = UDim2new(1, 0, 0, 26), Order = 1, Z = 182, Parent = card })
local msg = Label({ Text = tostring(o.Description or o.Message or ""), Size = 13, Color = "muted", Dim = UDim2new(1, 0, 0, 0), Auto = AutoY, Wrap = true, Order = 2, Z = 182, Parent = card })
local track = New("Frame", { Size = UDim2new(1, 0, 0, 8), LayoutOrder = 3, ZIndex = 182, Theme = { BackgroundColor3 = "line" }, Parent = card })
Corner(track, 4)
local fill = New("Frame", { Size = UDim2sc(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 183, Parent = track })
Corner(fill, 4)
New("UIGradient", { Theme = { Color = grad("accent", "accent2") }, Parent = fill })
local stepL = Label({ Text = "", Size = 12, Color = "faint", AlignX = RIGHT, Dim = UDim2new(1, 0, 0, 16), Order = 4, Z = 182, Parent = card })
local L = { Total = tonumber(o.TotalSteps) or 0, Step = 0 }
local function paint()
local r = L.Total > 0 and math.clamp(L.Step / L.Total, 0, 1) or 0
tween(fill, { Size = UDim2sc(r, 1) }, 0.3)
stepL.Text = L.Total > 0 and (L.Step .. " / " .. L.Total) or ""
end
function L:SetTitle(t)
title.Text = tostring(t)
end
function L:SetMessage(t)
msg.Text = tostring(t)
end
L.SetDescription = L.SetMessage
function L:SetTotalSteps(n)
L.Total = tonumber(n) or 0
paint()
end
function L:SetCurrentStep(n)
L.Step = tonumber(n) or 0
paint()
end
function L:Destroy()
if dim.Parent then
forget(dim)
dim:Destroy()
end
end
L.Continue, L.Close = L.Destroy, L.Destroy
function L:ShowErrorPage(t, m)
title.Text = tostring(t or "Something went wrong")
pcall(function()
Reg[title].TextColor3 = "err"
refresh(title)
end)
msg.Text = tostring(m or "")
track.Visible, stepL.Visible = false, false
local b = Container._button(card, "Close", "danger", nil, UDim2new(1, 0, 0, 34))
b.LayoutOrder = 5
b.ZIndex = 182
b.MouseButton1Click:Connect(L.Destroy)
end
paint()
return L
end
function Window:ShowErrorPage(t, m)
return self:Dialog({ Title = t or "Something went wrong", Content = m, Icon = "alert", Danger = true, Buttons = { { Name = "OK", Style = "danger" } } })
end
function Window:AddFooterButton(o)
o = type(o) == "string" and { Text = o } or (o or {})
if not self._footBar then
self._footBar = New("Frame", { BackgroundTransparency = 1, AnchorPoint = V2(1, 0.5), Position = UDim2new(1, -118, 0.5, 0), Size = UDim2off(0, 24), AutomaticSize = AutoX, Parent = self.Foot })
List(self._footBar, Enum.FillDirection.Horizontal, 6, nil, Enum.VerticalAlignment.Center)
end
local b = Container._button(self._footBar, tostring(o.Text or o.Name or ""), o.Style, o.Icon, UDim2off(0, 24))
b.AutomaticSize = AutoX
Pad(b, 0, 10, 0, 10)
b.MouseButton1Click:Connect(function()
local cb = o.Callback or o.Func
if cb then
task.spawn(cb)
end
end)
if o.Tooltip then
Binger:_tooltip(b, o.Tooltip)
end
local fb = { Button = b }
function fb:Remove()
if b.Parent then
forget(b)
b:Destroy()
end
end
fb.Destroy = fb.Remove
return fb
end
function Window:RemoveFooterButton(fb)
if type(fb) == "table" and fb.Remove then
fb:Remove()
end
end
function Container:Video(o)
o = o or {}
local el = Element.new(self, o, "Video")
local v = New("VideoFrame", {
Size = UDim2new(1, 0, 0, o.Height or 160),
Video = o.Video or "",
Looped = o.Looped ~= false,
Volume = o.Volume or 0.5,
BackgroundTransparency = 0.2,
LayoutOrder = self:_order(),
Theme = { BackgroundColor3 = "field" },
Parent = self.Body,
})
Corner(v, 10)
el.Row, el.VideoFrame = v, v
el.Item = self:_reg(v, o.Name or "video", o.Name or "Video", "Image")
function el:Play()
pcall(v.Play, v)
end
function el:Pause()
pcall(v.Pause, v)
end
function el:SetPlaying(on)
if on then
el:Play()
else
el:Pause()
end
end
function el:SetVideo(id)
v.Video = id
end
el.Set = el.SetVideo
function el:SetVolume(n)
v.Volume = n
end
function el:SetLooped(on)
v.Looped = on and true or false
end
if o.Playing ~= false and v.Video ~= "" then
el:Play()
end
return el
end
function Container:Viewport(o)
o = o or {}
local el = Element.new(self, o, "Viewport")
local vf = New("ViewportFrame", {
Size = UDim2new(1, 0, 0, o.Height or 180),
BackgroundTransparency = 0.2,
LayoutOrder = self:_order(),
Theme = { BackgroundColor3 = "field" },
Parent = self.Body,
})
Corner(vf, 10)
local cam = o.Camera or Instance.new("Camera")
cam.Parent = vf
vf.CurrentCamera = cam
local obj, yaw, center, dist = nil, 0, Vector3.zero, 10
local function frame()
cam.CFrame = CFrame.new(center) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(-15), 0, 0) * CFrame.new(0, 0, dist)
end
function el:SetObject(x, clone)
if obj then
obj:Destroy()
obj = nil
end
if not x then
return
end
local ok, c = pcall(function()
return clone == false and x or x:Clone()
end)
if not (ok and c) then
return
end
obj = c
obj.Parent = vf
local cf, size
if obj:IsA("Model") then
cf, size = obj:GetBoundingBox()
elseif obj:IsA("BasePart") then
cf, size = obj.CFrame, obj.Size
end
if cf then
center, dist = cf.Position, math.max(size.Magnitude * 1.2, 2)
end
frame()
end
el.Set = el.SetObject
function el:SetCamera(c)
cam = c
c.Parent = vf
vf.CurrentCamera = c
end
if o.Interactive then
vf.InputBegan:Connect(function(input)
if not isPress(input) then
return
end
local start, y0 = Binger:_pointer(input), yaw
Binger:_beginDrag(input, function(p)
yaw = y0 - (p.X - start.X) * 0.6
frame()
end)
end)
end
el.Row, el.ViewportFrame = vf, vf
el.Item = self:_reg(vf, o.Name or "viewport", o.Name or "Viewport", "Image")
if o.Object then
el:SetObject(o.Object, o.Clone)
end
return el
end
local cursor, cursorConn
function Binger:SetCustomCursor(on, image, size)
self.ShowCustomCursor = on and true or false
if not cursor then
cursor = New("ImageLabel", { BackgroundTransparency = 1, Visible = false, ZIndex = 250, Size = UDim2off(24, 24), Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png", Parent = Root })
Reg[cursor] = nil
end
if image then
cursor.Image = image
end
if size then
cursor.Size = UDim2off(size, size)
end
if on and not cursorConn then
cursorConn = Binger:_g(Svc.UserInputService.InputChanged, function(input)
if input.UserInputType ~= UIT.MouseMovement then
return
end
local w = Binger.Windows[1]
local show = Binger.ShowCustomCursor and w and w.Visible and not Binger.Touch
cursor.Visible = show and true or false
pcall(function()
Svc.UserInputService.MouseIconEnabled = not show
end)
if show then
local p = Binger:_toRoot(Binger:_pointer(input))
cursor.Position = UDim2off(p.X, p.Y)
end
end)
elseif not on then
cursor.Visible = false
pcall(function()
Svc.UserInputService.MouseIconEnabled = true
end)
end
end
function Binger:ChangeCursorIcon(image, size)
self:SetCustomCursor(true, image, size)
end
function Binger:ChangeCursorIconSize(size)
if cursor then
cursor.Size = UDim2off(size, size)
end
end
function Binger:ResetCursorIcon()
self:SetCustomCursor(false)
end
Binger:OnUnload(function()
pcall(function()
Svc.UserInputService.MouseIconEnabled = true
end)
end)
function Binger:SetNotifySide(side)
local left = tostring(side):lower() == "left"
self._notifyLeft = left
local h = self._notifyHolder
if h then
h.AnchorPoint = V2(left and 0 or 1, 0)
h.Position = left and UDim2new(0, 18, 0, 18) or UDim2new(1, -18, 0, 18)
local lay = h:FindFirstChildOfClass("UIListLayout")
if lay then
lay.HorizontalAlignment = left and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
end
end
end
function Window:SetCompact(on)
local w = on and 64 or SIDE
self.Compact = on and true or false
self._side = w
self.Side.Size = UDim2new(0, w, 1, 0)
self.SideLine.Position = UDim2off(w, 0)
self.Content.Position = UDim2off(w + 1, 0)
self.Content.Size = UDim2new(1, -w - 1, 1, 0)
if self._syncSide then
self._syncSide()
end
for _, x in ipairs(self._wideOnly or {}) do
x.Visible = not on
end
for _, t in ipairs(self.Tabs) do
if t.LabelText then
t.LabelText.Visible = not on
end
if on and t.Button and not t._compactTip then
t._compactTip = true
Binger:_tooltip(t.Button, t.Name)
end
end
pcall(function()
self:_glide(false)
end)
end
function Window:IsSidebarCompacted()
return self.Compact == true
end
function Binger:SetCompact(on)
local w = self.Windows[1]
if w then
w:SetCompact(on)
end
end
end
return Binger
