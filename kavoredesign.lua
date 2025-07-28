--[[
    Custom Kavo UI Rewrite — source.lua
    Features:
      - Fixed size window (like original)
      - 7 pastel themes: Dark, Light, Red, Blue, Purple, Teal, Pink
      - Glass Mode toggle in Settings tab
      - Smooth animations (toggles, buttons, tabs)
      - Rounded edges, soft shadows, minimal look
      - Built-in theme switcher UI
      - Backward compatibility
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local KavoUI = {}
KavoUI.__index = KavoUI

-- Fixed window size like original Kavo UI
local WINDOW_SIZE = Vector2.new(450, 550)

-- Pastel theme colors (main colors + accents)
local Themes = {
    Dark = {
        Background = Color3.fromRGB(35, 37, 43),
        Accent = Color3.fromRGB(104, 106, 124),
        LightContrast = Color3.fromRGB(50, 52, 60),
        TextColor = Color3.fromRGB(230, 230, 230),
        GlassAccent = Color3.fromRGB(70, 72, 84)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(180, 180, 200),
        LightContrast = Color3.fromRGB(220, 220, 230),
        TextColor = Color3.fromRGB(35, 37, 43),
        GlassAccent = Color3.fromRGB(230, 230, 235)
    },
    Red = {
        Background = Color3.fromRGB(255, 228, 228),
        Accent = Color3.fromRGB(240, 130, 130),
        LightContrast = Color3.fromRGB(255, 200, 200),
        TextColor = Color3.fromRGB(80, 30, 30),
        GlassAccent = Color3.fromRGB(255, 190, 190)
    },
    Blue = {
        Background = Color3.fromRGB(225, 235, 255),
        Accent = Color3.fromRGB(140, 170, 240),
        LightContrast = Color3.fromRGB(200, 215, 255),
        TextColor = Color3.fromRGB(30, 40, 80),
        GlassAccent = Color3.fromRGB(180, 210, 255)
    },
    Purple = {
        Background = Color3.fromRGB(235, 225, 255),
        Accent = Color3.fromRGB(170, 140, 240),
        LightContrast = Color3.fromRGB(210, 200, 255),
        TextColor = Color3.fromRGB(50, 30, 80),
        GlassAccent = Color3.fromRGB(200, 190, 255)
    },
    Teal = {
        Background = Color3.fromRGB(220, 245, 245),
        Accent = Color3.fromRGB(100, 190, 190),
        LightContrast = Color3.fromRGB(180, 230, 230),
        TextColor = Color3.fromRGB(25, 70, 70),
        GlassAccent = Color3.fromRGB(170, 230, 230)
    },
    Pink = {
        Background = Color3.fromRGB(255, 230, 240),
        Accent = Color3.fromRGB(240, 140, 180),
        LightContrast = Color3.fromRGB(255, 190, 210),
        TextColor = Color3.fromRGB(80, 30, 50),
        GlassAccent = Color3.fromRGB(255, 180, 210)
    },
}

-- Helper function to create UI instances with properties
local function CreateInstance(className, props)
    local inst = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            inst[k] = v
        end
    end
    return inst
end

-- Tween helper for smooth animations
local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Main UI constructor
function KavoUI.new(title)
    local self = setmetatable({}, KavoUI)
    self.title = title or "Kavo UI"
    self.themeName = "Dark"
    self.theme = Themes[self.themeName]
    self.glassMode = false

    -- Create ScreenGui root
    self.screenGui = CreateInstance("ScreenGui", {
        Name = "KavoUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })

    -- Main Frame (fixed size)
    self.mainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = self.screenGui,
        Size = UDim2.new(0, WINDOW_SIZE.X, 0, WINDOW_SIZE.Y),
        Position = UDim2.new(0.5, -WINDOW_SIZE.X/2, 0.5, -WINDOW_SIZE.Y/2),
        BackgroundColor3 = self.theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    -- Rounded corners
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.mainFrame})
    local shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        Parent = self.mainFrame,
        ZIndex = 0,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5058352909", -- subtle soft shadow image
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.9,
    })

    -- Title Label
    self.titleLabel = CreateInstance("TextLabel", {
        Parent = self.mainFrame,
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 0, 15),
        BackgroundTransparency = 1,
        Text = self.title,
        TextColor3 = self.theme.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
    })

    -- Tab container
    self.tabContainer = CreateInstance("Frame", {
        Parent = self.mainFrame,
        Size = UDim2.new(1, -30, 1, -70),
        Position = UDim2.new(0, 15, 0, 55),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })

    -- Tabs bar
    self.tabsBar = CreateInstance("Frame", {
        Parent = self.mainFrame,
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 15, 0, 50),
        BackgroundTransparency = 1,
    })

    self.tabs = {}
    self.pages = {}

    -- Theme switcher UI inside Settings tab (will create Settings tab below)
    -- Glass Mode toggle UI will also be inside Settings

    -- Build Tabs
    self:AddTab("Main")
    self:AddTab("Settings")

    -- Setup Theme Switcher & Glass Mode toggle in Settings tab page
    self:SetupSettingsPage()

    -- Default select first tab
    self:SelectTab("Main")

    -- Make window draggable
    self:MakeDraggable(self.mainFrame, self.titleLabel)

    return self
end

-- Make a frame draggable by dragging a handle frame (usually title)
function KavoUI:MakeDraggable(window, handle)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            window.Position.X.Scale,
            startPos.X + delta.X,
            window.Position.Y.Scale,
            startPos.Y + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Add a tab (name) and create corresponding page container
function KavoUI:AddTab(name)
    local tabBtn = CreateInstance("TextButton", {
        Name = name .. "Tab",
        Parent = self.tabsBar,
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        TextColor3 = self.theme.Accent,
        AutoButtonColor = false,
        Size = UDim2.new(0, 90, 1, 0),
    })

    -- Rounded corners on hover
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

    tabBtn.MouseEnter:Connect(function()
        Tween(tabBtn, {TextColor3 = self.theme.LightContrast}, 0.2)
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.currentTab ~= name then
            Tween(tabBtn, {TextColor3 = self.theme.Accent}, 0.3)
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    local page = CreateInstance("Frame", {
        Name = name .. "Page",
        Parent = self.tabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ClipsDescendants = true,
    })

    self.tabs[name] = tabBtn
    self.pages[name] = page
end

-- Select a tab by name
function KavoUI:SelectTab(name)
    if self.currentTab == name then return end

    if self.currentTab and self.tabs[self.currentTab] then
        local prevTabBtn = self.tabs[self.currentTab]
        Tween(prevTabBtn, {TextColor3 = self.theme.Accent}, 0.3)
        self.pages[self.currentTab].Visible = false
    end

    local newTabBtn = self.tabs[name]
    if newTabBtn then
        Tween(newTabBtn, {TextColor3 = self.theme.LightContrast}, 0.3)
    end

    if self.pages[name] then
        self.pages[name].Visible = true
    end

    self.currentTab = name
end

-- Create a toggle button
function KavoUI:CreateToggle(parent, labelText, defaultValue, callback)
    local container = CreateInstance("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    })

    local label = CreateInstance("TextLabel", {
        Parent = container,
        Text = labelText,
        TextColor3 = self.theme.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local toggleBtn = CreateInstance("Frame", {
        Parent = container,
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -40, 0, 6),
        BackgroundColor3 = self.theme.LightContrast,
        BorderSizePixel = 0,
    })
    local toggleCorner = CreateInstance("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0, 9)})

    local toggleCircle = CreateInstance("Frame", {
        Parent = toggleBtn,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(defaultValue and 1 or 0, defaultValue and -14 or 0, 0.5, -7),
        BackgroundColor3 = defaultValue and self.theme.Accent or Color3.fromRGB(150, 150, 150),
        BorderSizePixel = 0,
    })
    local circleCorner = CreateInstance("UICorner", {Parent = toggleCircle, CornerRadius = UDim.new(1, 0)})

    local toggled = defaultValue or false

    local function updateToggle(state)
        toggled = state
        if toggled then
            Tween(toggleCircle, {Position = UDim2.new(1, -14, 0.5, -7)}, 0.25)
            Tween(toggleCircle, {BackgroundColor3 = self.theme.Accent}, 0.25)
            Tween(toggleBtn, {BackgroundColor3 = self.theme.LightContrast}, 0.25)
        else
            Tween(toggleCircle, {Position = UDim2.new(0, 0, 0.5, -7)}, 0.25)
            Tween(toggleCircle, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)}, 0.25)
            Tween(toggleBtn, {BackgroundColor3 = self.theme.LightContrast}, 0.25)
        end
        if callback then pcall(callback, toggled) end
    end

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle(not toggled)
        end
    end)

    updateToggle(toggled)
    return container, function() return toggled end, updateToggle
end

-- Setup the Settings page UI: Theme switcher + Glass Mode toggle
function KavoUI:SetupSettingsPage()
    local page = self.pages["Settings"]
    page.BackgroundTransparency = 1

    -- Theme switcher label
    local themeLabel = CreateInstance("TextLabel", {
        Parent = page,
        Text = "Select Theme:",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = self.theme.TextColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Container for theme buttons
    local themeContainer = CreateInstance("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(1, -20, 0, 120),
    })

    -- Layout for theme buttons
    local gridLayout = CreateInstance("UIGridLayout", {
        Parent = themeContainer,
        CellSize = UDim2.new(0, 100, 0, 40),
        CellPadding = UDim2.new(0, 10, 0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Create theme buttons for each theme
    for themeName, colors in pairs(Themes) do
        local btn = CreateInstance("TextButton", {
            Parent = themeContainer,
            Text = themeName,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            BackgroundColor3 = colors.Accent,
            TextColor3 = colors.TextColor,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ClipsDescendants = true,
        })
        local btnCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = colors.LightContrast}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = colors.Accent}, 0.25)
        end)
        btn.MouseButton1Click:Connect(function()
            self:SetTheme(themeName)
        end)
    end

    -- Glass Mode toggle
    local glassToggleContainer, getGlassState, setGlassState = self:CreateToggle(page, "Glass Mode", self.glassMode, function(state)
        self.glassMode = state
        self:ApplyGlassMode(state)
    end)
    glassToggleContainer.Position = UDim2.new(0, 10, 0, 180)
    glassToggleContainer.Parent = page
end

-- Change theme by name and update UI colors
function KavoUI:SetTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    self.themeName = themeName
    self.theme = theme

    -- Update main background
    if self.glassMode then
        self.mainFrame.BackgroundColor3 = theme.GlassAccent
        self.mainFrame.BackgroundTransparency = 0.7
    else
        self.mainFrame.BackgroundColor3 = theme.Background
        self.mainFrame.BackgroundTransparency = 0
    end

    -- Update title color
    self.titleLabel.TextColor3 = theme.TextColor

    -- Update tabs colors
    for name, tabBtn in pairs(self.tabs) do
        if self.currentTab == name then
            tabBtn.TextColor3 = theme.LightContrast
        else
            tabBtn.TextColor3 = theme.Accent
        end
    end

    -- Update Settings page text color
    local settingsPage = self.pages["Settings"]
    for _, child in pairs(settingsPage:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Text ~= "Glass Mode" then
                child.TextColor3 = theme.TextColor
                if child:IsA("TextButton") then
                    -- Update button bg color (theme buttons)
                    child.BackgroundColor3 = Themes[child.Text] and Themes[child.Text].Accent or child.BackgroundColor3
                    child.TextColor3 = Themes[child.Text] and Themes[child.Text].TextColor or child.TextColor3
                end
            end
        elseif child:IsA("Frame") then
            for _, subChild in pairs(child:GetChildren()) do
                if subChild:IsA("TextButton") and Themes[subChild.Text] then
                    subChild.BackgroundColor3 = Themes[subChild.Text].Accent
                    subChild.TextColor3 = Themes[subChild.Text].TextColor
                end
            end
        end
    end

    -- Update toggles text color
    for _, page in pairs(self.pages) do
        for _, child in pairs(page:GetChildren()) do
            if child:IsA("Frame") then
                for _, subChild in pairs(child:GetChildren()) do
                    if subChild:IsA("TextLabel") then
                        subChild.TextColor3 = theme.TextColor
                    end
                end
            end
        end
    end
end

-- Apply or remove glass mode effect
function KavoUI:ApplyGlassMode(enabled)
    if enabled then
        self.mainFrame.BackgroundTransparency = 0.7
        self.mainFrame.BackgroundColor3 = self.theme.GlassAccent
        self.mainFrame.BorderSizePixel = 0
    else
        self.mainFrame.BackgroundTransparency = 0
        self.mainFrame.BackgroundColor3 = self.theme.Background
        self.mainFrame.BorderSizePixel = 0
    end
end

-- Add a generic button to a page
function KavoUI:AddButton(pageName, text, callback)
    local page = self.pages[pageName]
    if not page then return end

    local btn = CreateInstance("TextButton", {
        Parent = page,
        Text = text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = self.theme.TextColor,
        BackgroundColor3 = self.theme.LightContrast,
        Size = UDim2.new(0, 150, 0, 35),
        Position = UDim2.new(0, 10, 0, 10 + (#page:GetChildren() * 40)),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = self.theme.Accent}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = self.theme.LightContrast}, 0.3)
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)

    return btn
end

-- Add label text to a page
function KavoUI:AddLabel(pageName, text)
    local page = self.pages[pageName]
    if not page then return end

    local label = CreateInstance("TextLabel", {
        Parent = page,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = self.theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10 + (#page:GetChildren() * 30)),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return label
end

-- Public method to destroy UI
function KavoUI:Destroy()
    if self.screenGui then
        self.screenGui:Destroy()
        self.screenGui = nil
    end
end

-- Return the module
return KavoUI
