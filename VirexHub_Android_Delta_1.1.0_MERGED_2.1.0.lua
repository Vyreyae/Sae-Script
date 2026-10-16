--[[
	VirexHub  -  Android / Delta edition  -  v1.1.0 + 2.1.0 merged

	One self-contained LocalScript-style file for the Roblox Delta executor on Android.
	Everything is wrapped in module tables (Util, Maid, Env, Store, Motion, Anim, Typo,
	Theme, Sfx, Notify, UI, Bg, Splash, Avatar, Win, Pages, App, Scripts) so the main chunk stays
	far below Luau's local-variable and upvalue limits.

	WHAT CAME FROM WHERE
	  VirexHub_Android_Delta.lua (original)  identity, tabs, title "VIREX / HUB", palettes
	                                         Obsidian + DeepTeal, clock / compact / reduced
	                                         motion / notifications / UI scale / reset / close
	  blxyo_v6_3_free_event.lua              loading-screen structure (welcome chip, emblem with
	                                         orbit ring, sheen title, thin progress track,
	                                         ready hand-off), loading / error / hover sound
	                                         asset IDs, honest step reporting
	  Vyre-Multiverse-44.lua                 click sound ID, FPS / ping readout, time-played
	                                         counter, rejoin action, luminance-based text colour
	  Vyre-Multiverse-41.lua                 script catalog entries (names and links, unchanged) and
	                                         the favourite-star idea; no styling or layout
	  VYRE-INSTANT_STEAL.lua                 visual language only (diamond palette, living
	                                         gradient strokes); none of its game logic is used
	  AVATAR-CHANGER.lua (returnreturnfunction)  HumanoidDescription avatar changer, clothing
	                                         customizer, favourites (ported with validation)

	EXECUTOR FEATURES ARE OPTIONAL. File saving, clipboard, custom assets, HTTP and gethui are
	feature-detected inside pcall. If one is missing, the matching control says so and the
	hub keeps working with session-only settings.

	NOTHING HERE IS SERVER-AUTHORITATIVE. Avatar changes use Roblox's HumanoidDescription API
	from the client; whether the game accepts or replicates them is up to the game.
]]

local CONFIG = {
	Version = "1.1.0+2.1.0-merged",
	GuiName = "VirexHub",
	SplashName = "VirexHubSplash",
	Folder = "VirexHub",
	ConfigFile = "VirexHub/config.json",
	BackgroundFolder = "VirexHub/backgrounds",
	CacheFolder = "VirexHub/cache",
	FontFolder = "VirexHub/fonts",
	LegacyGuis = { "VirexStyleHub" },
	LegacyFavorites = "Favorites.json", -- read once (never modified) to import old avatar favourites
	LegacyScriptFavorites = "VyreHub_Favorites.json", -- read once (never modified) to import script favorites from Vyre Hub
	ToggleKey = "RightShift",           -- keyboard / mouse users only

	Splash = {
		MinSeconds = 1.7,   -- brand moment; the bar itself only shows real completed work
		HoldSeconds = 0.5,  -- pause on "Ready" before the hand-off
		MaxSeconds = 14,    -- watchdog: the loading screen can never hang longer than this
		PreloadSeconds = 6, -- cap for asset preloading
	},

	-- UI sounds. IDs come from the scripts you supplied (Multiverse click, Blyxo hover / loading /
	-- error). They could NOT be verified from the build sandbox, so every asset is preloaded at
	-- boot and anything that fails to load is skipped silently (see Settings > Sound status).
	-- Replace an id with any audio asset you own or that is public. Use "" to disable an event.
	-- Fields: id, volume (0-1), speed (pitch), chain (list of {at = seconds, speed = n}).
	Sounds = {
		click    = { id = "rbxassetid://6895079853",   volume = 0.35, speed = 1.00 },
		select   = { id = "rbxassetid://6895079853",   volume = 0.30, speed = 1.18 },
		toggleOn = { id = "rbxassetid://6895079853",   volume = 0.32, speed = 1.32 },
		toggleOff= { id = "rbxassetid://6895079853",   volume = 0.30, speed = 0.82 },
		dropdown = { id = "rbxassetid://6895079853",   volume = 0.28, speed = 1.06 },
		tab      = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 1.00 },
		open     = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 0.92 },
		close    = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 0.74 },
		success  = { id = "rbxassetid://6895079853",   volume = 0.30, speed = 1.20,
			chain = { { at = 0.00, speed = 1.20 }, { at = 0.075, speed = 1.62 } } },
		warning  = { id = "rbxassetid://6895079853",   volume = 0.32, speed = 0.78,
			chain = { { at = 0.00, speed = 0.78 }, { at = 0.10, speed = 0.78 } } },
		error    = { id = "rbxassetid://71028126634386", volume = 0.45, speed = 1.00 },
		loading  = { id = "rbxassetid://139746569667955", volume = 0.45, speed = 1.00, maxSeconds = 6 },
	},

	-- Typography. "enum" families use Roblox's built-in fonts (always available).
	-- To add your own fonts later, upload them to Roblox as a Font Family asset (Creator Hub) and
	-- add an entry with  face = "rbxassetid://<family asset id>"  - nothing else has to change.
	Fonts = {
		Default = "gotham",
		Families = {
			{ id = "gotham",  name = "Gotham",       enum = { regular = "Gotham",       medium = "GothamMedium",       bold = "GothamBold" } },
			{ id = "builder", name = "Builder Sans", enum = { regular = "BuilderSans",  medium = "BuilderSansMedium",  bold = "BuilderSansBold" } },
			{ id = "source",  name = "Source Sans",  enum = { regular = "SourceSans",   medium = "SourceSansSemibold", bold = "SourceSansBold" } },
			{ id = "ubuntu",  name = "Ubuntu",       enum = { regular = "Ubuntu",       medium = "Ubuntu",             bold = "Ubuntu" } },
			{ id = "roboto",  name = "Roboto",       enum = { regular = "Roboto",       medium = "Roboto",             bold = "Roboto" } },
			-- { id = "brand", name = "My Brand Font", face = "rbxassetid://0" },   <- example, keep commented until you have an id
		},
	},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local function optionalService(name)
	local ok, service = pcall(game.GetService, game, name)
	if ok then
		return service
	end
	return nil
end

local GuiService = optionalService("GuiService")
local ContentProvider = optionalService("ContentProvider")
local SoundService = optionalService("SoundService")
local Lighting = optionalService("Lighting")
local TeleportService = optionalService("TeleportService")
local StatsService = optionalService("Stats")

local Util, Maid, Env, Store, Motion, Anim, Typo, Theme, Sfx, Notify, UI, Bg, Splash, Avatar, Win, Pages, App, Scripts =
	{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

----------------------------------------------------------------------------------------------------
-- Util: small pure helpers shared by every module
----------------------------------------------------------------------------------------------------
Util.logs = {}

function Util.log(level, message)
	local logs = Util.logs
	logs[#logs + 1] = { t = os.clock(), level = level, message = tostring(message) }
	if #logs > 80 then
		table.remove(logs, 1)
	end
end

function Util.try(label, fn, ...)
	local ok, a, b, c = pcall(fn, ...)
	if not ok then
		Util.log("error", tostring(label) .. ": " .. tostring(a))
	end
	return ok, a, b, c
end

function Util.clamp(x, lo, hi)
	if x < lo then
		return lo
	elseif x > hi then
		return hi
	end
	return x
end

function Util.lerp(a, b, t)
	return a + (b - a) * t
end

function Util.round(x, step)
	step = step or 1
	return math.floor(x / step + 0.5) * step
end

function Util.percent(x)
	return math.floor(x * 100 + 0.5)
end

function Util.trim(s)
	s = tostring(s == nil and "" or s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Util.split(s, sep)
	local out, pos = {}, 1
	s = tostring(s)
	if sep == nil or sep == "" then
		out[1] = s
		return out
	end
	while true do
		local a, b = string.find(s, sep, pos, true)
		if not a then
			out[#out + 1] = string.sub(s, pos)
			break
		end
		out[#out + 1] = string.sub(s, pos, a - 1)
		pos = b + 1
	end
	return out
end

function Util.cap(s, n)
	s = tostring(s)
	if #s <= n then
		return s
	end
	return string.sub(s, 1, math.max(1, n - 3)) .. "..."
end

function Util.count(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

function Util.indexOf(list, value)
	for i = 1, #list do
		if list[i] == value then
			return i
		end
	end
	return nil
end

function Util.copy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

function Util.deepCopy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = Util.deepCopy(v)
	end
	return out
end

function Util.hash(s)
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 4294967296
	end
	return string.format("%08x", h)
end

function Util.duration(seconds)
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%dh %02dm", h, m)
	end
	return string.format("%dm %02ds", m, s)
end

function Util.jsonEncode(value)
	local ok, result = pcall(HttpService.JSONEncode, HttpService, value)
	if ok then
		return result
	end
	return nil, result
end

function Util.jsonDecode(text)
	local ok, result = pcall(HttpService.JSONDecode, HttpService, text)
	if ok then
		return result
	end
	return nil, result
end

-- colour helpers ------------------------------------------------------------------------------
function Util.mix(a, b, t)
	if t <= 0 then
		return a
	elseif t >= 1 then
		return b
	end
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function linearChannel(v)
	if v <= 0.04045 then
		return v / 12.92
	end
	return ((v + 0.055) / 1.055) ^ 2.4
end

function Util.lum(c)
	return 0.2126 * linearChannel(c.R) + 0.7152 * linearChannel(c.G) + 0.0722 * linearChannel(c.B)
end

function Util.contrast(a, b)
	local la, lb = Util.lum(a), Util.lum(b)
	if la < lb then
		la, lb = lb, la
	end
	return (la + 0.05) / (lb + 0.05)
end

-- text colour (dark or light) that reads best on `bg`
function Util.onColor(bg, dark, light)
	dark = dark or Color3.fromRGB(12, 14, 20)
	light = light or Color3.fromRGB(248, 250, 253)
	if Util.contrast(bg, dark) >= Util.contrast(bg, light) then
		return dark
	end
	return light
end

function Util.lighten(c, t)
	return Util.mix(c, Color3.new(1, 1, 1), t)
end

function Util.darken(c, t)
	return Util.mix(c, Color3.new(0, 0, 0), t)
end

-- instance helpers (properties are assigned BEFORE parenting, which is cheaper) ----------------
function Util.new(className, props, parent)
	local inst = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			inst[key] = value
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Util.corner(parent, radius)
	return Util.new("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

function Util.round_corner(parent)
	return Util.new("UICorner", { CornerRadius = UDim.new(1, 0) }, parent)
end

function Util.stroke(parent, color, thickness, transparency)
	return Util.new("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

function Util.pad(parent, left, top, right, bottom)
	top = top or left
	right = right or left
	bottom = bottom or top
	return Util.new("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	}, parent)
end

function Util.list(parent, padding, horizontal)
	return Util.new("UIListLayout", {
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 0),
	}, parent)
end

function Util.isInstance(v)
	return typeof(v) == "Instance"
end

function Util.alive(inst)
	return inst ~= nil and typeof(inst) == "Instance" and inst.Parent ~= nil
end

----------------------------------------------------------------------------------------------------
-- Maid: collects connections / instances / callbacks so teardown is one call
----------------------------------------------------------------------------------------------------
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _items = {}, _n = 0 }, Maid)
end

local function disposeItem(item)
	local kind = typeof(item)
	if kind == "function" then
		pcall(item)
	elseif kind == "RBXScriptConnection" then
		pcall(item.Disconnect, item)
	elseif kind == "Instance" then
		if item.ClassName == "Tween" then
			pcall(item.Cancel, item)
		end
		pcall(item.Destroy, item)
	elseif kind == "thread" then
		pcall(task.cancel, item)
	elseif kind == "table" then
		if type(item.Destroy) == "function" then
			pcall(item.Destroy, item)
		elseif type(item.Disconnect) == "function" then
			pcall(item.Disconnect, item)
		elseif type(item.Cancel) == "function" then
			pcall(item.Cancel, item)
		end
	end
end

function Maid:Give(item)
	if item ~= nil then
		self._n = self._n + 1
		self._items[self._n] = item
	end
	return item
end

function Maid:Connect(signal, fn)
	return self:Give(signal:Connect(fn))
end

function Maid:Clean()
	local items, n = self._items, self._n
	self._items, self._n = {}, 0
	for i = n, 1, -1 do
		disposeItem(items[i])
	end
end

Maid.Destroy = Maid.Clean

----------------------------------------------------------------------------------------------------
-- Env: executor / platform feature detection. Every executor global is read inside pcall.
----------------------------------------------------------------------------------------------------
local function optionalGlobal(getter)
	local ok, value = pcall(getter)
	if ok and type(value) == "function" then
		return value
	end
	return nil
end

Env.fn = {}

function Env.detect()
	local fn = Env.fn
	fn.writefile = optionalGlobal(function() return writefile end)
	fn.readfile = optionalGlobal(function() return readfile end)
	fn.isfile = optionalGlobal(function() return isfile end)
	fn.makefolder = optionalGlobal(function() return makefolder end)
	fn.isfolder = optionalGlobal(function() return isfolder end)
	fn.getcustomasset = optionalGlobal(function() return getcustomasset or getsynasset end)
	fn.setclipboard = optionalGlobal(function() return setclipboard or toclipboard end)
	fn.request = optionalGlobal(function()
		return request or http_request or (syn and syn.request) or (http and http.request)
	end)
	fn.gethui = optionalGlobal(function() return gethui end)
	fn.getgenv = optionalGlobal(function() return getgenv end)
	fn.identify = optionalGlobal(function() return identifyexecutor or getexecutorname end)
	fn.loadstring = optionalGlobal(function() return loadstring end)
	fn.httpget = optionalGlobal(function() return game.HttpGet end)

	Env.executor, Env.executorVersion = "unknown", ""
	if fn.identify then
		local ok, name, version = pcall(fn.identify)
		if ok and type(name) == "string" and name ~= "" then
			Env.executor = name
			if type(version) == "string" then
				Env.executorVersion = version
			end
		end
	end

	Env.touch = UserInputService.TouchEnabled
	Env.keyboard = UserInputService.KeyboardEnabled
	Env.mouse = UserInputService.MouseEnabled
	return Env
end

function Env.canSave()
	local fn = Env.fn
	return fn.writefile ~= nil and fn.readfile ~= nil and fn.isfile ~= nil
end

function Env.canClipboard()
	return Env.fn.setclipboard ~= nil
end

function Env.canCustomAsset()
	return Env.fn.getcustomasset ~= nil and Env.canSave()
end

function Env.canDownload()
	return Env.canCustomAsset() and (Env.fn.request ~= nil)
end

-- Some executors expose file functions but refuse every call. A harmless folder query distinguishes the cases.
function Env.filesWork()
	local fn = Env.fn
	if not (fn.isfile and fn.isfolder) then
		return false
	end
	local ok = pcall(fn.isfolder, CONFIG.Folder)
	return ok
end

-- the table that survives re-execution (executor global environment, or _G as a fallback)
function Env.global()
	if Env.fn.getgenv then
		local ok, env = pcall(Env.fn.getgenv)
		if ok and type(env) == "table" then
			return env
		end
	end
	return _G
end

function Env.viewport()
	local camera = workspace.CurrentCamera
	if camera then
		local size = camera.ViewportSize
		if size.X > 50 and size.Y > 50 then
			return size
		end
	end
	return Vector2.new(800, 450)
end

function Env.localPlayer()
	local player = Players.LocalPlayer
	if player then
		return player
	end
	local waited = 0
	while not Players.LocalPlayer and waited < 10 do
		task.wait(0.1)
		waited = waited + 0.1
	end
	return Players.LocalPlayer
end

-- where the ScreenGui goes: hidden UI container when the executor offers one, else PlayerGui
function Env.guiParent()
	if Env.fn.gethui then
		local ok, container = pcall(Env.fn.gethui)
		if ok and typeof(container) == "Instance" then
			return container, "gethui"
		end
	end
	local player = Env.localPlayer()
	if player then
		local pg = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 8)
		if pg then
			return pg, "PlayerGui"
		end
	end
	return nil, "none"
end

function Env.readFile(path)
	local fn = Env.fn
	if not (fn.readfile and fn.isfile) then
		return nil, "file access unavailable"
	end
	local okExists, exists = pcall(fn.isfile, path)
	if not okExists or not exists then
		return nil, "missing"
	end
	local ok, data = pcall(fn.readfile, path)
	if ok and type(data) == "string" then
		return data
	end
	return nil, tostring(data)
end

function Env.writeFile(path, data)
	if not Env.fn.writefile then
		return false, "file access unavailable"
	end
	local ok, err = pcall(Env.fn.writefile, path, data)
	if ok then
		return true
	end
	return false, tostring(err)
end

function Env.fileExists(path)
	if not Env.fn.isfile then
		return false
	end
	local ok, exists = pcall(Env.fn.isfile, path)
	return ok and exists == true
end

function Env.ensureFolder(path)
	local fn = Env.fn
	if not (fn.makefolder and fn.isfolder) then
		return false
	end
	local built = ""
	for _, part in ipairs(Util.split(path, "/")) do
		if part ~= "" then
			built = (built == "") and part or (built .. "/" .. part)
			local okExists, exists = pcall(fn.isfolder, built)
			if okExists and not exists then
				pcall(fn.makefolder, built)
			end
		end
	end
	local okFinal, final = pcall(fn.isfolder, path)
	return okFinal and final == true
end

function Env.copy(text)
	if not Env.fn.setclipboard then
		return false
	end
	local ok = pcall(Env.fn.setclipboard, tostring(text))
	return ok
end

function Env.customAsset(path)
	if not Env.fn.getcustomasset then
		return nil, "getcustomasset unavailable"
	end
	local ok, result = pcall(Env.fn.getcustomasset, path)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return nil, tostring(result)
end

-- plain GET used only to download an image the user explicitly typed in (never executed as code)
function Env.httpGet(url)
	local fn = Env.fn
	if fn.request then
		local ok, res = pcall(fn.request, { Url = url, Method = "GET" })
		if not ok then
			return nil, tostring(res)
		end
		if type(res) == "table" then
			local code = tonumber(res.StatusCode or res.status_code) or 0
			if (res.Success == true or (code >= 200 and code < 300)) and type(res.Body) == "string" then
				return res.Body
			end
			return nil, "HTTP " .. tostring(code)
		end
		return nil, "unexpected response"
	end
	return nil, "request function unavailable"
end

----------------------------------------------------------------------------------------------------
-- script launcher helpers (added in 2.1.0). They are used only by the Scripts tab and the Private
-- Server Finder, and only after the user taps a button. Env.httpGet above keeps its own contract
-- (image download, never executed).
----------------------------------------------------------------------------------------------------
function Env.canRun()
	return Env.fn.loadstring ~= nil
end

function Env.canFetch()
	return Env.fn.httpget ~= nil or Env.fn.request ~= nil
end

-- One GET. order: "get" (game:HttpGet, then the request function), "request" (request function, then
-- game:HttpGet) or "request-only". The second function is tried only when the first gave no HTTP status,
-- so a real 404 or 429 is final. Returns { ok, status, body, error, via }.
function Env.fetch(url, order)
	local fn = Env.fn
	local function viaHttpGet()
		if not fn.httpget then
			return { ok = false, via = "HttpGet", error = "HttpGet is not available" }
		end
		local ok, body = pcall(fn.httpget, game, url)
		if ok and type(body) == "string" then
			return { ok = true, via = "HttpGet", body = body }
		end
		return { ok = false, via = "HttpGet", error = tostring(body) }
	end
	local function viaRequest()
		if not fn.request then
			return { ok = false, via = "request", error = "request function is not available" }
		end
		local ok, res = pcall(fn.request, { Url = url, Method = "GET" })
		if not ok then
			return { ok = false, via = "request", error = tostring(res) }
		end
		if type(res) ~= "table" then
			return { ok = false, via = "request", error = "unexpected response" }
		end
		local code = tonumber(res.StatusCode or res.status_code) or 0
		local status = code > 0 and code or nil
		local success = (code >= 200 and code < 300) or (code == 0 and res.Success == true)
		if success and type(res.Body) == "string" then
			return { ok = true, via = "request", status = status, body = res.Body }
		end
		return { ok = false, via = "request", status = status, error = status and ("HTTP " .. status) or "request failed" }
	end
	local first, second = viaHttpGet, viaRequest
	if order == "request" or order == "request-only" then
		first, second = viaRequest, viaHttpGet
	end
	local result = first()
	if result.ok or result.status or order == "request-only" then
		return result
	end
	local fallback = second()
	if fallback.ok or fallback.status then
		return fallback
	end
	result.error = tostring(result.error) .. " / " .. tostring(fallback.error)
	return result
end

-- loadstring wrapper: returns the compiled function, or nil and the reason
function Env.compile(source)
	local compile = Env.fn.loadstring
	if not compile then
		return nil, "loadstring is not available"
	end
	local ok, chunk, err = pcall(compile, source)
	if not ok then
		return nil, tostring(chunk)
	end
	if type(chunk) ~= "function" then
		return nil, tostring(err or "the script could not be compiled")
	end
	return chunk
end

function Env.runSummary()
	local fn = Env.fn
	local function flag(v)
		return v and "yes" or "no"
	end
	return string.format("Run scripts (loadstring) %s | HttpGet %s | request %s", flag(fn.loadstring), flag(fn.httpget), flag(fn.request))
end

function Env.summary()
	local fn = Env.fn
	local function flag(v)
		return v and "yes" or "no"
	end
	return string.format(
		"Executor %s | files %s | clipboard %s | custom assets %s | http %s | hidden ui %s | touch %s",
		Env.executor,
		flag(Env.canSave()),
		flag(Env.canClipboard()),
		flag(fn.getcustomasset ~= nil),
		flag(fn.request ~= nil),
		flag(fn.gethui ~= nil),
		flag(Env.touch)
	)
end

----------------------------------------------------------------------------------------------------
-- Store: validated settings with debounced saving (only when the executor offers file access)
----------------------------------------------------------------------------------------------------
Store.defaults = {
	version = 1,
	theme = "obsidian",
	fx = 2,
	reducedMotion = false,
	lowPower = false,
	notifications = true,
	clock = true,
	compact = false,
	scale = 1,
	sound = true,
	volume = 0.6,
	font = "gotham",
	bgMode = "solid",
	bgImage = "",
	bgSequence = "",
	bgVideo = "",
	bgFps = 8,
	bgCols = 4,
	bgRows = 4,
	glass = 0,
	overlay = 0.35,
	blur = false,
	splash = true,
	splashSound = true,
	favorites = {},
	scriptFavorites = {},
	lastTarget = "",
}

Store.rules = {
	version = { kind = "int", min = 1, max = 99 },
	theme = { kind = "string", max = 32 },
	fx = { kind = "int", min = 0, max = 2 },
	reducedMotion = { kind = "bool" },
	lowPower = { kind = "bool" },
	notifications = { kind = "bool" },
	clock = { kind = "bool" },
	compact = { kind = "bool" },
	scale = { kind = "number", min = 0.9, max = 1.15 },
	sound = { kind = "bool" },
	volume = { kind = "number", min = 0, max = 1 },
	font = { kind = "string", max = 32 },
	bgMode = { kind = "string", max = 16, oneOf = { "solid", "aurora", "sparkle", "image", "sheet", "sequence", "video" } },
	bgImage = { kind = "string", max = 400 },
	bgSequence = { kind = "string", max = 1200 },
	bgVideo = { kind = "string", max = 400 },
	bgFps = { kind = "int", min = 1, max = 24 },
	bgCols = { kind = "int", min = 1, max = 16 },
	bgRows = { kind = "int", min = 1, max = 16 },
	glass = { kind = "number", min = 0, max = 0.6 },
	overlay = { kind = "number", min = 0, max = 0.9 },
	blur = { kind = "bool" },
	splash = { kind = "bool" },
	splashSound = { kind = "bool" },
	favorites = { kind = "idlist", max = 60 },
	scriptFavorites = { kind = "strlist", max = 120 },
	lastTarget = { kind = "string", max = 40 },
}

Store.data = Util.deepCopy(Store.defaults)
Store.listeners = {}
Store.persistent = false
Store.unreadable = nil -- tracks whether an unreadable config was preserved/replaced/left untouched
Store.unreadableConfig = nil
Store.lastSaveOk = nil
Store.lastError = nil

function Store.clean(key, value)
	local rule = Store.rules[key]
	if not rule then
		return nil
	end
	local kind = rule.kind
	if kind == "bool" then
		if type(value) == "boolean" then
			return value
		end
		return nil
	elseif kind == "int" or kind == "number" then
		if type(value) ~= "number" or value ~= value then
			return nil
		end
		if kind == "int" then
			value = math.floor(value + 0.5)
		end
		return Util.clamp(value, rule.min, rule.max)
	elseif kind == "string" then
		if type(value) ~= "string" then
			return nil
		end
		if #value > (rule.max or 256) then
			value = string.sub(value, 1, rule.max or 256)
		end
		if rule.oneOf and not Util.indexOf(rule.oneOf, value) then
			return nil
		end
		return value
	elseif kind == "idlist" then
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, id in ipairs(value) do
			if type(id) == "number" and id == math.floor(id) and id > 0 and id < 1e12 and not seen[id] then
				out[#out + 1] = id
				seen[id] = true
				if #out >= (rule.max or 60) then
					break
				end
			end
		end
		return out
	elseif kind == "strlist" then
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, id in ipairs(value) do
			if type(id) == "string" and #id >= 1 and #id <= 40 and string.match(id, "^[a-z0-9][a-z0-9%-]*$") and not seen[id] then
				out[#out + 1] = id
				seen[id] = true
				if #out >= (rule.max or 60) then
					break
				end
			end
		end
		return out
	end
	return nil
end

function Store.get(key)
	return Store.data[key]
end

function Store.on(key, fn)
	local list = Store.listeners[key]
	if not list then
		list = {}
		Store.listeners[key] = list
	end
	list[#list + 1] = fn
	return function()
		local current = Store.listeners[key]
		if current then
			local index = Util.indexOf(current, fn)
			if index then
				table.remove(current, index)
			end
		end
	end
end

local function fireStore(key, new, old)
	local list = Store.listeners[key]
	if not list then
		return
	end
	local snapshot = {}
	for i = 1, #list do
		snapshot[i] = list[i]
	end
	for i = 1, #snapshot do
		Util.try("store listener " .. key, snapshot[i], new, old)
	end
end

function Store.set(key, value, silent)
	local clean = Store.clean(key, value)
	if clean == nil then
		return false
	end
	local old = Store.data[key]
	Store.data[key] = clean
	if not silent then
		fireStore(key, clean, old)
	end
	Store.queueSave()
	return true
end

function Store.queueSave()
	if not Store.persistent or Store.saveToken then
		return
	end
	Store.saveToken = task.delay(0.8, function()
		Store.saveToken = nil
		Store.save()
	end)
end

function Store.save()
	if not Env.canSave() then
		Store.lastSaveOk = false
		Store.lastError = "file access unavailable"
		return false
	end
	local text, encodeError = Util.jsonEncode(Store.data)
	if not text then
		Store.lastSaveOk, Store.lastError = false, tostring(encodeError)
		return false
	end
	Env.ensureFolder(CONFIG.Folder)
	local ok, err = Env.writeFile(CONFIG.ConfigFile, text)
	Store.lastSaveOk, Store.lastError = ok, err
	return ok
end

function Store.flush()
	if Store.saveToken then
		pcall(task.cancel, Store.saveToken)
		Store.saveToken = nil
	end
	if Store.persistent then
		Store.save()
	end
end

function Store.load()
	Store.data = Util.deepCopy(Store.defaults)
	Store.loadedFromFile = false
	Store.unreadable = nil
	Store.unreadableConfig = nil
	local text = Env.readFile(CONFIG.ConfigFile)
	if text then
		local decoded = Util.jsonDecode(text)
		if type(decoded) == "table" then
			for key in pairs(Store.defaults) do
				local clean = Store.clean(key, decoded[key])
				if clean ~= nil then
					Store.data[key] = clean
				end
			end
			Store.loadedFromFile = true
		else
			Util.log("warn", "config.json could not be parsed; defaults are in use")
			Store.unreadableConfig = text
			Store.unreadable = "left"
		end
	end

	-- one-time, read-only import of favourites written by the old AVATAR-CHANGER script
	if #Store.data.favorites == 0 then
		local legacy = Env.readFile(CONFIG.LegacyFavorites)
		if legacy then
			local decoded = Util.jsonDecode(legacy)
			local clean = Store.clean("favorites", decoded)
			if clean and #clean > 0 then
				Store.data.favorites = clean
				Util.log("info", "imported " .. #clean .. " avatar favourites from " .. CONFIG.LegacyFavorites)
			end
		end
	end

	-- one-time, read-only import of script favorites written by Vyre Hub (name -> true), mapped to catalog ids
	if #Store.data.scriptFavorites == 0 then
		local legacyScripts = Env.readFile(CONFIG.LegacyScriptFavorites)
		if legacyScripts then
			local decoded = Util.jsonDecode(legacyScripts)
			local ids = Scripts.importLegacy(decoded)
			if #ids > 0 then
				Store.data.scriptFavorites = Store.clean("scriptFavorites", ids) or {}
				Util.log("info", "imported " .. #ids .. " script favorites from " .. CONFIG.LegacyScriptFavorites)
			end
		end
	end

	Store.persistent = Env.canSave()
	if Store.persistent then
		Env.ensureFolder(CONFIG.Folder)
		local copyKept = false
		if Store.unreadableConfig then
			copyKept = Env.writeFile(CONFIG.Folder .. "/config.unreadable.json", Store.unreadableConfig) == true
			Util.log("info", copyKept and "kept the unreadable config as config.unreadable.json" or "could not keep a copy of the unreadable config")
			Store.unreadableConfig = nil
		end
		Store.persistent = Store.save() == true
		if Store.unreadable then
			Store.unreadable = copyKept and "kept" or (Store.persistent and "replaced" or "left")
		end
	end
	return Store.data
end

-- restores every preference except the favourites (avatar and script) / last target
function Store.reset()
	for key, default in pairs(Store.defaults) do
		if key ~= "favorites" and key ~= "scriptFavorites" and key ~= "lastTarget" and key ~= "version" then
			Store.set(key, Util.deepCopy(default))
		end
	end
end

do -- [02_motion_typo.lua]

----------------------------------------------------------------------------------------------------
-- Anim: one shared Heartbeat driver. Jobs can be throttled (hz) and gated (e.g. only while visible).
----------------------------------------------------------------------------------------------------
Anim.jobs = {}
Anim.byName = {}
Anim.conn = nil
Anim.seq = 0

function Anim.nextId()
	Anim.seq = Anim.seq + 1
	return Anim.seq
end

local function animStep(dt)
	local jobs = Anim.jobs
	local count = #jobs
	local now = os.clock()
	local anyDead = false
	for i = 1, count do
		local job = jobs[i]
		if job.dead then
			anyDead = true
		else
			job.acc = job.acc + dt
			if job.acc >= job.interval then
				local elapsed = job.acc
				job.acc = 0
				if job.gate == nil or job.gate() then
					local ok, err = pcall(job.fn, elapsed, now)
					if not ok then
						job.dead = true
						anyDead = true
						if Anim.byName[job.name] == job then
							Anim.byName[job.name] = nil
						end
						Util.log("error", "anim job '" .. job.name .. "' stopped: " .. tostring(err))
					end
				end
			end
		end
	end
	if anyDead then
		local alive = {}
		for i = 1, #jobs do
			if not jobs[i].dead then
				alive[#alive + 1] = jobs[i]
			end
		end
		Anim.jobs = alive
	end
	if #Anim.jobs == 0 then
		Anim.stop()
	end
end

function Anim.start()
	if not Anim.conn then
		Anim.conn = RunService.Heartbeat:Connect(animStep)
	end
end

function Anim.stop()
	if Anim.conn then
		Anim.conn:Disconnect()
		Anim.conn = nil
	end
end

-- fn(dt, now). hz = maximum calls per second (nil = every frame). gate() = false skips the call.
function Anim.add(name, fn, hz, gate)
	local existing = Anim.byName[name]
	if existing and not existing.dead then
		existing.fn = fn
		existing.interval = hz and (1 / hz) or 0
		existing.gate = gate
		return existing
	end
	local job = { name = name, fn = fn, interval = hz and (1 / hz) or 0, acc = 0, gate = gate, dead = false }
	Anim.jobs[#Anim.jobs + 1] = job
	Anim.byName[name] = job
	Anim.start()
	return job
end

function Anim.remove(name)
	local job = Anim.byName[name]
	if job then
		job.dead = true
		Anim.byName[name] = nil
	end
end

function Anim.has(name)
	local job = Anim.byName[name]
	return job ~= nil and not job.dead
end

function Anim.stopAll()
	for _, job in ipairs(Anim.jobs) do
		job.dead = true
	end
	Anim.jobs = {}
	Anim.byName = {}
	Anim.stop()
end

----------------------------------------------------------------------------------------------------
-- Motion: tweens with per-(object, property) cancellation, reduced-motion support, easing library
----------------------------------------------------------------------------------------------------
Motion.reduced = false
Motion.fast, Motion.base, Motion.slow = 0.12, 0.2, 0.34
Motion.style = Enum.EasingStyle.Quart
Motion.dir = Enum.EasingDirection.Out

Motion.ease = {
	linear = function(t) return t end,
	outQuad = function(t) return 1 - (1 - t) * (1 - t) end,
	outCubic = function(t)
		local u = 1 - t
		return 1 - u * u * u
	end,
	outQuart = function(t)
		local u = 1 - t
		return 1 - u * u * u * u
	end,
	inOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
	inOutCubic = function(t)
		if t < 0.5 then
			return 4 * t * t * t
		end
		local u = -2 * t + 2
		return 1 - u * u * u / 2
	end,
	outBack = function(t)
		local u = t - 1
		return 1 + 2.70158 * u * u * u + 1.70158 * u * u
	end,
}

local activeTweens = setmetatable({}, { __mode = "k" }) -- obj -> { [prop] = { tween, group } }

local function cancelProps(obj, props)
	local entry = activeTweens[obj]
	if not entry then
		return
	end
	local function cancelRecord(key)
		local record = entry[key]
		if record then
			entry[key] = nil
			record.group.dead = true
			pcall(record.tween.Cancel, record.tween)
		end
	end
	if props then
		for key in pairs(props) do
			cancelRecord(key)
		end
	else
		for key in pairs(Util.copy(entry)) do
			cancelRecord(key)
		end
	end
end

function Motion.cancel(obj, props)
	cancelProps(obj, props)
end

-- instant assignment that also cancels any running tween on those properties
function Motion.set(obj, props)
	cancelProps(obj, props)
	for key, value in pairs(props) do
		pcall(function()
			obj[key] = value
		end)
	end
end

-- Animates `props` on `obj`. A newer call for the same property replaces the older tween.
-- onDone() runs once when every property finished (not when interrupted).
function Motion.tween(obj, props, duration, style, direction, onDone)
	if obj == nil then
		return nil
	end
	duration = duration or Motion.base
	cancelProps(obj, props)
	if Motion.reduced or duration <= 0 then
		for key, value in pairs(props) do
			pcall(function()
				obj[key] = value
			end)
		end
		if onDone then
			onDone()
		end
		return nil
	end

	local info = TweenInfo.new(duration, style or Motion.style, direction or Motion.dir)
	local entry = activeTweens[obj]
	if not entry then
		entry = {}
		activeTweens[obj] = entry
	end

	local keys = {}
	for key in pairs(props) do
		keys[#keys + 1] = key
	end
	local group = { remaining = #keys, dead = false }
	local lastTween = nil

	for _, key in ipairs(keys) do
		local ok, tween = pcall(TweenService.Create, TweenService, obj, info, { [key] = props[key] })
		if ok and tween then
			local record = { tween = tween, group = group }
			entry[key] = record
			local connection = nil
			connection = tween.Completed:Connect(function()
				if connection then
					connection:Disconnect()
				end
				if entry[key] == record then
					entry[key] = nil
				end
				if group.dead then
					return
				end
				group.remaining = group.remaining - 1
				if group.remaining <= 0 then
					group.dead = true
					if onDone then
						onDone()
					end
				end
			end)
			tween:Play()
			lastTween = tween
		else
			group.remaining = group.remaining - 1
			pcall(function()
				obj[key] = props[key]
			end)
		end
	end

	if group.remaining <= 0 and not group.dead then
		group.dead = true
		if onDone then
			onDone()
		end
	end
	return lastTween
end

-- Frame-driven animation for things TweenService cannot express (counters, driven gradients ...)
-- step(alpha 0..1 eased). Returns a handle with :Cancel().
function Motion.run(duration, step, easeFn, onDone)
	local handle = { cancelled = false }
	function handle.Cancel()
		handle.cancelled = true
	end
	if Motion.reduced or duration <= 0 then
		step(1)
		if onDone then
			onDone()
		end
		return handle
	end
	easeFn = easeFn or Motion.ease.outCubic
	local started = os.clock()
	local name = "run" .. tostring(Anim.nextId())
	Anim.add(name, function()
		if handle.cancelled then
			Anim.remove(name)
			return
		end
		local a = (os.clock() - started) / duration
		if a >= 1 then
			Anim.remove(name)
			step(1)
			if onDone then
				onDone()
			end
			return
		end
		step(easeFn(a))
	end)
	return handle
end

----------------------------------------------------------------------------------------------------
-- Typo: every text object gets its font through a role, so fonts can change in one place
----------------------------------------------------------------------------------------------------
Typo.roles = {
	display = { size = 30, weight = "bold" },
	title = { size = 20, weight = "bold" },
	heading = { size = 14, weight = "medium" },
	body = { size = 12, weight = "regular", lineHeight = 1.12 },
	caption = { size = 11, weight = "regular", lineHeight = 1.12 },
	label = { size = 11, weight = "bold" },
	button = { size = 13, weight = "medium" },
	buttonSmall = { size = 12, weight = "medium" },
	tab = { size = 13, weight = "medium" },
	stat = { size = 18, weight = "bold" },
}

Typo.families = {}
Typo.order = {}
Typo.family = nil
Typo.registry = {} -- strong on purpose: Roblox may drop Lua wrappers of live instances; Typo.prune() cleans dead ones
Typo.faceSupported = false

local function enumFont(name, fallback)
	local ok, value = pcall(function()
		return Enum.Font[name]
	end)
	if ok and value then
		return value
	end
	return fallback
end

local function fontWeight(weight)
	local names = { regular = "Regular", medium = "Medium", bold = "Bold" }
	local ok, value = pcall(function()
		return Enum.FontWeight[names[weight] or "Regular"]
	end)
	if ok then
		return value
	end
	return nil
end

function Typo.init()
	Typo.families, Typo.order = {}, {}
	Typo.faceSupported = pcall(function()
		return Font.new("rbxasset://fonts/families/GothamSSm.json")
	end)
	for _, def in ipairs(CONFIG.Fonts.Families) do
		local family = { id = def.id, name = def.name, face = def.face }
		if def.enum then
			family.regular = enumFont(def.enum.regular, nil)
			family.medium = enumFont(def.enum.medium, family.regular)
			family.bold = enumFont(def.enum.bold, family.medium or family.regular)
		end
		if family.regular or (family.face and Typo.faceSupported) then
			Typo.families[def.id] = family
			Typo.order[#Typo.order + 1] = def.id
		else
			Util.log("warn", "font family '" .. tostring(def.id) .. "' is not available in this client")
		end
	end
	if not Typo.families.gotham then
		local fallback = { id = "gotham", name = "Gotham", regular = Enum.Font.Gotham, medium = Enum.Font.GothamMedium, bold = Enum.Font.GothamBold }
		Typo.families.gotham = fallback
		table.insert(Typo.order, 1, "gotham")
	end
	Typo.family = Typo.families[Store.get("font")] or Typo.families[CONFIG.Fonts.Default] or Typo.families.gotham
	return Typo
end

function Typo.assign(obj, weight, size)
	local family = Typo.family
	local done = false
	if family.face and Typo.faceSupported then
		local ok = pcall(function()
			obj.FontFace = Font.new(family.face, fontWeight(weight))
		end)
		done = ok
	end
	if not done then
		local base = Typo.families.gotham
		obj.Font = family[weight] or family.regular or base[weight] or Enum.Font.Gotham
	end
	if size then
		obj.TextSize = size
	end
end

-- role: "display" | "title" | "heading" | "body" | "caption" | "label" | "button" | ...
function Typo.apply(obj, role, sizeOverride)
	local spec = Typo.roles[role] or Typo.roles.body
	local size = sizeOverride or spec.size
	Typo.registry[obj] = { role = role, size = size }
	Typo.assign(obj, spec.weight, size)
	obj.LineHeight = spec.lineHeight or 1 -- a little air between wrapped lines of descriptive text
	return obj
end

function Typo.setFamily(id)
	local family = Typo.families[id]
	if not family then
		return false
	end
	Typo.family = family
	for obj, info in pairs(Typo.registry) do
		local spec = Typo.roles[info.role] or Typo.roles.body
		pcall(Typo.assign, obj, spec.weight, info.size)
	end
	return true
end

function Typo.prune()
	for obj in pairs(Typo.registry) do
		if obj.Parent == nil then
			Typo.registry[obj] = nil
		end
	end
end

function Typo.list()
	local out = {}
	for _, id in ipairs(Typo.order) do
		out[#out + 1] = { id = id, label = Typo.families[id].name }
	end
	return out
end
end -- [02_motion_typo.lua]

do -- [03_theme.lua]

----------------------------------------------------------------------------------------------------
-- Theme: role-based palettes, live transitions, gradients and (optional) animated accents.
-- To add a theme, append one row to Theme.catalog. Only the roles you list are required:
--   Background, Panel, Card, Border, Accent, Text, Muted  (everything else is derived)
-- Optional roles: Accent2 (gradient partner), Shine (highlight), AccentSoft, Info ...
----------------------------------------------------------------------------------------------------
local function C(r, g, b)
	return Color3.fromRGB(r, g, b)
end

Theme.catalog = {
	-- the two palettes from the original VirexHub -------------------------------------------------
	{ id = "obsidian", name = "Obsidian", group = "Classic", colors = {
		Background = C(12, 15, 22), Panel = C(19, 23, 33), Card = C(26, 31, 43), Border = C(48, 57, 75),
		Accent = C(112, 97, 255), Accent2 = C(168, 148, 255), Shine = C(226, 220, 255), AccentSoft = C(47, 42, 87),
		Text = C(240, 242, 249), Muted = C(153, 162, 180),
	} },
	{ id = "deepteal", name = "Deep Teal", group = "Classic", colors = {
		Background = C(11, 18, 23), Panel = C(17, 27, 34), Card = C(23, 37, 45), Border = C(42, 65, 71),
		Accent = C(48, 195, 177), Accent2 = C(104, 232, 214), Shine = C(206, 255, 247), AccentSoft = C(29, 67, 67),
		Text = C(237, 245, 245), Muted = C(149, 171, 175),
	} },
	-- premium metals -----------------------------------------------------------------------------
	{ id = "silver", name = "Silver", group = "Premium", colors = {
		Background = C(13, 15, 19), Panel = C(20, 23, 29), Card = C(29, 33, 41), Border = C(62, 68, 80),
		Accent = C(206, 213, 226), Accent2 = C(146, 156, 176), Shine = C(255, 255, 255), AccentSoft = C(50, 55, 67),
		Text = C(238, 241, 246), Muted = C(150, 158, 172),
	} },
	{ id = "gold", name = "Gold", group = "Premium", colors = {
		Background = C(15, 12, 7), Panel = C(23, 18, 10), Card = C(33, 26, 14), Border = C(78, 62, 30),
		Accent = C(230, 184, 78), Accent2 = C(176, 128, 38), Shine = C(255, 238, 176), AccentSoft = C(68, 52, 22),
		Text = C(248, 242, 228), Muted = C(178, 164, 132),
	} },
	{ id = "diamond", name = "Diamond", group = "Premium", colors = {
		Background = C(5, 11, 22), Panel = C(10, 19, 33), Card = C(16, 29, 48), Border = C(36, 70, 104),
		Accent = C(96, 218, 255), Accent2 = C(36, 120, 214), Shine = C(235, 252, 255), AccentSoft = C(22, 56, 84),
		Text = C(236, 249, 255), Muted = C(138, 174, 196),
	} },
	{ id = "emerald", name = "Emerald", group = "Premium", colors = {
		Background = C(6, 15, 11), Panel = C(10, 24, 18), Card = C(15, 34, 26), Border = C(32, 76, 56),
		Accent = C(46, 204, 140), Accent2 = C(16, 140, 96), Shine = C(176, 255, 214), AccentSoft = C(18, 58, 42),
		Text = C(233, 248, 240), Muted = C(136, 172, 152),
	} },
	-- two-colour combinations -------------------------------------------------------------------
	{ id = "gold_black", name = "Gold + Black", group = "Combos", colors = {
		Background = C(4, 4, 4), Panel = C(11, 10, 8), Card = C(19, 17, 13), Border = C(70, 56, 26),
		Accent = C(232, 182, 72), Accent2 = C(140, 104, 30), Shine = C(255, 232, 160), AccentSoft = C(52, 41, 17),
		Text = C(250, 245, 232), Muted = C(158, 148, 126),
	} },
	{ id = "silver_blue", name = "Silver + Blue", group = "Combos", colors = {
		Background = C(8, 12, 22), Panel = C(14, 20, 35), Card = C(21, 29, 50), Border = C(50, 68, 104),
		Accent = C(202, 212, 230), Accent2 = C(70, 120, 255), Shine = C(240, 246, 255), AccentSoft = C(28, 44, 88),
		Text = C(240, 244, 252), Muted = C(144, 160, 188), Info = C(110, 160, 255),
	} },
	{ id = "diamond_purple", name = "Diamond + Purple", group = "Combos", colors = {
		Background = C(10, 7, 22), Panel = C(17, 12, 35), Card = C(26, 18, 52), Border = C(70, 50, 116),
		Accent = C(176, 136, 255), Accent2 = C(120, 214, 255), Shine = C(232, 246, 255), AccentSoft = C(50, 34, 96),
		Text = C(242, 238, 252), Muted = C(158, 146, 190),
	} },
	{ id = "emerald_black", name = "Emerald + Black", group = "Combos", colors = {
		Background = C(3, 7, 5), Panel = C(8, 14, 11), Card = C(13, 22, 17), Border = C(28, 62, 46),
		Accent = C(44, 214, 132), Accent2 = C(14, 120, 80), Shine = C(150, 255, 204), AccentSoft = C(12, 46, 32),
		Text = C(232, 246, 238), Muted = C(128, 160, 142),
	} },
}

Theme.defs = {}
Theme.byId = {}
Theme.live = {}
Theme.target = nil
Theme.id = nil
Theme.glass = 0
Theme.fxLevel = 0
Theme.listeners = {}
Theme.active = function()
	return true
end

-- These registries are strong on purpose (Roblox can drop the Lua wrapper of a live Instance, which
-- would silently unbind a weak key). Theme.prune() removes entries whose instance was destroyed.
local boundProps = {}    -- inst -> { [prop] = {role, mixRole, mixT} }
local alphaProps = {}    -- inst -> { kind }
local gradientBinds = {} -- UIGradient -> builder(live) -> ColorSequence
local fxItems = {}

function Theme.define(spec)
	local c = Util.copy(spec.colors)
	c.Accent2 = c.Accent2 or Util.lighten(c.Accent, 0.25)
	c.Shine = c.Shine or Util.lighten(c.Accent, 0.55)
	c.AccentSoft = c.AccentSoft or Util.mix(c.Card, c.Accent, 0.25)
	c.Elevated = c.Elevated or Util.mix(c.Card, c.Text, 0.06)
	c.Track = c.Track or Util.mix(c.Card, c.Text, 0.17)
	c.Faint = c.Faint or Util.mix(c.Muted, c.Card, 0.5)
	c.Danger = c.Danger or C(235, 87, 99)
	c.Green = c.Green or C(78, 202, 146)
	c.Warn = c.Warn or C(240, 178, 74)
	c.Info = c.Info or c.Accent
	c.OnAccent = c.OnAccent or Util.onColor(c.Accent)
	c.OnDanger = c.OnDanger or Util.onColor(c.Danger)
	c.Scrim = c.Scrim or C(0, 0, 0)
	local def = { id = spec.id, name = spec.name, group = spec.group or "Custom", colors = c }
	if Theme.byId[spec.id] then
		for i, existing in ipairs(Theme.defs) do
			if existing.id == spec.id then
				Theme.defs[i] = def
			end
		end
	else
		Theme.defs[#Theme.defs + 1] = def
	end
	Theme.byId[spec.id] = def
	return def
end

function Theme.init()
	Theme.defs, Theme.byId = {}, {}
	for _, spec in ipairs(Theme.catalog) do
		Theme.define(spec)
	end
	for role, color in pairs(Theme.defs[1].colors) do
		Theme.live[role] = color
	end
	return Theme
end

function Theme.color(role, mixRole, mixT)
	local live = Theme.live
	local base = live[role] or live.Text or Color3.new(1, 1, 1)
	if mixRole and mixT then
		return Util.mix(base, live[mixRole] or base, mixT)
	end
	return base
end

-- keep `inst[prop]` in sync with a theme role (optionally mixed toward a second role)
function Theme.bind(inst, prop, role, mixRole, mixT)
	local list = boundProps[inst]
	if not list then
		list = {}
		boundProps[inst] = list
	end
	list[prop] = { role = role, mixRole = mixRole, mixT = mixT }
	inst[prop] = Theme.color(role, mixRole, mixT)
	return inst
end

function Theme.unbind(inst, prop)
	local list = boundProps[inst]
	if list then
		list[prop] = nil
	end
end

-- changes the role of an existing binding and animates the property to the new colour
function Theme.tweenRole(inst, prop, role, duration, mixRole, mixT)
	local list = boundProps[inst]
	if not list then
		list = {}
		boundProps[inst] = list
	end
	list[prop] = { role = role, mixRole = mixRole, mixT = mixT }
	Motion.tween(inst, { [prop] = Theme.color(role, mixRole, mixT) }, duration or Motion.base)
end

local function glassFor(kind)
	local g = Theme.glass
	if kind == "bg" then
		return g
	elseif kind == "panel" then
		return g * 0.92
	elseif kind == "card" then
		return g * 0.6
	elseif kind == "input" then
		return g * 0.45
	end
	return 0
end

-- background surface whose transparency follows the "panel transparency" setting
function Theme.surface(inst, role, kind, mixRole, mixT)
	Theme.bind(inst, "BackgroundColor3", role, mixRole, mixT)
	alphaProps[inst] = { kind = kind }
	inst.BackgroundTransparency = glassFor(kind)
	return inst
end

function Theme.setGlass(value)
	Theme.glass = Util.clamp(value, 0, 0.6)
	for inst, info in pairs(alphaProps) do
		inst.BackgroundTransparency = glassFor(info.kind)
	end
end

function Theme.gradient(gradient, builder)
	gradientBinds[gradient] = builder
	gradient.Color = builder(Theme.live)
	return gradient
end

local function seq(points)
	local keys = {}
	for i, p in ipairs(points) do
		keys[i] = ColorSequenceKeypoint.new(p[1], p[2])
	end
	return ColorSequence.new(keys)
end

Theme.G = {
	accent = function(l)
		return seq({ { 0, l.Accent }, { 1, l.Accent2 } })
	end,
	metal = function(l)
		return seq({ { 0, l.Shine }, { 0.42, l.Accent }, { 1, l.Accent2 } })
	end,
	stroke = function(l)
		return seq({ { 0, l.Border }, { 0.25, l.Accent }, { 0.5, l.Border }, { 0.75, l.Accent2 }, { 1, l.Border } })
	end,
	aurora = function(l)
		return seq({
			{ 0, l.Background },
			{ 0.35, Util.mix(l.Background, l.Accent, 0.28) },
			{ 0.65, Util.mix(l.Background, l.Accent2, 0.22) },
			{ 1, l.Background },
		})
	end,
	sheen = function(l)
		return seq({ { 0, l.Text }, { 0.4, l.Text }, { 0.5, l.Shine }, { 0.6, l.Text }, { 1, l.Text } })
	end,
	glint = function(l)
		return seq({ { 0, l.Accent }, { 0.4, l.Accent }, { 0.5, l.Shine }, { 0.6, l.Accent }, { 1, l.Accent2 } })
	end,
}

function Theme.refresh()
	for inst, props in pairs(boundProps) do
		for prop, b in pairs(props) do
			inst[prop] = Theme.color(b.role, b.mixRole, b.mixT)
		end
	end
	for gradient, builder in pairs(gradientBinds) do
		gradient.Color = builder(Theme.live)
	end
end

local function fireTheme()
	local def = Theme.byId[Theme.id]
	local snapshot = {}
	for i, fn in ipairs(Theme.listeners) do
		snapshot[i] = fn
	end
	for _, fn in ipairs(snapshot) do
		Util.try("theme listener", fn, Theme.id, def)
	end
end

function Theme.onChange(fn)
	Theme.listeners[#Theme.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Theme.listeners, fn)
		if index then
			table.remove(Theme.listeners, index)
		end
	end
end

function Theme.apply(id, instant)
	local def = Theme.byId[id]
	if not def then
		return false
	end
	local first = Theme.id == nil
	Theme.id = id
	Store.set("theme", id, true)
	local from = Util.copy(Theme.live)
	local to = def.colors
	Theme.target = to
	if instant or first or Motion.reduced then
		Anim.remove("themelerp")
		for role, color in pairs(to) do
			Theme.live[role] = color
		end
		Theme.refresh()
	else
		local started = os.clock()
		Anim.add("themelerp", function()
			local a = Util.clamp((os.clock() - started) / 0.4, 0, 1)
			local e = Motion.ease.outCubic(a)
			for role, color in pairs(to) do
				Theme.live[role] = Util.mix(from[role] or color, color, e)
			end
			Theme.refresh()
			if a >= 1 then
				Anim.remove("themelerp")
			end
		end, 40)
	end
	fireTheme()
	return true
end

function Theme.prune()
	for inst in pairs(boundProps) do
		if inst.Parent == nil then
			boundProps[inst] = nil
		end
	end
	for inst in pairs(alphaProps) do
		if inst.Parent == nil then
			alphaProps[inst] = nil
		end
	end
	for gradient in pairs(gradientBinds) do
		if gradient.Parent == nil then
			gradientBinds[gradient] = nil
		end
	end
end

function Theme.current()
	return Theme.byId[Theme.id]
end

----------------------------------------------------------------------------------------------------
-- Animated accents (spin / sweep / pulse). Level 0 = off, 1 = subtle, 2 = full.
-- Effects are time-based, throttled to 30 Hz, and pause while the hub is hidden.
----------------------------------------------------------------------------------------------------
function Theme.fxSpin(inst, degreesPerSecond, minLevel)
	fxItems[#fxItems + 1] = { kind = "spin", inst = inst, speed = degreesPerSecond, minLevel = minLevel or 2 }
	Theme.syncFx()
end

function Theme.fxSweep(inst, period, rest, minLevel, phase)
	fxItems[#fxItems + 1] = {
		kind = "sweep", inst = inst, period = period, rest = rest or 0.5, minLevel = minLevel or 1, phase = phase or 0,
	}
	Theme.syncFx()
end

function Theme.fxPulse(inst, prop, a, b, period, minLevel)
	fxItems[#fxItems + 1] = {
		kind = "pulse", inst = inst, prop = prop, a = a, b = b, period = period, minLevel = minLevel or 2,
	}
	Theme.syncFx()
end

local function fxRest(item)
	pcall(function()
		if item.kind == "spin" then
			item.inst.Rotation = 0
		elseif item.kind == "sweep" then
			item.inst.Offset = Vector2.new(1, 0)
		elseif item.kind == "pulse" then
			item.inst[item.prop] = item.a
		end
	end)
end

local function fxTick(_, now)
	local level = Theme.fxLevel
	local i = #fxItems
	while i >= 1 do
		local item = fxItems[i]
		local inst = item.inst
		if inst.Parent == nil then
			table.remove(fxItems, i)
		elseif level >= item.minLevel then
			if item.kind == "spin" then
				inst.Rotation = (now * item.speed) % 360
			elseif item.kind == "sweep" then
				local phase = (now / item.period + item.phase) % 1
				local travel = 1 - item.rest
				local a = 1
				if phase < travel then
					a = phase / travel
				end
				inst.Offset = Vector2.new(-1 + 2 * Motion.ease.inOutSine(a), 0)
			else
				local s = 0.5 + 0.5 * math.sin(now * 2 * math.pi / item.period)
				inst[item.prop] = item.a + (item.b - item.a) * s
			end
		end
		i = i - 1
	end
end

function Theme.syncFx()
	local level = Store.get("fx")
	if Store.get("reducedMotion") or Store.get("lowPower") then
		level = 0
	end
	local changed = level ~= Theme.fxLevel
	Theme.fxLevel = level
	if level == 0 then
		Anim.remove("themefx")
		if changed then
			for _, item in ipairs(fxItems) do
				fxRest(item)
			end
		end
	elseif #fxItems > 0 then
		Anim.add("themefx", fxTick, 30, function()
			return Theme.active()
		end)
	end
end

function Theme.clearFx()
	fxItems = {}
	Anim.remove("themefx")
end
end -- [03_theme.lua]

do -- [04_sfx.lua]

----------------------------------------------------------------------------------------------------
-- Sfx: short UI sounds. Every asset is preloaded; anything that fails is skipped silently.
----------------------------------------------------------------------------------------------------
Sfx.holder = nil
Sfx.records = {}   -- asset id -> { id, sound, status = "pending" | "ok" | "failed" | "unknown", length }
Sfx.last = {}      -- event -> os.clock() of the last play (rate limit)
Sfx.tracked = {}

function Sfx.init()
	Sfx.records = {}
	if not SoundService then
		return false
	end
	local ok, holder = pcall(function()
		return Util.new("Folder", { Name = "VirexHubSfx" }, SoundService)
	end)
	if not ok then
		Util.log("warn", "sound holder could not be created: " .. tostring(holder))
		return false
	end
	Sfx.holder = holder
	for _, def in pairs(CONFIG.Sounds) do
		local id = def.id
		if type(id) == "string" and id ~= "" and not Sfx.records[id] then
			local created, sound = pcall(function()
				return Util.new("Sound", { Name = "Sfx" .. Util.hash(id), SoundId = id, Volume = 0 }, holder)
			end)
			if created then
				Sfx.records[id] = { id = id, sound = sound, status = "pending", length = 0 }
			end
		end
	end
	return true
end

-- Preloads every sound. Yields (call from a task). onProgress(done, total) reports REAL completions.
-- Returns loaded, failed, total. Never waits longer than `timeout` seconds.
function Sfx.preload(onProgress, timeout)
	local list, byId = {}, {}
	for id, record in pairs(Sfx.records) do
		list[#list + 1] = record.sound
		byId[id] = record
	end
	local total = #list
	if total == 0 then
		return 0, 0, 0
	end
	if not ContentProvider then
		for _, record in pairs(Sfx.records) do
			record.status = "unknown"
		end
		return 0, 0, total
	end

	local done, finished = 0, false
	task.spawn(function()
		local ok, err = pcall(ContentProvider.PreloadAsync, ContentProvider, list, function(contentId, status)
			done = done + 1
			local record = byId[contentId]
			if not record then
				for id, candidate in pairs(byId) do
					if string.find(tostring(contentId), id, 1, true) then
						record = candidate
					end
				end
			end
			if record then
				if tostring(status) == "Enum.AssetFetchStatus.Success" then
					record.status = "ok"
				else
					record.status = "failed"
				end
			end
			if onProgress then
				onProgress(done, total)
			end
		end)
		if not ok then
			Util.log("warn", "sound preload unavailable: " .. tostring(err))
			for _, record in pairs(Sfx.records) do
				if record.status == "pending" then
					record.status = "unknown"
				end
			end
		end
		finished = true
	end)

	local started = os.clock()
	while not finished and os.clock() - started < (timeout or 6) do
		task.wait(0.05)
	end

	local loaded, failed = 0, 0
	for _, record in pairs(Sfx.records) do
		local ok, length = pcall(function()
			return record.sound.TimeLength
		end)
		if ok and type(length) == "number" then
			record.length = length
		end
		if record.status == "pending" then
			-- preload never reported (timed out): trust the Sound's own state if it has one
			local okLoaded, isLoaded = pcall(function()
				return record.sound.IsLoaded
			end)
			if okLoaded and isLoaded then
				record.status = "ok"
			else
				record.status = finished and "failed" or "unknown"
			end
		end
		if record.status == "ok" then
			loaded = loaded + 1
		elseif record.status == "failed" then
			failed = failed + 1
			Util.log("warn", "sound asset failed to load: " .. record.id)
		end
	end
	return loaded, failed, total
end

local function fireSound(record, def, speed, master, tracked)
	if not Sfx.holder then
		return nil -- the hub was closed while a delayed part of a sound was still pending
	end
	local clone = record.sound:Clone()
	if not clone then
		return nil
	end
	clone.Volume = Util.clamp((def.volume or 0.4) * master * 1.5, 0, 1)
	clone.PlaybackSpeed = speed
	clone.Looped = false
	clone.Parent = Sfx.holder
	local played = pcall(clone.Play, clone)
	if not played and SoundService then
		played = pcall(SoundService.PlayLocalSound, SoundService, clone)
	end
	local length = record.length
	local life = (length > 0 and (length / math.max(speed, 0.1)) or 1.5) + 0.5
	local cut = def.maxSeconds
	if not cut and length > 2.5 then
		cut = 0.9
	end
	if cut and cut < life then
		task.delay(cut, function()
			if clone.Parent then
				Motion.tween(clone, { Volume = 0 }, 0.18)
			end
		end)
		life = cut + 0.3
	end
	task.delay(life, function()
		pcall(clone.Destroy, clone)
	end)
	if tracked then
		Sfx.tracked[#Sfx.tracked + 1] = clone
	end
	return clone
end

-- Plays a named UI sound. Respects the sound toggle, the volume setting and a per-event cooldown.
function Sfx.play(event, force)
	if not force and not Store.get("sound") then
		return false
	end
	local def = CONFIG.Sounds[event]
	if not def or type(def.id) ~= "string" or def.id == "" or not Sfx.holder then
		return false
	end
	local record = Sfx.records[def.id]
	if not record or record.status == "failed" then
		return false
	end
	local master = Store.get("volume")
	if master <= 0.001 then
		return false
	end
	local now = os.clock()
	local previous = Sfx.last[event]
	if previous and now - previous < (def.cooldown or 0.045) then
		return false
	end
	Sfx.last[event] = now

	local steps = def.chain or { { at = 0, speed = def.speed or 1 } }
	for _, step in ipairs(steps) do
		local speed = step.speed or def.speed or 1
		if step.at and step.at > 0 then
			task.delay(step.at, function()
				if Sfx.holder then
					Util.try("sfx " .. event, fireSound, record, def, speed, master, false)
				end
			end)
		else
			Util.try("sfx " .. event, fireSound, record, def, speed, master, false)
		end
	end
	return true
end

-- Plays a sound that the caller wants to be able to fade out (loading music). Returns a handle.
function Sfx.playTracked(event, force)
	local handle = { clone = nil }
	function handle.Stop(fadeSeconds)
		local clone = handle.clone
		if clone and clone.Parent then
			Motion.tween(clone, { Volume = 0 }, fadeSeconds or 0.3, Enum.EasingStyle.Quad)
			task.delay((fadeSeconds or 0.3) + 0.05, function()
				pcall(clone.Destroy, clone)
			end)
		end
		handle.clone = nil
	end
	if not force and not Store.get("sound") then
		return handle
	end
	local def = CONFIG.Sounds[event]
	local record = def and Sfx.records[def.id]
	if not record or record.status == "failed" or not Sfx.holder then
		return handle
	end
	local master = Store.get("volume")
	if master <= 0.001 then
		return handle
	end
	local ok, clone = Util.try("sfx " .. event, fireSound, record, def, def.speed or 1, master, true)
	if ok then
		handle.clone = clone
	end
	return handle
end

function Sfx.stopAll()
	for _, clone in ipairs(Sfx.tracked) do
		pcall(clone.Destroy, clone)
	end
	Sfx.tracked = {}
end

-- human-readable status for Settings > Sound
function Sfx.status()
	local events, ok, failed, pending = {}, 0, 0, 0
	for event, def in pairs(CONFIG.Sounds) do
		local record = def.id ~= "" and Sfx.records[def.id] or nil
		local state = "off"
		if record then
			state = record.status
		end
		events[#events + 1] = { event = event, id = def.id, state = state }
	end
	table.sort(events, function(a, b)
		return a.event < b.event
	end)
	for _, record in pairs(Sfx.records) do
		if record.status == "ok" then
			ok = ok + 1
		elseif record.status == "failed" then
			failed = failed + 1
		else
			pending = pending + 1
		end
	end
	return { events = events, ok = ok, failed = failed, pending = pending, total = ok + failed + pending }
end

function Sfx.summary()
	local s = Sfx.status()
	if not Sfx.holder then
		return "Audio is unavailable in this environment."
	end
	if s.total == 0 then
		return "No sound assets are configured."
	end
	if s.failed == 0 and s.pending == 0 then
		return string.format("All %d sound assets loaded.", s.total)
	end
	return string.format("%d of %d sound assets loaded; %d unavailable (silent).", s.ok, s.total, s.failed + s.pending)
end

function Sfx.destroy()
	Sfx.stopAll()
	if Sfx.holder then
		pcall(Sfx.holder.Destroy, Sfx.holder)
	end
	Sfx.holder = nil
	Sfx.records = {}
end
end -- [04_sfx.lua]

do -- [05_ui_base.lua]

----------------------------------------------------------------------------------------------------
-- UI kit, part 1: input sessions, drawn icons, pressable feedback, button, toggle, slider,
-- stepper, segmented selector. Every control is built as  Hit (TextButton, transparent)  +
-- Face (Frame, scaled on press) so the touch target can be larger than what is drawn.
----------------------------------------------------------------------------------------------------
UI.metrics = { buttonH = 34, radius = 9, rowH = 58, touchMin = 36 }
UI.sessions = {}
UI.layers = {}
UI.scale = function()
	return 1
end

local function isPress(input)
	local t = input.UserInputType
	return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end
UI.isPress = isPress

-- Follows ONE press until it ends. Used by sliders, window drag and press feedback so that a
-- missed InputEnded can never leave a control stuck in its pressed state.
function UI.watchInput(input, onMove, onEnd)
	local session = { done = false, conns = {} }
	local isTouch = input.UserInputType == Enum.UserInputType.Touch
	local function finish(cancelled)
		if session.done then
			return
		end
		session.done = true
		for _, connection in ipairs(session.conns) do
			connection:Disconnect()
		end
		session.conns = {}
		UI.sessions[session] = nil
		if onEnd then
			Util.try("input end", onEnd, cancelled)
		end
	end
	session.finish = finish
	session.conns[#session.conns + 1] = UserInputService.InputChanged:Connect(function(i)
		if session.done or not onMove then
			return
		end
		local t = i.UserInputType
		if i == input or (isTouch and t == Enum.UserInputType.Touch) or (not isTouch and t == Enum.UserInputType.MouseMovement) then
			onMove(i)
		end
	end)
	session.conns[#session.conns + 1] = UserInputService.InputEnded:Connect(function(i)
		local t = i.UserInputType
		if i == input or (isTouch and t == Enum.UserInputType.Touch) or (not isTouch and t == Enum.UserInputType.MouseButton1) then
			finish(false)
		end
	end)
	pcall(function()
		session.conns[#session.conns + 1] = input.Changed:Connect(function()
			local state = input.UserInputState
			if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
				finish(false)
			end
		end)
	end)
	UI.sessions[session] = true
	return session
end

function UI.endSessions()
	local list = {}
	for session in pairs(UI.sessions) do
		list[#list + 1] = session
	end
	for _, session in ipairs(list) do
		session.finish(true)
	end
end

function UI.findScroller(inst)
	local node = inst.Parent
	while node do
		if node:IsA("ScrollingFrame") then
			return node
		end
		node = node.Parent
	end
	return nil
end

function UI.scrollIntoView(inst)
	local scroller = UI.findScroller(inst)
	if not scroller then
		return
	end
	local s = UI.scale()
	local rel = (inst.AbsolutePosition.Y - scroller.AbsolutePosition.Y) / s + scroller.CanvasPosition.Y
	Motion.tween(scroller, { CanvasPosition = Vector2.new(0, math.max(0, rel - 10)) }, 0.25)
end

-- quick horizontal nudge used for "that control is unavailable" feedback
function UI.shake(inst)
	if Motion.reduced or not inst or not inst.Parent then
		return
	end
	local home = inst.Position
	local function at(dx)
		return UDim2.new(home.X.Scale, home.X.Offset + dx, home.Y.Scale, home.Y.Offset)
	end
	Motion.tween(inst, { Position = at(4) }, 0.05, Enum.EasingStyle.Quad, nil, function()
		Motion.tween(inst, { Position = at(-4) }, 0.07, Enum.EasingStyle.Quad, nil, function()
			Motion.tween(inst, { Position = home }, 0.08, Enum.EasingStyle.Quad)
		end)
	end)
end

----------------------------------------------------------------------------------------------------
-- icons drawn from frames (no image assets, no font glyph dependencies)
----------------------------------------------------------------------------------------------------
local ICONS = {}

ICONS.grid = function(g)
	g.box(5.5, 5.5, 7, 7, 2)
	g.box(14.5, 5.5, 7, 7, 2)
	g.box(5.5, 14.5, 7, 7, 2)
	g.box(14.5, 14.5, 7, 7, 2)
end
ICONS.user = function(g)
	g.dot(10, 6.2, 7)
	g.box(10, 15.2, 14, 6.5, 3.2)
end
ICONS.sparkle = function(g)
	g.bar(10, 10, 2, 18)
	g.bar(10, 10, 18, 2)
	g.bar(10, 10, 2, 12, 45)
	g.bar(10, 10, 2, 12, -45)
	g.dot(10, 10, 5)
end
ICONS.image = function(g)
	g.outline(10, 10, 17, 14, 3, 1.7)
	g.dot(7.4, 7.6, 3.2)
	g.bar(12.6, 12.4, 8, 1.8, -38)
end
ICONS.sliders = function(g)
	g.bar(10, 5, 16, 1.8)
	g.bar(10, 10, 16, 1.8)
	g.bar(10, 15, 16, 1.8)
	g.dot(6, 5, 4.6)
	g.dot(13.5, 10, 4.6)
	g.dot(8.5, 15, 4.6)
end
ICONS.gear = function(g)
	g.ring(10, 10, 11, 2.2)
	g.dot(10, 10, 3.2)
	for i = 0, 7 do
		local a = i * math.pi / 4
		g.bar(10 + 7 * math.sin(a), 10 - 7 * math.cos(a), 2.6, 3.4, i * 45)
	end
end
ICONS.close = function(g)
	g.bar(10, 10, 14, 2, 45)
	g.bar(10, 10, 14, 2, -45)
end
ICONS.minus = function(g)
	g.bar(10, 10, 12, 2)
end
ICONS.plus = function(g)
	g.bar(10, 10, 12, 2)
	g.bar(10, 10, 2, 12)
end
ICONS.restore = function(g)
	g.outline(10, 10, 11.5, 11.5, 2, 1.8)
end
ICONS.chevron = function(g)
	g.bar(7.6, 9.4, 7, 2, 45)
	g.bar(12.4, 9.4, 7, 2, -45)
end
ICONS.check = function(g)
	g.bar(6.5, 12.1, 5, 2.2, 45)
	g.bar(11.8, 10, 10.6, 2.2, -47)
end
ICONS.bang = function(g)
	g.bar(10, 7.4, 2.6, 8.6)
	g.dot(10, 14.8, 3)
end
ICONS.info = function(g)
	g.dot(10, 5.4, 3)
	g.bar(10, 11.8, 2.6, 7.6)
end
ICONS.dots = function(g)
	g.dot(4.5, 10, 3.2)
	g.dot(10, 10, 3.2)
	g.dot(15.5, 10, 3.2)
end
ICONS.logo = function(g)
	-- the VIREX mark: a bold "V" made of two bars with a small diamond above it
	g.bar(6.6, 9.4, 3, 12.6, -24)
	g.bar(13.4, 9.4, 3, 12.6, 24)
	g.bar(10, 3.6, 3.2, 3.2, 45)
end

ICONS.scripts = function(g)
	-- "</>": two angle brackets and a slash
	g.bar(5.4, 7.5, 6.6, 1.9, -49)
	g.bar(5.4, 12.5, 6.6, 1.9, 49)
	g.bar(14.6, 7.5, 6.6, 1.9, 49)
	g.bar(14.6, 12.5, 6.6, 1.9, -49)
	g.bar(10, 10, 1.8, 11, 20)
end
ICONS.star = function(g)
	-- five arms around a centre disc; the colour (Muted / Warn) tells empty from filled
	g.dot(10, 10.6, 7)
	for i = 0, 4 do
		local a = i * 2 * math.pi / 5
		g.bar(10 + 4.2 * math.sin(a), 10.6 - 4.2 * math.cos(a), 3.2, 8.4, i * 72)
	end
end

-- returns { Instance, SetRole(role, seconds) }
function UI.icon(name, parent, size, role, o)
	o = o or {}
	local S = size or 20
	local k = S / 20
	local builder = ICONS[name] or ICONS.dots
	local root = Util.new("Frame", {
		Name = "Icon_" .. name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(S, S),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
		Rotation = o.rotation or 0,
		ZIndex = o.zindex or 1,
	}, parent)
	local pieces = {}
	local currentRole = role or "Text"

	local function register(inst, prop)
		pieces[#pieces + 1] = { inst = inst, prop = prop }
		Theme.bind(inst, prop, currentRole)
	end
	local function place(inst, cx, cy, w, h, rot)
		inst.AnchorPoint = Vector2.new(0.5, 0.5)
		inst.Position = UDim2.fromOffset(cx * k, cy * k)
		inst.Size = UDim2.fromOffset(math.max(1, w * k), math.max(1, h * k))
		inst.Rotation = rot or 0
		inst.ZIndex = root.ZIndex
	end
	local g = {}
	function g.bar(cx, cy, w, h, rot)
		local f = Util.new("Frame", { BorderSizePixel = 0 }, root)
		place(f, cx, cy, w, h, rot)
		Util.new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
		register(f, "BackgroundColor3")
	end
	function g.dot(cx, cy, d)
		g.bar(cx, cy, d, d, 0)
	end
	function g.box(cx, cy, w, h, r)
		local f = Util.new("Frame", { BorderSizePixel = 0 }, root)
		place(f, cx, cy, w, h, 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0, math.max(0, r * k)) }, f)
		register(f, "BackgroundColor3")
	end
	function g.ring(cx, cy, d, thickness)
		local f = Util.new("Frame", { BorderSizePixel = 0, BackgroundTransparency = 1 }, root)
		place(f, cx, cy, d, d, 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
		local stroke = Util.new("UIStroke", { Thickness = math.max(1, thickness * k), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		register(stroke, "Color")
	end
	function g.outline(cx, cy, w, h, r, thickness)
		local f = Util.new("Frame", { BorderSizePixel = 0, BackgroundTransparency = 1 }, root)
		place(f, cx, cy, w, h, 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0, math.max(0, r * k)) }, f)
		local stroke = Util.new("UIStroke", { Thickness = math.max(1, thickness * k), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		register(stroke, "Color")
	end
	builder(g)

	local api = { Instance = root }
	function api.SetRole(newRole, seconds)
		currentRole = newRole
		for _, piece in ipairs(pieces) do
			if seconds and seconds > 0 then
				Theme.tweenRole(piece.inst, piece.prop, newRole, seconds)
			else
				Theme.bind(piece.inst, piece.prop, newRole)
			end
		end
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- pressable feedback: hover / press overlay + press scale. Returns a state table.
----------------------------------------------------------------------------------------------------
function UI.pressable(hit, face, o)
	o = o or {}
	local state = { pressed = false, hover = false, dragged = false, disabled = false }
	local overlay = Util.new("Frame", {
		Name = "Fx",
		Active = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = face.ZIndex + 4,
	}, face)
	Theme.bind(overlay, "BackgroundColor3", o.overlayRole or "Text")
	if o.radius then
		Util.corner(overlay, o.radius)
	end
	local scaler = Util.new("UIScale", { Scale = 1 }, face)

	local function render()
		local alpha, scale = 1, 1
		if state.disabled then
			alpha = 1
		elseif state.pressed then
			alpha, scale = o.pressAlpha or 0.82, o.pressScale or 0.965
		elseif state.hover then
			alpha = o.hoverAlpha or 0.92
		end
		Motion.tween(overlay, { BackgroundTransparency = alpha }, state.pressed and 0.06 or 0.16)
		if state.pressed then
			Motion.tween(scaler, { Scale = scale }, 0.07)
		else
			Motion.tween(scaler, { Scale = scale }, 0.22, Enum.EasingStyle.Back)
		end
	end
	state.render = render

	hit.InputBegan:Connect(function(input)
		if state.disabled or not isPress(input) then
			return
		end
		state.pressed = true
		state.dragged = false
		local origin = input.Position
		render()
		UI.watchInput(input, function(i)
			if state.dragged then
				return
			end
			local d = i.Position - origin
			if math.abs(d.X) + math.abs(d.Y) > 14 then
				state.dragged = true
				state.pressed = false
				render()
			end
		end, function()
			state.pressed = false
			render()
		end)
	end)

	if UserInputService.MouseEnabled then
		hit.MouseEnter:Connect(function()
			state.hover = true
			render()
		end)
		hit.MouseLeave:Connect(function()
			state.hover = false
			state.pressed = false
			render()
		end)
	end

	-- true when this activation should be ignored because the finger dragged (scroll gesture)
	function state.wasDrag()
		if state.dragged then
			state.dragged = false
			return true
		end
		return false
	end
	return state
end

----------------------------------------------------------------------------------------------------
-- button
----------------------------------------------------------------------------------------------------
-- o: parent, text, kind ("primary" | "secondary" | "ghost" | "danger"), width, height, size,
--    anchor, position, order, icon, small, sound, cooldown, onClick(api)
function UI.button(o)
	local kind = o.kind or "secondary"
	local radius = o.radius or UI.metrics.radius
	local hit = Util.new("TextButton", {
		Name = o.name or "Button",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(o.width or 100, o.height or UI.metrics.buttonH),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
		ZIndex = o.zindex or 1,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face",
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		ZIndex = hit.ZIndex,
	}, hit)
	Util.corner(face, radius)

	local textRole, overlayRole = "Text", "Text"
	if kind == "primary" then
		face.BackgroundColor3 = Color3.new(1, 1, 1)
		local gradient = Util.new("UIGradient", { Rotation = 25 }, face)
		Theme.gradient(gradient, Theme.G.accent)
		textRole, overlayRole = "OnAccent", "OnAccent"
	elseif kind == "danger" then
		Theme.bind(face, "BackgroundColor3", "Danger")
		textRole, overlayRole = "OnDanger", "OnDanger"
	elseif kind == "ghost" then
		face.BackgroundTransparency = 1
		Theme.bind(Util.stroke(face, nil, 1), "Color", "Border")
	else
		Theme.bind(face, "BackgroundColor3", "AccentSoft")
	end

	local label = Util.new("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = o.text or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = hit.ZIndex + 1,
	}, face)
	Util.pad(label, o.icon and 30 or 8, 0, 8, 0)
	Typo.apply(label, o.small and "buttonSmall" or "button")
	Theme.bind(label, "TextColor3", textRole)

	local api = { Instance = hit, Face = face, Label = label, enabled = true, last = 0, kind = kind }

	-- icon (optional). SetIcon(name) swaps it later, e.g. minimize <-> restore. o.iconRole overrides its colour.
	local function buildIcon(name)
		if api.Icon then
			api.Icon.Instance:Destroy()
			api.Icon = nil
		end
		if not name then
			return
		end
		local iconOnly = (o.text == nil or o.text == "")
		api.Icon = UI.icon(name, face, 16, o.iconRole or textRole, {
			anchor = iconOnly and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5),
			position = iconOnly and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 10, 0.5, 0),
			zindex = hit.ZIndex + 1,
		})
	end
	buildIcon(o.icon)
	api.SetIcon = buildIcon

	local state = UI.pressable(hit, face, { radius = radius, overlayRole = overlayRole })

	function api.SetText(text)
		label.Text = tostring(text)
	end
	function api.SetEnabled(enabled, reason)
		api.enabled = enabled and true or false
		api.reason = reason
		state.disabled = not api.enabled
		Motion.tween(label, { TextTransparency = api.enabled and 0 or 0.55 }, 0.15)
		Motion.tween(face, { BackgroundTransparency = (api.enabled or kind == "ghost") and (kind == "ghost" and 1 or 0) or 0.45 }, 0.15)
		state.render()
	end
	function api.SetBusy(busy, text)
		api.busy = busy and true or false
		if busy then
			api.idleText = api.idleText or label.Text
			label.Text = text or "Working..."
			api.SetEnabled(false)
		else
			if api.idleText then
				label.Text = api.idleText
				api.idleText = nil
			end
			api.SetEnabled(true)
		end
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			if api.reason and os.clock() - (api.lastReason or 0) > 2 then
				api.lastReason = os.clock()
				Notify.warn("Unavailable", api.reason)
			end
			return
		end
		local now = os.clock()
		if now - api.last < (o.cooldown or 0.2) then
			return
		end
		api.last = now
		Sfx.play(o.sound or "click")
		if o.onClick then
			Util.try("button " .. tostring(o.text), o.onClick, api)
		end
	end)
	return api
end

----------------------------------------------------------------------------------------------------
-- toggle (switch)
----------------------------------------------------------------------------------------------------
-- o: parent, value, onChange(value), anchor, position, order, name
function UI.toggle(o)
	local value = o.value and true or false
	local hit = Util.new("TextButton", {
		Name = o.name or "Toggle",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(56, 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(46, 26), BackgroundTransparency = 1, BorderSizePixel = 0,
	}, hit)
	local track = Util.new("Frame", { Name = "Track", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, face)
	Util.round_corner(track)
	Theme.bind(track, "BackgroundColor3", "Track")
	local trackStroke = Util.stroke(track, nil, 1, 0.35)
	Theme.bind(trackStroke, "Color", "Border")

	local fill = Util.new("Frame", {
		Name = "On", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = value and 0 or 1, ZIndex = 2,
	}, face)
	Util.round_corner(fill)
	local gradient = Util.new("UIGradient", { Rotation = 0 }, fill)
	Theme.gradient(gradient, Theme.G.accent)

	local knob = Util.new("Frame", {
		Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(20, 20), BorderSizePixel = 0, ZIndex = 3,
		Position = UDim2.new(0, value and 23 or 3, 0.5, 0),
	}, face)
	Util.round_corner(knob)
	Theme.bind(knob, "BackgroundColor3", value and "OnAccent" or "Muted")

	local state = UI.pressable(hit, face, { radius = 13, overlayRole = "Text", pressScale = 0.97, hoverAlpha = 0.95, pressAlpha = 0.9 })
	local api = { Instance = hit, enabled = true, last = 0 }

	local function render(animate)
		local dur = animate and 0.2 or 0
		Motion.tween(fill, { BackgroundTransparency = value and 0 or 1 }, dur)
		Motion.tween(knob, { Position = UDim2.new(0, value and 23 or 3, 0.5, 0) }, dur, Enum.EasingStyle.Back)
		Theme.tweenRole(knob, "BackgroundColor3", value and "OnAccent" or "Muted", dur)
	end

	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = newValue and true or false
		if newValue == value then
			return
		end
		value = newValue
		render(true)
		if not silent and o.onChange then
			Util.try("toggle onChange", o.onChange, value)
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		state.disabled = not api.enabled
		track.BackgroundTransparency = api.enabled and 0 or 0.5
		knob.BackgroundTransparency = api.enabled and 0 or 0.5
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			return
		end
		local now = os.clock()
		if now - api.last < 0.14 then
			return
		end
		api.last = now
		local target = not value
		Sfx.play(target and "toggleOn" or "toggleOff")
		api.Set(target, false)
	end)
	return api
end

----------------------------------------------------------------------------------------------------
-- slider
----------------------------------------------------------------------------------------------------
-- o: parent, min, max, step, value, width, format(v) -> string, onChange(value, final), anchor, position, order
function UI.slider(o)
	local min, max, step = o.min or 0, o.max or 1, o.step or 0.01
	local value = Util.clamp(o.value or min, min, max)
	local width = o.width or 200
	local format = o.format or function(v)
		return Util.percent((v - min) / (max - min)) .. "%"
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Slider", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local labelWidth = 46
	local track = Util.new("Frame", {
		Name = "Track", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.new(1, -(labelWidth + 22), 0, 6), BorderSizePixel = 0,
	}, holder)
	Util.round_corner(track)
	Theme.bind(track, "BackgroundColor3", "Track")
	local fill = Util.new("Frame", {
		Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
	}, track)
	Util.round_corner(fill)
	Theme.gradient(Util.new("UIGradient", { Rotation = 0 }, fill), Theme.G.accent)
	local knob = Util.new("Frame", {
		Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(18, 18), BorderSizePixel = 0, ZIndex = 3,
	}, track)
	Util.round_corner(knob)
	Theme.bind(knob, "BackgroundColor3", "Text")
	Theme.bind(Util.stroke(knob, nil, 2, 0), "Color", "Accent")
	local readout = Util.new("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(labelWidth, 20), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
	}, holder)
	Typo.apply(readout, "caption")
	Theme.bind(readout, "TextColor3", "Muted")

	local hit = Util.new("TextButton", {
		Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -(labelWidth + 4), 1, 0), ZIndex = 5,
	}, holder)

	local api = { Instance = holder, enabled = true }
	local dragging = false
	local lastTick = 0

	local function render(animate)
		local alpha = (value - min) / (max - min)
		local dur = animate and 0.12 or 0
		Motion.tween(fill, { Size = UDim2.fromScale(alpha, 1) }, dur)
		Motion.tween(knob, { Position = UDim2.fromScale(alpha, 0.5) }, dur)
		readout.Text = format(value)
	end

	local function snap(raw)
		local snapped = min + Util.round(raw - min, step)
		snapped = math.floor(snapped * 10000 + 0.5) / 10000
		return Util.clamp(snapped, min, max)
	end

	local function setFromX(x, final)
		local width_ = track.AbsoluteSize.X
		if width_ <= 0 then
			return
		end
		local alpha = Util.clamp((x - track.AbsolutePosition.X) / width_, 0, 1)
		local newValue = snap(min + alpha * (max - min))
		if newValue ~= value then
			value = newValue
			render(false)
			local now = os.clock()
			if now - lastTick > 0.07 then
				lastTick = now
				Sfx.play("select")
			end
			if o.onChange then
				Util.try("slider onChange", o.onChange, value, false)
			end
		end
	end

	-- Touch gestures are disambiguated so that scrolling a page never moves a slider by accident (same idea as Android's
	-- SeekBar inside a scrolling list): a touch decides after ~8 px of movement -- sideways = slider drag, vertical = the page
	-- scrolls. Pressing ON the knob never makes it jump (it keeps its offset to the finger); pressing on the bare track and
	-- dragging sideways, or just tapping, moves the knob to that spot. A mouse press acts at once.
	hit.InputBegan:Connect(function(input)
		if not api.enabled or dragging or not isPress(input) then
			return
		end
		dragging = true
		local isTouch = input.UserInputType == Enum.UserInputType.Touch
		local scroller = UI.findScroller(holder)
		local origin = input.Position
		local decided = not isTouch
		local engaged = false
		local knobX = knob.AbsolutePosition.X + knob.AbsoluteSize.X / 2
		local grabOffset = 0
		if math.abs(origin.X - knobX) <= 20 then
			grabOffset = origin.X - knobX
		end
		local function engage()
			if engaged then
				return
			end
			engaged = true
			decided = true
			if scroller then
				scroller.ScrollingEnabled = false
			end
			Motion.tween(knob, { Size = UDim2.fromOffset(22, 22) }, 0.1)
		end
		if not isTouch then
			engage()
			setFromX(origin.X - grabOffset)
		end
		UI.watchInput(input, function(i)
			local delta = i.Position - origin
			if not decided then
				if math.abs(delta.X) + math.abs(delta.Y) < 8 then
					return
				end
				decided = true
				if math.abs(delta.X) >= math.abs(delta.Y) then
					engage()
					setFromX(i.Position.X - grabOffset)
				end
				return
			end
			if engaged then
				setFromX(i.Position.X - grabOffset)
			end
		end, function(cancelled)
			dragging = false
			if not decided and not cancelled then
				engage()
				setFromX(origin.X - grabOffset) -- a tap
			end
			if engaged then
				if scroller then
					scroller.ScrollingEnabled = true
				end
				Motion.tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.15)
				if o.onChange then
					Util.try("slider onChange", o.onChange, value, true)
				end
			end
		end)
	end)

	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = snap(newValue)
		if newValue == value then
			return
		end
		value = newValue
		render(true)
		if not silent and o.onChange then
			Util.try("slider onChange", o.onChange, value, true)
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		holder.BackgroundTransparency = 1
		track.BackgroundTransparency = api.enabled and 0 or 0.5
		knob.BackgroundTransparency = api.enabled and 0 or 0.5
	end
	render(false)
	return api
end

----------------------------------------------------------------------------------------------------
-- stepper:  [-]  value  [+]
----------------------------------------------------------------------------------------------------
-- o: parent, min, max, step, value, format(v), onChange(v), anchor, position, order
function UI.stepper(o)
	local min, max, step = o.min, o.max, o.step
	local value = Util.clamp(o.value or min, min, max)
	local format = o.format or function(v)
		return tostring(v)
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Stepper", BackgroundTransparency = 1, Size = UDim2.fromOffset(150, 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local readout = Util.new("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 56, 0, 24), BackgroundTransparency = 1, Text = "",
	}, holder)
	Typo.apply(readout, "heading")
	Theme.bind(readout, "TextColor3", "Text")
	local api = { Instance = holder }
	local function render()
		readout.Text = format(value)
	end
	local function change(delta)
		local newValue = Util.clamp(Util.round(value + delta, step), min, max)
		newValue = Util.round(newValue * 1000) / 1000
		if newValue ~= value then
			value = newValue
			render()
			if o.onChange then
				Util.try("stepper onChange", o.onChange, value)
			end
		else
			Sfx.play("warning")
			UI.shake(holder)
		end
	end
	local minus = UI.button({
		parent = holder, text = "", icon = "minus", width = 42, height = 34, anchor = Vector2.new(0, 0.5),
		position = UDim2.new(0, 0, 0.5, 0), cooldown = 0.08, name = "Minus", onClick = function()
			change(-step)
		end,
	})
	minus.Label.Text = ""
	local plus = UI.button({
		parent = holder, text = "", icon = "plus", width = 42, height = 34, anchor = Vector2.new(1, 0.5),
		position = UDim2.new(1, 0, 0.5, 0), cooldown = 0.08, name = "Plus", onClick = function()
			change(step)
		end,
	})
	plus.Label.Text = ""
	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = Util.clamp(newValue, min, max)
		if newValue ~= value then
			value = newValue
			render()
			if not silent and o.onChange then
				Util.try("stepper onChange", o.onChange, value)
			end
		end
	end
	render()
	return api
end

----------------------------------------------------------------------------------------------------
-- segmented selector (2-4 short options)
----------------------------------------------------------------------------------------------------
-- o: parent, options = { {id=, label=}, ... }, value, onChange(id), width, height, anchor, position, order
function UI.segmented(o)
	local options = o.options
	local count = #options
	local index = 1
	for i, opt in ipairs(options) do
		if opt.id == o.value then
			index = i
		end
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Segmented", BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(o.width or 220, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	Util.corner(holder, 10)
	Theme.bind(holder, "BackgroundColor3", "Track", "Panel", 0.4)
	Theme.bind(Util.stroke(holder, nil, 1, 0.4), "Color", "Border")

	local pill = Util.new("Frame", {
		Name = "Pill", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2,
		Size = UDim2.new(1 / count, -6, 1, -6), Position = UDim2.new((index - 1) / count, 3, 0, 3),
	}, holder)
	Util.corner(pill, 8)
	Theme.gradient(Util.new("UIGradient", { Rotation = 20 }, pill), Theme.G.accent)

	local buttons, labels = {}, {}
	local api = { Instance = holder, enabled = true, last = 0 }

	local function paint(animate)
		local dur = animate and 0.22 or 0
		Motion.tween(pill, { Position = UDim2.new((index - 1) / count, 3, 0, 3) }, dur, Enum.EasingStyle.Quart)
		for i, label in ipairs(labels) do
			Theme.tweenRole(label, "TextColor3", i == index and "OnAccent" or "Muted", dur)
		end
	end

	for i, opt in ipairs(options) do
		local hit = Util.new("TextButton", {
			Name = "Opt_" .. tostring(opt.id), Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1 / count, 0, 1, 0), Position = UDim2.new((i - 1) / count, 0, 0, 0), ZIndex = 3,
		}, holder)
		local label = Util.new("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = opt.label, ZIndex = 4,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, hit)
		Util.pad(label, 4, 0, 4, 0)
		Typo.apply(label, "buttonSmall")
		Theme.bind(label, "TextColor3", i == index and "OnAccent" or "Muted")
		buttons[i], labels[i] = hit, label
		local state = { dragged = false }
		hit.InputBegan:Connect(function(input)
			if isPress(input) then
				state.dragged = false
				local origin = input.Position
				UI.watchInput(input, function(ev)
					local d = ev.Position - origin
					if math.abs(d.X) + math.abs(d.Y) > 14 then
						state.dragged = true
					end
				end, nil)
			end
		end)
		hit.Activated:Connect(function()
			if state.dragged then
				state.dragged = false
				return
			end
			if not api.enabled then
				UI.shake(holder)
				return
			end
			if i == index then
				return
			end
			local now = os.clock()
			if now - api.last < 0.12 then
				return
			end
			api.last = now
			index = i
			Sfx.play("select")
			paint(true)
			if o.onChange then
				Util.try("segmented onChange", o.onChange, opt.id)
			end
		end)
	end

	function api.Get()
		return options[index].id
	end
	function api.Set(id, silent)
		for i, opt in ipairs(options) do
			if opt.id == id and i ~= index then
				index = i
				paint(true)
				if not silent and o.onChange then
					Util.try("segmented onChange", o.onChange, id)
				end
				return
			end
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		for _, label in ipairs(labels) do
			label.TextTransparency = api.enabled and 0 or 0.55
		end
	end
	paint(false)
	return api
end
end -- [05_ui_base.lua]

do -- [06_ui_more.lua]

----------------------------------------------------------------------------------------------------
-- UI kit, part 2: cards, sections, pages, chips, stat tiles, dropdown, text input, confirm dialog
----------------------------------------------------------------------------------------------------
function UI.prune()
	Theme.prune()
	Typo.prune()
end

-- Card with title + description on the left and an optional control area on the right.
-- o: parent, title, desc, order, control (px reserved on the right), stack (controls below the text),
--    controlHeight (stack mode), minHeight, name
-- returns { Instance, Title, Desc, Controls, SetTitle, SetDesc }
function UI.card(o)
	local controlWidth = o.control or 0
	local card = Util.new("Frame", {
		Name = o.name or "Card",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, o.minHeight or UI.metrics.rowH),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = o.order or 0,
	}, o.parent)
	Theme.surface(card, "Card", "card")
	Util.corner(card, 12)
	Theme.bind(Util.stroke(card, nil, 1, 0.15), "Color", "Border")
	Util.pad(card, 14, 11, 12, 11)

	local inner = Util.new("Frame", {
		Name = "Inner", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	}, card)
	Util.list(inner, 9)

	local sideControls = controlWidth > 0 and not o.stack
	local textBlock = Util.new("Frame", {
		Name = "Text", BackgroundTransparency = 1, LayoutOrder = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, sideControls and -(controlWidth + 12) or 0, 0, 0),
	}, inner)
	Util.list(textBlock, 3)

	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, LayoutOrder = 1, Text = o.title or "",
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, textBlock)
	Typo.apply(title, "heading")
	Theme.bind(title, "TextColor3", "Text")

	local desc = Util.new("TextLabel", {
		Name = "Desc", BackgroundTransparency = 1, LayoutOrder = 2, Text = o.desc or "",
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Visible = (o.desc ~= nil and o.desc ~= ""),
	}, textBlock)
	Typo.apply(desc, "caption")
	Theme.bind(desc, "TextColor3", "Muted")

	local controlHeight = o.controlHeight or 38
	local controls
	if o.stack then
		controls = Util.new("Frame", {
			Name = "Controls", BackgroundTransparency = 1, LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, controlHeight),
		}, inner)
	else
		controls = Util.new("Frame", {
			Name = "Controls", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, controlWidth, 0, controlHeight),
		}, card)
	end

	local api = {
		Instance = card, Title = title, Desc = desc, Controls = controls,
		controlWidth = controlWidth, stacked = o.stack and true or false,
	}
	function api.SetTitle(text)
		title.Text = tostring(text)
	end
	function api.SetDesc(text)
		desc.Text = tostring(text)
		desc.Visible = text ~= nil and text ~= ""
	end
	-- Moves the controls below the text (narrow windows) or back to the right side (wide windows).
	function api.SetStacked(flag)
		flag = flag and true or false
		if controlWidth <= 0 or api.stacked == flag then
			return
		end
		api.stacked = flag
		if flag then
			controls.Parent = inner
			controls.LayoutOrder = 2
			controls.AnchorPoint = Vector2.new(0, 0)
			controls.Position = UDim2.new(0, 0, 0, 0)
			controls.Size = UDim2.new(1, 0, 0, controlHeight)
			textBlock.Size = UDim2.new(1, 0, 0, 0)
		else
			controls.Parent = card
			controls.AnchorPoint = Vector2.new(1, 0.5)
			controls.Position = UDim2.new(1, 0, 0.5, 0)
			controls.Size = UDim2.new(0, controlWidth, 0, controlHeight)
			textBlock.Size = UDim2.new(1, -(controlWidth + 12), 0, 0)
		end
	end
	return api
end

function UI.section(parent, text, order)
	local row = Util.new("Frame", {
		Name = "Section", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = order or 0,
	}, parent)
	local bar = Util.new("Frame", {
		Name = "Mark", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 2, 1, -3), Size = UDim2.fromOffset(3, 12),
		BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
	}, row)
	Util.round_corner(bar)
	Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, bar), Theme.G.accent)
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, 0),
		Size = UDim2.new(1, -12, 0, 18), Text = string.upper(text), TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	Typo.apply(label, "label")
	Theme.bind(label, "TextColor3", "Muted")
	return row
end

function UI.page(parent, name)
	local page = Util.new("ScrollingFrame", {
		Name = name .. "Page",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.35,
		Visible = false,
	}, parent)
	Theme.bind(page, "ScrollBarImageColor3", "Accent")
	Util.pad(page, 0, 2, 7, 16)
	Util.list(page, 8)
	return page
end

-- small status pill. o: parent, text, role ("Green" | "Warn" | "Danger" | "Accent" | "Muted"), order, anchor, position
function UI.chip(o)
	local role = o.role or "Accent"
	local chip = Util.new("Frame", {
		Name = "Chip", BorderSizePixel = 0, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = o.order or 0, AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0),
	}, o.parent)
	Util.round_corner(chip)
	Theme.bind(chip, "BackgroundColor3", "Card", role, 0.2)
	Util.pad(chip, 9, 0, 9, 0)
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
		Text = o.text or "",
	}, chip)
	Typo.apply(label, "label", 10)
	Theme.bind(label, "TextColor3", role)
	local api = { Instance = chip }
	function api.Set(text, newRole)
		label.Text = tostring(text)
		if newRole then
			Theme.bind(chip, "BackgroundColor3", "Card", newRole, 0.2)
			Theme.tweenRole(label, "TextColor3", newRole, 0.2)
		end
	end
	return api
end

-- compact value tile (FPS, ping ...). o: parent, label, value, order, size
function UI.statTile(o)
	local tile = Util.new("Frame", {
		Name = "Stat", BorderSizePixel = 0, LayoutOrder = o.order or 0, Size = o.size or UDim2.new(1 / 3, -6, 0, 62),
	}, o.parent)
	Theme.surface(tile, "Card", "card")
	Util.corner(tile, 12)
	Theme.bind(Util.stroke(tile, nil, 1, 0.15), "Color", "Border")
	local value = Util.new("TextLabel", {
		Name = "Value", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 26),
		Text = o.value or "-", TextXAlignment = Enum.TextXAlignment.Left,
	}, tile)
	Typo.apply(value, "stat")
	Theme.bind(value, "TextColor3", "Text")
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 37), Size = UDim2.new(1, -24, 0, 16),
		Text = o.label or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, tile)
	Typo.apply(label, "caption")
	Theme.bind(label, "TextColor3", "Muted")
	local api = { Instance = tile }
	function api.Set(text, role)
		value.Text = tostring(text)
		if role then
			Theme.tweenRole(value, "TextColor3", role, 0.2)
		end
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- dropdown (popup lives in the window's popup layer so scrolling pages never clip it)
----------------------------------------------------------------------------------------------------
UI.openDropdown = nil

function UI.closeDropdown(immediate)
	local active = UI.openDropdown
	if active then
		UI.openDropdown = nil
		active.close(immediate)
	end
end

-- o: parent, options = { {id=, label=}, ... }, value, onChange(id), width, height, popupWidth, anchor, position, order, name
function UI.dropdown(o)
	local options = o.options
	local current = o.value
	local hit = Util.new("TextButton", {
		Name = o.name or "Dropdown", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(o.width or 170, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
	}, hit)
	Util.corner(face, 10)
	Theme.bind(face, "BackgroundColor3", "Track", "Panel", 0.4)
	Theme.bind(Util.stroke(face, nil, 1, 0.3), "Color", "Border")
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
	}, face)
	Typo.apply(label, "buttonSmall")
	Theme.bind(label, "TextColor3", "Text")
	local chevron = UI.icon("chevron", face, 16, "Muted", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0) })
	local state = UI.pressable(hit, face, { radius = 10, hoverAlpha = 0.94, pressAlpha = 0.88 })
	local api = { Instance = hit, enabled = true, last = 0 }

	local function labelFor(id)
		for _, opt in ipairs(options) do
			if opt.id == id then
				return opt.label
			end
		end
		return o.placeholder or "Select..."
	end
	label.Text = labelFor(current)

	local function open()
		local layer = UI.layers.popup
		if not layer then
			return
		end
		local s = UI.scale()
		local lx = (hit.AbsolutePosition.X - layer.AbsolutePosition.X) / s
		local ly = (hit.AbsolutePosition.Y - layer.AbsolutePosition.Y) / s
		local bw, bh = hit.AbsoluteSize.X / s, hit.AbsoluteSize.Y / s
		local lw, lh = layer.AbsoluteSize.X / s, layer.AbsoluteSize.Y / s
		local rowHeight = 36
		local visibleRows = math.min(#options, 6)
		local listHeight = visibleRows * rowHeight + 10
		local width = math.min(math.max(bw, o.popupWidth or 170), math.max(120, lw - 12))
		local x = Util.clamp(lx + bw - width, 6, math.max(6, lw - width - 6))
		local below = ly + bh + 4
		local anchorY, y = 0, below
		if below + listHeight > lh - 6 then
			local above = ly - 4
			if above - listHeight >= 6 then
				anchorY, y = 1, above
			else
				y = Util.clamp(below, 6, math.max(6, lh - listHeight - 6))
			end
		end

		layer.Visible = true
		local catcher = Util.new("TextButton", {
			Name = "Catcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), ZIndex = 1,
		}, layer)
		local list = Util.new("Frame", {
			Name = "DropdownList", AnchorPoint = Vector2.new(0, anchorY), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(width, 0), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
		}, layer)
		Util.corner(list, 12)
		Theme.bind(list, "BackgroundColor3", "Elevated")
		Theme.bind(Util.stroke(list, nil, 1, 0.1), "Color", "Border")
		local scroller = Util.new("ScrollingFrame", {
			Name = "Options", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.4,
		}, list)
		Theme.bind(scroller, "ScrollBarImageColor3", "Accent")
		Util.pad(scroller, 5, 5, 5, 5)
		Util.list(scroller, 0)

		for i, opt in ipairs(options) do
			local rowHit = Util.new("TextButton", {
				Name = "Opt_" .. tostring(opt.id), Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, rowHeight), LayoutOrder = i, ZIndex = 4,
			}, scroller)
			local rowFace = Util.new("Frame", {
				Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -2, 1, -4), BorderSizePixel = 0, ZIndex = 4,
				BackgroundTransparency = opt.id == current and 0 or 1,
			}, rowHit)
			Util.corner(rowFace, 8)
			Theme.bind(rowFace, "BackgroundColor3", "AccentSoft")
			local rowLabel = Util.new("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), Text = opt.label,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
			}, rowFace)
			Typo.apply(rowLabel, "buttonSmall")
			Theme.bind(rowLabel, "TextColor3", opt.id == current and "Text" or "Muted")
			if opt.id == current then
				UI.icon("check", rowFace, 16, "Accent", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0), zindex = 5 })
			end
			local rowState = UI.pressable(rowHit, rowFace, { radius = 8, hoverAlpha = 0.93, pressAlpha = 0.85, pressScale = 0.98 })
			rowHit.Activated:Connect(function()
				if rowState.wasDrag() then
					return
				end
				Sfx.play("select")
				current = opt.id
				label.Text = opt.label
				UI.closeDropdown()
				if o.onChange then
					Util.try("dropdown onChange", o.onChange, opt.id)
				end
			end)
		end

		local closing = false
		local function close(immediate)
			if closing then
				return
			end
			closing = true
			Motion.tween(chevron.Instance, { Rotation = 0 }, 0.15)
			local function finish()
				catcher:Destroy()
				list:Destroy()
				if not UI.openDropdown then
					layer.Visible = false
				end
				UI.prune()
			end
			if immediate then
				Motion.cancel(list)
				finish()
			else
				Motion.tween(list, { Size = UDim2.fromOffset(width, 0) }, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
			end
		end
		UI.openDropdown = { close = close, owner = api }
		catcher.Activated:Connect(function()
			Sfx.play("dropdown")
			UI.closeDropdown()
		end)
		Sfx.play("dropdown")
		Motion.tween(chevron.Instance, { Rotation = 180 }, 0.2)
		Motion.tween(list, { Size = UDim2.fromOffset(width, listHeight) }, 0.2)
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			return
		end
		local now = os.clock()
		if now - api.last < 0.15 then
			return
		end
		api.last = now
		local active = UI.openDropdown
		if active and active.owner == api then
			Sfx.play("dropdown")
			UI.closeDropdown()
			return
		end
		UI.closeDropdown(true)
		open()
	end)

	function api.Get()
		return current
	end
	function api.Set(id, silent)
		current = id
		label.Text = labelFor(id)
		if not silent and o.onChange then
			Util.try("dropdown onChange", o.onChange, id)
		end
	end
	function api.SetOptions(newOptions, selected)
		options = newOptions
		current = selected
		label.Text = labelFor(current)
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		label.TextTransparency = api.enabled and 0 or 0.55
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- text input
----------------------------------------------------------------------------------------------------
-- o: parent, placeholder, text, width, height, size, numeric, maxLength, onSubmit(text, enter), onChange(text),
--    anchor, position, order
function UI.input(o)
	local holder = Util.new("Frame", {
		Name = o.name or "Input", BorderSizePixel = 0, ClipsDescendants = true,
		Size = o.size or UDim2.fromOffset(o.width or 200, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	Util.corner(holder, 10)
	Theme.surface(holder, "Panel", "input")
	local stroke = Util.stroke(holder, nil, 1, 0.1)
	Theme.bind(stroke, "Color", "Border")
	local box = Util.new("TextBox", {
		Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
		Text = o.text or "", PlaceholderText = o.placeholder or "", ClearTextOnFocus = false, MultiLine = false,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false, ClipsDescendants = true,
	}, holder)
	Typo.apply(box, "body", 13)
	Theme.bind(box, "TextColor3", "Text")
	Theme.bind(box, "PlaceholderColor3", "Faint")
	local api = { Instance = holder, Box = box }
	local guard = false

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if guard then
			return
		end
		local text = box.Text
		local cleaned = text
		if o.numeric then
			cleaned = string.gsub(cleaned, "%D", "")
		end
		if o.maxLength and #cleaned > o.maxLength then
			cleaned = string.sub(cleaned, 1, o.maxLength)
		end
		if cleaned ~= text then
			guard = true
			box.Text = cleaned
			guard = false
		end
		if o.onChange then
			Util.try("input onChange", o.onChange, cleaned)
		end
	end)
	box.Focused:Connect(function()
		Theme.tweenRole(stroke, "Color", "Accent", 0.15)
		Motion.tween(stroke, { Thickness = 1.5, Transparency = 0 }, 0.15)
		Sfx.play("select")
		UI.scrollIntoView(holder)
		if Win.onInputFocus then
			Win.onInputFocus(holder, true)
		end
	end)
	box.FocusLost:Connect(function(enter)
		Theme.tweenRole(stroke, "Color", "Border", 0.2)
		Motion.tween(stroke, { Thickness = 1, Transparency = 0.1 }, 0.2)
		if Win.onInputFocus then
			Win.onInputFocus(holder, false)
		end
		if o.onSubmit then
			Util.try("input onSubmit", o.onSubmit, Util.trim(box.Text), enter)
		end
	end)

	function api.Get()
		return Util.trim(box.Text)
	end
	function api.Set(text)
		guard = true
		box.Text = tostring(text or "")
		guard = false
	end
	function api.Focus()
		box:CaptureFocus()
	end
	function api.Flash(role)
		Theme.bind(stroke, "Color", role or "Danger")
		Motion.tween(stroke, { Thickness = 2 }, 0.1)
		task.delay(0.9, function()
			if stroke.Parent then
				Theme.tweenRole(stroke, "Color", "Border", 0.3)
				Motion.tween(stroke, { Thickness = 1 }, 0.3)
			end
		end)
		UI.shake(holder)
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- confirm dialog (one at a time, rendered in the window's modal layer)
----------------------------------------------------------------------------------------------------
UI.modal = nil

function UI.closeModal(immediate)
	local modal = UI.modal
	if not modal then
		return
	end
	UI.modal = nil
	local layer = UI.layers.modal
	local function finish()
		modal.scrim:Destroy()
		modal.card:Destroy()
		if layer then
			layer.Visible = false
		end
		UI.prune()
	end
	if immediate then
		finish()
		return
	end
	Motion.tween(modal.scrim, { BackgroundTransparency = 1 }, 0.14)
	Motion.tween(modal.scale, { Scale = 0.94 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
end

-- o: title, text, confirmText, cancelText, danger, onConfirm(), onCancel()
function UI.confirm(o)
	local layer = UI.layers.modal
	if not layer or UI.modal then
		return false
	end
	UI.closeDropdown(true)
	layer.Visible = true
	local s = UI.scale()
	local layerWidth = layer.AbsoluteSize.X / s
	local width = Util.clamp(layerWidth - 40, 240, 350)

	local scrim = Util.new("TextButton", {
		Name = "Scrim", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, ZIndex = 1,
	}, layer)
	Theme.bind(scrim, "BackgroundColor3", "Scrim")
	local card = Util.new("Frame", {
		Name = "Confirm", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 2,
	}, layer)
	Util.corner(card, 14)
	Theme.bind(card, "BackgroundColor3", "Elevated")
	Theme.bind(Util.stroke(card, nil, 1, 0), "Color", o.danger and "Danger" or "Accent", "Border", o.danger and 0.55 or 0.5)
	Util.pad(card, 18, 16, 18, 16)
	local scale = Util.new("UIScale", { Scale = 0.92 }, card)
	Util.list(card, 10)

	local head = Util.new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1 }, card)
	UI.icon(o.danger and "bang" or "info", head, 22, o.danger and "Danger" or "Accent", { anchor = Vector2.new(0, 0.5), position = UDim2.new(0, 0, 0.5, 0) })
	local title = Util.new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -30, 1, 0),
		Text = o.title or "Are you sure?", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, head)
	Typo.apply(title, "heading", 15)
	Theme.bind(title, "TextColor3", "Text")
	local body = Util.new("TextLabel", {
		BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.text or "", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, card)
	Typo.apply(body, "body")
	Theme.bind(body, "TextColor3", "Muted")
	local row = Util.new("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 3 }, card)

	local modal = { scrim = scrim, card = card, scale = scale }
	UI.modal = modal
	local decided = false
	local function decide(confirmed)
		if decided then
			return
		end
		decided = true
		UI.closeModal()
		if confirmed then
			if o.onConfirm then
				Util.try("confirm", o.onConfirm)
			end
		elseif o.onCancel then
			Util.try("cancel", o.onCancel)
		end
	end
	UI.button({
		parent = row, text = o.cancelText or "Cancel", kind = "ghost", size = UDim2.new(0.5, -5, 1, 0), name = "Cancel",
		sound = "close", onClick = function()
			decide(false)
		end,
	})
	UI.button({
		parent = row, text = o.confirmText or "Confirm", kind = o.danger and "danger" or "primary",
		size = UDim2.new(0.5, -5, 1, 0), position = UDim2.new(0.5, 5, 0, 0), name = "Confirm",
		sound = o.danger and "warning" or "success", onClick = function()
			decide(true)
		end,
	})
	scrim.Activated:Connect(function()
		decide(false)
	end)

	Sfx.play("open")
	Motion.tween(scrim, { BackgroundTransparency = 0.5 }, 0.18)
	Motion.tween(scale, { Scale = 1 }, 0.24, Enum.EasingStyle.Back)
	return true
end
end -- [06_ui_more.lua]

do -- [07_notify.lua]

----------------------------------------------------------------------------------------------------
-- Notify: success / warning / error / info toasts. The stack sits at the bottom centre (like an Android snackbar) so it never
-- covers the window's title-bar buttons. Newest goes on TOP of the stack, so entering never shifts the others; leaving
-- collapses the slot so the newer ones glide down. Repeats are merged.
----------------------------------------------------------------------------------------------------
Notify.layer = nil
Notify.items = {}
Notify.max = 4
Notify.width = 300
Notify.counter = 0

local TOAST = {
	success = { role = "Green", icon = "check", sound = "success", duration = 3.4 },
	warning = { role = "Warn", icon = "bang", sound = "warning", duration = 4.8 },
	error = { role = "Danger", icon = "close", sound = "error", duration = 5.6 },
	info = { role = "Info", icon = "info", sound = "select", duration = 3.4 },
}

function Notify.init(gui)
	Notify.destroy()
	local viewport = Env.viewport()
	Notify.width = Util.clamp(viewport.X - 28, 220, 320)
	local layer = Util.new("Frame", {
		Name = "Toasts", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.fromOffset(Notify.width, 0),
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 200,
	}, gui)
	Util.new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, layer)
	Notify.layer = layer
end

local function removeItem(item)
	local index = Util.indexOf(Notify.items, item)
	if index then
		table.remove(Notify.items, index)
	end
end

local function dismiss(item, instant)
	if item.closing then
		return
	end
	item.closing = true
	removeItem(item)
	local wrapper, card = item.wrapper, item.card
	if not wrapper.Parent then
		return
	end
	local height = wrapper.AbsoluteSize.Y
	local function finish()
		wrapper:Destroy()
		UI.prune()
	end
	if instant or Motion.reduced then
		finish()
		return
	end
	wrapper.AutomaticSize = Enum.AutomaticSize.None
	wrapper.Size = UDim2.new(1, 0, 0, height)
	Motion.tween(card, { Position = UDim2.new(0, Notify.width + 40, 0, 0) }, 0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	Motion.tween(wrapper, { Size = UDim2.new(1, 0, 0, 0) }, 0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In, finish)
end

local function tick()
	local now = os.clock()
	local expired = {}
	for _, item in ipairs(Notify.items) do
		if not item.closing and now >= item.expires then
			expired[#expired + 1] = item
		end
	end
	for _, item in ipairs(expired) do
		dismiss(item)
	end
	if #Notify.items == 0 then
		Anim.remove("notify")
	end
end

local function startBar(item, duration)
	local bar = item.bar
	Motion.cancel(bar)
	bar.Size = UDim2.new(1, -28, 0, 2)
	Motion.tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
end

-- kind: "success" | "warning" | "error" | "info"
-- opts: duration (seconds), key (merge key), force (show even when notifications are switched off)
function Notify.push(kind, title, text, opts)
	local spec = TOAST[kind] or TOAST.info
	opts = opts or {}
	if not Notify.layer or not Notify.layer.Parent then
		return nil
	end
	if not Store.get("notifications") and not opts.force then
		return nil
	end
	title, text = tostring(title or ""), tostring(text or "")
	local key = opts.key or (kind .. "|" .. title .. "|" .. text)
	local duration = opts.duration or spec.duration

	for _, item in ipairs(Notify.items) do
		if item.key == key and not item.closing then
			item.count = item.count + 1
			item.badge.Text = "x" .. item.count
			item.badge.Visible = true
			item.expires = os.clock() + duration
			startBar(item, duration)
			if not Motion.reduced then
				Motion.tween(item.scale, { Scale = 1.04 }, 0.08, Enum.EasingStyle.Quad, nil, function()
					Motion.tween(item.scale, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
				end)
			end
			Sfx.play(spec.sound)
			return item
		end
	end

	Notify.counter = Notify.counter + 1
	local wrapper = Util.new("Frame", {
		Name = "Slot", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = -Notify.counter,
	}, Notify.layer)
	local card = Util.new("TextButton", {
		Name = "Toast", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, -44), ZIndex = 201,
	}, wrapper)
	Util.corner(card, 12)
	Theme.bind(card, "BackgroundColor3", "Elevated")
	Theme.bind(Util.stroke(card, nil, 1, 0.05), "Color", spec.role, "Border", 0.6)
	local scale = Util.new("UIScale", { Scale = 1 }, card)

	local accent = Util.new("Frame", {
		Name = "Accent", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 7, 0.5, 0),
		Size = UDim2.new(0, 3, 1, -22), ZIndex = 202,
	}, card)
	Util.round_corner(accent)
	Theme.bind(accent, "BackgroundColor3", spec.role)

	local disc = Util.new("Frame", {
		Name = "Disc", BorderSizePixel = 0, Position = UDim2.fromOffset(18, 12), Size = UDim2.fromOffset(26, 26), ZIndex = 202,
	}, card)
	Util.round_corner(disc)
	Theme.bind(disc, "BackgroundColor3", "Card", spec.role, 0.28)
	UI.icon(spec.icon, disc, 16, spec.role, { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 203 })

	local inner = Util.new("Frame", {
		Name = "Inner", BackgroundTransparency = 1, Position = UDim2.fromOffset(54, 0), Size = UDim2.new(1, -92, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 202,
	}, card)
	Util.pad(inner, 0, 11, 0, 14)
	Util.list(inner, 2)
	local heading = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Text = title, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 203,
	}, inner)
	Typo.apply(heading, "heading", 13)
	Theme.bind(heading, "TextColor3", "Text")
	local body = Util.new("TextLabel", {
		Name = "Text", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, Visible = text ~= "", ZIndex = 203,
	}, inner)
	Typo.apply(body, "caption", 12)
	Theme.bind(body, "TextColor3", "Muted")

	local badge = Util.new("TextLabel", {
		Name = "Count", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(34, 16), Text = "x2", TextXAlignment = Enum.TextXAlignment.Right, Visible = false, ZIndex = 203,
	}, card)
	Typo.apply(badge, "label", 11)
	Theme.bind(badge, "TextColor3", spec.role)

	local bar = Util.new("Frame", {
		Name = "Timer", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -5),
		Size = UDim2.new(1, -28, 0, 2), BackgroundTransparency = 0.35, ZIndex = 203,
	}, card)
	Util.round_corner(bar)
	Theme.bind(bar, "BackgroundColor3", spec.role)

	local item = {
		key = key, kind = kind, wrapper = wrapper, card = card, scale = scale, badge = badge, bar = bar,
		count = 1, expires = os.clock() + duration, closing = false,
	}
	Notify.items[#Notify.items + 1] = item
	card.Activated:Connect(function()
		dismiss(item)
	end)

	Motion.tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	startBar(item, duration)
	Sfx.play(spec.sound)
	Anim.add("notify", tick, 6)

	while #Notify.items > Notify.max do
		dismiss(Notify.items[1])
	end
	return item
end

function Notify.success(title, text, opts)
	return Notify.push("success", title, text, opts)
end
function Notify.warn(title, text, opts)
	return Notify.push("warning", title, text, opts)
end
function Notify.error(title, text, opts)
	return Notify.push("error", title, text, opts)
end
function Notify.info(title, text, opts)
	return Notify.push("info", title, text, opts)
end

function Notify.clear(instant)
	local snapshot = {}
	for i, item in ipairs(Notify.items) do
		snapshot[i] = item
	end
	for _, item in ipairs(snapshot) do
		dismiss(item, instant)
	end
end

function Notify.destroy()
	Anim.remove("notify")
	Notify.items = {}
	if Notify.layer then
		pcall(Notify.layer.Destroy, Notify.layer)
		Notify.layer = nil
	end
end
end -- [07_notify.lua]

do -- [08_background.lua]

----------------------------------------------------------------------------------------------------
-- Bg: panel background system.
--   solid     flat theme colour
--   aurora    two drifting theme gradients                (procedural, no assets)
--   sparkle   slowly rising glints                        (procedural, no assets)
--   image     one static image (asset id, rbxassetid, file in VirexHub/backgrounds, or image URL)
--   sheet     sprite-sheet animation (cols x rows grid in ONE image)    <- GIF-like
--   sequence  list of images shown one after another                    <- GIF-like
--   video     Roblox VideoFrame (experimental, needs a Roblox-hosted video asset or a local webm/mp4)
-- Roblox ImageLabels cannot play GIF files and arbitrary video URLs cannot be streamed, which is why the
-- GIF-like modes use sheets / sequences. A dark overlay and a minimum darkness keep text readable.
----------------------------------------------------------------------------------------------------
Bg.layer = nil
Bg.content = nil
Bg.overlay = nil
Bg.mode = "solid"
Bg.token = 0
Bg.status = { kind = "idle", text = "Solid colour background." }
Bg.listeners = {}
Bg.blur = nil
Bg.cacheNote = nil

local MEDIA_MODES = { image = true, sheet = true, sequence = true, video = true }
Bg.MODES = {
	{ id = "solid", label = "Solid" },
	{ id = "aurora", label = "Aurora" },
	{ id = "sparkle", label = "Sparkle" },
	{ id = "image", label = "Image" },
	{ id = "sheet", label = "Sprite sheet" },
	{ id = "sequence", label = "Image sequence" },
	{ id = "video", label = "Video (beta)" },
}

function Bg.onStatus(fn)
	Bg.listeners[#Bg.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Bg.listeners, fn)
		if index then
			table.remove(Bg.listeners, index)
		end
	end
end

function Bg.setStatus(kind, text)
	Bg.status = { kind = kind, text = text }
	for _, fn in ipairs(Util.copy(Bg.listeners)) do
		Util.try("bg status listener", fn, kind, text)
	end
end

function Bg.animated()
	return not Store.get("reducedMotion") and not Store.get("lowPower")
end

function Bg.init(layer)
	Bg.layer = layer
	Theme.G.aurora2 = function(l)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, Util.mix(l.Background, l.Accent2, 0.22)),
			ColorSequenceKeypoint.new(0.5, l.Background),
			ColorSequenceKeypoint.new(1, Util.mix(l.Background, l.Accent, 0.26)),
		})
	end
	Bg.content = Util.new("Frame", {
		Name = "BgContent", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, layer)
	Bg.overlay = Util.new("Frame", {
		Name = "BgOverlay", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, ZIndex = 2,
	}, layer)
	Util.corner(Bg.overlay, 16)
end

function Bg.clearContent()
	Anim.remove("bg")
	if Bg.content then
		for _, child in ipairs(Bg.content:GetChildren()) do
			child:Destroy()
		end
	end
	UI.prune()
end

function Bg.updateOverlay()
	if not Bg.overlay then
		return
	end
	local amount = 0
	if MEDIA_MODES[Bg.mode] then
		amount = math.max(Store.get("overlay"), 0.2) -- never let media make the UI unreadable
	end
	Motion.tween(Bg.overlay, { BackgroundTransparency = 1 - amount }, 0.25)
end

function Bg.setOverlay(value)
	Store.set("overlay", value)
	Bg.updateOverlay()
end

function Bg.setGlass(value)
	Store.set("glass", value)
	Theme.setGlass(value)
end

----------------------------------------------------------------------------------------------------
-- source resolution (yields when it has to download)
----------------------------------------------------------------------------------------------------
local function detectImageKind(bytes)
	if type(bytes) ~= "string" or #bytes < 12 then
		return nil
	end
	local b1, b2, b3, b4 = string.byte(bytes, 1, 4)
	if b1 == 0x89 and b2 == 0x50 and b3 == 0x4E and b4 == 0x47 then
		return "png"
	elseif b1 == 0xFF and b2 == 0xD8 and b3 == 0xFF then
		return "jpg"
	elseif string.sub(bytes, 1, 4) == "RIFF" and string.sub(bytes, 9, 12) == "WEBP" then
		return "webp"
	elseif string.sub(bytes, 1, 3) == "GIF" then
		return "gif"
	end
	return nil
end

local function robloxAssetFromUrl(text)
	local id = string.match(text, "roblox%.com/asset/?%?id=(%d+)") or string.match(text, "roblox%.com/library/(%d+)")
	if id then
		return "rbxassetid://" .. id
	end
	return nil
end

local GIF_HELP = "GIF files do not animate in Roblox. Convert it to a sprite sheet (one grid image) or an image sequence."

-- returns { ok = true, url = "rbxasset..." , note = "..." } or { ok = false, reason = "..." }
function Bg.resolve(text, wantVideo)
	text = Util.trim(text)
	if text == "" then
		return { ok = false, reason = "Enter an asset ID, file name or image link first." }
	end
	if string.match(text, "^%d+$") then
		return { ok = true, url = "rbxassetid://" .. text, note = "Roblox asset ID" }
	end
	if string.match(text, "^rbxassetid://%d+$") or string.match(text, "^rbxthumb://") or string.match(text, "^rbxasset://") then
		return { ok = true, url = text, note = "Roblox asset" }
	end
	local lower = string.lower(text)
	if string.match(lower, "^https?://") then
		local asset = robloxAssetFromUrl(lower)
		if asset then
			return { ok = true, url = asset, note = "Roblox asset link" }
		end
		if wantVideo then
			return { ok = false, reason = "Video links cannot be streamed. Use a Roblox video asset ID or a local .webm/.mp4 file." }
		end
		if not Env.canDownload() or not Env.filesWork() then
			return { ok = false, reason = "Image links need working executor file + HTTP support, which was not available here. Use a Roblox asset ID instead." }
		end
		if string.match(lower, "%.gif[%?#]?") or string.match(lower, "%.gif$") then
			return { ok = false, reason = GIF_HELP }
		end
		-- a previous download of the same link is reused instead of downloading it again
		for _, ext in ipairs({ "png", "jpg", "webp" }) do
			local cached = CONFIG.CacheFolder .. "/bg_" .. Util.hash(text) .. "." .. ext
			if Env.fileExists(cached) then
				local cachedAsset = Env.customAsset(cached)
				if cachedAsset then
					return { ok = true, url = cachedAsset, note = "cached " .. string.upper(ext) }
				end
			end
		end
		Bg.setStatus("loading", "Downloading image...")
		local body, err = Env.httpGet(text)
		if not body then
			return { ok = false, reason = "Download failed (" .. tostring(err) .. ")." }
		end
		if #body > 12 * 1024 * 1024 then
			return { ok = false, reason = "That image is larger than 12 MB." }
		end
		local kind = detectImageKind(body)
		if kind == "gif" then
			return { ok = false, reason = GIF_HELP }
		elseif not kind then
			return { ok = false, reason = "The link did not return a PNG, JPG or WEBP image." }
		end
		Env.ensureFolder(CONFIG.Folder)
		Env.ensureFolder(CONFIG.CacheFolder)
		local path = CONFIG.CacheFolder .. "/bg_" .. Util.hash(text) .. "." .. kind
		local wrote, writeErr = Env.writeFile(path, body)
		if not wrote then
			return { ok = false, reason = "Could not save the download (" .. tostring(writeErr) .. ")." }
		end
		local asset, assetErr = Env.customAsset(path)
		if not asset then
			return { ok = false, reason = "This executor could not turn the file into an asset (" .. tostring(assetErr) .. ")." }
		end
		return { ok = true, url = asset, note = "downloaded " .. kind:upper() }
	end

	-- a file name / relative path inside the executor workspace
	if not Env.canCustomAsset() then
		return { ok = false, reason = "Local files need executor file + custom-asset support, which was not detected." }
	end
	if not Env.filesWork() then
		return { ok = false, reason = "This executor blocked file access, so local files cannot be used. Roblox asset IDs still work." }
	end
	local candidates = { text, CONFIG.BackgroundFolder .. "/" .. text }
	for _, path in ipairs(candidates) do
		if Env.fileExists(path) then
			local data = Env.readFile(path)
			if wantVideo then
				if not (string.match(lower, "%.webm$") or string.match(lower, "%.mp4$")) then
					return { ok = false, reason = "Video files must be .webm or .mp4." }
				end
			else
				local kind = detectImageKind(data)
				if kind == "gif" then
					return { ok = false, reason = GIF_HELP }
				elseif not kind then
					return { ok = false, reason = "'" .. text .. "' is not a PNG, JPG or WEBP image." }
				end
			end
			local asset, assetErr = Env.customAsset(path)
			if not asset then
				return { ok = false, reason = "This executor could not load that file as an asset (" .. tostring(assetErr) .. ")." }
			end
			return { ok = true, url = asset, note = "local file" }
		end
	end
	return { ok = false, reason = "File not found. Put it in the executor workspace folder '" .. CONFIG.BackgroundFolder .. "'." }
end

-- waits (yields) until an ImageLabel's image is fetched or the timeout passes
function Bg.verifyImage(label, timeout)
	if not ContentProvider then
		return true, "unverified"
	end
	local succeeded, finished = false, false
	task.spawn(function()
		local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, { label }, function(_, status)
			if tostring(status) == "Enum.AssetFetchStatus.Success" then
				succeeded = true
			end
		end)
		if not ok then
			succeeded = true -- preloading unsupported: let Roblox stream it
		end
		finished = true
	end)
	local started = os.clock()
	while not finished and os.clock() - started < (timeout or 8) do
		task.wait(0.05)
	end
	if succeeded then
		return true
	end
	local okLoaded, loaded = pcall(function()
		return label.IsLoaded
	end)
	if okLoaded and loaded then
		return true
	end
	return false
end

----------------------------------------------------------------------------------------------------
-- procedural modes
----------------------------------------------------------------------------------------------------
local function gate()
	return Theme.active()
end

function Bg.buildAurora()
	local layers = {}
	local specs = { { builder = Theme.G.aurora, transparency = 0, speed = 5 }, { builder = Theme.G.aurora2, transparency = 0.45, speed = -7 } }
	for i, spec in ipairs(specs) do
		local frame = Util.new("Frame", {
			Name = "Aurora" .. i, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = spec.transparency, ZIndex = i,
		}, Bg.content)
		Util.corner(frame, 16)
		local gradient = Util.new("UIGradient", { Rotation = i == 1 and 25 or 140 }, frame)
		Theme.gradient(gradient, spec.builder)
		layers[i] = { gradient = gradient, speed = spec.speed, base = i == 1 and 25 or 140 }
	end
	if Bg.animated() then
		Anim.add("bg", function(_, now)
			for i, layer in ipairs(layers) do
				layer.gradient.Rotation = (layer.base + now * layer.speed) % 360
				layer.gradient.Offset = Vector2.new(0.22 * math.sin(now * 0.31 + i), 0.22 * math.cos(now * 0.23 + i * 2))
			end
		end, 20, gate)
	end
	Bg.setStatus("ok", "Aurora - animated theme gradient.")
end

function Bg.buildSparkle()
	local count = Bg.animated() and 24 or 12
	local particles = {}
	local seed = 17
	local function rand()
		seed = (seed * 1103515245 + 12345) % 2147483648
		return seed / 2147483648
	end
	for i = 1, count do
		local size = 2 + math.floor(rand() * 3)
		local dot = Util.new("Frame", {
			Name = "Glint" .. i, BorderSizePixel = 0, Size = UDim2.fromOffset(size, size), AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.6, ZIndex = 1, Position = UDim2.fromScale(0.04 + rand() * 0.92, 0.05 + rand() * 0.9),
		}, Bg.content)
		Util.round_corner(dot)
		Theme.bind(dot, "BackgroundColor3", "Shine")
		particles[i] = { dot = dot, x = 0.04 + rand() * 0.92, y = rand(), speed = 0.012 + rand() * 0.02, tw = 0.8 + rand() * 1.6, ph = rand() * 6.28 }
	end
	if Bg.animated() then
		Anim.add("bg", function(_, now)
			for _, p in ipairs(particles) do
				local y = (p.y - p.speed * now) % 1
				p.dot.Position = UDim2.fromScale(p.x, 0.04 + y * 0.92)
				p.dot.BackgroundTransparency = 0.45 + 0.5 * (0.5 + 0.5 * math.sin(now * p.tw + p.ph))
			end
		end, 20, gate)
	end
	Bg.setStatus("ok", "Sparkle - slow rising glints.")
end

----------------------------------------------------------------------------------------------------
-- media modes
----------------------------------------------------------------------------------------------------
local function fail(token, message)
	if token == Bg.token then
		Bg.clearContent()
		Bg.setStatus("error", message)
	end
end

function Bg.buildImage(token)
	local source = Store.get("bgImage")
	if source == "" then
		Bg.setStatus("idle", "No image yet - enter an asset ID, file name or link, then press Apply.")
		return
	end
	Bg.setStatus("loading", "Loading image...")
	local result = Bg.resolve(source, false)
	if token ~= Bg.token then
		return
	end
	if not result.ok then
		return fail(token, result.reason)
	end
	local image = Util.new("ImageLabel", {
		Name = "BgImage", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop,
		Image = result.url, ImageTransparency = 1, ZIndex = 1,
	}, Bg.content)
	Util.corner(image, 16)
	local ok = Bg.verifyImage(image, 9)
	if token ~= Bg.token or not image.Parent then
		return
	end
	if not ok then
		return fail(token, "The image could not be loaded. Check the ID (use the Image asset ID, not a Decal ID) and that the asset is public.")
	end
	Motion.tween(image, { ImageTransparency = 0 }, 0.5)
	Bg.setStatus("ok", "Image loaded (" .. tostring(result.note) .. ").")
end

local function splitList(text)
	local items = {}
	local normalized = string.gsub(text, "[\r\n;]", ",") -- gsub returns (string, count): keep only the string
	for _, piece in ipairs(Util.split(normalized, ",")) do
		piece = Util.trim(piece)
		if piece ~= "" then
			items[#items + 1] = piece
		end
	end
	return items
end

function Bg.buildSheet(token)
	local source = Store.get("bgImage")
	if source == "" then
		Bg.setStatus("idle", "Enter the sprite-sheet image first (asset ID or file), then set columns, rows and speed.")
		return
	end
	Bg.setStatus("loading", "Loading sprite sheet...")
	local result = Bg.resolve(source, false)
	if token ~= Bg.token then
		return
	end
	if not result.ok then
		return fail(token, result.reason)
	end
	local cols, rows, fps = Store.get("bgCols"), Store.get("bgRows"), Store.get("bgFps")
	local clip = Util.new("Frame", {
		Name = "SheetClip", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, Bg.content)
	local sheet = Util.new("ImageLabel", {
		Name = "Sheet", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(cols, rows),
		Position = UDim2.fromScale(0, 0), ScaleType = Enum.ScaleType.Stretch, Image = result.url, ZIndex = 1,
	}, clip)
	local ok = Bg.verifyImage(sheet, 9)
	if token ~= Bg.token or not sheet.Parent then
		return
	end
	if not ok then
		return fail(token, "The sprite sheet could not be loaded. Check the asset ID or file name.")
	end
	local total = cols * rows
	local last = -1
	local function show(index)
		if index == last then
			return
		end
		last = index
		local col, row = index % cols, math.floor(index / cols)
		sheet.Position = UDim2.fromScale(-col, -row)
	end
	show(0)
	if Bg.animated() and total > 1 then
		Anim.add("bg", function(_, now)
			show(math.floor(now * fps) % total)
		end, math.min(fps, 24), gate)
	end
	Bg.setStatus("ok", string.format("Sprite sheet %dx%d at %d fps%s.", cols, rows, fps, Bg.animated() and "" or " (paused: reduced motion / low power)"))
end

function Bg.buildSequence(token)
	local list = splitList(Store.get("bgSequence"))
	if #list == 0 then
		Bg.setStatus("idle", "Enter 2 or more image IDs or file names separated by commas.")
		return
	end
	if #list > 24 then
		list = { table.unpack(list, 1, 24) }
	end
	Bg.setStatus("loading", "Loading frames (0/" .. #list .. ")...")
	local frames, loaded = {}, 0
	for i, entry in ipairs(list) do
		local result = Bg.resolve(entry, false)
		if token ~= Bg.token then
			return
		end
		if not result.ok then
			return fail(token, "Frame " .. i .. ": " .. result.reason)
		end
		local frame = Util.new("ImageLabel", {
			Name = "Frame" .. i, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Crop, Image = result.url, Visible = i == 1, ZIndex = 1,
		}, Bg.content)
		Util.corner(frame, 16)
		frames[i] = frame
	end
	for i, frame in ipairs(frames) do
		if not Bg.verifyImage(frame, 8) then
			return fail(token, "Frame " .. i .. " could not be loaded.")
		end
		if token ~= Bg.token then
			return
		end
		loaded = loaded + 1
		Bg.setStatus("loading", "Loading frames (" .. loaded .. "/" .. #frames .. ")...")
	end
	local fps = Store.get("bgFps")
	local current = 1
	if Bg.animated() and #frames > 1 then
		Anim.add("bg", function(_, now)
			local index = (math.floor(now * fps) % #frames) + 1
			if index ~= current then
				frames[current].Visible = false
				frames[index].Visible = true
				current = index
			end
		end, math.min(fps, 24), gate)
	end
	Bg.setStatus("ok", string.format("Image sequence: %d frames at %d fps%s.", #frames, fps, Bg.animated() and "" or " (paused: reduced motion / low power)"))
end

function Bg.buildVideo(token)
	local source = Store.get("bgVideo")
	if source == "" then
		Bg.setStatus("idle", "Enter a Roblox video asset ID or a local .webm / .mp4 file name.")
		return
	end
	local created, video = pcall(Instance.new, "VideoFrame")
	if not created then
		return fail(token, "VideoFrame is not available in this Roblox client.")
	end
	Bg.setStatus("loading", "Loading video...")
	local result = Bg.resolve(source, true)
	if token ~= Bg.token then
		video:Destroy()
		return
	end
	if not result.ok then
		video:Destroy()
		return fail(token, result.reason)
	end
	local okProps = pcall(function()
		video.Name = "BgVideo"
		video.BackgroundTransparency = 1
		video.BorderSizePixel = 0
		video.Size = UDim2.fromScale(1, 1)
		video.Looped = true
		video.Volume = 0
		video.Video = result.url
		video.ZIndex = 1
		video.Parent = Bg.content
	end)
	if not okProps then
		video:Destroy()
		return fail(token, "This client rejected the video settings.")
	end
	local started, ready = os.clock(), false
	while os.clock() - started < 12 and token == Bg.token and video.Parent do
		local okLoaded, isLoaded = pcall(function()
			return video.IsLoaded
		end)
		if okLoaded and isLoaded then
			ready = true
			break
		end
		task.wait(0.1)
	end
	if token ~= Bg.token or not video.Parent then
		return
	end
	if not ready then
		return fail(token, "The video did not load in time. It must be a Roblox-hosted video asset (or a valid local webm/mp4).")
	end
	pcall(function()
		video.Playing = Bg.animated()
	end)
	Bg.setStatus("ok", "Video playing (experimental)." .. (Bg.animated() and "" or " Paused: reduced motion / low power."))
end

----------------------------------------------------------------------------------------------------
-- apply / public setters
----------------------------------------------------------------------------------------------------
function Bg.apply()
	if not Bg.content then
		return
	end
	Bg.token = Bg.token + 1
	local token = Bg.token
	Bg.clearContent()
	Bg.mode = Store.get("bgMode")
	if Bg.mode == "solid" then
		Bg.setStatus("idle", "Solid colour background.")
	elseif Bg.mode == "aurora" then
		Bg.buildAurora()
	elseif Bg.mode == "sparkle" then
		Bg.buildSparkle()
	elseif Bg.mode == "image" then
		task.spawn(Bg.buildImage, token)
	elseif Bg.mode == "sheet" then
		task.spawn(Bg.buildSheet, token)
	elseif Bg.mode == "sequence" then
		task.spawn(Bg.buildSequence, token)
	elseif Bg.mode == "video" then
		task.spawn(Bg.buildVideo, token)
	end
	Bg.updateOverlay()
end

function Bg.setMode(mode)
	if Store.set("bgMode", mode) then
		Bg.apply()
	end
end

-- Saves the text for a media mode and applies it. The new value is only kept when it really loads;
-- otherwise the previous background is restored. onResult(ok, message) reports the outcome.
function Bg.useSource(mode, text, onResult)
	text = Util.trim(text)
	local key = (mode == "sequence") and "bgSequence" or (mode == "video") and "bgVideo" or "bgImage"
	local previousValue, previousMode = Store.get(key), Store.get("bgMode")
	Store.set(key, text, true)
	Store.set("bgMode", mode, true)
	Bg.apply()
	local token = Bg.token
	task.spawn(function()
		local waited = 0
		while Bg.status.kind == "loading" and token == Bg.token and waited < 45 do
			task.wait(0.1)
			waited = waited + 0.1
		end
		if token ~= Bg.token then
			if onResult then
				onResult(nil, "A newer background change replaced this one.")
			end
			return
		end
		if Bg.status.kind == "ok" then
			if onResult then
				onResult(true, Bg.status.text)
			end
		else
			local message = Bg.status.text
			Store.set(key, previousValue, true)
			Store.set("bgMode", previousMode, true)
			Bg.apply()
			if onResult then
				onResult(false, message)
			end
		end
	end)
end

function Bg.syncBlur()
	local wanted = Store.get("blur") and Win.visible and not Win.minimized
	if wanted and not Bg.blur then
		local parent = Lighting or workspace.CurrentCamera
		if not parent then
			return
		end
		local ok, effect = pcall(function()
			return Util.new("BlurEffect", { Name = "VirexHubBlur", Size = 0 }, parent)
		end)
		if ok then
			Bg.blur = effect
		end
	end
	if Bg.blur then
		if wanted then
			Motion.tween(Bg.blur, { Size = 14 }, 0.35)
		else
			local effect = Bg.blur
			if not Store.get("blur") then
				Bg.blur = nil
			end
			Motion.tween(effect, { Size = 0 }, 0.25, nil, nil, function()
				if not Bg.blur then
					pcall(effect.Destroy, effect)
				end
			end)
		end
	end
end

function Bg.destroy()
	Anim.remove("bg")
	Bg.token = Bg.token + 1
	if Bg.blur then
		pcall(Bg.blur.Destroy, Bg.blur)
		Bg.blur = nil
	end
	Bg.layer, Bg.content, Bg.overlay = nil, nil, nil
	Bg.listeners = {}
end
end -- [08_background.lua]

do -- [09_splash.lua]

----------------------------------------------------------------------------------------------------
-- Splash: loading screen. Layout and motion follow the Blyxo splash (welcome chip, emblem with an
-- orbiting arc, sheen title, thin progress track, ready hand-off) but with VirexHub branding.
-- HONESTY RULES: the track only moves when a real boot step finished (or a real asset finished
-- preloading); the orbit / sheen are decorative and are NOT progress. A watchdog guarantees the
-- screen can never stay up longer than CONFIG.Splash.MaxSeconds.
----------------------------------------------------------------------------------------------------
Splash.gui = nil
Splash.isOpen = false
Splash.closing = false
Splash.createdAt = 0
Splash.fraction = 0
Splash.parts = {}

local CARD_W, CARD_H = 440, 296

local function snapshotFade(root)
	local list = {}
	local function add(obj, prop)
		list[#list + 1] = { obj = obj, prop = prop, rest = obj[prop] }
	end
	local function visit(obj)
		if obj:IsA("GuiObject") then
			add(obj, "BackgroundTransparency")
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				add(obj, "TextTransparency")
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				add(obj, "ImageTransparency")
			end
		elseif obj:IsA("UIStroke") then
			add(obj, "Transparency")
		end
	end
	visit(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		visit(descendant)
	end
	return list
end

local function fadeTo(list, hidden, duration, style)
	for _, entry in ipairs(list) do
		Motion.tween(entry.obj, { [entry.prop] = hidden and 1 or entry.rest }, duration, style or Enum.EasingStyle.Quad)
	end
end

local function hideNow(list)
	for _, entry in ipairs(list) do
		entry.obj[entry.prop] = 1
	end
end

local function setStatusText(label, text)
	if label.Text == text then
		return
	end
	label.Text = text
	if Splash.parts.drawn and not Motion.reduced then
		label.TextTransparency = 0.7
		Motion.tween(label, { TextTransparency = 0 }, 0.3)
	end
end

function Splash.create(container)
	Splash.destroy()
	Splash.createdAt = os.clock()
	Splash.fraction = 0
	Splash.closing = false
	local parts = {}
	Splash.parts = parts

	local viewport = Env.viewport()
	local fit = Util.clamp(math.min((viewport.X - 24) / CARD_W, (viewport.Y - 24) / CARD_H), 0.55, 1.1)

	local gui = Util.new("ScreenGui", {
		Name = CONFIG.SplashName, DisplayOrder = 1000, IgnoreGuiInset = true, ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)
	local backdrop = Util.new("Frame", {
		Name = "Backdrop", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 1, Active = true, ZIndex = 1,
	}, gui)
	Theme.bind(backdrop, "BackgroundColor3", "Background", "Scrim", 0.35)
	local vignette = Util.new("UIGradient", { Rotation = 90 }, backdrop)
	vignette.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.3), NumberSequenceKeypoint.new(1, 0),
	})

	local holder = Util.new("Frame", {
		Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(CARD_W, CARD_H), BackgroundTransparency = 1, ZIndex = 2,
	}, gui)
	local scale = Util.new("UIScale", { Scale = fit * 0.92 }, holder)

	local card = Util.new("Frame", { Name = "Card", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 2 }, holder)
	Util.corner(card, 18)
	Theme.bind(card, "BackgroundColor3", "Panel", "Background", 0.25)
	local cardStroke = Util.stroke(card, nil, 1.5, 0.15)
	Theme.bind(cardStroke, "Color", "Border")
	local strokeGradient = Util.new("UIGradient", { Rotation = 0 }, cardStroke)
	Theme.gradient(strokeGradient, Theme.G.stroke)

	-- welcome chip -------------------------------------------------------------------------------
	local player = Players.LocalPlayer
	if player then
		local chip = Util.new("Frame", {
			Name = "Welcome", Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X,
			BorderSizePixel = 0, ZIndex = 3,
		}, card)
		Util.round_corner(chip)
		Theme.bind(chip, "BackgroundColor3", "Card")
		Theme.bind(Util.stroke(chip, nil, 1, 0.3), "Color", "Border")
		Util.pad(chip, 5, 0, 16, 0)
		Util.new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 9),
		}, chip)
		local avatar = Util.new("ImageLabel", {
			Name = "Avatar", Size = UDim2.fromOffset(30, 30), BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 4,
			Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60", math.floor(player.UserId)),
		}, chip)
		Util.round_corner(avatar)
		Theme.bind(avatar, "BackgroundColor3", "Track")
		parts.avatar = avatar
		local lines = Util.new("Frame", {
			Name = "Lines", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2, ZIndex = 4,
		}, chip)
		Util.new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }, lines)
		local greeting = Util.new("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 14), AutomaticSize = Enum.AutomaticSize.X,
			Text = "Welcome back,", TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 4,
		}, lines)
		Typo.apply(greeting, "caption", 11)
		Theme.bind(greeting, "TextColor3", "Muted")
		local shown = player.DisplayName
		if shown == nil or shown == "" then
			shown = player.Name
		end
		local nameLabel = Util.new("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X,
			Text = shown, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 4,
		}, lines)
		Typo.apply(nameLabel, "heading", 13)
		Theme.bind(nameLabel, "TextColor3", "Text")
		Util.new("UISizeConstraint", { MaxSize = Vector2.new(190, 16) }, nameLabel)
	end

	-- emblem -------------------------------------------------------------------------------------
	local emblem = Util.new("Frame", {
		Name = "Emblem", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 52), Size = UDim2.fromOffset(88, 88),
		BackgroundTransparency = 1, ZIndex = 3,
	}, card)
	local core = Util.new("Frame", {
		Name = "Core", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(66, 66),
		BorderSizePixel = 0, ZIndex = 3,
	}, emblem)
	Util.round_corner(core)
	Theme.bind(core, "BackgroundColor3", "Card")
	Theme.bind(Util.stroke(core, nil, 1.2, 0.2), "Color", "Border")
	local logo = UI.icon("logo", core, 38, "Accent", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 4 })
	parts.logo = logo.Instance
	local function ring(name)
		local frame = Util.new("Frame", {
			Name = name, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3,
		}, emblem)
		Util.round_corner(frame)
		local stroke = Util.new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, frame)
		Theme.bind(stroke, "Color", "Accent")
		return stroke
	end
	local trackStroke = ring("RingTrack")
	trackStroke.Transparency = 0.82
	local arcStroke = ring("RingArc")
	local arc = Util.new("UIGradient", { Rotation = 0 }, arcStroke)
	arc.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 1), NumberSequenceKeypoint.new(1, 1),
	})
	parts.arc, parts.trackStroke, parts.arcStroke = arc, trackStroke, arcStroke

	-- title / subtitle ---------------------------------------------------------------------------
	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 148), Size = UDim2.new(1, 0, 0, 36),
		Text = "VIREX  /  HUB", ZIndex = 3, TextColor3 = Color3.new(1, 1, 1),
	}, card)
	Typo.apply(title, "display", 28)
	local sheenGradient = Util.new("UIGradient", { Rotation = 18, Offset = Vector2.new(1, 0) }, title)
	Theme.gradient(sheenGradient, Theme.G.sheen)
	parts.sheen = sheenGradient

	local subtitle = Util.new("TextLabel", {
		Name = "Subtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 185), Size = UDim2.new(1, 0, 0, 16),
		Text = "ANDROID EDITION  -  V" .. CONFIG.Version, ZIndex = 3,
	}, card)
	Typo.apply(subtitle, "label", 11)
	Theme.bind(subtitle, "TextColor3", "Muted")

	-- status / progress ----------------------------------------------------------------------------
	local status = Util.new("TextLabel", {
		Name = "Status", BackgroundTransparency = 1, Position = UDim2.fromOffset(32, 220), Size = UDim2.new(1, -110, 0, 18),
		Text = "Starting...", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, card)
	Typo.apply(status, "button", 13)
	Theme.bind(status, "TextColor3", "Text")
	local counter = Util.new("TextLabel", {
		Name = "Counter", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -32, 0, 221),
		Size = UDim2.fromOffset(60, 16), Text = "", TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3,
	}, card)
	Typo.apply(counter, "caption", 11)
	Theme.bind(counter, "TextColor3", "Muted")

	local track = Util.new("Frame", {
		Name = "Track", Position = UDim2.fromOffset(32, 246), Size = UDim2.new(1, -64, 0, 4), BorderSizePixel = 0, ZIndex = 3,
	}, card)
	Util.round_corner(track)
	Theme.bind(track, "BackgroundColor3", "Track")
	local fill = Util.new("Frame", {
		Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 4,
	}, track)
	Util.round_corner(fill)
	Theme.gradient(Util.new("UIGradient", { Rotation = 0 }, fill), Theme.G.accent)
	local fillSheen = Util.new("Frame", {
		Name = "Sheen", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5,
	}, fill)
	Util.round_corner(fillSheen)
	local fillSheenGradient = Util.new("UIGradient", { Offset = Vector2.new(-1, 0) }, fillSheen)
	fillSheenGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.55), NumberSequenceKeypoint.new(1, 1),
	})
	parts.fillSheen = fillSheenGradient

	local detail = Util.new("TextLabel", {
		Name = "Detail", BackgroundTransparency = 1, Position = UDim2.fromOffset(32, 260), Size = UDim2.new(1, -64, 0, 16),
		Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, card)
	Typo.apply(detail, "caption", 11)
	Theme.bind(detail, "TextColor3", "Faint")

	local tap = Util.new("TextButton", {
		Name = "Continue", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 8, Visible = false,
	}, card)

	parts.gui, parts.holder, parts.card, parts.scale, parts.fit = gui, holder, card, scale, fit
	parts.status, parts.counter, parts.fill, parts.detail, parts.tap = status, counter, fill, detail, tap
	parts.strokeGradient, parts.emblem, parts.core = strokeGradient, emblem, core
	parts.backdrop, parts.title = backdrop, title

	-- entrance --------------------------------------------------------------------------------------
	parts.fade = snapshotFade(holder)
	hideNow(parts.fade)
	local backdropRest = 0.2
	backdrop.BackgroundTransparency = 1
	gui.Parent = container
	Splash.gui = gui
	Splash.isOpen = true

	task.defer(function()
		if not Splash.isOpen or Splash.closing then
			return
		end
		parts.drawn = true
		fadeTo(parts.fade, false, 0.5)
		Motion.tween(backdrop, { BackgroundTransparency = backdropRest }, 0.4, Enum.EasingStyle.Quad)
		Motion.tween(scale, { Scale = fit }, 0.55, Enum.EasingStyle.Quart)
		if CONFIG.Sounds.loading and Store.get("splashSound") then
			parts.music = Sfx.playTracked("loading")
		end
		if Motion.reduced then
			sheenGradient.Offset = Vector2.new(1, 0)
		else
			Anim.add("splash", function(_, now)
				arc.Rotation = (now * 300) % 360
				strokeGradient.Rotation = (now * 24) % 360
				logo.Instance.Rotation = 2.4 * math.sin(now * 1.7)
				local phase = (now / 2.2) % 1
				local travel = 0.6
				local a = phase < travel and (phase / travel) or 1
				sheenGradient.Offset = Vector2.new(-1 + 2 * Motion.ease.inOutSine(a), 0)
				fillSheenGradient.Offset = Vector2.new(-1 + 2 * ((now / 1.4) % 1), 0)
			end, 30)
		end
	end)
	return gui
end

-- Reports REAL progress. text = stage name, done / total = completed boot steps, partial = 0..1 of the current one
function Splash.step(text, done, total, partial)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing or not parts.status then
		return
	end
	if text then
		setStatusText(parts.status, text)
	end
	local fraction = Util.clamp((done + (partial or 0)) / math.max(total, 1), 0, 1)
	if fraction > Splash.fraction then
		Splash.fraction = fraction
		Motion.tween(parts.fill, { Size = UDim2.fromScale(fraction, 1) }, 0.4, Enum.EasingStyle.Quart)
	end
	parts.counter.Text = string.format("%d / %d", math.min(done + 1, total), total)
end

function Splash.detail(text, role)
	local parts = Splash.parts
	if parts.detail then
		parts.detail.Text = tostring(text or "")
		Theme.bind(parts.detail, "TextColor3", role or "Faint")
	end
end

local function finishClose(onClosed)
	Anim.remove("splash")
	local gui = Splash.gui
	Splash.gui, Splash.isOpen = nil, false
	Splash.parts = {}
	if gui then
		pcall(gui.Destroy, gui)
	end
	UI.prune()
	if onClosed then
		Util.try("splash onClosed", onClosed)
	end
end

-- fade-out then destroy. onHandoff() runs when the fade begins (the hub window opens under it).
function Splash.close(onHandoff, onClosed)
	if Splash.closing or not Splash.isOpen then
		if onClosed and not Splash.isOpen then
			Util.try("splash onClosed", onClosed)
		end
		return
	end
	Splash.closing = true
	local parts = Splash.parts
	if parts.music then
		parts.music.Stop(0.35)
	end
	Sfx.play("open")
	if onHandoff then
		Util.try("splash handoff", onHandoff)
	end
	if Motion.reduced or not parts.fade then
		finishClose(onClosed)
		return
	end
	fadeTo(parts.fade, true, 0.32, Enum.EasingStyle.Quad)
	Motion.tween(parts.backdrop, { BackgroundTransparency = 1 }, 0.38, Enum.EasingStyle.Quad)
	Motion.tween(parts.scale, { Scale = parts.fit * 0.94 }, 0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.42, function()
		finishClose(onClosed)
	end)
end

-- All real work finished: fill the track, keep the screen for the brand moment, then hand off.
function Splash.ready(onHandoff, onClosed)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing then
		return
	end
	setStatusText(parts.status, "Ready")
	parts.counter.Text = ""
	if Splash.fraction < 1 then
		Splash.fraction = 1
		Motion.tween(parts.fill, { Size = UDim2.fromScale(1, 1) }, 0.35, Enum.EasingStyle.Quart)
	end
	Motion.tween(parts.arcStroke, { Transparency = 1 }, 0.5)
	Motion.tween(parts.trackStroke, { Transparency = 0.45 }, 0.5)
	Sfx.play("success")
	if not Motion.reduced then
		local ripple = Util.new("Frame", {
			Name = "Ripple", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(66, 66),
			BackgroundTransparency = 1, ZIndex = 2,
		}, parts.emblem)
		Util.round_corner(ripple)
		local stroke = Util.new("UIStroke", { Thickness = 2, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, ripple)
		Theme.bind(stroke, "Color", "Accent")
		Motion.tween(stroke, { Transparency = 1 }, 0.7)
		Motion.tween(ripple, { Size = UDim2.fromOffset(130, 130) }, 0.7, Enum.EasingStyle.Quart)
	end
	parts.tap.Visible = true
	parts.tap.Activated:Connect(function()
		Splash.close(onHandoff, onClosed)
	end)
	task.spawn(function()
		local minimum = CONFIG.Splash.MinSeconds
		while Splash.isOpen and not Splash.closing and os.clock() - Splash.createdAt < minimum do
			task.wait(0.05)
		end
		if Splash.isOpen and not Splash.closing then
			task.wait(CONFIG.Splash.HoldSeconds)
		end
		Splash.close(onHandoff, onClosed)
	end)
end

-- Something essential failed: say so honestly, then close.
function Splash.fail(message, onClosed)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing then
		return
	end
	if parts.music then
		parts.music.Stop(0.2)
	end
	Sfx.play("error")
	setStatusText(parts.status, "Startup problem")
	Theme.bind(parts.status, "TextColor3", "Danger")
	Theme.bind(parts.detail, "TextColor3", "Danger")
	parts.detail.Text = Util.cap(tostring(message or "Unknown error"), 90)
	Theme.bind(parts.arcStroke, "Color", "Danger")
	Motion.tween(parts.fill, { Size = UDim2.fromScale(1, 1) }, 0.3)
	task.delay(2.6, function()
		Splash.close(nil, onClosed)
	end)
end

function Splash.destroy()
	Anim.remove("splash")
	if Splash.parts.music then
		Splash.parts.music.Stop(0)
	end
	if Splash.gui then
		pcall(Splash.gui.Destroy, Splash.gui)
	end
	Splash.gui, Splash.isOpen, Splash.closing, Splash.parts = nil, false, false, {}
end
end -- [09_splash.lua]

do -- [10_avatar.lua]

----------------------------------------------------------------------------------------------------
-- Avatar: ported from AVATAR-CHANGER.lua (returnreturnfunction) and extended with input validation,
-- player look-up with a preview, one-operation-at-a-time protection, honest result messages and a
-- favourites list stored in the hub config.
-- It uses Roblox's HumanoidDescription API from the CLIENT. Whether the experience accepts the change,
-- keeps it after a respawn, or shows it to other players is decided by the experience, not by this hub.
----------------------------------------------------------------------------------------------------
local MarketplaceService = optionalService("MarketplaceService")

Avatar.busy = false
Avatar.names = {}       -- userId -> username cache
Avatar.current = nil    -- userId of the look that was applied through this hub (nil = your own)
Avatar.listeners = {}
Avatar.hooks = {}       -- status(kind, text) / resolved(userId, name), set by the page
Avatar.ui = {}

function Avatar.notify()
	for _, fn in ipairs(Util.copy(Avatar.listeners)) do
		Util.try("avatar listener", fn)
	end
end

function Avatar.onChange(fn)
	Avatar.listeners[#Avatar.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Avatar.listeners, fn)
		if index then
			table.remove(Avatar.listeners, index)
		end
	end
end

local function say(kind, text)
	local fn = Avatar.hooks.status
	if fn then
		Util.try("avatar status", fn, kind, text)
	end
end

local function sawUser(userId, name)
	local fn = Avatar.hooks.resolved
	if fn then
		Util.try("avatar resolved", fn, userId, name)
	end
end

function Avatar.thumb(userId)
	return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=100&h=100", math.floor(userId))
end

-- "12345" -> "id", 12345   |   "Roblox" -> "name", "Roblox"   |   bad input -> nil, reason
function Avatar.parseTarget(text)
	text = Util.trim(text)
	if text == "" then
		return nil, "Enter a user ID or a username first."
	end
	if string.match(text, "^%d+$") then
		local id = tonumber(text)
		if #text > 12 or id == nil or id < 1 then
			return nil, "That user ID is out of range."
		end
		return "id", id
	end
	if string.match(text, "^[%w_]+$") and #text >= 3 and #text <= 20 then
		return "name", text
	end
	return nil, "Usernames use letters, numbers and underscores (3-20 characters)."
end

-- yields. Returns name or nil
function Avatar.nameFor(userId)
	if Avatar.names[userId] then
		return Avatar.names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	if ok and type(name) == "string" and name ~= "" then
		Avatar.names[userId] = name
		return name
	end
	return nil
end

-- yields. Returns userId, name  |  nil, reason
function Avatar.resolve(text)
	local kind, value = Avatar.parseTarget(text)
	if not kind then
		return nil, value
	end
	if kind == "id" then
		local name = Avatar.nameFor(value)
		if not name then
			return nil, "Could not find a Roblox user with ID " .. value .. " (or Roblox did not answer)."
		end
		return value, name
	end
	local ok, id = pcall(Players.GetUserIdFromNameAsync, Players, value)
	if not ok or type(id) ~= "number" then
		return nil, "Could not find a Roblox user named '" .. value .. "' (or Roblox did not answer)."
	end
	Avatar.names[id] = value
	return id, value
end

-- returns humanoid, character  |  nil, nil, reason
function Avatar.character()
	local player = Players.LocalPlayer
	local character = player and player.Character
	if not character then
		return nil, nil, "Your character has not loaded yet."
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil, "Your character has no Humanoid in this experience."
	end
	return humanoid, character
end

-- yields. Tries the documented method name first, then the one used by the original script.
function Avatar.description(userId)
	local lastError = "HumanoidDescription lookup is unavailable."
	for _, method in ipairs({ "GetHumanoidDescriptionFromUserId", "GetHumanoidDescriptionFromUserIdAsync" }) do
		local ok, result = pcall(function()
			return Players[method](Players, userId)
		end)
		if ok and typeof(result) == "Instance" then
			return result
		end
		lastError = tostring(result)
	end
	return nil, lastError
end

-- yields. Returns true, methodName  |  false, reason
function Avatar.applyDescription(humanoid, description)
	local lastError = "no apply method available"
	for _, method in ipairs({ "ApplyDescriptionClientServer", "ApplyDescription" }) do
		local ok, err = pcall(function()
			humanoid[method](humanoid, description)
		end)
		if ok then
			return true, method
		end
		lastError = tostring(err)
	end
	return false, lastError
end

-- The original script re-parents a fresh copy of "Animate" so animations match the new body.
local function refreshAnimate(character)
	pcall(function()
		task.wait(0.1)
		local animate = character:FindFirstChild("Animate")
		if animate and character.Parent then
			local copy = animate:Clone()
			animate:Destroy()
			copy.Parent = character
		end
	end)
end

-- yields. Runs ONE avatar operation at a time. fn() returns ok, message.
function Avatar.exclusive(fn)
	if Avatar.busy then
		return false, "Another avatar change is still running."
	end
	Avatar.busy = true
	Avatar.notify()
	local ran, ok, message = pcall(fn)
	Avatar.busy = false
	Avatar.notify()
	if not ran then
		Util.log("error", "avatar operation: " .. tostring(ok))
		return false, "Unexpected error: " .. Util.cap(tostring(ok), 80)
	end
	return ok, message
end

-- yields. The real work of "wear this user". Only call inside Avatar.exclusive.
local function wearUser(userId, name)
	local humanoid, _, problem = Avatar.character()
	if not humanoid then
		return false, problem
	end
	say("working", "Fetching " .. (name or ("user " .. userId)) .. "'s outfit...")
	local description, lookupError = Avatar.description(userId)
	if not description then
		return false, "Roblox refused the outfit lookup (" .. Util.cap(tostring(lookupError), 60) .. ")."
	end
	-- the character can respawn while we waited for the network, so fetch it again
	local liveHumanoid, character, stale = Avatar.character()
	if not liveHumanoid then
		return false, stale
	end
	say("working", "Applying the outfit...")
	local applied, how = Avatar.applyDescription(liveHumanoid, description)
	if not applied then
		return false, "The experience blocked the change (" .. Util.cap(tostring(how), 60) .. ")."
	end
	refreshAnimate(character)
	Avatar.current = userId
	return true, "Applied with " .. how .. ". The experience decides who can see it and whether it survives a respawn."
end

-- yields. Resolves a typed ID / username, then applies that look.
function Avatar.changeTo(text)
	return Avatar.exclusive(function()
		say("working", "Looking up " .. Util.cap(text, 24) .. "...")
		local userId, name = Avatar.resolve(text)
		if not userId then
			return false, name
		end
		sawUser(userId, name)
		Store.set("lastTarget", tostring(userId))
		return wearUser(userId, name)
	end)
end

-- yields. Applies a look for a user that is already known (favourites).
function Avatar.changeToId(userId, name)
	return Avatar.exclusive(function()
		sawUser(userId, name or Avatar.names[userId])
		Store.set("lastTarget", tostring(userId))
		return wearUser(userId, name or Avatar.names[userId])
	end)
end

-- yields. Picks random IDs until one belongs to a real account, then applies it.
function Avatar.randomUser()
	return Avatar.exclusive(function()
		for attempt = 1, 6 do
			local userId = math.random(10000000, 500000000)
			say("working", string.format("Finding a random player (try %d of 6)...", attempt))
			local name = Avatar.nameFor(userId)
			if name then
				sawUser(userId, name)
				return wearUser(userId, name)
			end
			task.wait(0.3)
		end
		return false, "Could not find an available random player. Try again."
	end)
end

-- yields. Puts your own outfit back.
function Avatar.restoreOwn()
	local player = Players.LocalPlayer
	if not player then
		return false, "There is no local player."
	end
	return Avatar.exclusive(function()
		local shown = player.DisplayName
		if shown == nil or shown == "" then
			shown = player.Name
		end
		local ok, message = wearUser(player.UserId, shown)
		if ok then
			Avatar.current = nil
			message = "Your own avatar was restored."
		end
		return ok, message
	end)
end

-- yields. expectedType: 11 = Shirt, 12 = Pants. Unverifiable IDs are allowed through (flagged).
function Avatar.checkAsset(assetId, expectedType, label)
	if not MarketplaceService then
		return true, false
	end
	local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, assetId, Enum.InfoType.Asset)
	if not ok or type(info) ~= "table" then
		return true, false
	end
	local actual = info.AssetTypeId
	if type(actual) == "number" and actual ~= expectedType then
		return false, string.format("%s ID %d is not a %s item.", label, assetId, string.lower(label))
	end
	return true, true
end

-- yields. Classic clothing. Either id may be nil.
function Avatar.applyClothing(shirtId, pantsId)
	if not shirtId and not pantsId then
		return false, "Enter a Shirt ID, a Pants ID, or both."
	end
	return Avatar.exclusive(function()
		local unverified = false
		if shirtId then
			say("working", "Checking the shirt...")
			local ok, detail = Avatar.checkAsset(shirtId, 11, "Shirt")
			if not ok then
				return false, detail
			end
			unverified = unverified or detail == false
		end
		if pantsId then
			say("working", "Checking the pants...")
			local ok, detail = Avatar.checkAsset(pantsId, 12, "Pants")
			if not ok then
				return false, detail
			end
			unverified = unverified or detail == false
		end
		local humanoid, _, problem = Avatar.character()
		if not humanoid then
			return false, problem
		end
		local gotDescription, description = pcall(humanoid.GetAppliedDescription, humanoid)
		if not gotDescription or typeof(description) ~= "Instance" then
			return false, "Could not read your current outfit."
		end
		if shirtId then
			description.Shirt = shirtId
		end
		if pantsId then
			description.Pants = pantsId
		end
		say("working", "Applying clothing...")
		local applied, how = Avatar.applyDescription(humanoid, description)
		if not applied then
			return false, "The experience blocked the change (" .. Util.cap(tostring(how), 60) .. ")."
		end
		local _, character = Avatar.character()
		if character then
			refreshAnimate(character)
		end
		return true, unverified and "Clothing applied (the IDs could not be verified with Roblox)." or "Clothing applied."
	end)
end

----------------------------------------------------------------------------------------------------
-- favourites
----------------------------------------------------------------------------------------------------
function Avatar.isFavorite(userId)
	return Util.indexOf(Store.get("favorites"), userId) ~= nil
end

function Avatar.addFavorite(userId)
	local list = Util.copy(Store.get("favorites"))
	if Util.indexOf(list, userId) then
		return false, "Already in your favourites."
	end
	if #list >= 60 then
		return false, "Favourites are full (60)."
	end
	list[#list + 1] = userId
	Store.set("favorites", list)
	return true
end

function Avatar.removeFavorite(userId)
	local list = Util.copy(Store.get("favorites"))
	local index = Util.indexOf(list, userId)
	if not index then
		return false
	end
	table.remove(list, index)
	Store.set("favorites", list)
	return true
end

----------------------------------------------------------------------------------------------------
-- Avatar page
----------------------------------------------------------------------------------------------------
local FAV_RIGHT = 134 -- pixels reserved on the right of a favourites row (Apply + remove)

-- A set of buttons laid out in 1-3 rows. On a narrow page they wrap onto their own lines so no label is ever cut off.
-- plans: widest first; each is { minWidth = pageWidth, slots = { { row, widthScale, widthOffset }, ... } } (one slot per button).
local function buttonRows(parent, name, order, rowCount, plans)
	local host = Util.new("Frame", {
		Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order,
	}, parent)
	Util.list(host, 8)
	local set = { host = host, rows = {}, items = {}, plans = plans }
	for index = 1, rowCount do
		local row = Util.new("Frame", {
			Name = "Row" .. index, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = index, Visible = index == 1,
		}, host)
		Util.list(row, 8, true)
		set.rows[index] = row
	end
	function set.place(pageWidth)
		pageWidth = pageWidth or 400
		local plan = plans[#plans]
		for _, candidate in ipairs(plans) do
			if pageWidth >= candidate.minWidth then
				plan = candidate
				break
			end
		end
		local used = {}
		for index, button in ipairs(set.items) do
			local slot = plan.slots[index]
			if slot then
				local inst = button.Instance
				inst.Parent = set.rows[slot[1]]
				inst.Size = UDim2.new(slot[2], slot[3], 1, 0)
				used[slot[1]] = true
			end
		end
		for index, row in ipairs(set.rows) do
			row.Visible = used[index] == true
		end
	end
	function set.add(button)
		set.items[#set.items + 1] = button
		return button
	end
	Pages.gridUpdaters[#Pages.gridUpdaters + 1] = set.place
	return set
end

function Avatar.buildPage(page)
	local ui = {}
	Avatar.ui = ui
	local buttons = {}      -- every button that must be disabled while an operation runs
	local rowButtons = {}   -- favourites rows' Apply buttons (rebuilt with the list)
	local renderedCurrent = nil
	local savingFavorite = false

	-- status line -------------------------------------------------------------------------------
	local statusRoles = { idle = "Muted", working = "Accent", ok = "Green", error = "Danger" }
	local function setStatus(kind, text)
		if not ui.status then
			return
		end
		ui.status.Text = tostring(text)
		Theme.tweenRole(ui.status, "TextColor3", statusRoles[kind] or "Muted", 0.2)
	end

	local function setBusyLook()
		local busy = Avatar.busy
		local reason = busy and "Please wait for the current avatar change to finish." or nil
		for _, button in ipairs(buttons) do
			button.SetEnabled(not busy, reason)
		end
		for _, button in ipairs(rowButtons) do
			button.SetEnabled(not busy, reason)
		end
	end

	-- runs a yielding avatar action with status + toast feedback
	local function run(action)
		if Avatar.busy then
			Notify.warn("Please wait", "Another avatar change is still running.")
			return
		end
		task.spawn(function()
			local ok, message = action()
			message = tostring(message or "")
			if ok then
				setStatus("ok", message)
				Notify.success("Avatar updated", Util.cap(message, 110))
			else
				setStatus("error", message)
				Notify.error("Avatar change failed", Util.cap(message, 120))
			end
		end)
	end

	Avatar.hooks.status = setStatus

	-- target card -------------------------------------------------------------------------------
	UI.section(page, "Change avatar", 1)
	local card = UI.card({
		parent = page, order = 2, stack = true, controlHeight = 0, name = "TargetCard",
		title = "Copy a player's look",
		desc = "Type a user ID or username. VirexHub asks Roblox for that player's outfit and applies it to your character. Some experiences block or reset avatar changes.",
	})
	local box = card.Controls
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.Size = UDim2.new(1, 0, 0, 0)
	Util.list(box, 8)

	local function submit()
		local text = ui.input.Get()
		local kind, reason = Avatar.parseTarget(text)
		if not kind then
			ui.input.Flash()
			setStatus("error", reason)
			Notify.warn("Check the target", reason)
			return
		end
		run(function()
			return Avatar.changeTo(text)
		end)
	end

	local inputRow = Util.new("Frame", { Name = "InputRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 1 }, box)
	ui.input = UI.input({
		parent = inputRow, size = UDim2.new(1, -92, 1, 0), placeholder = "User ID or username", maxLength = 24, name = "Target",
		text = Store.get("lastTarget"),
		onSubmit = function(_, enter)
			if enter then
				submit()
			end
		end,
	})
	ui.apply = UI.button({
		parent = inputRow, text = "Apply", kind = "primary", size = UDim2.fromOffset(84, 38), anchor = Vector2.new(1, 0),
		position = UDim2.new(1, 0, 0, 0), name = "Apply", onClick = submit,
	})
	buttons[#buttons + 1] = ui.apply

	-- preview of the last player that was looked up (validation feedback) -----------------------
	local preview = Util.new("Frame", { Name = "Preview", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = 2 }, box)
	Util.corner(preview, 10)
	Theme.bind(preview, "BackgroundColor3", "Panel")
	local previewStroke = Util.stroke(preview, nil, 1, 0.25)
	Theme.bind(previewStroke, "Color", "Border")
	ui.thumb = Util.new("ImageLabel", {
		Name = "Thumb", Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(36, 36), BorderSizePixel = 0, Image = "",
	}, preview)
	Util.round_corner(ui.thumb)
	Theme.bind(ui.thumb, "BackgroundColor3", "Track")
	ui.previewName = Util.new("TextLabel", {
		Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(54, 8), Size = UDim2.new(1, -64, 0, 18),
		Text = "No player yet", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, preview)
	Typo.apply(ui.previewName, "heading", 13)
	Theme.bind(ui.previewName, "TextColor3", "Text")
	ui.previewSub = Util.new("TextLabel", {
		Name = "Sub", BackgroundTransparency = 1, Position = UDim2.fromOffset(54, 27), Size = UDim2.new(1, -64, 0, 16),
		Text = "Press Apply first.", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, preview)
	Typo.apply(ui.previewSub, "caption", 11)
	Theme.bind(ui.previewSub, "TextColor3", "Muted")

	local previewId = nil
	local function showPreview(userId, name)
		previewId = userId
		ui.thumb.Image = Avatar.thumb(userId)
		ui.previewName.Text = name or ("User " .. userId)
		local worn = Avatar.current == userId
		ui.previewSub.Text = "ID " .. userId .. (worn and "  -  worn now" or "")
		Theme.tweenRole(ui.previewSub, "TextColor3", worn and "Accent" or "Muted", 0.2)
		Theme.tweenRole(previewStroke, "Color", worn and "Accent" or "Border", 0.2)
	end
	Avatar.hooks.resolved = showPreview

	-- action row ---------------------------------------------------------------------------------
	local actions = buttonRows(box, "Actions", 3, 3, {
		{ minWidth = 410, slots = { { 1, 1 / 3, -6 }, { 1, 1 / 3, -6 }, { 1, 1 / 3, -6 } } },
		{ minWidth = 270, slots = { { 1, 0.5, -4 }, { 1, 0.5, -4 }, { 2, 1, 0 } } },
		{ minWidth = 0, slots = { { 1, 1, 0 }, { 2, 1, 0 }, { 3, 1, 0 } } },
	})
	local function actionButton(text, order, handler)
		local button = UI.button({
			parent = actions.rows[1], text = text, small = true, order = order, size = UDim2.new(1 / 3, -6, 1, 0), onClick = handler,
		})
		buttons[#buttons + 1] = button
		return actions.add(button)
	end
	actionButton("Random", 1, function()
		run(function()
			return Avatar.randomUser()
		end)
	end)
	actionButton("Reset to mine", 2, function()
		run(function()
			return Avatar.restoreOwn()
		end)
	end)
	actionButton("Save favourite", 3, function()
		if savingFavorite then
			return
		end
		local text = ui.input.Get()
		local kind, reason = Avatar.parseTarget(text)
		if not kind then
			ui.input.Flash()
			Notify.warn("Check the target", reason)
			return
		end
		savingFavorite = true
		task.spawn(function()
			local userId, name = Avatar.resolve(text)
			savingFavorite = false
			if not userId then
				ui.input.Flash()
				Notify.error("User not found", Util.cap(name, 110))
				return
			end
			showPreview(userId, name)
			local added, why = Avatar.addFavorite(userId)
			if added then
				Notify.success("Saved", name .. " was added to your favourites.")
			else
				Notify.info("Not saved", why or "Already saved.")
			end
		end)
	end)

	actions.place(Win.pageW)

	ui.status = Util.new("TextLabel", {
		Name = "Status", BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = "Ready.", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, box)
	Typo.apply(ui.status, "caption", 12)
	Theme.bind(ui.status, "TextColor3", "Muted")

	-- clothing ------------------------------------------------------------------------------------
	UI.section(page, "Clothing", 3)
	local clothes = UI.card({
		parent = page, order = 4, stack = true, controlHeight = 0, name = "ClothingCard", title = "Classic shirt and pants",
		desc = "Paste the item ID from the catalog link (the number in the URL). Leave one empty to keep it unchanged. Each ID is checked with Roblox first.",
	})
	local cbox = clothes.Controls
	cbox.AutomaticSize = Enum.AutomaticSize.Y
	cbox.Size = UDim2.new(1, 0, 0, 0)
	Util.list(cbox, 8)
	local clothRow = Util.new("Frame", { Name = "Ids", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 1 }, cbox)
	Util.new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
	}, clothRow)
	ui.shirt = UI.input({
		parent = clothRow, size = UDim2.new(0.5, -4, 1, 0), placeholder = "Shirt ID", numeric = true, maxLength = 13, order = 1, name = "Shirt",
	})
	ui.pants = UI.input({
		parent = clothRow, size = UDim2.new(0.5, -4, 1, 0), placeholder = "Pants ID", numeric = true, maxLength = 13, order = 2, name = "Pants",
	})
	local clothAction = buttonRows(cbox, "Buttons", 2, 2, {
		{ minWidth = 300, slots = { { 1, 0.5, -4 }, { 1, 0.5, -4 } } },
		{ minWidth = 0, slots = { { 1, 1, 0 }, { 2, 1, 0 } } },
	})
	buttons[#buttons + 1] = clothAction.add(UI.button({
		parent = clothAction.rows[1], text = "Apply clothing", kind = "primary", small = true, order = 1, size = UDim2.new(0.5, -4, 1, 0),
		onClick = function()
			local shirt, pants = tonumber(ui.shirt.Get()), tonumber(ui.pants.Get())
			if shirt and shirt < 1 then
				shirt = nil
			end
			if pants and pants < 1 then
				pants = nil
			end
			if not shirt and not pants then
				ui.shirt.Flash()
				ui.pants.Flash()
				Notify.warn("Nothing to apply", "Enter a Shirt ID, a Pants ID, or both.")
				return
			end
			run(function()
				return Avatar.applyClothing(shirt, pants)
			end)
		end,
	}))
	buttons[#buttons + 1] = clothAction.add(UI.button({
		parent = clothAction.rows[1], text = "Restore my outfit", kind = "ghost", small = true, order = 2, size = UDim2.new(0.5, -4, 1, 0),
		onClick = function()
			run(function()
				return Avatar.restoreOwn()
			end)
		end,
	}))
	clothAction.place(Win.pageW)

	-- favourites ----------------------------------------------------------------------------------
	UI.section(page, "Favourites", 5)
	local listHost = Util.new("Frame", {
		Name = "Favorites", BackgroundTransparency = 1, LayoutOrder = 6, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	}, page)
	Util.list(listHost, 8)

	local function renderFavorites()
		for _, child in ipairs(listHost:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		rowButtons = {}
		UI.prune()
		renderedCurrent = Avatar.current
		local list = Store.get("favorites")
		if #list == 0 then
			UI.card({
				parent = listHost, order = 1, name = "Empty", title = "No favourites yet",
				desc = "Type a player above and press 'Save favourite' to keep them here for one-tap use.",
			})
			return
		end
		local pending = {}
		for index, userId in ipairs(list) do
			local worn = Avatar.current == userId
			local row = Util.new("Frame", { Name = "Fav" .. userId, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 60), LayoutOrder = index }, listHost)
			Theme.surface(row, "Card", "card")
			Util.corner(row, 12)
			local stroke = Util.stroke(row, nil, worn and 1.5 or 1, worn and 0 or 0.15)
			Theme.bind(stroke, "Color", worn and "Accent" or "Border")
			local picture = Util.new("ImageLabel", {
				Name = "Thumb", Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(44, 44), BorderSizePixel = 0,
				Image = Avatar.thumb(userId),
			}, row)
			Util.round_corner(picture)
			Theme.bind(picture, "BackgroundColor3", "Track")
			local nameLabel = Util.new("TextLabel", {
				Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(64, 10), Size = UDim2.new(1, -(64 + FAV_RIGHT), 0, 20),
				Text = Avatar.names[userId] or ("User " .. userId), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
			Typo.apply(nameLabel, "heading", 13)
			Theme.bind(nameLabel, "TextColor3", "Text")
			local idLabel = Util.new("TextLabel", {
				Name = "Id", BackgroundTransparency = 1, Position = UDim2.fromOffset(64, 31), Size = UDim2.new(1, -(64 + FAV_RIGHT), 0, 18),
				Text = "ID " .. userId .. (worn and "  -  worn now" or ""), TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
			Typo.apply(idLabel, "caption", 11)
			Theme.bind(idLabel, "TextColor3", worn and "Accent" or "Muted")
			if not Avatar.names[userId] then
				pending[#pending + 1] = { id = userId, label = nameLabel }
			end
			local wear = UI.button({
				parent = row, text = worn and "Worn" or "Apply", small = true, kind = worn and "secondary" or "primary",
				size = UDim2.fromOffset(70, 34), anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -52, 0.5, 0), name = "Wear",
				onClick = function()
					run(function()
						return Avatar.changeToId(userId, Avatar.names[userId])
					end)
				end,
			})
			rowButtons[#rowButtons + 1] = wear
			UI.button({
				parent = row, text = "", icon = "close", kind = "ghost", size = UDim2.fromOffset(34, 34), anchor = Vector2.new(1, 0.5),
				position = UDim2.new(1, -10, 0.5, 0), name = "Remove", sound = "close", onClick = function()
					if Avatar.removeFavorite(userId) then
						Notify.info("Removed", (Avatar.names[userId] or ("User " .. userId)) .. " was removed from favourites.")
					end
				end,
			})
		end
		setBusyLook()
		if #pending > 0 then
			-- one slow worker instead of 60 parallel requests; stops when the list is rebuilt
			Avatar.nameToken = (Avatar.nameToken or 0) + 1
			local token = Avatar.nameToken
			task.spawn(function()
				for _, entry in ipairs(pending) do
					if token ~= Avatar.nameToken then
						return
					end
					local name = Avatar.nameFor(entry.id)
					if name and entry.label.Parent then
						entry.label.Text = name
					end
					task.wait(0.12)
				end
			end)
		end
	end
	ui.render = renderFavorites
	renderFavorites()

	Avatar.onChange(function()
		if not listHost.Parent then
			return
		end
		setBusyLook()
		if Avatar.current ~= renderedCurrent then
			renderFavorites()
			if previewId then
				showPreview(previewId, Avatar.names[previewId])
			end
		end
	end)
	Store.on("favorites", function()
		if listHost.Parent then
			renderFavorites()
		end
	end)
	return ui
end
end -- [10_avatar.lua]

do -- [11_window.lua]

----------------------------------------------------------------------------------------------------
-- Win: the hub window.
--   Window   positioning container (top-centre anchored, UIScale = user scale x fit), holds the shadow
--   Surface  the visible rounded panel (clips everything)
--     BgLayer / TitleBar / Body (sidebar + content) / popup layer / modal layer
-- The window keeps its TITLE BAR in place when it collapses, and its CENTRE when it opens or closes,
-- by tweening Position, Size and Scale together with identical easing.
----------------------------------------------------------------------------------------------------
Win.TITLE_H = 52
Win.COLLAPSED_W = 320
Win.visible = false
Win.minimized = false
Win.x, Win.top = 0, 0         -- top-centre of the window in screen pixels (canonical target)
Win.w, Win.h, Win.s = 760, 510, 1
Win.rail, Win.short = false, false
Win.itemH, Win.gap = 40, 6
Win.ui = {}
Win.nav = {}
Win.pages = {}
Win.currentTab = nil
Win.layoutListeners = {}
Win.focusToken = 0
Win.kbShift = 0
Win.userMoved = false         -- true once the player has dragged the window; until then it stays centred
Win.lastViewport = nil

Win.tabList = {
	{ id = "overview", title = "Overview", desc = "Your current session at a glance.", icon = "grid" },
	{ id = "scripts", title = "Scripts", desc = "Browse, check and run the script catalog.", icon = "scripts" },
	{ id = "avatar", title = "Avatar", desc = "Try looks, clothing and favourites.", icon = "user" },
	{ id = "appearance", title = "Appearance", desc = "Theme, fonts and motion.", icon = "sparkle" },
	{ id = "background", title = "Background", desc = "Image, overlay and transparency.", icon = "image" },
	{ id = "tools", title = "Tools", desc = "Interface and Roblox actions.", icon = "sliders" },
	{ id = "settings", title = "Settings", desc = "Notifications, sound, scale and more.", icon = "gear" },
	{ id = "information", title = "Information", desc = "What's new, controls, status and notices.", icon = "info" },
}
Win.tabById, Win.tabIndex = {}, {}
for index, def in ipairs(Win.tabList) do
	Win.tabById[def.id] = def
	Win.tabIndex[def.id] = index
end

-- popups convert screen pixels to layout units with the window's live scale
UI.scale = function()
	local scaler = Win.scaler
	if scaler and scaler.Parent then
		return scaler.Scale
	end
	return 1
end

----------------------------------------------------------------------------------------------------
-- geometry
----------------------------------------------------------------------------------------------------
-- layout size (in layout units) and total scale for the current viewport / user scale / compact mode
function Win.computeLayout()
	local viewport = Env.viewport()
	local user = Store.get("scale")
	local baseW, baseH = 760, 510
	if Store.get("compact") then
		baseW, baseH = 700, 470
	end
	local availW = (viewport.X - 20) / user
	local availH = (viewport.Y - 20) / user
	local w, h = math.min(baseW, availW), math.min(baseH, availH)
	local minW, minH = 300, 270
	local fit = 1
	if w < minW or h < minH then
		fit = math.min(w / minW, h / minH)
		w, h = math.max(w, minW), math.max(h, minH)
	end
	return math.floor(w + 0.5), math.floor(h + 0.5), user * fit
end

-- size the window should have right now (collapsed to its title bar, or full)
function Win.currentTarget()
	if Win.minimized then
		return math.min(Win.w, Win.COLLAPSED_W), Win.TITLE_H
	end
	return Win.w, Win.h
end

-- keeps the window reachable. widthPx / heightPx are screen pixels.
-- Dragging may push part of the window off screen, but never so far that its title bar can't be grabbed again.
-- `strict` (after a rotation / scale change, on restore and on recentre) pulls the WHOLE window back inside the screen
-- whenever it fits, so a window that nearly fills the screen can't be left hanging over an edge.
function Win.clampPx(x, top, widthPx, heightPx, strict)
	local viewport = Env.viewport()
	local nx, maxTop
	if strict and widthPx <= viewport.X then
		nx = Util.clamp(x, widthPx / 2, viewport.X - widthPx / 2)
	else
		local keep = math.min(220, widthPx - 8)
		nx = Util.clamp(x, keep - widthPx / 2, viewport.X + widthPx / 2 - keep)
	end
	if strict and heightPx <= viewport.Y then
		maxTop = viewport.Y - heightPx
	else
		maxTop = viewport.Y - math.min(heightPx, Win.TITLE_H * Win.s)
	end
	local ny = Util.clamp(top, 0, math.max(0, maxTop))
	return nx, ny
end

-- animates position, size and scale together (same TweenInfo => same progress every frame)
function Win.glide(x, top, width, height, scale, duration, style, direction, onDone)
	local window, scaler = Win.window, Win.scaler
	if not window then
		return
	end
	Motion.tween(window, { Position = UDim2.fromOffset(x, top), Size = UDim2.fromOffset(width, height) }, duration, style, direction)
	Motion.tween(scaler, { Scale = scale }, duration, style, direction, onDone)
end

----------------------------------------------------------------------------------------------------
-- responsive layout: positions every region from (w, h). Immediate, no tweening.
----------------------------------------------------------------------------------------------------
function Win.refreshChrome()
	local ui = Win.ui
	if not ui.titleBar then
		return
	end
	local min = Win.minimized
	ui.clock.Visible = Store.get("clock") and not min and Win.w >= 460
	ui.subtitle.Visible = (not min) and Win.w >= 520
	ui.divider.Visible = not min
	local iconName = min and "restore" or "minus"
	if ui.minIconName ~= iconName then
		ui.minIconName = iconName
		ui.minButton.SetIcon(iconName)
	end
end

function Win.placePill(animate)
	local ui = Win.ui
	local index = Win.tabIndex[Win.currentTab]
	if not ui.pill then
		return
	end
	if not index then
		ui.pill.Visible = false
		return
	end
	ui.pill.Visible = true
	local props = {
		Position = UDim2.fromOffset(0, (index - 1) * (Win.itemH + Win.gap)),
		Size = UDim2.new(1, 0, 0, Win.itemH),
	}
	if animate then
		Motion.tween(ui.pill, props, 0.28, Enum.EasingStyle.Quart)
	else
		Motion.set(ui.pill, props)
	end
end

function Win.applyLayout()
	local ui = Win.ui
	if not ui.body then
		return
	end
	local w, h = Win.w, Win.h
	local rail = w < 600
	local short = h < 430
	Win.rail, Win.short = rail, short
	local bodyH = h - Win.TITLE_H
	ui.body.Size = UDim2.fromOffset(w, bodyH)

	-- sidebar ---------------------------------------------------------------------------------------
	local sidebarW = rail and 62 or 164
	ui.sidebar.Position = UDim2.fromOffset(10, 2)
	ui.sidebar.Size = UDim2.fromOffset(sidebarW, bodyH - 12)
	Win.itemH = short and 36 or 40
	local headingH = (rail or short) and 0 or 26
	ui.heading.Visible = headingH > 0
	local footerH = 0
	if not short then
		footerH = rail and 48 or 58
	end
	ui.footer.Visible = footerH > 0
	ui.footer.Size = UDim2.new(1, -16, 0, footerH)
	ui.footer.Position = UDim2.new(0, 8, 1, -(footerH + 8))
	local navTop = 8 + headingH
	local navBottom = footerH > 0 and (footerH + 16) or 8
	ui.navScroll.Position = UDim2.fromOffset(8, navTop)
	ui.navScroll.Size = UDim2.new(1, -16, 1, -(navTop + navBottom))
	ui.navScroll.CanvasSize = UDim2.fromOffset(0, #Win.tabList * (Win.itemH + Win.gap))
	for index, item in ipairs(Win.nav) do
		item.hit.Position = UDim2.fromOffset(0, (index - 1) * (Win.itemH + Win.gap))
		item.hit.Size = UDim2.new(1, 0, 0, Win.itemH)
		item.label.Visible = not rail
		local icon = item.icon.Instance
		if rail then
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.fromScale(0.5, 0.5)
		else
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 12, 0.5, 0)
		end
	end
	Win.placePill(false)

	-- footer card ------------------------------------------------------------------------------------
	ui.footerName.Visible = not rail
	ui.footerStatus.Visible = not rail
	ui.footerDot.Visible = rail
	ui.footerThumb.AnchorPoint = rail and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
	ui.footerThumb.Position = rail and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 9, 0.5, 0)

	-- content ----------------------------------------------------------------------------------------
	local x0 = 10 + sidebarW + 10
	ui.content.Position = UDim2.fromOffset(x0, 0)
	ui.content.Size = UDim2.fromOffset(math.max(120, w - x0 - 12), bodyH - 6)
	Win.pageW = math.max(120, w - x0 - 12) - 7 -- usable width of a page (its scroll bar padding removed)
	Typo.apply(ui.pageTitle, "title", short and 18 or 21)
	ui.pageTitle.Size = UDim2.new(1, -4, 0, short and 26 or 28)
	ui.pageTitle.Position = UDim2.fromOffset(2, short and 2 or 4)
	ui.pageSub.Visible = not short
	local headerH = short and 32 or 58
	ui.pageHost.Position = UDim2.fromOffset(0, headerH)
	ui.pageHost.Size = UDim2.new(1, 0, 1, -headerH)

	Win.refreshChrome()
	for _, listener in ipairs(Util.copy(Win.layoutListeners)) do
		Util.try("layout listener", listener, w, h, rail, short)
	end
end

-- recompute everything for the current viewport / scale / compact setting
function Win.relayout(animate)
	local window = Win.window
	if not window then
		return
	end
	local w, h, s = Win.computeLayout()
	Win.w, Win.h, Win.s = w, h, s
	Win.applyLayout()
	local cw, ch = Win.currentTarget()
	local viewport = Env.viewport()
	local last = Win.lastViewport
	Win.lastViewport = viewport
	if not Win.userMoved then
		-- never dragged: stay centred whatever the screen / scale does (a collapsed window keeps its title bar's height)
		Win.x = viewport.X / 2
		if not Win.minimized then
			Win.top = math.max(10, (viewport.Y - ch * s) / 2)
		end
	elseif last and last.X > 0 and last.Y > 0 and (last.X ~= viewport.X or last.Y ~= viewport.Y) then
		-- dragged somewhere: keep the same relative spot after a rotation / resize
		Win.x = Win.x * viewport.X / last.X
		Win.top = Win.top * viewport.Y / last.Y
	end
	Win.x, Win.top = Win.clampPx(Win.x, Win.top, cw * s, ch * s, true)
	if animate and Win.visible then
		Win.glide(Win.x, Win.top, cw, ch, s, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	else
		Motion.set(window, { Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(cw, ch) })
		Motion.set(Win.scaler, { Scale = s })
	end
end

function Win.scheduleRelayout()
	Win.relayoutToken = (Win.relayoutToken or 0) + 1
	local token = Win.relayoutToken
	task.delay(0.12, function()
		if token == Win.relayoutToken then
			Win.relayout(true)
		end
	end)
end

function Win.onLayout(listener)
	Win.layoutListeners[#Win.layoutListeners + 1] = listener
end

----------------------------------------------------------------------------------------------------
-- tabs
----------------------------------------------------------------------------------------------------
local function paintNav(item, selected, animate)
	local duration = animate and 0.22 or 0
	Theme.tweenRole(item.label, "TextColor3", selected and "OnAccent" or "Muted", duration)
	item.icon.SetRole(selected and "OnAccent" or "Muted", duration)
end

function Win.selectTab(id, instant)
	local def, page = Win.tabById[id], Win.pages[id]
	if not def or not page or Win.currentTab == id then
		return false
	end
	UI.closeDropdown(true)
	local previous = Win.currentTab
	Win.currentTab = id
	local animate = (not instant) and (not Motion.reduced) and Win.visible
	for _, item in ipairs(Win.nav) do
		paintNav(item, item.id == id, animate)
	end
	Win.placePill(animate)

	local old = previous and Win.pages[previous]
	if old and old ~= page then
		Motion.cancel(old)
		old.Visible = false
		old.Position = UDim2.fromScale(0, 0)
	end
	page.Visible = true
	if animate then
		page.Position = UDim2.fromOffset(0, 16)
		Motion.tween(page, { Position = UDim2.fromScale(0, 0) }, 0.28, Enum.EasingStyle.Quart)
	else
		Motion.set(page, { Position = UDim2.fromScale(0, 0) })
	end

	local ui = Win.ui
	ui.pageTitle.Text = def.title
	ui.pageSub.Text = def.desc
	if animate then
		ui.pageTitle.TextTransparency = 0.8
		ui.pageSub.TextTransparency = 0.8
		Motion.tween(ui.pageTitle, { TextTransparency = 0 }, 0.25)
		Motion.tween(ui.pageSub, { TextTransparency = 0 }, 0.32)
	end
	if previous then
		Sfx.play("tab")
	end
	return true
end

function Win.addPage(id)
	local page = UI.page(Win.ui.pageHost, id)
	Win.pages[id] = page
	return page
end

----------------------------------------------------------------------------------------------------
-- show / hide / minimize / recenter
----------------------------------------------------------------------------------------------------
function Win.show(instant)
	local window, scaler = Win.window, Win.scaler
	if not window or Win.visible then
		return
	end
	Win.visible = true
	window.Visible = true
	local cw, ch = Win.currentTarget()
	if instant or Motion.reduced then
		Motion.set(window, { Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(cw, ch) })
		Motion.set(scaler, { Scale = Win.s })
	else
		local fromScale = Win.s * 0.9
		Motion.set(scaler, { Scale = fromScale })
		Motion.set(window, {
			Position = UDim2.fromOffset(Win.x, Win.top + ch * (Win.s - fromScale) / 2 + 10),
			Size = UDim2.fromOffset(cw, ch),
		})
		Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end
	Sfx.play("open")
	Bg.syncBlur()
end

function Win.hide(instant)
	local window = Win.window
	if not window or not Win.visible then
		return
	end
	Win.visible = false
	UI.closeDropdown(true)
	UI.closeModal(true)
	UI.endSessions()
	Sfx.play("close")
	local function finish()
		if not Win.visible and Win.window then
			Win.window.Visible = false
		end
	end
	if instant or Motion.reduced then
		finish()
	else
		local cw, ch = Win.currentTarget()
		local toScale = Win.s * 0.92
		Win.glide(Win.x, Win.top + ch * (Win.s - toScale) / 2 + 8, cw, ch, toScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, finish)
	end
	Bg.syncBlur()
end

function Win.toggle()
	if Win.visible then
		Win.hide()
	else
		Win.show()
	end
end

function Win.setMinimized(flag, instant)
	flag = flag and true or false
	if not Win.window or Win.minimized == flag then
		return
	end
	Win.minimized = flag
	UI.closeDropdown(true)
	UI.closeModal(true)
	local ui = Win.ui
	local cw, ch = Win.currentTarget()
	-- collapsing keeps the title bar exactly where it is; restoring pulls the whole window back on screen if it would overhang
	Win.x, Win.top = Win.clampPx(Win.x, Win.top, cw * Win.s, ch * Win.s, not flag)
	Win.refreshChrome()
	Sfx.play(flag and "close" or "open")
	if flag then
		Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
			if Win.minimized and Win.ui.body then
				Win.ui.body.Visible = false
			end
		end)
	else
		ui.body.Visible = true
		Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.36, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	if instant then
		Motion.set(Win.window, { Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(cw, ch) })
		Motion.set(Win.scaler, { Scale = Win.s })
		ui.body.Visible = not flag
	end
	Bg.syncBlur()
end

function Win.recenter()
	if not Win.window then
		return
	end
	local viewport = Env.viewport()
	local cw, ch = Win.currentTarget()
	Win.userMoved = false
	Win.lastViewport = viewport
	local x = viewport.X / 2
	local top = Win.minimized and 24 or math.max(10, (viewport.Y - ch * Win.s) / 2)
	Win.x, Win.top = Win.clampPx(x, top, cw * Win.s, ch * Win.s, true)
	Win.kbShift = 0
	Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

function Win.setStatus(text, role)
	local label = Win.ui.footerStatus
	if label then
		label.Text = "\226\151\143  " .. text -- "●  "
		Theme.tweenRole(label, "TextColor3", role or "Green", 0.25)
		Theme.tweenRole(Win.ui.footerDot, "BackgroundColor3", role or "Green", 0.25)
	end
end

function Win.applyPerformance()
	local lowPower = Store.get("lowPower")
	for _, shadow in ipairs(Win.ui.shadows or {}) do
		shadow.Visible = not lowPower
	end
end

----------------------------------------------------------------------------------------------------
-- on-screen keyboard (Android): keep the focused text box visible
----------------------------------------------------------------------------------------------------
function Win.avoidKeyboard(holder)
	local visible = false
	pcall(function()
		visible = UserInputService.OnScreenKeyboardVisible
	end)
	if not visible or not Win.window then
		return
	end
	local ok, position = pcall(function()
		return UserInputService.OnScreenKeyboardPosition
	end)
	if not ok or typeof(position) ~= "Vector2" then
		return
	end
	local bottom = holder.AbsolutePosition.Y + holder.AbsoluteSize.Y + 14
	local overshoot = bottom - position.Y
	if overshoot <= 0 then
		return
	end
	local shift = math.min(overshoot, math.max(0, Win.top))
	if shift <= 0 then
		return
	end
	Win.kbShift = shift
	Motion.tween(Win.window, { Position = UDim2.fromOffset(Win.x, Win.top - shift) }, 0.24, Enum.EasingStyle.Quart)
end

function Win.releaseKeyboard()
	if Win.kbShift > 0 and Win.window then
		Win.kbShift = 0
		Motion.tween(Win.window, { Position = UDim2.fromOffset(Win.x, Win.top) }, 0.24, Enum.EasingStyle.Quart)
	end
end

-- called by UI.input
function Win.onInputFocus(holder, focused)
	if not Env.touch or not Win.window then
		return
	end
	Win.focusToken = Win.focusToken + 1
	local token = Win.focusToken
	if focused then
		task.delay(0.45, function()
			if token == Win.focusToken and holder.Parent then
				Win.avoidKeyboard(holder)
			end
		end)
	else
		Win.releaseKeyboard()
	end
end

----------------------------------------------------------------------------------------------------
-- construction
----------------------------------------------------------------------------------------------------
local function label(parent, props, role, size, color)
	local obj = Util.new("TextLabel", props, parent)
	Typo.apply(obj, role, size)
	if color then
		Theme.bind(obj, "TextColor3", color)
	end
	return obj
end

local function buildTitleBar(surface)
	local ui = Win.ui
	local titleBar = Util.new("Frame", {
		Name = "TitleBar", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, Win.TITLE_H), ZIndex = 5,
	}, surface)
	ui.titleBar = titleBar
	local handle = Util.new("TextButton", {
		Name = "DragHandle", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -112, 1, 0), ZIndex = 6,
	}, titleBar)
	ui.handle = handle

	UI.icon("logo", titleBar, 28, "Accent", { anchor = Vector2.new(0, 0.5), position = UDim2.new(0, 16, 0.5, 0), zindex = 7 })
	local title = label(titleBar, {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(52, 7), Size = UDim2.fromOffset(190, 22),
		Text = "VIREX  /  HUB", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7, TextColor3 = Color3.new(1, 1, 1),
	}, "title", 17)
	local sheen = Util.new("UIGradient", { Rotation = 18, Offset = Vector2.new(1, 0) }, title)
	Theme.gradient(sheen, Theme.G.sheen)
	Theme.fxSweep(sheen, 5.2, 0.62, 1, 0)
	ui.title = title
	ui.subtitle = label(titleBar, {
		Name = "Subtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(52, 29), Size = UDim2.new(1, -260, 0, 16),
		Text = "A clean, local interface for your experience", TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7,
	}, "caption", 11, "Muted")

	ui.clock = label(titleBar, {
		Name = "Clock", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -106, 0.5, 0),
		Size = UDim2.fromOffset(52, 20), Text = os.date("%H:%M"), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
	}, "buttonSmall", 12, "Muted")

	ui.closeButton = UI.button({
		parent = titleBar, name = "Close", icon = "close", iconRole = "Danger", kind = "ghost", sound = "close", zindex = 8,
		size = UDim2.fromOffset(36, 36), anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -14, 0.5, 0),
		onClick = function()
			UI.confirm({
				title = "Close VirexHub?",
				text = "The hub is removed from the screen. Run the script again to reopen it. Your saved settings are kept.",
				confirmText = "Close hub", cancelText = "Keep open", danger = true,
				onConfirm = function()
					App.destroy()
				end,
			})
		end,
	})
	ui.minButton = UI.button({
		parent = titleBar, name = "Minimize", icon = "minus", kind = "ghost", zindex = 8,
		size = UDim2.fromOffset(36, 36), anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -58, 0.5, 0),
		onClick = function()
			Win.setMinimized(not Win.minimized)
		end,
	})
	ui.minIconName = "minus"
	ui.divider = Util.new("Frame", {
		Name = "Divider", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, 0),
		Size = UDim2.new(1, -28, 0, 1), BackgroundTransparency = 0.55, ZIndex = 6,
	}, titleBar)
	Theme.bind(ui.divider, "BackgroundColor3", "Border")

	-- dragging: threshold first, so a tap never moves the window; double tap minimizes / restores
	local lastTap = 0
	handle.InputBegan:Connect(function(input)
		if not UI.isPress(input) or not Win.window then
			return
		end
		Motion.cancel(Win.window, { Position = true })
		Win.releaseKeyboard()
		local startX, startTop = Win.window.Position.X.Offset, Win.window.Position.Y.Offset
		local origin = input.Position
		local moved = false
		UI.watchInput(input, function(i)
			local dx, dy = i.Position.X - origin.X, i.Position.Y - origin.Y
			if not moved then
				if math.abs(dx) + math.abs(dy) < 6 then
					return
				end
				moved = true
				Win.userMoved = true
				UI.closeDropdown(true)
			end
			local size = Win.window.AbsoluteSize
			local nx, ny = Win.clampPx(startX + dx, startTop + dy, size.X, size.Y)
			Win.x, Win.top = nx, ny
			Win.window.Position = UDim2.fromOffset(nx, ny)
		end, function()
			if moved then
				return
			end
			local now = os.clock()
			if now - lastTap < 0.35 then
				lastTap = 0
				Win.setMinimized(not Win.minimized)
			else
				lastTap = now
			end
		end)
	end)
end

local function buildNav(sidebar)
	local ui = Win.ui
	ui.heading = label(sidebar, {
		Name = "Heading", BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -24, 0, 18),
		Text = "NAVIGATION", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
	}, "label", 10, "Muted")

	local scroll = Util.new("ScrollingFrame", {
		Name = "Nav", BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ZIndex = 3,
		CanvasSize = UDim2.fromOffset(0, 300), ScrollingDirection = Enum.ScrollingDirection.Y,
	}, sidebar)
	ui.navScroll = scroll

	-- the moving selection pill (lives behind the tab buttons)
	local pill = Util.new("Frame", {
		Name = "Pill", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 1, Size = UDim2.new(1, 0, 0, 40),
	}, scroll)
	Util.corner(pill, 10)
	Theme.gradient(Util.new("UIGradient", { Rotation = 20 }, pill), Theme.G.accent)
	local shimmer = Util.new("Frame", {
		Name = "Shimmer", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 2,
	}, pill)
	Util.corner(shimmer, 10)
	local shimmerGradient = Util.new("UIGradient", { Rotation = 20, Offset = Vector2.new(1, 0) }, shimmer)
	shimmerGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.78), NumberSequenceKeypoint.new(1, 1),
	})
	Theme.fxSweep(shimmerGradient, 3.8, 0.55, 2, 0.2)
	ui.pill = pill

	for index, def in ipairs(Win.tabList) do
		local hit = Util.new("TextButton", {
			Name = def.title .. "Tab", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, (index - 1) * 46), ZIndex = 3,
		}, scroll)
		local face = Util.new("Frame", {
			Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
		}, hit)
		Util.corner(face, 10)
		local icon = UI.icon(def.icon, face, 18, "Muted", {
			anchor = Vector2.new(0, 0.5), position = UDim2.new(0, 12, 0.5, 0), zindex = 4,
		})
		local text = label(face, {
			Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -46, 1, 0),
			Text = def.title, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
		}, "tab", nil, "Muted")
		local state = UI.pressable(hit, face, { radius = 10, hoverAlpha = 0.93, pressAlpha = 0.86, pressScale = 0.97 })
		hit.Activated:Connect(function()
			if state.wasDrag() then
				return
			end
			Win.selectTab(def.id)
		end)
		Win.nav[index] = { id = def.id, hit = hit, face = face, icon = icon, label = text }
	end
end

local function buildFooter(sidebar)
	local ui = Win.ui
	local footer = Util.new("Frame", { Name = "Footer", BorderSizePixel = 0, ZIndex = 3 }, sidebar)
	Theme.surface(footer, "Card", "card")
	Util.corner(footer, 10)
	Theme.bind(Util.stroke(footer, nil, 1, 0.2), "Color", "Border")
	ui.footer = footer
	local player = Players.LocalPlayer
	local thumb = Util.new("ImageLabel", {
		Name = "Thumb", Size = UDim2.fromOffset(32, 32), BorderSizePixel = 0, ZIndex = 4,
		Image = player and string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60", math.floor(player.UserId)) or "",
	}, footer)
	Util.round_corner(thumb)
	Theme.bind(thumb, "BackgroundColor3", "Track")
	ui.footerThumb = thumb
	ui.footerStatus = label(footer, {
		Name = "Status", BackgroundTransparency = 1, Position = UDim2.fromOffset(49, 9), Size = UDim2.new(1, -56, 0, 16),
		Text = "\226\151\143  Ready", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
	}, "caption", 11, "Green")
	local shown = ""
	if player then
		shown = player.DisplayName
		if shown == nil or shown == "" then
			shown = player.Name
		end
	end
	ui.footerName = label(footer, {
		Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(49, 28), Size = UDim2.new(1, -56, 0, 16),
		Text = shown, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
	}, "caption", 11, "Muted")
	local dot = Util.new("Frame", {
		Name = "Dot", BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 11, 0.5, 11),
		Size = UDim2.fromOffset(10, 10), ZIndex = 6, Visible = false,
	}, footer)
	Util.round_corner(dot)
	Theme.bind(dot, "BackgroundColor3", "Green")
	Theme.bind(Util.stroke(dot, nil, 2, 0), "Color", "Card")
	ui.footerDot = dot
end

-- Builds the whole window inside `gui` (a ScreenGui). Pages are added later with Win.addPage.
function Win.create(gui)
	Win.destroy()
	local maid = Maid.new()
	Win.maid = maid
	Win.gui = gui
	local ui = {}
	Win.ui = ui
	Win.nav, Win.pages, Win.currentTab = {}, {}, nil
	Win.visible, Win.minimized = false, false

	local w, h, s = Win.computeLayout()
	Win.w, Win.h, Win.s = w, h, s
	local viewport = Env.viewport()
	Win.x, Win.top = Win.clampPx(viewport.X / 2, math.max(10, (viewport.Y - h * s) / 2), w * s, h * s, true)
	Win.userMoved, Win.lastViewport = false, viewport

	local window = Util.new("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(w, h), Visible = false, ZIndex = 1,
	}, gui)
	Win.window = window
	Win.scaler = Util.new("UIScale", { Scale = s }, window)

	-- soft shadow: a few translucent rounded rectangles behind the surface (no image assets needed)
	ui.shadows = {}
	for i, spec in ipairs({ { 3, 0.92 }, { 8, 0.95 }, { 14, 0.968 }, { 22, 0.982 } }) do
		local grow = spec[1]
		local shadow = Util.new("Frame", {
			Name = "Shadow" .. i, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = spec[2],
			Position = UDim2.fromOffset(-grow, -grow + 8), Size = UDim2.new(1, grow * 2, 1, grow * 2), ZIndex = i,
		}, window)
		Util.corner(shadow, 16 + grow)
		ui.shadows[i] = shadow
	end

	local surface = Util.new("Frame", {
		Name = "Surface", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Active = true, ZIndex = 10,
	}, window)
	Theme.surface(surface, "Background", "bg")
	Util.corner(surface, 16)
	local stroke = Util.new("UIStroke", { Thickness = 1.5, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, surface)
	local strokeGradient = Util.new("UIGradient", { Rotation = 0 }, stroke)
	Theme.gradient(strokeGradient, Theme.G.stroke)
	Theme.fxSpin(strokeGradient, 24, 2)
	ui.surface = surface

	local bgLayer = Util.new("Frame", {
		Name = "BgLayer", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, surface)
	Bg.init(bgLayer)

	buildTitleBar(surface)

	local body = Util.new("Frame", {
		Name = "Body", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, Win.TITLE_H),
		Size = UDim2.fromOffset(w, h - Win.TITLE_H), ZIndex = 5,
	}, surface)
	ui.body = body

	local sidebar = Util.new("Frame", { Name = "Sidebar", BorderSizePixel = 0, ZIndex = 2 }, body)
	Theme.surface(sidebar, "Panel", "panel")
	Util.corner(sidebar, 14)
	Theme.bind(Util.stroke(sidebar, nil, 1, 0.25), "Color", "Border")
	ui.sidebar = sidebar
	buildNav(sidebar)
	buildFooter(sidebar)

	local content = Util.new("Frame", { Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, body)
	ui.content = content
	ui.pageTitle = label(content, {
		Name = "PageTitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 4), Size = UDim2.new(1, -4, 0, 28),
		Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "title", 21, "Text")
	ui.pageSub = label(content, {
		Name = "PageSubtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 33), Size = UDim2.new(1, -4, 0, 18),
		Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "caption", 11, "Muted")
	ui.pageHost = Util.new("Frame", {
		Name = "Pages", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
	}, content)

	-- popup (dropdown) and modal (confirm) layers sit above everything inside the surface
	ui.popupLayer = Util.new("Frame", {
		Name = "Popups", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 50,
	}, surface)
	ui.modalLayer = Util.new("Frame", {
		Name = "Modals", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 60,
	}, surface)
	UI.layers.popup, UI.layers.modal = ui.popupLayer, ui.modalLayer

	Win.applyLayout()
	Win.applyPerformance()

	-- clock (1 Hz, only while the window is shown)
	Anim.add("clock", function()
		local text = os.date("%H:%M")
		if ui.clock.Text ~= text then
			ui.clock.Text = text
		end
	end, 1, function()
		return Win.visible and ui.clock.Visible
	end)

	-- keyboard shortcut (keyboard / mouse devices only)
	local keyOk, keyCode = pcall(function()
		return Enum.KeyCode[CONFIG.ToggleKey]
	end)
	if keyOk and keyCode then
		maid:Connect(UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == keyCode then
				Win.toggle()
			end
		end)
	end

	-- viewport changes (rotation, window resize)
	local cameraConnection = nil
	local function watchCamera()
		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end
		local camera = workspace.CurrentCamera
		if camera then
			cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(Win.scheduleRelayout)
		end
	end
	watchCamera()
	maid:Give(function()
		if cameraConnection then
			cameraConnection:Disconnect()
		end
	end)
	maid:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		watchCamera()
		Win.scheduleRelayout()
	end)

	maid:Give(Store.on("scale", function()
		Win.relayout(true)
	end))
	maid:Give(Store.on("compact", function()
		Win.relayout(true)
	end))
	maid:Give(Store.on("clock", function()
		Win.refreshChrome()
	end))
	maid:Give(Store.on("lowPower", function()
		Win.applyPerformance()
	end))
	return window
end

function Win.destroy()
	Anim.remove("clock")
	if Win.maid then
		Win.maid:Clean()
		Win.maid = nil
	end
	if Win.window then
		pcall(Win.window.Destroy, Win.window)
	end
	Win.window, Win.scaler, Win.gui = nil, nil, nil
	Win.ui = {}
	Win.nav, Win.pages, Win.currentTab = {}, {}, nil
	Win.visible, Win.minimized = false, false
	Win.layoutListeners = {}
	UI.layers.popup, UI.layers.modal = nil, nil
	UI.openDropdown, UI.modal = nil, nil
end
end -- [11_window.lua]

do -- [12_pages.lua]

----------------------------------------------------------------------------------------------------
-- Pages: Overview, Avatar, Appearance, Background, Tools, Settings (Scripts and Information are built in 14_scripts.lua).
-- Every setting goes through Store; side effects live in App.wire() (Store listeners), and every
-- widget listens to its own key so "Reset preferences" updates the whole interface in one pass.
----------------------------------------------------------------------------------------------------
local MarketplaceServiceP = optionalService("MarketplaceService")
local BULLET = "\226\128\162"

Pages.cards = {}
Pages.syncers = {}
Pages.disposers = {}
Pages.gridUpdaters = {}
Pages.build = {}

function Pages.watch(key, fn)
	Pages.disposers[#Pages.disposers + 1] = Store.on(key, fn)
end

function Pages.sync(fn)
	Pages.syncers[#Pages.syncers + 1] = fn
end

function Pages.syncAll()
	for _, fn in ipairs(Util.copy(Pages.syncers)) do
		Util.try("page sync", fn)
	end
end

function Pages.register(card, controlWidth)
	Pages.cards[#Pages.cards + 1] = { card = card, width = controlWidth }
end

-- cards whose controls would squeeze the text too much drop them below it
function Pages.syncCards()
	local width = Win.pageW or 400
	local alive = {}
	for _, entry in ipairs(Pages.cards) do
		if entry.card.Instance.Parent then
			alive[#alive + 1] = entry
			entry.card.SetStacked(width - (entry.width + 38) < 170)
		end
	end
	Pages.cards = alive
	for _, update in ipairs(Pages.gridUpdaters) do
		Util.try("grid update", update, width)
	end
end

function Pages.init()
	Pages.destroy()
	Win.onLayout(function()
		Pages.syncCards()
	end)
end

function Pages.destroy()
	for _, dispose in ipairs(Pages.disposers) do
		pcall(dispose)
	end
	Pages.cards, Pages.syncers, Pages.disposers, Pages.gridUpdaters = {}, {}, {}, {}
	Anim.remove("fps")
	Anim.remove("overview")
end

----------------------------------------------------------------------------------------------------
-- card helpers
----------------------------------------------------------------------------------------------------
local function actionCard(page, order, title, desc, buttonText, onClick, o)
	o = o or {}
	local width = o.width or 124
	local card = UI.card({ parent = page, order = order, title = title, desc = desc, control = width, name = o.name or title })
	local button = UI.button({
		parent = card.Controls, text = buttonText, icon = o.icon, kind = o.kind, small = true, name = "Action", sound = o.sound,
		size = UDim2.new(1, 0, 0, 34), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5), onClick = onClick,
	})
	Pages.register(card, width)
	return card, button
end

local function toggleCard(page, order, title, desc, key, after)
	local card = UI.card({ parent = page, order = order, title = title, desc = desc, control = 62, name = title })
	local toggle = UI.toggle({
		parent = card.Controls, value = Store.get(key), anchor = Vector2.new(1, 0.5), position = UDim2.fromScale(1, 0.5), name = "Toggle",
		onChange = function(value)
			Store.set(key, value)
			if after then
				Util.try("toggle after " .. key, after, value)
			end
		end,
	})
	Pages.watch(key, function(value)
		toggle.Set(value, true)
	end)
	Pages.register(card, 62)
	return card, toggle
end

local function sliderCard(page, order, title, desc, key, o)
	local card = UI.card({ parent = page, order = order, title = title, desc = desc, stack = true, controlHeight = 38, name = title })
	local slider = UI.slider({
		parent = card.Controls, min = o.min, max = o.max, step = o.step, value = Store.get(key), format = o.format, name = "Slider",
		onChange = function(value, final)
			Store.set(key, value)
			if o.onChange then
				Util.try("slider onChange " .. key, o.onChange, value, final)
			end
		end,
	})
	slider.Instance.Size = UDim2.new(1, 0, 0, 38)
	Pages.watch(key, function(value)
		slider.Set(value, true)
	end)
	return card, slider
end

local function percentFormat(value)
	return Util.percent(value) .. "%"
end

local function stepperRow(parent, order, text, key, min, max, step, onChange)
	local row = Util.new("Frame", { Name = key, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = order }, parent)
	local caption = Util.new("TextLabel", {
		Name = "Caption", BackgroundTransparency = 1, Size = UDim2.new(1, -160, 1, 0), Text = text,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	Typo.apply(caption, "body", 12)
	Theme.bind(caption, "TextColor3", "Text")
	local stepper = UI.stepper({
		parent = row, min = min, max = max, step = step, value = Store.get(key), anchor = Vector2.new(1, 0.5),
		position = UDim2.fromScale(1, 0.5), name = "Stepper",
		onChange = function(value)
			Store.set(key, value)
			if onChange then
				Util.try("stepper onChange " .. key, onChange, value)
			end
		end,
	})
	Pages.watch(key, function(value)
		stepper.Set(value, true)
	end)
	return row, stepper
end

local function textCard(page, order, title, text)
	return UI.card({ parent = page, order = order, title = title, desc = text, name = title })
end

----------------------------------------------------------------------------------------------------
-- shared actions
----------------------------------------------------------------------------------------------------
function Pages.openRobloxSettings()
	if not GuiService then
		Notify.warn("Settings unavailable", "Roblox settings could not be opened here.")
		return
	end
	local called = false
	local attempts = {
		function()
			GuiService:SetMenuIsOpen(true)
		end,
		function()
			GuiService:OpenSettings() -- the call the original script used; kept as a fallback
		end,
	}
	for _, attempt in ipairs(attempts) do
		if pcall(attempt) then
			called = true
			break
		end
	end
	if not called then
		Notify.warn("Settings unavailable", "Roblox settings could not be opened here.")
		return
	end
	task.delay(0.35, function()
		local isOpen = nil
		pcall(function()
			isOpen = GuiService.MenuIsOpen
		end)
		if isOpen == false then
			Notify.warn("Settings unavailable", "Roblox did not open its menu. Use the Roblox menu button instead.")
		end
	end)
end

function Pages.pingMs()
	if StatsService then
		local ok, value = pcall(function()
			return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and type(value) == "number" and value > 0 then
			return math.floor(value + 0.5)
		end
	end
	local player = Players.LocalPlayer
	if player then
		local ok, seconds = pcall(player.GetNetworkPing, player)
		if ok and type(seconds) == "number" and seconds > 0 then
			return math.floor(seconds * 1000 + 0.5)
		end
	end
	return nil
end

function Pages.rejoin()
	if not TeleportService or not Players.LocalPlayer then
		Notify.error("Rejoin unavailable", "TeleportService is not available in this client.")
		return
	end
	UI.confirm({
		title = "Rejoin this server?",
		text = "Roblox reconnects you to this server if it still has room, otherwise to the experience. Unsaved progress in the experience may be lost.",
		confirmText = "Rejoin", cancelText = "Stay", danger = true,
		onConfirm = function()
			Notify.info("Rejoining", "Asking Roblox to reconnect you...")
			local failure = nil
			pcall(function()
				failure = TeleportService.TeleportInitFailed:Connect(function(_, result, message)
					Notify.error("Rejoin failed", Util.cap(tostring(message ~= "" and message or result), 110))
				end)
			end)
			task.delay(20, function()
				if failure then
					pcall(failure.Disconnect, failure)
				end
			end)
			local ok, err = pcall(function()
				if game.JobId ~= "" then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
				else
					TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
				end
			end)
			if not ok then
				Notify.error("Rejoin failed", Util.cap(tostring(err), 110))
			end
		end,
	})
end

----------------------------------------------------------------------------------------------------
-- Private Server Finder (Tools > Roblox). Native: it reads Roblox's own PUBLIC server list for this
-- place (up to 3 pages, a short delay between them, cached for 30 s) and lists the quietest servers
-- that still have room. It never opens private servers, never touches access codes, and runs no
-- external script. Joining uses TeleportToPlaceInstance, with the same failure handling as Rejoin.
----------------------------------------------------------------------------------------------------
Pages.servers = { cache = nil, blockedUntil = 0, pages = 3, delay = 0.7, cacheSeconds = 30, show = 10 }

-- Yields while it reads the list. Returns result, nil on success
-- (result = { servers = sorted list, seen = how many Roblox listed, partial, cached, age }) or nil, reason.
function Pages.findServers()
	local S = Pages.servers
	local now = os.clock()
	if S.cache and S.cache.placeId == game.PlaceId and now - S.cache.at < S.cacheSeconds then
		return { servers = S.cache.servers, seen = S.cache.seen, partial = false, cached = true, age = now - S.cache.at }
	end
	if not Env.fn.request then
		return nil, "This executor has no request function, so the server list cannot be read."
	end
	if now < S.blockedUntil then
		return nil, string.format("Roblox is rate limiting server requests (HTTP 429). Try again in about %d s.", math.ceil(S.blockedUntil - now))
	end

	local servers, seen, cursor, partial = {}, 0, nil, false
	local jobId = game.JobId
	for pageIndex = 1, S.pages do
		local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
		if cursor then
			local okEncode, encoded = pcall(HttpService.UrlEncode, HttpService, cursor)
			url = url .. "&cursor=" .. (okEncode and encoded or cursor)
		end
		local result = Env.fetch(url, "request-only")
		local decoded = result.ok and Util.jsonDecode(result.body) or nil
		local readable = type(decoded) == "table" and type(decoded.data) == "table"
		if not result.ok or not readable then
			if result.status == 429 then
				S.blockedUntil = os.clock() + 30
			end
			if pageIndex == 1 then
				if result.status == 429 then
					return nil, "Roblox is rate limiting server requests (HTTP 429). Try again in about 30 s."
				elseif not result.ok then
					return nil, "Roblox did not return the server list (" .. Util.cap(tostring(result.error), 60) .. ")."
				end
				return nil, "Roblox sent an answer this hub could not read."
			end
			partial = true -- keep what the earlier pages gave us
			break
		end
		for _, item in ipairs(decoded.data) do
			if type(item) == "table" and type(item.id) == "string" and type(item.playing) == "number" and type(item.maxPlayers) == "number" then
				seen = seen + 1
				if item.id ~= jobId and item.playing < item.maxPlayers then
					servers[#servers + 1] = { id = item.id, playing = item.playing, max = item.maxPlayers }
				end
			end
		end
		cursor = type(decoded.nextPageCursor) == "string" and decoded.nextPageCursor or nil
		if not cursor then
			break
		end
		if pageIndex < S.pages then
			task.wait(S.delay)
			if App.destroyed then
				return nil, "The hub was closed."
			end
		end
	end

	table.sort(servers, function(a, b)
		if a.playing ~= b.playing then
			return a.playing < b.playing
		end
		return a.id < b.id
	end)
	local result = { servers = servers, seen = seen, partial = partial, placeId = game.PlaceId, at = os.clock() }
	if not partial then
		S.cache = result
	end
	return result
end

function Pages.buildServerFinder(page, order)
	local S = Pages.servers
	local list = Util.new("Frame", {
		Name = "ServerList", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order + 1, Visible = false,
	}, page)
	Util.list(list, 8)

	local function clearList()
		for _, child in ipairs(list:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
	end

	local function join(server)
		if not TeleportService or not Players.LocalPlayer then
			Notify.error("Join unavailable", "TeleportService is not available in this client.")
			return
		end
		UI.confirm({
			title = "Join this server?",
			text = string.format("Roblox moves you to a public server with %d of %d players. Unsaved progress in this experience may be lost.", server.playing, server.max),
			confirmText = "Join", cancelText = "Stay", danger = true,
			onConfirm = function()
				Notify.info("Joining", "Asking Roblox to move you...")
				local failure = nil
				pcall(function()
					failure = TeleportService.TeleportInitFailed:Connect(function(_, result, message)
						S.cache = nil -- the list is out of date now (full or closed server)
						Notify.error("Join failed", Util.cap(tostring(message ~= "" and message or result), 110))
					end)
				end)
				task.delay(20, function()
					if failure then
						pcall(failure.Disconnect, failure)
					end
				end)
				local ok, err = pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
				end)
				if not ok then
					Notify.error("Join failed", Util.cap(tostring(err), 110))
				end
			end,
		})
	end

	local function render(result)
		clearList()
		local servers = result.servers
		local shown = math.min(#servers, S.show)
		local summary = string.format("Showing the %d quietest of %d open public servers", shown, #servers)
		if result.cached then
			summary = summary .. string.format(" (list is %d s old)", math.floor(result.age + 0.5))
		end
		summary = summary .. ". Roblox's list changes constantly; a server can fill up before you join."
		if result.partial then
			summary = summary .. " Roblox stopped answering part-way, so this list is incomplete."
		end
		UI.card({ parent = list, order = 0, title = "Quietest public servers", desc = summary, name = "ServerSummary" })
		for index = 1, shown do
			local server = servers[index]
			local card = UI.card({
				parent = list, order = index, name = "Server" .. index, control = 92,
				title = string.format("%d / %d players", server.playing, server.max),
				desc = "Server " .. string.sub(server.id, 1, 8),
			})
			UI.button({
				parent = card.Controls, text = "Join", small = true, kind = "primary", name = "Join",
				size = UDim2.new(1, 0, 0, 34), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
				onClick = function()
					join(server)
				end,
			})
			Pages.register(card, 92)
		end
		list.Visible = true
	end

	local busy, token = false, 0
	local _, button = actionCard(page, order, "Private Server Finder",
		"Lists the 10 quietest public servers of this experience so you can hop to a calmer one. It reads Roblox's own public list only; it cannot open private servers you were not invited to.",
		"Find servers", function(btn)
			if busy then
				return
			end
			if game.PrivateServerId ~= "" then
				Notify.info("Already in a private server", "You are in a private server right now, so there is no public list to search from here. Leave it first to see public servers.")
				return
			end
			busy = true
			token = token + 1
			local mine = token
			btn.SetBusy(true, "Searching...")
			local function finish(result, reason)
				if token ~= mine then
					return
				end
				token = token + 1 -- closes this search: a late answer or the timeout can no longer run it twice
				busy = false
				if Util.alive(btn.Instance) then
					btn.SetBusy(false)
				end
				if App.destroyed or not Util.alive(list) then
					return
				end
				if not result then
					clearList()
					list.Visible = false
					Notify.warn("Server list unavailable", Util.cap(tostring(reason), 130))
				elseif #result.servers == 0 then
					clearList()
					list.Visible = false
					Notify.info("No other servers", "Roblox lists no other open public servers for this experience right now.")
				else
					render(result)
				end
			end
			task.delay(25, function()
				finish(nil, "Roblox took too long to answer.")
			end)
			task.spawn(function()
				local result, reason = Pages.findServers()
				finish(result, reason)
			end)
		end, { width = 132, name = "ServerFinder" })
	if not Env.fn.request then
		button.SetEnabled(false, "This executor has no request function, so the server list cannot be read.")
	elseif not TeleportService then
		button.SetEnabled(false, "TeleportService is not available in this client.")
	end
end

local function storageText()
	if Store.persistent then
		return "Settings are saved to " .. CONFIG.ConfigFile .. " in the executor workspace."
	elseif Env.canSave() then
		return "File saving was detected but the first save failed (" .. tostring(Store.lastError) .. "). Settings last for this session only."
	end
	return "This executor has no file access, so settings last for this session only."
end

----------------------------------------------------------------------------------------------------
-- Overview
----------------------------------------------------------------------------------------------------
function Pages.build.overview(page)
	local player = Players.LocalPlayer
	local info = { name = game.Name ~= "" and game.Name or "Roblox experience" }
	local session

	local function describe()
		local shown = "Player"
		if player then
			shown = player.DisplayName ~= "" and player.DisplayName or player.Name
		end
		session.SetDesc(string.format(
			"%s  %s  Place ID %s  %s  Player %s  %s  Refreshed %s",
			info.name, BULLET, tostring(game.PlaceId), BULLET, shown, BULLET, os.date("%H:%M:%S")
		))
	end
	local function fetchName()
		if not MarketplaceServiceP or game.PlaceId == 0 then
			return
		end
		task.spawn(function()
			local ok, product = pcall(MarketplaceServiceP.GetProductInfo, MarketplaceServiceP, game.PlaceId)
			if ok and type(product) == "table" and type(product.Name) == "string" and product.Name ~= "" then
				info.name = product.Name
				if session.Instance.Parent then
					describe()
				end
			end
		end)
	end

	UI.section(page, "Session", 1)
	session = actionCard(page, 2, "Experience session", "", "Refresh", function()
		describe()
		fetchName()
		Notify.success("Session refreshed", "The session details are up to date.")
	end, { width = 112, name = "Session" })
	describe()
	fetchName()

	-- live readouts: frame rate (measured here), ping (Roblox stat), hub uptime
	local tiles = Util.new("Frame", {
		Name = "Stats", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3,
	}, page)
	local grid = Util.new("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -6, 0, 62), CellPadding = UDim2.fromOffset(9, 8), SortOrder = Enum.SortOrder.LayoutOrder,
	}, tiles)
	Pages.gridUpdaters[#Pages.gridUpdaters + 1] = function(width)
		if width < 380 then
			grid.CellSize = UDim2.new(1, 0, 0, 58)
		else
			grid.CellSize = UDim2.new(1 / 3, -6, 0, 62)
		end
	end
	local fps = UI.statTile({ parent = tiles, label = "Frames per second", value = "-", order = 1 })
	local ping = UI.statTile({ parent = tiles, label = "Ping to server", value = "-", order = 2 })
	local uptime = UI.statTile({ parent = tiles, label = "Hub uptime", value = "-", order = 3 })

	local function visible()
		return Win.visible and not Win.minimized and Win.currentTab == "overview"
	end
	local sample = 60
	Anim.add("fps", function(dt)
		if dt > 0 then
			sample = sample * 0.92 + (1 / dt) * 0.08
		end
	end, nil, visible)
	Anim.add("overview", function(_, now)
		local value = math.floor(sample + 0.5)
		fps.Set(tostring(value), value >= 50 and "Green" or (value >= 30 and "Warn" or "Danger"))
		local ms = Pages.pingMs()
		if ms then
			ping.Set(ms .. " ms", ms <= 100 and "Green" or (ms <= 200 and "Warn" or "Danger"))
		else
			ping.Set("-", "Muted")
		end
		uptime.Set(Util.duration(now - App.startedAt), "Text")
	end, 2, visible)

	UI.section(page, "Quick actions", 4)
	actionCard(page, 5, "Open Roblox settings", "Open the platform's built-in settings menu.", "Open settings", Pages.openRobloxSettings,
		{ width = 132, name = "OpenSettings" })
	actionCard(page, 6, "Appearance", "Jump to the controls for theme, window size, and motion.", "Customize", function()
		Win.selectTab("appearance")
	end, { width = 124, name = "Customize" })

	UI.section(page, "About", 7)
	local lines = {
		"VirexHub is client-side interface code for your own sessions. Executor features (saving, clipboard, custom assets) are optional and detected at start. Nothing here changes server-side game rules.",
		string.format("Version %s  %s  Executor: %s  %s  %s", CONFIG.Version, BULLET, Env.executor, BULLET, Store.persistent and "settings saved" or "settings last for this session"),
		"Credits: avatar tools adapted from AVATAR-CHANGER (returnreturnfunction); loading screen modelled on the Blyxo loader; click sound from Vyre Multiverse.",
	}
	textCard(page, 8, "About this hub", table.concat(lines, "\n\n"))
end

----------------------------------------------------------------------------------------------------
-- Avatar (see 10_avatar.lua)
----------------------------------------------------------------------------------------------------
function Pages.build.avatar(page)
	Avatar.buildPage(page)
end

----------------------------------------------------------------------------------------------------
-- Appearance
----------------------------------------------------------------------------------------------------
local function buildThemeGroup(page, order, title, defs, tiles)
	local heading = Util.new("TextLabel", {
		Name = "Group", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = order, Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, page)
	Typo.apply(heading, "caption", 11)
	Theme.bind(heading, "TextColor3", "Muted")
	local host = Util.new("Frame", {
		Name = "Themes", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order + 1,
	}, page)
	local grid = Util.new("UIGridLayout", {
		CellSize = UDim2.fromOffset(118, 76), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder,
	}, host)
	-- tiles stretch to fill each row (at least 118 px wide), so long names such as "Diamond + Purple" keep their room
	local function sizeTiles(width)
		local columns = math.max(2, math.floor((width + 8) / (118 + 8)))
		grid.CellSize = UDim2.fromOffset(math.floor((width - (columns - 1) * 8) / columns), 76)
	end
	Pages.gridUpdaters[#Pages.gridUpdaters + 1] = sizeTiles
	sizeTiles(Win.pageW or 400)
	for index, def in ipairs(defs) do
		local hit = Util.new("TextButton", {
			Name = "Theme_" .. def.id, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = index,
		}, host)
		local face = Util.new("Frame", {
			Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
		}, hit)
		Util.corner(face, 12)
		Theme.surface(face, "Card", "card")
		local stroke = Util.stroke(face, nil, 1, 0.15)
		Theme.bind(stroke, "Color", "Border")
		-- a miniature of that theme: its background, an accent bar and a highlight dot
		local preview = Util.new("Frame", {
			Name = "Preview", Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 34), BorderSizePixel = 0,
			BackgroundColor3 = def.colors.Background,
		}, face)
		Util.corner(preview, 8)
		Util.stroke(preview, def.colors.Border, 1, 0.2)
		local bar = Util.new("Frame", {
			Name = "Bar", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(0.6, 0, 0, 8),
			BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		}, preview)
		Util.round_corner(bar)
		Util.new("UIGradient", {
			Color = ColorSequence.new(def.colors.Accent, def.colors.Accent2 or def.colors.Accent),
		}, bar)
		local dot = Util.new("Frame", {
			Name = "Dot", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(10, 10),
			BorderSizePixel = 0, BackgroundColor3 = def.colors.Shine or def.colors.Accent,
		}, preview)
		Util.round_corner(dot)
		local name = Util.new("TextLabel", {
			Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 44), Size = UDim2.new(1, -16, 0, 28), Text = def.name,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, face)
		Typo.apply(name, "buttonSmall", 12)
		Theme.bind(name, "TextColor3", "Text")
		local badge = Util.new("Frame", {
			Name = "Selected", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -5, 0, 5), Size = UDim2.fromOffset(20, 20),
			BorderSizePixel = 0, ZIndex = 5, Visible = false,
		}, face)
		Util.round_corner(badge)
		Theme.bind(badge, "BackgroundColor3", "Accent")
		UI.icon("check", badge, 14, "OnAccent", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 6 })
		local state = UI.pressable(hit, face, { radius = 12, hoverAlpha = 0.94, pressAlpha = 0.88, pressScale = 0.96 })
		hit.Activated:Connect(function()
			if state.wasDrag() then
				return
			end
			if Theme.id == def.id then
				Sfx.play("click")
				return
			end
			Sfx.play("select")
			Store.set("theme", def.id)
			Notify.info("Theme changed", "Using the " .. def.name .. " theme.", { key = "theme" })
		end)
		tiles[#tiles + 1] = { id = def.id, stroke = stroke, badge = badge }
	end
end

function Pages.build.appearance(page)
	UI.section(page, "Window", 1)
	toggleCard(page, 2, "Compact window", "Use a smaller window size while keeping all controls available.", "compact")
	toggleCard(page, 3, "Title bar clock", "Show or hide the local time in the title bar.", "clock")

	UI.section(page, "Motion", 4)
	toggleCard(page, 5, "Reduced motion", "Turn off interface tweens and animated accents; changes become immediate.", "reducedMotion", function(value)
		Notify.info("Reduced motion", value and "Animations are off." or "Animations are on.", { key = "motion", force = true })
	end)
	toggleCard(page, 6, "Low power mode", "Removes shadows, animated accents and animated backgrounds to save battery and keep the frame rate steady.", "lowPower")
	local fxCard = UI.card({
		parent = page, order = 7, title = "Animated accents",
		desc = "Moving highlights on the window border, title and selection (premium themes look best on Full).", control = 210, name = "Accents",
	})
	local fxControl = UI.segmented({
		parent = fxCard.Controls, size = UDim2.new(1, 0, 0, 36), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
		options = { { id = 0, label = "Off" }, { id = 1, label = "Subtle" }, { id = 2, label = "Full" } }, value = Store.get("fx"),
		onChange = function(id)
			Store.set("fx", id)
		end,
	})
	Pages.watch("fx", function(value)
		fxControl.Set(value, true)
	end)
	Pages.register(fxCard, 210)

	UI.section(page, "Theme", 8)
	local tiles = {}
	local groups, order = {}, {}
	for _, def in ipairs(Theme.defs) do
		if not groups[def.group] then
			groups[def.group] = {}
			order[#order + 1] = def.group
		end
		table.insert(groups[def.group], def)
	end
	local nextOrder = 9
	for _, group in ipairs(order) do
		buildThemeGroup(page, nextOrder, group, groups[group], tiles)
		nextOrder = nextOrder + 2
	end
	local function paintTiles()
		for _, tile in ipairs(tiles) do
			local selected = Theme.id == tile.id
			Theme.tweenRole(tile.stroke, "Color", selected and "Accent" or "Border", 0.22)
			Motion.tween(tile.stroke, { Thickness = selected and 2 or 1, Transparency = selected and 0 or 0.15 }, 0.22)
			tile.badge.Visible = selected
		end
	end
	paintTiles()
	Pages.disposers[#Pages.disposers + 1] = Theme.onChange(paintTiles)

	UI.section(page, "Typography", nextOrder)
	local fontCard = UI.card({
		parent = page, order = nextOrder + 1, title = "Font family",
		desc = "One font setting for every label in the hub.", control = 180, name = "Font",
	})
	local fontDropdown = UI.dropdown({
		parent = fontCard.Controls, options = Typo.list(), value = Typo.family.id, name = "FontDropdown",
		onChange = function(id)
			Store.set("font", id)
		end,
	})
	fontDropdown.Instance.Size = UDim2.new(1, 0, 0, 36)
	fontDropdown.Instance.AnchorPoint = Vector2.new(0, 0.5)
	fontDropdown.Instance.Position = UDim2.fromScale(0, 0.5)
	Pages.watch("font", function(value)
		fontDropdown.Set(value, true)
	end)
	Pages.register(fontCard, 180)

	local sample = UI.card({
		parent = page, order = nextOrder + 2, name = "FontPreview", title = "Preview",
		desc = "The quick brown fox jumps over the lazy dog. 0123456789",
	})
	Typo.apply(sample.Desc, "body", 14)
	textCard(page, nextOrder + 3, "Using your own font",
		"Roblox cannot load a .ttf or .otf file straight into a script. Upload the font to Roblox as a Font Family (Creator Hub), then add one line with its asset ID to CONFIG.Fonts.Families at the top of this file. Nothing else has to change; it will appear in this list.")
end

----------------------------------------------------------------------------------------------------
-- Background
----------------------------------------------------------------------------------------------------
function Pages.build.background(page)
	UI.section(page, "Background", 1)
	local modeCard = UI.card({
		parent = page, order = 2, title = "Style",
		desc = "Aurora and Sparkle use the theme colours and need no files. Image styles load a picture you provide.", control = 190, name = "Style",
	})
	local ui = {}
	local function modeLabel(id)
		for _, entry in ipairs(Bg.MODES) do
			if entry.id == id then
				return entry.label
			end
		end
		return tostring(id)
	end
	local function sourceKey(mode)
		if mode == "sequence" then
			return "bgSequence"
		elseif mode == "video" then
			return "bgVideo"
		end
		return "bgImage"
	end

	-- source card ---------------------------------------------------------------------------------
	local source = UI.card({ parent = page, order = 3, stack = true, controlHeight = 0, title = "Source", desc = "", name = "Source" })
	local box = source.Controls
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.Size = UDim2.new(1, 0, 0, 0)
	Util.list(box, 8)

	local inputRow = Util.new("Frame", { Name = "InputRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 1 }, box)
	ui.input = UI.input({
		parent = inputRow, size = UDim2.new(1, -92, 1, 0), placeholder = "Image ID, file name or link", maxLength = 400, name = "SourceInput",
	})
	ui.apply = UI.button({
		parent = inputRow, text = "Apply", kind = "primary", size = UDim2.fromOffset(84, 38), anchor = Vector2.new(1, 0),
		position = UDim2.new(1, 0, 0, 0), name = "ApplySource", onClick = function()
			local mode = Store.get("bgMode")
			local text = ui.input.Get()
			if text == "" then
				ui.input.Flash()
				Notify.warn("Nothing to apply", "Enter an asset ID, file name or link first.")
				return
			end
			ui.apply.SetBusy(true, "Loading")
			Bg.useSource(mode, text, function(ok, message)
				ui.apply.SetBusy(false)
				if ok == nil then
					return
				end
				if ok then
					Notify.success("Background applied", Util.cap(message, 100))
				else
					Notify.error("Background failed", Util.cap(message, 150))
				end
			end)
		end,
	})
	ui.rowCols = stepperRow(box, 2, "Sheet columns", "bgCols", 1, 16, 1, function()
		if Store.get("bgMode") == "sheet" then
			Bg.apply()
		end
	end)
	ui.rowRows = stepperRow(box, 3, "Sheet rows", "bgRows", 1, 16, 1, function()
		if Store.get("bgMode") == "sheet" then
			Bg.apply()
		end
	end)
	ui.rowFps = stepperRow(box, 4, "Frames per second", "bgFps", 1, 24, 1, function()
		local mode = Store.get("bgMode")
		if mode == "sheet" or mode == "sequence" then
			Bg.apply()
		end
	end)
	local clearRow = Util.new("Frame", { Name = "ClearRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 5 }, box)
	ui.clear = UI.button({
		parent = clearRow, text = "Clear source", kind = "ghost", small = true, size = UDim2.fromOffset(130, 34), name = "ClearSource",
		onClick = function()
			Store.set(sourceKey(Store.get("bgMode")), "")
			ui.input.Set("")
			Bg.apply()
			Notify.info("Source cleared", "The saved background source was removed.")
		end,
	})
	ui.status = Util.new("TextLabel", {
		Name = "Status", BackgroundTransparency = 1, LayoutOrder = 6, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = "", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, box)
	Typo.apply(ui.status, "caption", 12)
	Theme.bind(ui.status, "TextColor3", "Muted")

	local hints = {
		image = { holder = "Image ID, file name or link", desc = "One static picture. Use a Roblox Image asset ID, a PNG/JPG/WEBP in the executor folder 'VirexHub/backgrounds', or an image link." },
		sheet = { holder = "Sprite-sheet image (ID, file or link)", desc = "A GIF-style animation drawn as ONE picture made of a grid of frames. Set the grid and speed below." },
		sequence = { holder = "id1, id2, id3 (at least 2 frames)", desc = "A GIF-style animation from several images shown one after another. Separate the IDs or file names with commas." },
		video = { holder = "Roblox video ID or file.webm", desc = "Experimental. Needs a Roblox-hosted video asset or a local .webm / .mp4 file. Arbitrary video links cannot be streamed." },
	}
	local function refreshPanels()
		local mode = Store.get("bgMode")
		local hint = hints[mode]
		source.Instance.Visible = hint ~= nil
		if hint then
			local desc = hint.desc
			if not Env.canCustomAsset() then
				desc = desc .. " Local files and link downloads need file + custom-asset support, which this executor did not report; Roblox asset IDs still work."
			end
			source.SetTitle("Source: " .. modeLabel(mode))
			source.SetDesc(desc)
			ui.input.Box.PlaceholderText = hint.holder
			ui.input.Set(Store.get(sourceKey(mode)))
		end
		ui.rowCols.Visible = mode == "sheet"
		ui.rowRows.Visible = mode == "sheet"
		ui.rowFps.Visible = mode == "sheet" or mode == "sequence"
	end

	local modeDropdown = UI.dropdown({
		parent = modeCard.Controls, options = Bg.MODES, value = Store.get("bgMode"), name = "ModeDropdown",
		onChange = function(id)
			Store.set("bgMode", id)
			Bg.apply()
			refreshPanels()
		end,
	})
	modeDropdown.Instance.Size = UDim2.new(1, 0, 0, 36)
	modeDropdown.Instance.AnchorPoint = Vector2.new(0, 0.5)
	modeDropdown.Instance.Position = UDim2.fromScale(0, 0.5)
	Pages.register(modeCard, 190)
	Pages.sync(function()
		modeDropdown.Set(Store.get("bgMode"), true)
		refreshPanels()
	end)
	refreshPanels()

	local statusRoles = { idle = "Muted", loading = "Accent", ok = "Green", error = "Danger" }
	local function showStatus(kind, text)
		ui.status.Text = text
		Theme.tweenRole(ui.status, "TextColor3", statusRoles[kind] or "Muted", 0.2)
	end
	showStatus(Bg.status.kind, Bg.status.text)
	Pages.disposers[#Pages.disposers + 1] = Bg.onStatus(showStatus)

	-- readability ----------------------------------------------------------------------------------
	UI.section(page, "Readability", 4)
	sliderCard(page, 5, "Dark overlay", "Darkens picture and video backgrounds so text stays easy to read (never below 20% for media).", "overlay",
		{ min = 0, max = 0.9, step = 0.05, format = percentFormat })
	sliderCard(page, 6, "Panel transparency", "Lets the background show through the panels. Text keeps its contrast.", "glass",
		{ min = 0, max = 0.6, step = 0.05, format = percentFormat })
	toggleCard(page, 7, "Blur the game behind", "Adds a Roblox blur to the game view while the hub is open. Some experiences block new effects.", "blur")

	UI.section(page, "Good to know", 8)
	textCard(page, 9, "GIFs and video",
		"Roblox image labels cannot play .gif files, and video links from the internet cannot be streamed. For an animated background use a sprite sheet or an image sequence (they play at the speed you choose). Video works only with a Roblox-hosted video asset or a local .webm / .mp4 file.")
end

----------------------------------------------------------------------------------------------------
-- Tools
----------------------------------------------------------------------------------------------------
function Pages.build.tools(page)
	UI.section(page, "Interface", 1)
	actionCard(page, 2, "Recenter window", "Move the hub back to the center of the screen.", "Recenter", function()
		Win.recenter()
		Notify.info("Window centered", "The hub was moved to the screen center.")
	end, { name = "Recenter" })
	actionCard(page, 3, "Minimize window", "Collapse the hub to its title bar. Press the square button (or double-tap the title bar) to restore it.", "Minimize", function()
		Win.setMinimized(true)
	end, { name = "Minimize" })

	UI.section(page, "Roblox", 4)
	actionCard(page, 5, "Open Roblox settings", "Open Roblox's built-in settings menu.", "Open settings", Pages.openRobloxSettings,
		{ width = 132, name = "OpenSettings" })
	actionCard(page, 6, "Show session details", "Display the current experience, place ID, and player name.", "Show details", function()
		local player = Players.LocalPlayer
		Notify.info("Current session", string.format("%s %s Place %s %s %s", game.Name ~= "" and game.Name or "Experience", BULLET,
			tostring(game.PlaceId), BULLET, player and player.DisplayName or "Player"), { duration = 5 })
	end, { name = "Details" })
	actionCard(page, 7, "Rejoin server", "Ask Roblox to reconnect you to this server. You are asked to confirm first.", "Rejoin", Pages.rejoin,
		{ name = "Rejoin", kind = "danger" })
	Pages.buildServerFinder(page, 8) -- uses LayoutOrder 8 (card) and 9 (results)

	UI.section(page, "Clipboard", 10)
	local canCopy = Env.canClipboard()
	local _, copyPlace = actionCard(page, 11, "Copy place ID", "Copy this experience's place ID to the clipboard.", "Copy", function()
		if Env.copy(tostring(game.PlaceId)) then
			Notify.success("Copied", "Place ID " .. tostring(game.PlaceId) .. " is on your clipboard.")
		else
			Notify.error("Copy failed", "The executor refused the clipboard request.")
		end
	end, { name = "CopyPlace" })
	local _, copyJob = actionCard(page, 12, "Copy server ID", "Copy this server's job ID to the clipboard.", "Copy", function()
		if game.JobId == "" then
			Notify.warn("No server ID", "This session has no job ID (it may be a Studio or private test).")
		elseif Env.copy(game.JobId) then
			Notify.success("Copied", "The server ID is on your clipboard.")
		else
			Notify.error("Copy failed", "The executor refused the clipboard request.")
		end
	end, { name = "CopyJob" })
	if not canCopy then
		copyPlace.SetEnabled(false, "This executor does not provide a clipboard function.")
		copyJob.SetEnabled(false, "This executor does not provide a clipboard function.")
	end
end

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
function Pages.build.settings(page)
	UI.section(page, "Notifications", 1)
	toggleCard(page, 2, "Hub notifications", "Enable or silence notifications created by this interface.", "notifications", function(value)
		Notify.info("Notifications", value and "Notifications are on." or "Notifications are now off.", { key = "notif", force = true })
	end)

	UI.section(page, "Sound", 3)
	toggleCard(page, 4, "Sound effects", "Short sounds for buttons, tabs, toggles, notifications and opening or closing the hub.", "sound")
	sliderCard(page, 5, "Volume", "Master volume for every hub sound.", "volume", {
		min = 0, max = 1, step = 0.05, format = percentFormat,
		onChange = function(_, final)
			if final then
				Sfx.play("select")
			end
		end,
	})
	toggleCard(page, 6, "Loading screen sound", "Play the loading sound while the hub starts.", "splashSound")
	local soundCard = actionCard(page, 7, "Sound status", Sfx.summary(), "Test sound", function()
		if not Sfx.play("success", false) then
			Notify.warn("No sound played", "Sound is switched off, the volume is zero, or the sound assets did not load.")
		end
	end, { width = 124, name = "SoundStatus" })
	Pages.sync(function()
		soundCard.SetDesc(Sfx.summary())
	end)

	UI.section(page, "Interface scale", 8)
	local scaleCard = UI.card({
		parent = page, order = 9, title = "UI scale", desc = "Make the whole hub larger or smaller.", control = 150, name = "Scale",
	})
	local stepper = UI.stepper({
		parent = scaleCard.Controls, min = 0.9, max = 1.15, step = 0.05, value = Store.get("scale"), anchor = Vector2.new(1, 0.5),
		position = UDim2.fromScale(1, 0.5), format = function(value)
			return Util.percent(value) .. "%"
		end,
		onChange = function(value)
			Store.set("scale", value)
		end,
	})
	Pages.watch("scale", function(value)
		stepper.Set(value, true)
		scaleCard.SetDesc(string.format("Current scale: %d%%", Util.percent(value)))
	end)
	scaleCard.SetDesc(string.format("Current scale: %d%%", Util.percent(Store.get("scale"))))
	Pages.register(scaleCard, 150)

	UI.section(page, "Startup", 10)
	toggleCard(page, 11, "Show loading screen", "The loading screen reports real startup steps. Turning it off skips the screen; the hub starts the same way.", "splash")

	UI.section(page, "Storage", 12)
	textCard(page, 13, "Saved settings", storageText())

	UI.section(page, "Diagnostics", 14)
	actionCard(page, 15, "Environment", Env.summary(), "Copy report", function()
		local text = App.report()
		if Env.copy(text) then
			Notify.success("Report copied", "Paste it wherever you are getting help.")
		else
			Notify.warn("Clipboard unavailable", "This executor has no clipboard function, so the report cannot be copied.")
		end
	end, { width = 132, name = "Report" })

	UI.section(page, "Preferences", 16)
	actionCard(page, 17, "Reset preferences", "Restore the default theme, scale, background, sound and toggle states. Avatar favourites are kept.", "Reset", function()
		UI.confirm({
			title = "Reset preferences?",
			text = "Theme, scale, background, sound and window options go back to their defaults. Your avatar favourites are kept.",
			confirmText = "Reset", cancelText = "Cancel", danger = true,
			onConfirm = function()
				App.resetPreferences()
			end,
		})
	end, { name = "Reset", kind = "danger" })
	actionCard(page, 18, "Close hub", "Remove this interface from the screen. Run the script again to reopen it.", "Close", function()
		UI.confirm({
			title = "Close VirexHub?",
			text = "The hub is removed from the screen. Your saved settings are kept.",
			confirmText = "Close hub", cancelText = "Keep open", danger = true,
			onConfirm = function()
				App.destroy()
			end,
		})
	end, { name = "Close", kind = "danger" })
end
end -- [12_pages.lua]

do -- [14_scripts.lua]

----------------------------------------------------------------------------------------------------
-- Scripts: the third-party script catalog, favorites, link checks, the Execute pipeline, and the
-- Scripts and Information pages. Numbered 14 because it was added after 13_app.lua, but it sits before
-- it because App.start() runs at the end of that section.
--
-- The 40 entries were copied unchanged (names and links) from Vyre-Multiverse-41.lua. They are other
-- people's code: nothing is fetched, checked or run until the user taps Check, Check all or Execute.
----------------------------------------------------------------------------------------------------
Scripts.groups = {
	{ id = "main-free", title = "Main - no key", group = "main", key = false },
	{ id = "main-key", title = "Main - key required", group = "main", key = true },
	{ id = "bonus-free", title = "Bonus - no key", group = "bonus", key = false },
	{ id = "bonus-key", title = "Bonus - key required", group = "bonus", key = true },
}

Scripts.catalog = {
	-- main, no key (Vyre-Multiverse-41: scriptsData)
	{ id = "miranda-op", name = "Miranda OP", url = "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/stealeggies", key = false, group = "main" },
	{ id = "miranda-afk", name = "Miranda AFK", url = "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/afkk", key = false, group = "main" },
	{ id = "polluted-hub", name = "Polluted Hub", url = "https://raw.githubusercontent.com/PollutedHub/Sae/main/SaePolluted", key = false, group = "main" },
	{ id = "chilli-hub", name = "Chilli Hub", url = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/StealAnEgg", key = false, group = "main" },
	{ id = "universal-sae", name = "Universal SAE", url = "https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg", key = false, group = "main" },
	{ id = "blyxo-hub", name = "Blyxo Hub", url = "https://flowauth.net/v1/loaders/69d3463240384f3a73fbe32c178093a2.lua", key = false, group = "main" },
	{ id = "source-anti-hit", name = "Source Anti Hit", url = "https://gist.githubusercontent.com/sourceshubs/df6e17b3672213791b47a0a8c5398b6e/raw/SourcesHubAntiHitNewest", key = false, group = "main" },
	{ id = "source-instant-steal", name = "Source Instant Steal", url = "https://gist.githubusercontent.com/sourceshubs/9c70c7c483019f2de5d7119ae05ba3f8/raw/SourcesHubStealAnEgg", key = false, group = "main" },
	{ id = "sources-instant", name = "Sources Instant", url = "https://gist.githubusercontent.com/sourceshubs/1737c14cdba5c6fb472a995d555a50f1/raw/SourcesHubInstantStealNew", key = false, group = "main" },
	{ id = "fox", name = "Fox", url = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Fn-stealanegg.lua", key = false, group = "main" },
	{ id = "virex", name = "Virex", url = "https://cdn.luaprotect.dev/u/8660b0/AvrC3cs5mZ38jbnD", key = false, group = "main" },
	{ id = "decode", name = "Decode", url = "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua", key = false, group = "main" },
	{ id = "lennon-hub-v3", name = "Lennon Hub V3", url = "https://raw.githubusercontent.com/lennonxscripts/lennonhubv3/refs/heads/main/stealanegg.lua", key = false, group = "main" },
	{ id = "yokudo-hub", name = "Yokudo Hub", url = "https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua", key = false, group = "main" },
	{ id = "virex-v2", name = "Virex V2", url = "https://gist.githubusercontent.com/virexx55/836653079c73281295d6bfb5c10be5d9/raw/128b0220c9a36354b5c6504c3669f328e5354805/virex.lua", key = false, group = "main" },
	{ id = "clout-hub", name = "NEW · Clout Hub", url = "https://raw.githubusercontent.com/ClouthubOnTop/Loader/main/main.lua", key = false, group = "main" },
	-- main, key required (scriptsDataKey)
	{ id = "fyy-hub", name = "FYY Hub", url = "https://FyyCommunity.my.id", key = true, group = "main" },
	{ id = "zeroin-hub", name = "Zeroin Hub", url = "https://zeroinhub.com/api/script", key = true, group = "main" },
	{ id = "bigfoot-bf", name = "Bigfoot Bf", url = "https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua", key = true, group = "main" },
	{ id = "clover-hub", name = "Clover Hub", url = "https://cloverhub.app/clover.lua", key = true, group = "main" },
	{ id = "titanic-hub", name = "Titanic Hub", url = "https://raw.githubusercontent.com/TITANIC-HUB/StealAnEgg/main/Loader.lua", key = true, group = "main" },
	{ id = "limbo-hub", name = "Limbo Hub", url = "https://limbohub.my.id/loader.lua", key = true, group = "main" },
	{ id = "kira-hub", name = "Kira Hub", url = "https://raw.githubusercontent.com/shebetterlol889/shh/refs/heads/main/shh", key = true, group = "main" },
	{ id = "equinox-hub", name = "Equinox Hub", url = "https://api.jnkie.com/api/v1/luascripts/public/338ceeba573ee21d1ce80a020b7923d8bde36038de4511162b01f325b16b9c3f/download", key = true, group = "main" },
	{ id = "ajjan-hub", name = "Ajjan Hub", url = "https://api.luarmor.net/files/v4/loaders/359e97f8618e9008afe5f496184ebb7c.lua", key = true, group = "main" },
	{ id = "nasi-rendang-hub", name = "Nasi Rendang Hub", url = "https://raw.githubusercontent.com/JualNasiRendang/loader/refs/heads/main/main.lua", key = true, group = "main" },
	{ id = "axon-hub", name = "Axon Hub", url = "https://api.luarmor.net/files/v3/loaders/97c3f6db55a2cf72141537a85458e5a7.lua", key = true, group = "main" },
	{ id = "speed-hub-x", name = "Speed Hub X", url = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", key = true, group = "main" },
	{ id = "neptune-hub", name = "Neptune Hub", url = "https://api.luarmor.net/files/v4/loaders/ed76667e766b5afc5bbfe2761bed56b7.lua", key = true, group = "main" },
	-- bonus, no key (bonusKeyless)
	{ id = "rene-baterbonia", name = "Rene Baterbonia", url = "https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg", key = false, group = "bonus" },
	{ id = "chocola-spawner", name = "Chocola Spawner", url = "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Pet-Spawner-steal-an-egg/refs/heads/main/script.lua", key = false, group = "bonus" },
	{ id = "exploit-hub", name = "Exploit Hub", url = "https://raw.githubusercontent.com/Main-Scripts-Ready-V9/Exploiter-Loader/refs/heads/main/New.lua", key = false, group = "bonus" },
	{ id = "private-server", name = "Private Server", url = "https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua", key = false, group = "bonus" },
	{ id = "source-hub-v1", name = "Source Hub V1", url = "https://pastefy.app/Lk0vDMmN/raw", key = false, group = "bonus" },
	{ id = "source-hub-v2", name = "Source Hub V2", url = "https://api.obscuravm.com/scripts/7924424523909516877", key = false, group = "bonus" },
	{ id = "source-hub-v3", name = "Source Hub V3", url = "https://api.obscuravm.com/scripts/2007463552086815334", key = false, group = "bonus" },
	{ id = "shader", name = "Shader", url = "https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/lua", key = false, group = "bonus" },
	-- bonus, key required (bonusKey)
	{ id = "infinite-robux", name = "Infinite Robux", url = "https://pastefy.app/CkaV7ET8/raw", key = true, group = "bonus" },
	{ id = "all-games-script", name = "All Games Script", url = "https://raw.githubusercontent.com/leenZzZzZ/ScriptHUB/refs/heads/main/Script%20Hub", key = true, group = "bonus" },
	{ id = "flowauth", name = "Flowauth", url = "https://flowauth.net/v1/loaders/6824c37a4078d7d311677732e231edaa.lua", key = true, group = "bonus" },
}

Scripts.byId, Scripts.byName = {}, {}
Scripts.state = {}      -- id -> { state = "unchecked" | "checking" | "online" | "offline", detail, at, token }
Scripts.views = {}      -- id -> { paint(state), describe() }, set by the Scripts page
Scripts.notes = {}      -- id -> "Last run: ..." text shown on the card
Scripts.confirmed = {}  -- id -> true once the first-run dialog was accepted this session
Scripts.running = {}    -- id -> true while Execute is working on it
Scripts.sweep = { running = false, token = 0 }
Scripts.onState = nil   -- optional function() that refreshes the "Link status" summary
Scripts.checkSeconds = 12
Scripts.gapSeconds = 0.4

for _, entry in ipairs(Scripts.catalog) do
	Scripts.byId[entry.id] = entry
	Scripts.byName[entry.name] = entry
	Scripts.state[entry.id] = { state = "unchecked", detail = "", token = 0 }
end

-- host part of a link, shown in the cards and in the first-run dialog
function Scripts.host(url)
	local host = string.match(tostring(url), "^%a[%w+.%-]*://([^/%?#]+)")
	if not host then
		return "unknown host"
	end
	host = string.gsub(host, "^.*@", "")
	return host
end

----------------------------------------------------------------------------------------------------
-- favorites (Store key "scriptFavorites": a list of catalog ids)
----------------------------------------------------------------------------------------------------
function Scripts.isFavorite(id)
	return Util.indexOf(Store.get("scriptFavorites"), id) ~= nil
end

-- returns true when the script is a favorite afterwards
function Scripts.toggleFavorite(id)
	if not Scripts.byId[id] then
		return false
	end
	local list = Util.copy(Store.get("scriptFavorites"))
	local index = Util.indexOf(list, id)
	if index then
		table.remove(list, index)
	else
		if #list >= Store.rules.scriptFavorites.max then
			Notify.warn("Favorites full", "You can keep up to " .. Store.rules.scriptFavorites.max .. " favorite scripts.")
			return false
		end
		list[#list + 1] = id
	end
	Store.set("scriptFavorites", list)
	return index == nil
end

-- drops favorites whose script is no longer in the catalog; returns how many were removed
function Scripts.pruneFavorites()
	local list, kept = Store.get("scriptFavorites"), {}
	for _, id in ipairs(list) do
		if Scripts.byId[id] then
			kept[#kept + 1] = id
		end
	end
	local removed = #list - #kept
	if removed > 0 then
		Store.set("scriptFavorites", kept, true)
		Util.log("info", "removed " .. removed .. " script favorite(s) that are not in the catalog")
	end
	return removed
end

-- Vyre Hub saved { [scriptName] = true } in VyreHub_Favorites.json; map those names to catalog ids
function Scripts.importLegacy(decoded)
	local ids = {}
	if type(decoded) ~= "table" then
		return ids
	end
	for _, entry in ipairs(Scripts.catalog) do
		if decoded[entry.name] == true then
			ids[#ids + 1] = entry.id
		end
	end
	return ids
end

----------------------------------------------------------------------------------------------------
-- link status (never persisted, never started at boot)
----------------------------------------------------------------------------------------------------
function Scripts.setState(id, state, detail)
	local st = Scripts.state[id]
	if not st then
		return
	end
	st.state, st.detail = state, detail or ""
	if state == "online" or state == "offline" then
		st.at = os.date("%H:%M:%S")
	end
	local view = Scripts.views[id]
	if view then
		Util.try("script card " .. id, view.paint, st)
	end
	if Scripts.onState then
		Util.try("script summary", Scripts.onState)
	end
end

function Scripts.setNote(id, text)
	Scripts.notes[id] = text
	local view = Scripts.views[id]
	if view then
		Util.try("script note " .. id, view.describe)
	end
end

function Scripts.counts()
	local counts = { unchecked = 0, checking = 0, online = 0, offline = 0 }
	for _, entry in ipairs(Scripts.catalog) do
		local state = Scripts.state[entry.id].state
		counts[state] = counts[state] + 1
	end
	return counts
end

-- Blocks (yields) until the link answered or Scripts.checkSeconds passed. Online = HTTP 2xx, nothing more.
function Scripts.check(id)
	local entry, st = Scripts.byId[id], Scripts.state[id]
	if not entry or not st then
		return nil
	end
	if st.state == "checking" then
		return st.state
	end
	st.token = st.token + 1
	local token = st.token
	Scripts.setState(id, "checking", "")
	local finished = false
	task.spawn(function()
		local result = Env.fetch(entry.url, "request")
		if st.token ~= token then
			return -- timed out or superseded; the late answer is ignored
		end
		finished = true
		if result.ok then
			Scripts.setState(id, "online", result.status and ("HTTP " .. result.status) or ("answered via " .. tostring(result.via)))
		else
			Scripts.setState(id, "offline", Util.cap(tostring(result.error), 80))
		end
	end)
	local waited = 0
	while not finished and st.token == token and waited < Scripts.checkSeconds and not App.destroyed do
		task.wait(0.1)
		waited = waited + 0.1
	end
	if not finished and st.token == token and not App.destroyed then
		st.token = st.token + 1
		Scripts.setState(id, "offline", "no answer after " .. Scripts.checkSeconds .. " s")
	end
	return st.state
end

-- sequential, Scripts.gapSeconds apart, cancellable with Scripts.stopCheckAll(); onFinish runs only when the sweep completes
function Scripts.checkAll(onFinish)
	local sweep = Scripts.sweep
	if sweep.running then
		return false
	end
	sweep.running = true
	sweep.token = sweep.token + 1
	local token = sweep.token
	task.spawn(function()
		for _, entry in ipairs(Scripts.catalog) do
			if sweep.token ~= token or App.destroyed then
				break
			end
			Scripts.check(entry.id)
			if sweep.token ~= token or App.destroyed then
				break
			end
			task.wait(Scripts.gapSeconds)
		end
		if sweep.token == token then
			sweep.running = false
			if onFinish then
				Util.try("check all finish", onFinish)
			end
		end
	end)
	return true
end

function Scripts.stopCheckAll()
	local sweep = Scripts.sweep
	sweep.token = sweep.token + 1
	sweep.running = false
end

----------------------------------------------------------------------------------------------------
-- Execute: fetch -> compile -> run, and say which stage failed
----------------------------------------------------------------------------------------------------
function Scripts.launch(entry, button)
	local id = entry.id
	if Scripts.running[id] then
		return
	end
	Scripts.running[id] = true
	local function finish(note)
		Scripts.running[id] = nil
		Scripts.setNote(id, note)
		if button and Util.alive(button.Instance) then
			button.SetBusy(false)
		end
	end
	if button then
		button.SetBusy(true, "Fetching...")
	end

	-- 1. fetch (game:HttpGet, then the executor's request function)
	local fetched = Env.fetch(entry.url, "get")
	if not fetched.ok then
		Notify.error("Fetch failed", entry.name .. ": " .. Util.cap(tostring(fetched.error), 100))
		finish("Last run: fetch failed - " .. Util.cap(tostring(fetched.error), 60))
		return
	end
	if not string.find(fetched.body, "%S") then
		Notify.error("Fetch failed", entry.name .. ": the link answered with an empty file.")
		finish("Last run: fetch failed - empty answer")
		return
	end

	-- 2. compile
	local chunk, compileError = Env.compile(fetched.body)
	if not chunk then
		Notify.error("Compile failed", entry.name .. ": " .. Util.cap(tostring(compileError), 100))
		finish("Last run: compile failed - " .. Util.cap(tostring(compileError), 60))
		return
	end

	-- 3. run (in its own thread, so a script that keeps running never blocks the hub)
	local run = { failed = false }
	task.spawn(function()
		local ok, runError = pcall(chunk)
		if not ok then
			run.failed = true
			Notify.error("Run failed", entry.name .. ": " .. Util.cap(tostring(runError), 100))
			Scripts.setNote(id, "Last run: failed while running - " .. Util.cap(tostring(runError), 60))
		end
	end)
	task.wait(0.3)
	if run.failed then
		finish(Scripts.notes[id])
	else
		Notify.success("Script started", entry.name .. " was fetched, compiled and started. Errors after start-up are reported here.")
		finish("Last run: started at " .. os.date("%H:%M:%S"))
	end
end

-- asks once per script per session, then launches
function Scripts.run(id, button)
	local entry = Scripts.byId[id]
	if not entry or Scripts.running[id] then
		return
	end
	if not Env.canRun() then
		Notify.warn("Execute unavailable", "This executor does not provide loadstring, so scripts cannot be run here.")
		return
	end
	local function go()
		task.spawn(Scripts.launch, entry, button)
	end
	if Scripts.confirmed[id] then
		go()
		return
	end
	local opened = UI.confirm({
		title = "Run this script?",
		text = string.format(
			"Name: %s\nHost: %s\nKey required: %s\n\nThis is third-party code. It runs with full access to your Roblox client and is not checked by VirexHub. Only continue if you trust the source.",
			entry.name, Scripts.host(entry.url), entry.key and "yes" or "no"
		),
		confirmText = "Run", cancelText = "Cancel", danger = true,
		onConfirm = function()
			Scripts.confirmed[id] = true
			go()
		end,
	})
	if not opened then
		Notify.warn("Dialog busy", "Close the open dialog first, then tap Execute again.")
	end
end

----------------------------------------------------------------------------------------------------
-- Scripts page
----------------------------------------------------------------------------------------------------
local STATE_CHIP = {
	unchecked = { "NOT CHECKED", "Muted" },
	checking = { "CHECKING", "Info" },
	online = { "ONLINE", "Green" },
	offline = { "OFFLINE", "Danger" },
}

function Pages.build.scripts(page)
	Scripts.pruneFavorites()
	local cards, sections = {}, {}
	local search, filter, empty, applyFilter

	-- toolbar: search + filter share a row on wide windows and stack on narrow ones ----------------
	local toolbar = Util.new("Frame", {
		Name = "Toolbar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 82), LayoutOrder = 1,
	}, page)
	search = UI.input({
		parent = toolbar, name = "Search", placeholder = "Search scripts", maxLength = 40,
		onChange = function()
			if applyFilter then
				applyFilter()
			end
		end,
	})
	filter = UI.segmented({
		parent = toolbar, name = "Filter", value = "all",
		options = {
			{ id = "all", label = "All" }, { id = "free", label = "No key" },
			{ id = "key", label = "Key" }, { id = "fav", label = "Favorites" },
		},
		onChange = function()
			if applyFilter then
				applyFilter()
			end
		end,
	})
	local function layoutToolbar(width)
		if width >= 520 then
			toolbar.Size = UDim2.new(1, 0, 0, 38)
			search.Instance.Size, search.Instance.Position = UDim2.new(0.55, -4, 0, 38), UDim2.new(0, 0, 0, 0)
			filter.Instance.Size, filter.Instance.Position = UDim2.new(0.45, -4, 0, 36), UDim2.new(0.55, 4, 0, 1)
		else
			toolbar.Size = UDim2.new(1, 0, 0, 82)
			search.Instance.Size, search.Instance.Position = UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 0)
			filter.Instance.Size, filter.Instance.Position = UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 46)
		end
	end
	Pages.gridUpdaters[#Pages.gridUpdaters + 1] = layoutToolbar
	layoutToolbar(Win.pageW or 400)

	-- link status summary + Check all -----------------------------------------------------------------
	local sweepCard = UI.card({ parent = page, order = 2, title = "Link status", desc = "", control = 112, name = "LinkStatus" })
	local sweepButton = UI.button({
		parent = sweepCard.Controls, text = "Check all", small = true, name = "CheckAll",
		size = UDim2.new(1, 0, 0, 34), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
		onClick = function(button)
			if Scripts.sweep.running then
				Scripts.stopCheckAll()
				button.SetText("Check all")
				Notify.info("Check stopped", "The remaining links were left unchecked.")
			elseif Scripts.checkAll(function()
				if Util.alive(button.Instance) then
					button.SetText("Check all")
				end
			end) then
				button.SetText("Stop")
			end
		end,
	})
	Pages.register(sweepCard, 112)
	if not Env.canFetch() then
		sweepButton.SetEnabled(false, "This executor has no HttpGet or request function, so links cannot be checked.")
	end
	Scripts.onState = function()
		if not Util.alive(sweepCard.Instance) then
			return
		end
		local counts = Scripts.counts()
		sweepCard.SetDesc(string.format(
			"%d online, %d offline, %d checking, %d not checked. Nothing is checked until you ask, and Online only means the link answered with HTTP 2xx - not that the script works.",
			counts.online, counts.offline, counts.checking, counts.unchecked
		))
	end
	Scripts.onState()

	-- cards ---------------------------------------------------------------------------------------------
	local function buildCard(entry, order)
		local host = Scripts.host(entry.url)
		local card = UI.card({
			parent = page, order = order, name = "Script_" .. entry.id, title = entry.name, desc = host,
			stack = true, controlHeight = 68,
		})
		local chips = Util.new("Frame", { Name = "Chips", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22) }, card.Controls)
		Util.list(chips, 6, true)
		local statusChip = UI.chip({ parent = chips, text = STATE_CHIP.unchecked[1], role = STATE_CHIP.unchecked[2], order = 1 })
		UI.chip({ parent = chips, text = entry.key and "KEY" or "NO KEY", role = entry.key and "Warn" or "Accent", order = 2 })

		local row = Util.new("Frame", {
			Name = "Actions", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 0, 36),
		}, card.Controls)
		local star = UI.button({
			parent = row, name = "Star", icon = "star", iconRole = "Muted", kind = "ghost", sound = "select",
			size = UDim2.fromOffset(40, 36),
			onClick = function()
				Scripts.toggleFavorite(entry.id)
			end,
		})
		local check = UI.button({
			parent = row, name = "Check", text = "Check", kind = "ghost", small = true,
			size = UDim2.new(0.4, -21, 1, 0), position = UDim2.new(0, 46, 0, 0),
			onClick = function()
				task.spawn(Scripts.check, entry.id)
			end,
		})
		local run = UI.button({
			parent = row, name = "Execute", text = "Execute", kind = "primary", small = true,
			size = UDim2.new(0.6, -31, 1, 0), position = UDim2.new(0.4, 31, 0, 0),
			onClick = function(button)
				Scripts.run(entry.id, button)
			end,
		})
		if not Env.canFetch() then
			check.SetEnabled(false, "This executor has no HttpGet or request function, so links cannot be checked.")
		end
		if not Env.canRun() then
			run.SetEnabled(false, "This executor does not provide loadstring, so scripts cannot be run here.")
		end

		local function describe()
			local st = Scripts.state[entry.id]
			local lines = { host }
			if st.state == "online" or st.state == "offline" then
				lines[#lines + 1] = string.format(
					"%s at %s%s", st.state == "online" and "Online" or "Offline", st.at or "-", st.detail ~= "" and (" - " .. st.detail) or ""
				)
			end
			if Scripts.notes[entry.id] then
				lines[#lines + 1] = Scripts.notes[entry.id]
			end
			card.SetDesc(table.concat(lines, "\n"))
		end
		Scripts.views[entry.id] = {
			describe = describe,
			paint = function(st)
				local chip = STATE_CHIP[st.state] or STATE_CHIP.unchecked
				statusChip.Set(chip[1], chip[2])
				describe()
			end,
		}
		cards[entry.id] = { card = card, lower = string.lower(entry.name), star = star }
	end

	for groupIndex, group in ipairs(Scripts.groups) do
		sections[groupIndex] = UI.section(page, group.title, groupIndex * 100)
		local position = 0
		for _, entry in ipairs(Scripts.catalog) do
			if entry.group == group.group and entry.key == group.key then
				position = position + 1
				buildCard(entry, groupIndex * 100 + position)
				if position % 10 == 0 then
					task.wait() -- keep the loading screen responsive while the cards are built
				end
			end
		end
	end
	empty = UI.card({ parent = page, order = 900, title = "No scripts to show", desc = "", name = "NoScripts" })
	empty.Instance.Visible = false

	-- filtering + favorites ------------------------------------------------------------------------------
	applyFilter = function()
		local query = string.lower(search.Get())
		local mode = filter.Get()
		local shown, perGroup = 0, {}
		for _, entry in ipairs(Scripts.catalog) do
			local view = cards[entry.id]
			if view then
				local visible = true
				if mode == "free" and entry.key then
					visible = false
				elseif mode == "key" and not entry.key then
					visible = false
				elseif mode == "fav" and not Scripts.isFavorite(entry.id) then
					visible = false
				end
				if visible and query ~= "" and not string.find(view.lower, query, 1, true) then
					visible = false
				end
				view.card.Instance.Visible = visible
				if visible then
					shown = shown + 1
					for groupIndex, group in ipairs(Scripts.groups) do
						if entry.group == group.group and entry.key == group.key then
							perGroup[groupIndex] = (perGroup[groupIndex] or 0) + 1
						end
					end
				end
			end
		end
		for groupIndex, row in ipairs(sections) do
			row.Visible = (perGroup[groupIndex] or 0) > 0
		end
		empty.Instance.Visible = shown == 0
		if shown == 0 then
			empty.SetDesc(mode == "fav" and query == "" and "No favorites yet. Tap the star on a script to keep it here."
				or "Nothing matches your search and filter.")
		end
	end
	local function paintStars()
		for id, view in pairs(cards) do
			if view.star.Icon then
				view.star.Icon.SetRole(Scripts.isFavorite(id) and "Warn" or "Muted", 0.15)
			end
		end
	end
	for id, view in pairs(cards) do
		if view.star.Icon and Scripts.isFavorite(id) then
			view.star.Icon.SetRole("Warn")
		end
	end
	Pages.watch("scriptFavorites", function()
		paintStars()
		applyFilter()
	end)
	applyFilter()
end

----------------------------------------------------------------------------------------------------
-- Information page (written from what this file actually does)
----------------------------------------------------------------------------------------------------
function Pages.build.information(page)
	local DOT = "\226\128\162"
	local order = 0
	local function nextOrder()
		order = order + 1
		return order
	end
	local function section(title)
		UI.section(page, title, nextOrder())
	end
	local function note(title, body)
		return UI.card({ parent = page, order = nextOrder(), title = title, desc = body, name = title })
	end
	local function bullets(...)
		return DOT .. " " .. table.concat({ ... }, "\n" .. DOT .. " ")
	end
	local function yesNo(flag, yes, no)
		return flag and yes or no
	end

	local counts = { main = 0, bonus = 0, key = 0 }
	for _, entry in ipairs(Scripts.catalog) do
		counts[entry.group] = counts[entry.group] + 1
		if entry.key then
			counts.key = counts.key + 1
		end
	end

	section("About")
	note("VirexHub", "A touch-first interface for the Delta executor on Android. It combines a script launcher, an avatar changer, themes and backgrounds, and a few Roblox tools in one window. It runs on your device only; nothing here changes server-side game rules.")
	note("This build", string.format("Version %s  %s  Executor: %s  %s  %s\nOwner / maintainer: TODO - add the name here (it is not given in the project files).",
		CONFIG.Version, DOT, Env.executor, DOT, Store.persistent and "settings saved to a file" or "settings last for this session"))

	section("What's new")
	note("Version " .. CONFIG.Version, bullets(
		"Scripts tab: " .. #Scripts.catalog .. " catalog entries (" .. counts.main .. " main, " .. counts.bonus .. " bonus) with search and an All / No key / Key / Favorites filter.",
		"Favorite stars, saved with your settings. Stars from Vyre Hub (VyreHub_Favorites.json) are imported once, read-only.",
		"Link checks only when you ask: Check on a card, or Check all. Nothing is contacted at start-up.",
		"Execute asks first (name, host, key) and reports whether fetch, compile or run failed.",
		"Tools: Private Server Finder lists the quietest public servers and joins one after you confirm.",
		"New Information tab (this page)."
	))
	note("Earlier", bullets("2.0.0: rebuilt interface with loading screen, themes, backgrounds, avatar tools, sounds, fonts and settings."))

	section("Feature directory")
	note("Tabs", bullets(
		"Overview: session details, live FPS, ping and hub uptime.",
		"Scripts: browse, check and run the script catalog.",
		"Avatar: copy a player's look, apply a classic shirt and pants, keep avatar favorites.",
		"Appearance: compact window, title bar clock, motion options, themes and fonts.",
		"Background: solid, aurora, sparkle, picture, sprite sheet, image sequence or video background, with overlay, transparency and blur.",
		"Tools: recenter or minimize the window, Roblox settings, session details, Rejoin, Private Server Finder, copy place or server ID.",
		"Settings: notifications, sound and volume, UI scale, loading screen, saved-settings status, environment report, reset, close.",
		"Information: this page."
	))

	section("Feature status")
	note("Right now on this device", bullets(
		"Script catalog: " .. #Scripts.catalog .. " entries, " .. counts.key .. " of them marked as needing a key.",
		"Execute: " .. yesNo(Env.canRun(), "available (loadstring found).", "unavailable - this executor has no loadstring."),
		"Link checks: " .. yesNo(Env.canFetch(), "available.", "unavailable - no HttpGet or request function."),
		"Favorites and settings: " .. yesNo(Store.persistent, "saved to " .. CONFIG.ConfigFile .. ".", "kept for this session only."),
		"Private Server Finder: " .. yesNo(Env.fn.request ~= nil, "available (public servers only).", "unavailable - needs the executor's request function."),
		"Avatar tools: use Roblox's HumanoidDescription from your client; the experience decides whether to accept the change.",
		"Sounds: asset IDs could not be verified when the hub was written. Failed loads stay silent (Settings > Sound status)."
	))

	section("Controls")
	note("Window", bullets(
		"Drag the title bar to move the window; double-tap it to minimize or restore.",
		"The minus button minimizes. The X button closes the hub after asking; run the script again to reopen it.",
		"Keyboard or mouse only: " .. CONFIG.ToggleKey .. " shows or hides the window.",
		"Pages scroll. The sidebar scrolls too when the window is short."
	))
	note("Scripts", bullets(
		"Star: add or remove a favorite.",
		"Check: ask the link if it answers.",
		"Execute: fetch, compile and run the script. You are asked the first time each session."
	))

	section("Known issues")
	note("Limits to expect", bullets(
		"Catalog links belong to other people and can move, stop working or start asking for a key. Online means HTTP 2xx only.",
		"Universal SAE and Rene Baterbonia share one link, as in the source list.",
		"Check uses a normal GET. A host may answer it differently than a game client, so Offline is not proof a script is dead.",
		"Private Server Finder lists public servers. Roblox can rate-limit it (HTTP 429), results are cached for 30 seconds, and a server can fill up before you join.",
		"Some experiences block or reset avatar changes, and some block the blur effect.",
		"Executors differ: without loadstring, Execute is off; without a request function, the Private Server Finder is off."
	))

	section("FAQ")
	note("Why is Execute greyed out?", "This executor has no loadstring function. Tap the button to see the reason. Everything else in the hub still works.")
	note("A script failed. What does the message mean?", "Fetch failed: the link could not be downloaded. Compile failed: what came back was not valid code (for example a web page). Run failed: the script started and then raised an error.")
	note("Where are my favorites kept?", "In " .. CONFIG.ConfigFile .. " in the executor workspace, when file access works. Reset preferences keeps your script favorites.")
	note("I used Vyre Hub before. Are my stars here?", "On the first launch with no script favorites, VirexHub reads " .. CONFIG.LegacyScriptFavorites .. " once (read-only) and stars the scripts with matching names.")

	section("Compatibility")
	note("This executor", Env.summary())
	note("Script launcher", Env.runSummary() .. "\nInterface container: " .. tostring(App.parentKind))
	note("Tested on", "Written for Delta on Android. Other executors may work if they provide the same functions. It has not been confirmed on every Roblox or Delta version.")

	section("Notices")
	note("Third-party scripts are unverified", "Scripts in the catalog are written and hosted by other people. VirexHub does not review them. Once you run one, it has full access to your Roblox client.")
	note("Protect your account", "Never share your cookies, passwords or login tokens, and never paste them anywhere a script or a website asks for them.")

	section("Credits")
	note("Sources used", bullets(
		"VirexHub (original): identity, tabs, palettes.",
		"Blyxo loader: loading-screen structure and sounds.",
		"Vyre Multiverse: click sound, FPS / ping readout, rejoin idea, and the script catalog entries.",
		"VYRE-INSTANT_STEAL: visual language only.",
		"AVATAR-CHANGER (returnreturnfunction): avatar tools."
	))
	note("Script authors", "Each script in the catalog belongs to its author. TODO: add maintainer and contributor names here once they are confirmed.")
end
end -- [14_scripts.lua]

do -- [13_app.lua]

----------------------------------------------------------------------------------------------------
-- App: boot sequence, duplicate-run protection, settings wiring, diagnostics, teardown.
-- The loading screen shows REAL work only: every bar step is a boot stage that actually finished
-- (or a real sound-preload completion). A watchdog hands off to the hub if startup stalls.
----------------------------------------------------------------------------------------------------
App.startedAt = os.clock()
App.gui = nil
App.maid = nil
App.token = nil
App.booted = false
App.destroyed = false
App.handedOff = false
App.parentKind = "none"
App.warnings = {}

function App.warn(text)
	App.warnings[#App.warnings + 1] = text
	Util.log("warn", text)
end

----------------------------------------------------------------------------------------------------
-- duplicate-run protection
----------------------------------------------------------------------------------------------------
-- Removes ScreenGuis left behind by an earlier run (or by the original script) in every place a hub can live.
function App.removeLeftovers()
	local names = { CONFIG.GuiName, CONFIG.SplashName }
	for _, legacy in ipairs(CONFIG.LegacyGuis) do
		names[#names + 1] = legacy
	end
	local parents = {}
	if Env.fn.gethui then
		local ok, container = pcall(Env.fn.gethui)
		if ok and typeof(container) == "Instance" then
			parents[#parents + 1] = container
		end
	end
	local player = Players.LocalPlayer
	local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		parents[#parents + 1] = playerGui
	end
	for _, parent in ipairs(parents) do
		for _, name in ipairs(names) do
			local guard = 0
			local found = parent:FindFirstChild(name)
			while found and guard < 8 do
				pcall(found.Destroy, found)
				guard = guard + 1
				found = parent:FindFirstChild(name)
			end
		end
	end
end

-- If a previous run registered itself, ask it to tear down first; then register this run.
function App.claim()
	local global = Env.global()
	local previous = global.__VirexHub
	if type(previous) == "table" and type(previous.destroy) == "function" then
		pcall(previous.destroy, "replaced by a newer run")
	end
	App.removeLeftovers()
	App.token = {}
	global.__VirexHub = {
		version = CONFIG.Version,
		token = App.token,
		destroy = function(reason)
			App.destroy(reason or "api")
		end,
		toggle = function()
			Win.toggle()
		end,
	}
end

----------------------------------------------------------------------------------------------------
-- settings side effects (one place). Widgets only call Store.set; these listeners do the rest.
----------------------------------------------------------------------------------------------------
function App.wire()
	local maid = App.maid
	local function on(key, fn)
		maid:Give(Store.on(key, fn))
	end
	on("reducedMotion", function(value)
		Motion.reduced = value
		Theme.syncFx()
		Bg.apply()
	end)
	on("lowPower", function()
		Theme.syncFx()
		Bg.apply()
	end)
	on("fx", function()
		Theme.syncFx()
	end)
	on("theme", function(id)
		Theme.apply(id)
	end)
	on("glass", function(value)
		Theme.setGlass(value)
	end)
	on("overlay", function()
		Bg.updateOverlay()
	end)
	on("blur", function()
		Bg.syncBlur()
	end)
	on("font", function(id)
		Typo.setFamily(id)
	end)
end

function App.resetPreferences()
	Store.reset()
	Bg.apply()
	Pages.syncAll()
	Win.recenter()
	Win.setMinimized(false)
	Notify.success("Preferences reset", "The hub is back to its default settings.")
end

----------------------------------------------------------------------------------------------------
-- diagnostics (Settings > Environment > Copy report)
----------------------------------------------------------------------------------------------------
function App.report()
	local lines = {}
	local function add(text)
		lines[#lines + 1] = text
	end
	add("VirexHub " .. CONFIG.Version)
	add(Env.summary())
	add("Interface parent: " .. tostring(App.parentKind))
	add("Settings: " .. (Store.persistent and ("saved to " .. CONFIG.ConfigFile) or "session only"))
	add("Sound: " .. Sfx.summary())
	add("Background: " .. tostring(Bg.status.kind) .. " - " .. tostring(Bg.status.text))
	add(string.format(
		"Theme %s | font %s | scale %d%% | compact %s | reduced motion %s | low power %s | accents %d",
		tostring(Theme.id), tostring(Store.get("font")), Util.percent(Store.get("scale")), tostring(Store.get("compact")),
		tostring(Store.get("reducedMotion")), tostring(Store.get("lowPower")), Store.get("fx")
	))
	local viewport = Env.viewport()
	add(string.format(
		"Viewport %dx%d | window %dx%d at scale %d%% | rail %s | short %s | minimized %s",
		math.floor(viewport.X), math.floor(viewport.Y), math.floor(Win.w), math.floor(Win.h), Util.percent(Win.s),
		tostring(Win.rail), tostring(Win.short), tostring(Win.minimized)
	))
	add("Recent log:")
	for index = math.max(1, #Util.logs - 25), #Util.logs do
		local entry = Util.logs[index]
		add(string.format("  [%.1fs] %s: %s", entry.t - App.startedAt, entry.level, entry.message))
	end
	return table.concat(lines, "\n")
end

----------------------------------------------------------------------------------------------------
-- teardown
----------------------------------------------------------------------------------------------------
function App.destroy(reason)
	if App.destroyed then
		return
	end
	App.destroyed = true
	Util.log("info", "destroy: " .. tostring(reason))
	pcall(Store.flush)
	pcall(UI.endSessions)
	pcall(UI.closeDropdown, true)
	pcall(UI.closeModal, true)
	pcall(Pages.destroy)
	pcall(Splash.destroy)
	pcall(Notify.destroy)
	pcall(Win.destroy)
	pcall(Bg.destroy)
	pcall(Sfx.destroy)
	pcall(Theme.clearFx)
	Anim.stopAll()
	if App.maid then
		pcall(App.maid.Clean, App.maid)
		App.maid = nil
	end
	Store.listeners = {}
	if App.gui then
		pcall(App.gui.Destroy, App.gui)
		App.gui = nil
	end
	local global = Env.global()
	local registered = global.__VirexHub
	if type(registered) == "table" and registered.token == App.token then
		global.__VirexHub = nil
	end
end

----------------------------------------------------------------------------------------------------
-- boot
----------------------------------------------------------------------------------------------------
function App.boot()
	-- environment + settings first: the loading screen needs the theme, fonts and the user's choices
	Env.detect()
	App.claim()
	Store.load()
	if Store.unreadable == "kept" then
		App.warn("Saved settings could not be read, so defaults are in use. The old file was kept as " .. CONFIG.Folder .. "/config.unreadable.json.")
	elseif Store.unreadable == "replaced" then
		App.warn("Saved settings could not be read, so defaults are in use and the unreadable file was replaced.")
	elseif Store.unreadable == "left" then
		App.warn("Saved settings could not be read, so defaults are in use for this session. The file was left as it is.")
	end
	Motion.reduced = Store.get("reducedMotion")
	Theme.init()
	Typo.init()
	if not Theme.apply(Store.get("theme"), true) then
		Theme.apply("obsidian", true)
	end
	Theme.setGlass(Store.get("glass"))
	Theme.active = function()
		return Win.visible
	end
	Sfx.init()

	local parent, parentKind = Env.guiParent()
	App.parentKind = parentKind
	if not parent then
		Util.log("error", "no place to put the interface (PlayerGui / gethui unavailable)")
		warn("[VirexHub] could not find a place to show the interface.")
		App.destroy("no gui parent")
		return
	end

	local useSplash = Store.get("splash")
	if useSplash then
		local ok, err = pcall(Splash.create, parent)
		if not ok then
			useSplash = false
			Util.log("error", "splash: " .. tostring(err))
		end
	end
	local total = 5
	local function step(text, done, partial)
		if useSplash then
			Splash.step(text, done, total, partial)
		end
	end
	local function fatal(message)
		Util.log("error", message)
		warn("[VirexHub] " .. message)
		if useSplash and Splash.isOpen then
			Splash.fail(message, function()
				App.destroy("startup failed")
			end)
		else
			App.destroy("startup failed")
		end
	end

	-- hand-off: the window opens as the loading screen fades; a watchdog makes sure that always happens
	local function handoff()
		if App.handedOff or App.destroyed then
			return
		end
		App.handedOff = true
		Win.show()
		task.delay(0.6, function()
			if App.destroyed then
				return
			end
			Notify.success("Hub ready", "Use the sidebar to explore the interface.")
			for index = 1, math.min(#App.warnings, 2) do
				Notify.warn("Startup notice", Util.cap(App.warnings[index], 140), { duration = 7 })
			end
		end)
	end
	task.delay(CONFIG.Splash.MaxSeconds, function()
		if App.destroyed or App.handedOff then
			return
		end
		App.warn("Startup took longer than expected; some optional parts may still be loading.")
		if Win.window and useSplash and Splash.isOpen then
			Splash.close(handoff)
		elseif Win.window then
			handoff()
		else
			fatal("Startup timed out before the window was ready.")
		end
	end)

	-- 1. window --------------------------------------------------------------------------------------
	step("Building window", 0, 0)
	local gui = Util.new("ScreenGui", {
		Name = CONFIG.GuiName, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)
	gui.Parent = parent
	App.gui = gui
	local okWindow, windowError = pcall(function()
		Win.create(gui)
		Notify.init(gui)
		Pages.init()
	end)
	if not okWindow then
		fatal("The window could not be built: " .. Util.cap(tostring(windowError), 80))
		return
	end
	task.wait()
	if App.destroyed then
		return -- closed while starting: do not build into a window that no longer exists
	end

	-- 2. pages (one real sub-step per page) ----------------------------------------------------------
	local count = #Win.tabList
	for index, def in ipairs(Win.tabList) do
		step("Building " .. def.title, 1, (index - 1) / count)
		if App.destroyed then
			return
		end
		local page = Win.addPage(def.id)
		local okPage, pageError = pcall(Pages.build[def.id], page)
		if not okPage then
			Util.log("error", "page " .. def.id .. ": " .. tostring(pageError))
			App.warn("The " .. def.title .. " page could not be built.")
			UI.card({ parent = page, order = 1, title = "This page could not be built", desc = Util.cap(tostring(pageError), 160) })
		end
		task.wait()
	end
	if App.destroyed then
		return
	end
	Win.selectTab("overview", true)
	Pages.syncCards()
	Win.applyLayout()

	-- 3. sounds (real preload progress; failures just stay silent) ----------------------------------------
	Bg.apply() -- starts loading the saved background in the background of the next step
	step("Loading sounds", 2, 0)
	local loaded, failed, soundCount = Sfx.preload(function(done, n)
		step("Loading sounds", 2, done / math.max(n, 1))
	end, CONFIG.Splash.PreloadSeconds)
	if App.destroyed then
		return
	end
	if useSplash then
		Splash.detail(Sfx.summary(), failed > 0 and "Warn" or "Faint")
	end
	if failed > 0 then
		App.warn(string.format("%d of %d sound assets could not be loaded; those sounds stay silent.", failed, soundCount))
	elseif loaded < soundCount then
		App.warn("Some sound assets did not finish loading in time; they will play only if they load later.")
	end
	Pages.syncAll()

	-- 4. background (waits for the real result, bounded) -----------------------------------------------
	step("Preparing background", 3, 0)
	local waited = 0
	while Bg.status.kind == "loading" and waited < 10 and not App.destroyed do
		task.wait(0.1)
		waited = waited + 0.1
	end
	if App.destroyed then
		return
	end
	if Bg.status.kind == "error" then
		App.warn("Background: " .. Bg.status.text)
	end

	-- 5. finish ------------------------------------------------------------------------------------------
	step("Almost ready", 4, 0)
	App.wire()
	Theme.syncFx()
	if Env.canSave() and not Store.persistent then
		App.warn("Settings could not be saved to a file, so they last for this session only.")
	end
	if #App.warnings > 0 then
		Win.setStatus(string.format("%d notice%s", #App.warnings, #App.warnings > 1 and "s" or ""), "Warn")
	end
	if App.destroyed then
		return
	end
	App.booted = true
	if useSplash and Splash.isOpen then
		Splash.ready(handoff)
	else
		handoff()
	end
end

function App.start()
	App.startedAt = os.clock()
	App.destroyed = false
	App.handedOff = false
	App.maid = Maid.new()
	task.spawn(function()
		local ok, err = pcall(App.boot)
		if not ok then
			Util.log("error", "boot: " .. tostring(err))
			warn("[VirexHub] startup failed: " .. tostring(err))
			if Splash.isOpen then
				Splash.fail(tostring(err), function()
					App.destroy("boot error")
				end)
			else
				App.destroy("boot error")
			end
		end
	end)
end

App.start()
end -- [13_app.lua]

