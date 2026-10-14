--[[
	PremiumUI (LocalScript)
	Put this in StarterPlayer > StarterPlayerScripts as a LocalScript.
	The whole UI is built from code. Edit Config below to customize it.
]]

local Config = {
	Title = "Premium UI",
	LogoId = "", -- e.g. "rbxassetid://1234567890" (empty = built-in diamond mark)
	Accent = Color3.fromRGB(61, 255, 162),
	ToggleKey = Enum.KeyCode.RightShift,
	StartOpen = true,
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("PremiumUI")
if previous then
	previous:Destroy()
end

----------------------------------------------------------------------
-- Theme and state
----------------------------------------------------------------------
local W, H = 520, 380
local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local TEXT, MUTED = Color3.fromRGB(232, 235, 242), Color3.fromRGB(142, 150, 168)
local TRACK, KNOB = Color3.fromRGB(42, 47, 58), Color3.fromRGB(207, 213, 226)
local AMBER = Color3.fromRGB(255, 190, 77)
local Quint, Back, Quad = Enum.EasingStyle.Quint, Enum.EasingStyle.Back, Enum.EasingStyle.Quad
local Out, In = Enum.EasingDirection.Out, Enum.EasingDirection.In
local Right = Enum.TextXAlignment.Right
local SWATCHES = {
	Color3.fromRGB(61, 255, 162),
	Color3.fromRGB(53, 224, 255),
	Color3.fromRGB(167, 139, 255),
	Color3.fromRGB(255, 194, 77),
	Color3.fromRGB(255, 107, 139),
}

local State = { accent = Config.Accent, anim = true, glow = true, radius = 18, open = true, running = true }
local conns, binders = {}, {}
local drag = nil

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function connect(signal, fn)
	local c = signal:Connect(fn)
	conns[#conns + 1] = c
	return c
end

local function bind(fn)
	binders[#binders + 1] = fn
	fn(State.accent)
end

local function setAccent(color)
	State.accent = color
	for _, fn in ipairs(binders) do
		fn(color)
	end
end

local function put(o, props)
	for k, v in pairs(props) do
		o[k] = v
	end
end

local function tw(o, props, t, style, dir)
	if not State.anim then
		put(o, props)
		return
	end
	TweenService:Create(o, TweenInfo.new(t or 0.3, style or Quint, dir or Out), props):Play()
end

local function new(class, props, kids)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			o[k] = v
		end
	end
	if kids then
		for _, k in ipairs(kids) do
			k.Parent = o
		end
	end
	if props.Parent then
		o.Parent = props.Parent
	end
	return o
end

local function corner(r)
	return new("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function gradient(c0, c1, rotation)
	return new("UIGradient", { Color = ColorSequence.new(c0, c1), Rotation = rotation or 90 })
end

local function label(parent, text, x, y, w, h, size, color, font, align)
	return new("TextLabel", {
		Text = text,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundTransparency = 1,
		TextSize = size,
		TextColor3 = color,
		Font = font,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

local function card(parent, x, y, w, h)
	return new("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
		Parent = parent,
	}, { corner(14), stroke(WHITE, 1, 0.94) })
end

local function divider(parent, y)
	new("Frame", {
		Position = UDim2.fromOffset(14, y),
		Size = UDim2.fromOffset(460, 1),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Parent = parent,
	})
end

----------------------------------------------------------------------
-- Root: ScreenGui > scaleHost (UIScale) > holder (dragged) > body (open anim)
----------------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "PremiumUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
	Parent = playerGui,
})
local scaleHost = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = gui })
local uiScale = new("UIScale", { Parent = scaleHost })
local holder = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(W, H),
	BackgroundTransparency = 1,
	Parent = scaleHost,
})
local body = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = holder,
})
local bodyScale = new("UIScale", { Parent = body })

----------------------------------------------------------------------
-- Toasts
----------------------------------------------------------------------
local toasts = new("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 14),
	Size = UDim2.fromOffset(250, 220),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Parent = scaleHost,
}, {
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	}),
})
local toastCount, activeToasts = 0, {}

local function outline(parent, radius, transparency)
	local f = new("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = parent,
	}, { corner(radius - 1) })
	local s = stroke(WHITE, 1, transparency)
	s.Parent = f
	return f, s
end

local function toast(text)
	toastCount = toastCount + 1
	local slot = new("Frame", {
		Size = UDim2.fromOffset(250, 40),
		BackgroundTransparency = 1,
		LayoutOrder = toastCount,
		Parent = toasts,
	})
	local card_ = new("CanvasGroup", {
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(29, 33, 43),
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Parent = slot,
	}, { corner(12) })
	new("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = State.accent,
		BorderSizePixel = 0,
		Parent = card_,
	})
	label(card_, text, 16, 0, 226, 40, 12, TEXT, Enum.Font.GothamMedium)
	outline(card_, 12, 0.92)

	activeToasts[#activeToasts + 1] = slot
	while #activeToasts > 3 do
		local oldest = table.remove(activeToasts, 1)
		if oldest.Parent then
			oldest:Destroy()
		end
	end

	tw(card_, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, 0.45, Back)
	task.delay(2.6, function()
		if not slot.Parent then
			return
		end
		tw(card_, { Position = UDim2.fromOffset(30, 0), GroupTransparency = 1 }, 0.3, Quad, In)
		task.delay(0.32, function()
			for i, v in ipairs(activeToasts) do
				if v == slot then
					table.remove(activeToasts, i)
					break
				end
			end
			if slot.Parent then
				slot:Destroy()
			end
		end)
	end)
end

----------------------------------------------------------------------
-- Layered shadows + accent glow (behind the window)
----------------------------------------------------------------------
local layers = {}
local function addLayer(grow, transparency, dy, color)
	local c = corner(State.radius + grow / 2)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, dy),
		Size = UDim2.new(1, grow, 1, grow),
		BackgroundColor3 = color or BLACK,
		BackgroundTransparency = transparency,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = body,
	}, { c })
	local entry = { f = f, c = c, grow = grow, base = transparency }
	layers[#layers + 1] = entry
	return entry
end

local glow = addLayer(20, 0.9, 0, State.accent)
addLayer(10, 0.8, 10)
addLayer(22, 0.88, 12)
addLayer(36, 0.94, 14)
bind(function(a)
	glow.f.BackgroundColor3 = a
end)

local function layersTo(open)
	for _, l in ipairs(layers) do
		local base = l.base
		if l == glow then
			base = State.glow and 0.9 or 1
		end
		tw(l.f, { BackgroundTransparency = open and base or 1 }, 0.3)
	end
end

----------------------------------------------------------------------
-- Window (CanvasGroup so the whole window fades and clips to the corners)
----------------------------------------------------------------------
local win = new("CanvasGroup", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 2,
	Parent = body,
})
local winCorner = corner(State.radius)
winCorner.Parent = win

local bg = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	ZIndex = 0,
	Parent = win,
})
gradient(Color3.fromRGB(38, 43, 54), Color3.fromRGB(20, 23, 30), 70).Parent = bg

local outFrame, outStroke = outline(win, State.radius, 0.1)
local outGrad = new("UIGradient", { Rotation = 90, Parent = outStroke })
bind(function(a)
	outGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, a:Lerp(Color3.fromRGB(38, 43, 54), 0.5)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(70, 76, 90)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 55, 66)),
	})
end)

local function setRadius(r)
	State.radius = r
	winCorner.CornerRadius = UDim.new(0, r)
	outFrame.UICorner.CornerRadius = UDim.new(0, r - 1)
	for _, l in ipairs(layers) do
		l.c.CornerRadius = UDim.new(0, r + l.grow / 2)
	end
end

----------------------------------------------------------------------
-- Controls: bevel button, switch, slider
----------------------------------------------------------------------
local function bevel(parent, text, x, y, w, h, primary, onClick)
	local box = new("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h + 4),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local edge = new("Frame", {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = Color3.fromRGB(18, 21, 27),
		BorderSizePixel = 0,
		Parent = box,
	}, { corner(11) })
	local face = new("Frame", {
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = box,
	}, { corner(11), stroke(WHITE, 1, primary and 0.75 or 0.88) })
	local g = new("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(59, 65, 79), Color3.fromRGB(43, 48, 59)),
		Parent = face,
	})
	local btn = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = primary and Color3.fromRGB(4, 20, 12) or TEXT,
		Parent = face,
	})
	if primary then
		bind(function(a)
			g.Color = ColorSequence.new(a:Lerp(WHITE, 0.08), a:Lerp(BLACK, 0.18))
			edge.BackgroundColor3 = a:Lerp(BLACK, 0.55)
		end)
	end
	local hover = false
	local function rest()
		tw(face, { Position = UDim2.fromOffset(0, hover and -1 or 0) }, 0.12)
	end
	connect(btn.MouseEnter, function()
		hover = true
		rest()
	end)
	connect(btn.MouseLeave, function()
		hover = false
		rest()
	end)
	connect(btn.MouseButton1Down, function()
		tw(face, { Position = UDim2.fromOffset(0, 3) }, 0.08)
	end)
	connect(btn.MouseButton1Up, rest)
	connect(btn.Activated, function()
		onClick(btn)
	end)
	return btn
end

local function switch(parent, x, y, default, onChange)
	local on = default
	local track = new("TextButton", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(40, 22),
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = TRACK,
		BorderSizePixel = 0,
		Parent = parent,
	}, { corner(11) })
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = KNOB,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(8) })
	local function render(animate)
		local trackColor = on and State.accent:Lerp(BLACK, 0.2) or TRACK
		local knobPos = UDim2.new(0, on and 21 or 3, 0.5, 0)
		local knobColor = on and WHITE or KNOB
		if animate then
			tw(track, { BackgroundColor3 = trackColor }, 0.25)
			tw(knob, { Position = knobPos }, 0.35, Back)
			tw(knob, { BackgroundColor3 = knobColor }, 0.25)
		else
			track.BackgroundColor3 = trackColor
			knob.Position = knobPos
			knob.BackgroundColor3 = knobColor
		end
	end
	bind(function()
		render(false)
	end)
	connect(track.Activated, function()
		on = not on
		render(true)
		onChange(on)
	end)
end

local function slider(parent, x, y, w, min, max, value, onChange)
	local bar = new("Frame", {
		Position = UDim2.fromOffset(x, y + 9),
		Size = UDim2.fromOffset(w, 6),
		BackgroundColor3 = TRACK,
		BorderSizePixel = 0,
		Parent = parent,
	}, { corner(3) })
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = State.accent,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(3) })
	local thumb = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = bar,
	}, { corner(8) })
	local hit = new("TextButton", {
		Position = UDim2.fromOffset(x - 8, y),
		Size = UDim2.fromOffset(w + 16, 24),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 3,
		Parent = parent,
	})
	bind(function(a)
		fill.BackgroundColor3 = a
	end)
	local function set(alpha)
		alpha = math.clamp(alpha, 0, 1)
		fill.Size = UDim2.fromScale(alpha, 1)
		thumb.Position = UDim2.fromScale(alpha, 0.5)
		onChange(math.floor(min + alpha * (max - min) + 0.5))
	end
	local function fromX(px)
		set((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
	end
	set((value - min) / (max - min))
	connect(hit.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = {
				update = function(pos)
					fromX(pos.X)
				end,
			}
			fromX(input.Position.X)
		end
	end)
end

----------------------------------------------------------------------
-- Header
----------------------------------------------------------------------
local header = new("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = win })

new("Frame", {
	Position = UDim2.fromOffset(16, 17),
	Size = UDim2.fromOffset(42, 42),
	BackgroundColor3 = Color3.fromRGB(15, 18, 24),
	BorderSizePixel = 0,
	Parent = header,
}, { corner(12) })
local logo = new("Frame", {
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.fromOffset(42, 42),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	ZIndex = 2,
	Parent = header,
}, { corner(12), stroke(WHITE, 1, 0.9), gradient(Color3.fromRGB(45, 51, 64), Color3.fromRGB(27, 31, 40), 55) })

if Config.LogoId ~= "" then
	new("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(26, 26),
		BackgroundTransparency = 1,
		Image = Config.LogoId,
		ZIndex = 3,
		Parent = logo,
	})
else
	local outer = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(18, 18),
		Rotation = 45,
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = logo,
	}, { corner(4) })
	local outerStroke = stroke(WHITE, 2, 0)
	outerStroke.Parent = outer
	local inner = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(8, 8),
		Rotation = 45,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = logo,
	}, { corner(2) })
	bind(function(a)
		outerStroke.Color = a
		inner.BackgroundColor3 = a
	end)
end

label(header, Config.Title, 70, 14, 280, 22, 15, WHITE, Enum.Font.GothamBold)
local statusText = label(header, "Running", 86, 38, 200, 18, 11, MUTED, Enum.Font.GothamMedium)

local pulse = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(74, 47),
	Size = UDim2.fromOffset(8, 8),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 2,
	Parent = header,
}, { corner(12) })
local dot = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(74, 47),
	Size = UDim2.fromOffset(8, 8),
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = header,
}, { corner(4) })
local pulseTween = TweenService:Create(
	pulse,
	TweenInfo.new(1.8, Quad, Out, -1),
	{ Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1 }
)

local function renderStatus()
	dot.BackgroundColor3 = State.running and State.accent or AMBER
	pulse.BackgroundColor3 = dot.BackgroundColor3
	statusText.Text = State.running and "Running" or "Paused"
	if State.running and State.anim then
		pulse.Visible = true
		pulseTween:Play()
	else
		pulseTween:Cancel()
		pulse.Visible = false
		pulse.Size = UDim2.fromOffset(8, 8)
		pulse.BackgroundTransparency = 0.55
	end
end
bind(renderStatus)

local closeBtn = new("TextButton", {
	Position = UDim2.fromOffset(474, 20),
	Size = UDim2.fromOffset(30, 30),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.95,
	AutoButtonColor = false,
	Text = "×",
	Font = Enum.Font.GothamMedium,
	TextSize = 20,
	TextColor3 = TEXT,
	Parent = header,
}, { corner(9) })
connect(closeBtn.MouseEnter, function()
	tw(closeBtn, { BackgroundTransparency = 0.88 }, 0.15)
end)
connect(closeBtn.MouseLeave, function()
	tw(closeBtn, { BackgroundTransparency = 0.95 }, 0.15)
end)

----------------------------------------------------------------------
-- Tabs with sliding indicator
----------------------------------------------------------------------
local tabsBar = new("Frame", {
	Position = UDim2.fromOffset(16, 74),
	Size = UDim2.fromOffset(488, 40),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.72,
	BorderSizePixel = 0,
	Parent = win,
}, { corner(12) })
local tabsInner = new("Frame", {
	Position = UDim2.fromOffset(4, 4),
	Size = UDim2.new(1, -8, 1, -8),
	BackgroundTransparency = 1,
	Parent = tabsBar,
})
local indicator = new("Frame", { Size = UDim2.fromScale(1 / 3, 1), BackgroundTransparency = 1, Parent = tabsInner })
new("Frame", {
	Size = UDim2.new(1, 0, 1, -2),
	Position = UDim2.fromOffset(0, 2),
	BackgroundColor3 = Color3.fromRGB(17, 20, 26),
	BorderSizePixel = 0,
	ZIndex = 1,
	Parent = indicator,
}, { corner(9) })
local indFace = new("Frame", {
	Size = UDim2.new(1, 0, 1, -2),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	ZIndex = 2,
	Parent = indicator,
}, { corner(9), gradient(Color3.fromRGB(52, 58, 72), Color3.fromRGB(40, 45, 57), 90) })
local underline = new("Frame", {
	Position = UDim2.new(0.3, 0, 1, -6),
	Size = UDim2.new(0.4, 0, 0, 2),
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = indFace,
}, { corner(1) })
bind(function(a)
	underline.BackgroundColor3 = a
end)

local pages, tabButtons, current = {}, {}, 1
local tabNames = { "Main", "Visuals", "Settings" }
local pagesRoot = new("Frame", {
	Position = UDim2.fromOffset(16, 126),
	Size = UDim2.fromOffset(488, 242),
	BackgroundTransparency = 1,
	Parent = win,
})
for i, name in ipairs(tabNames) do
	pages[i] = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = i == 1,
		Parent = pagesRoot,
	})
	tabButtons[i] = new("TextButton", {
		Position = UDim2.fromScale((i - 1) / 3, 0),
		Size = UDim2.fromScale(1 / 3, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = i == 1 and WHITE or MUTED,
		ZIndex = 4,
		Parent = tabsInner,
	})
	connect(tabButtons[i].Activated, function()
		if current == i then
			return
		end
		current = i
		tw(indicator, { Position = UDim2.fromScale((i - 1) / 3, 0) }, 0.45)
		for j, b in ipairs(tabButtons) do
			tw(b, { TextColor3 = j == i and WHITE or MUTED }, 0.2)
		end
		for j, p in ipairs(pages) do
			if j == i then
				p.Position = UDim2.fromOffset(0, 8)
				p.Visible = true
				tw(p, { Position = UDim2.fromOffset(0, 0) }, 0.35)
			else
				p.Visible = false
			end
		end
	end)
end

----------------------------------------------------------------------
-- Page 1: Main
----------------------------------------------------------------------
local progress, accTime, statTime, frames = 0, 0, 0, 0

local p1 = pages[1]
local progCard = card(p1, 0, 0, 488, 64)
label(progCard, "Syncing session", 14, 10, 300, 18, 12, MUTED, Enum.Font.GothamMedium)
local pct = label(progCard, "0%", 414, 10, 60, 18, 12, WHITE, Enum.Font.GothamBold, Right)
local progTrack = new("Frame", {
	Position = UDim2.fromOffset(14, 38),
	Size = UDim2.fromOffset(460, 9),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.6,
	BorderSizePixel = 0,
	Parent = progCard,
}, { corner(5) })
local progFill = new("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	Parent = progTrack,
}, { corner(5) })
local progGrad = new("UIGradient", { Parent = progFill })
bind(function(a)
	progGrad.Color = ColorSequence.new(a:Lerp(BLACK, 0.35), a)
end)

local function stat(x, title, initial)
	local c = card(p1, x, 76, 238, 60)
	label(c, title, 14, 9, 200, 14, 11, MUTED, Enum.Font.GothamMedium)
	return label(c, initial, 14, 25, 200, 26, 20, WHITE, Enum.Font.GothamBold)
end
local pingLabel = stat(0, "Ping", "-- ms")
local fpsLabel = stat(250, "Frame rate", "-- fps")

local goBtn
goBtn = bevel(p1, "Pause", 0, 150, 156, 40, true, function()
	State.running = not State.running
	goBtn.Text = State.running and "Pause" or "Start"
	renderStatus()
	toast(State.running and "Session resumed" or "Session paused")
end)
bevel(p1, "Reset", 166, 150, 156, 40, false, function()
	progress = 0
	progFill.Size = UDim2.fromScale(0, 1)
	pct.Text = "0%"
	toast("Progress reset")
end)
bevel(p1, "Notify", 332, 150, 156, 40, false, function()
	toast("Notification delivered")
end)

----------------------------------------------------------------------
-- Page 2: Visuals
----------------------------------------------------------------------
local p2 = pages[2]
local rows = card(p2, 0, 0, 488, 138)
local function rowLabel(parent, i, text)
	return label(parent, text, 14, (i - 1) * 46, 260, 46, 13, TEXT, Enum.Font.GothamMedium)
end

rowLabel(rows, 1, "Accent glow")
switch(rows, 434, 12, true, function(on)
	State.glow = on
	layersTo(State.open)
end)
divider(rows, 46)
rowLabel(rows, 2, "Animations")
switch(rows, 434, 58, true, function(on)
	State.anim = on
	renderStatus()
end)
divider(rows, 92)
local radiusLabel = rowLabel(rows, 3, "Corner radius  18")
slider(rows, 334, 104, 140, 6, 28, 18, function(v)
	setRadius(v)
	radiusLabel.Text = "Corner radius  " .. v
end)

local accentCard = card(p2, 0, 150, 488, 80)
label(accentCard, "Accent color", 14, 10, 200, 16, 12, MUTED, Enum.Font.GothamMedium)
local swatches = {}
for i, col in ipairs(SWATCHES) do
	local selected = col == Config.Accent
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(28 + (i - 1) * 40, 54),
		Size = UDim2.fromOffset(selected and 32 or 28, selected and 32 or 28),
		BackgroundColor3 = col,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = accentCard,
	}, { corner(16) })
	local ring = stroke(WHITE, 2, selected and 0 or 1)
	ring.Parent = b
	swatches[i] = { b = b, ring = ring, col = col }
	connect(b.Activated, function()
		setAccent(col)
		for _, s in ipairs(swatches) do
			local sel = s.col == col
			local size = sel and 32 or 28
			tw(s.b, { Size = UDim2.fromOffset(size, size) }, 0.3, Back)
			tw(s.ring, { Transparency = sel and 0 or 1 }, 0.2)
		end
		toast("Accent updated")
	end)
end

----------------------------------------------------------------------
-- Page 3: Settings
----------------------------------------------------------------------
local p3 = pages[3]
local info = card(p3, 0, 0, 488, 92)
rowLabel(info, 1, "Toggle key")
label(info, Config.ToggleKey.Name, 274, 0, 200, 46, 13, WHITE, Enum.Font.GothamBold, Right)
divider(info, 46)
rowLabel(info, 2, "Move window")
label(info, "Drag the header", 274, 46, 200, 46, 13, WHITE, Enum.Font.GothamBold, Right)

local codeBox = new("Frame", {
	Position = UDim2.fromOffset(0, 104),
	Size = UDim2.fromOffset(488, 112),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.65,
	BorderSizePixel = 0,
	Parent = p3,
}, { corner(10) })
local codeText = label(codeBox, "", 14, 10, 460, 92, 12, Color3.fromRGB(170, 179, 197), Enum.Font.Code)
codeText.TextYAlignment = Enum.TextYAlignment.Top
bind(function(a)
	codeText.Text = string.format(
		'local Config = {\n  Title     = "%s",\n  LogoId    = "%s",\n  Accent    = Color3.fromRGB(%d, %d, %d),\n  ToggleKey = Enum.KeyCode.%s,\n}',
		Config.Title,
		Config.LogoId,
		math.floor(a.R * 255 + 0.5),
		math.floor(a.G * 255 + 0.5),
		math.floor(a.B * 255 + 0.5),
		Config.ToggleKey.Name
	)
end)

----------------------------------------------------------------------
-- Open / close, toggle button, layout
----------------------------------------------------------------------
local function setOpen(open)
	State.open = open
	if open then
		holder.Visible = true
		if State.anim then
			for _, l in ipairs(layers) do
				l.f.BackgroundTransparency = 1
			end
		end
		bodyScale.Scale = State.anim and 0.92 or 1
		win.GroupTransparency = State.anim and 1 or 0
		tw(bodyScale, { Scale = 1 }, 0.5, Back)
		tw(win, { GroupTransparency = 0 }, 0.3)
		layersTo(true)
	else
		tw(bodyScale, { Scale = 0.92 }, 0.25, Quint, In)
		tw(win, { GroupTransparency = 1 }, 0.22)
		layersTo(false)
		task.delay(State.anim and 0.28 or 0, function()
			if not State.open then
				holder.Visible = false
			end
		end)
	end
end

local dock = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -14),
	Size = UDim2.fromOffset(130, 44),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = scaleHost,
})
bevel(dock, "Toggle UI", 0, 0, 130, 38, false, function()
	setOpen(not State.open)
end)

connect(closeBtn.Activated, function()
	setOpen(false)
	toast("Press " .. Config.ToggleKey.Name .. " to reopen")
end)

connect(UIS.InputBegan, function(input, processed)
	if not processed and input.KeyCode == Config.ToggleKey then
		setOpen(not State.open)
	end
end)

local centered = false
local function layout()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local s = math.clamp(math.min(vp.X / 560, vp.Y / 430), 0.5, 1.15)
	uiScale.Scale = s
	local sx, sy = vp.X / s, vp.Y / s
	scaleHost.Size = UDim2.fromOffset(sx, sy)
	if not centered then
		centered = true
		holder.Position = UDim2.fromOffset(sx / 2, sy / 2 - 10)
	else
		local p = holder.Position
		holder.Position = UDim2.fromOffset(math.clamp(p.X.Offset, 60, sx - 60), math.clamp(p.Y.Offset, 40, sy - 40))
	end
end

----------------------------------------------------------------------
-- Dragging (window header + slider share one input handler)
----------------------------------------------------------------------
connect(header.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local start = Vector2.new(input.Position.X, input.Position.Y)
		local origin = holder.Position
		drag = {
			update = function(pos)
				local d = (Vector2.new(pos.X, pos.Y) - start) / uiScale.Scale
				holder.Position = UDim2.fromOffset(
					math.clamp(origin.X.Offset + d.X, 60, scaleHost.Size.X.Offset - 60),
					math.clamp(origin.Y.Offset + d.Y, 40, scaleHost.Size.Y.Offset - 40)
				)
			end,
		}
	end
end)

connect(UIS.InputChanged, function(input)
	if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		drag.update(input.Position)
	end
end)

connect(UIS.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		drag = nil
	end
end)

----------------------------------------------------------------------
-- Live updates (one Heartbeat connection, skipped while the window is hidden)
----------------------------------------------------------------------
connect(RunService.Heartbeat, function(dt)
	if not State.open then
		return
	end
	frames = frames + 1
	statTime = statTime + dt
	if State.running then
		accTime = accTime + dt
		if accTime >= 0.1 then
			accTime = accTime - 0.1
			progress = progress + 0.01
			if progress > 1.005 then
				progress = 0
			end
			local shown = math.min(progress, 1)
			progFill.Size = UDim2.fromScale(shown, 1)
			pct.Text = math.floor(shown * 100 + 0.5) .. "%"
		end
	end
	if statTime >= 0.5 then
		fpsLabel.Text = math.floor(frames / statTime + 0.5) .. " fps"
		local ok, ping = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		pingLabel.Text = ok and (math.floor(ping + 0.5) .. " ms") or "-- ms"
		frames, statTime = 0, 0
	end
end)

----------------------------------------------------------------------
-- Start
----------------------------------------------------------------------
layout()
local camera = workspace.CurrentCamera
if camera then
	connect(camera:GetPropertyChangedSignal("ViewportSize"), layout)
end

connect(gui.Destroying, function()
	pulseTween:Cancel()
	for _, c in ipairs(conns) do
		c:Disconnect()
	end
end)

if Config.StartOpen then
	setOpen(true)
else
	State.open = false
	holder.Visible = false
end
