--====================== CHEEM HUB | ALL IN ONE ======================--
-- Loader + Map Detect + Hub + SaveConfig + Anti AFK
-- Dev friendly – Không chết menu

if getgenv().CheemHubLoaded then return end
getgenv().CheemHubLoaded = true

repeat task.wait() until game:IsLoaded()

--====================== SERVICES ======================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
game:GetService("UserInputService")

local Player = Players.LocalPlayer
repeat task.wait() until Player
repeat task.wait() until Player.Character

local UIVisible = true
local GlobalUI = nil

-- ================= THEME =================
local Theme = {
    Dark = {
        Background = Color3.fromRGB(25,25,25),
        Section    = Color3.fromRGB(40,40,40),
        Accent     = Color3.fromRGB(255,221,0),
        Text       = Color3.fromRGB(255,255,255)
    },
    Light = {
        Background = Color3.fromRGB(235,235,235),
        Section    = Color3.fromRGB(210,210,210),
        Accent     = Color3.fromRGB(60,180,75),
        Text       = Color3.fromRGB(30,30,30)
    }
}

local CurrentTheme = "Dark"

local function ApplyTheme(themeName)
    local t = Theme[themeName]
    if not t then return end

    for _,v in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("Frame") then
            v.BackgroundColor3 = t.Background
        elseif v:IsA("TextButton") then
            v.BackgroundColor3 = t.Section
            v.TextColor3 = t.Text
        elseif v:IsA("TextLabel") then
            v.TextColor3 = t.Text
        end
    end
end

--===== KEY SYSTEM (SAVE KEY) =====--

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local KeyFile = "CheemHub_Key.json"

local function ResetKey()
    if isfile(KeyFile) then
        delfile(KeyFile)
    end
end

local VALID_KEYS = {
    "8SSA18C72852AKXT1AS00GR",
    "5DSAH82736266AHFO655ASD",
    "2HFSD75AF74FSEGO755HDGH",
    "1SGDF44DGCF64FCSSHG75DF"
}

-- ===== Check key =====
local function IsValidKey(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then
            return true
        end
    end
    return false
end

-- ===== Load saved key =====
local function LoadSavedKey()
    if isfile(KeyFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(KeyFile))
        end)
        if success and data and data.key then
            return data.key
        end
    end
end

-- ===== Save key =====
local function SaveKey(key)
    writefile(KeyFile, HttpService:JSONEncode({
        key = key,
        time = os.time()
    }))
end

-- ================= AUTO LOGIN =================
local savedKey = LoadSavedKey()
if savedKey and IsValidKey(savedKey) then
    print("CheemHub: Auto login success")
    return  -- cho script chạy tiếp vào hub
end

-- ================= KEY UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheemHub_KeyUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromScale(0.35, 0.25)
Frame.Position = UDim2.fromScale(0.325, 0.35)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.fromScale(1,0.25)
Title.BackgroundTransparency = 1
Title.Text = "Cheem Hub | Key System"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local Box = Instance.new("TextBox", Frame)
Box.Size = UDim2.fromScale(0.9,0.25)
Box.Position = UDim2.fromScale(0.05,0.35)
Box.PlaceholderText = "Key Here"
Box.Text = ""
Box.TextScaled = true
Box.ClearTextOnFocus = false
Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
Box.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", Box).CornerRadius = UDim.new(0,6)

local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.fromScale(0.5,0.22)
Btn.Position = UDim2.fromScale(0.25,0.68)
Btn.Text = "Check Key"
Btn.TextScaled = true
Btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
Btn.TextColor3 = Color3.fromRGB(0,0,0)

Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

-- ===== Button logic =====
Btn.MouseButton1Click:Connect(function()
    local key = Box.Text

    if IsValidKey(key) then
        SaveKey(key)
        ScreenGui:Destroy()
        print("CheemHub: Key verified")
    else
        Box.Text = ""
        Btn.Text = "Wrong Key"
        Btn.BackgroundColor3 = Color3.fromRGB(255,80,80)
        task.wait(1)
        Btn.Text = "Check Key"
        Btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    end
end)

repeat task.wait() until not ScreenGui.Parent

end

--====================== NOTIFY ======================--
local function Notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title = "Cheem Hub",
            Text = txt,
            Duration = t or 4
        })
    end)
end

Notify("Loading Cheem Hub...")

--====================== CONFIG ======================--
local ConfigFile = "CheemHub_Config.json"

local Cheem = {}

-- ================= NOCLIP =================
game:GetService("RunService").Stepped:Connect(function()
    if Cheem.Noclip then
        local char = Player.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- ================= FLY =================
local FlyBV, FlyBG

game:GetService("RunService").RenderStepped:Connect(function()
    if not Cheem.Fly then
        if FlyBV then FlyBV:Destroy() FlyBV=nil end
        if FlyBG then FlyBG:Destroy() FlyBG=nil end
        return
    end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not FlyBV then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = hrp

        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        FlyBG.CFrame = hrp.CFrame
        FlyBG.Parent = hrp
    end

    local cam = workspace.CurrentCamera
    FlyBG.CFrame = cam.CFrame
    FlyBV.Velocity = cam.CFrame.LookVector * 80
end)

--===== LOOP =======--
UserInputService.JumpRequest:Connect(function()
    if Cheem.InfJump then
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Cheem.AutoClick = false

Cheem.FastAttack = false

Cheem.WalkSpeed = 16
Cheem.JumpPower = 50
Cheem.InfJump = false

Cheem.BuyChip = false
Cheem.ChipFruit = "Flame"

-- ===== AWAKEN RAID =====
Cheem.AutoAwaken = false
Cheem.AwakenSkill = "Z"
Cheem.AutoRaid = false
Cheem.RaidTeleport = true

--================= RAID TELEPORT =================
local function TeleportToRaid()
    if not Cheem.RaidTeleport then return end

    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc","Select","Flame")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc","Start")
    end)
end

--==================== BUY CHIP =======================
local function BuyChip()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer(
            "RaidsNpc",
            "Select",
            Cheem.ChipFruit
        )
    end)
end

--================= AUTO AWAKEN LOOP =================
task.spawn(function()
    while task.wait(0.3) do
        if not Cheem.AutoAwaken then continue end

        pcall(function()
            TeleportToRaid()
            AttackRaidMob()
        end)
    end
end)

--================ LOOP BUY CHIP ================
task.spawn(function()
    while task.wait(5) do
        if Cheem.BuyChip then
            BuyChip()
        end
    end
end)

--================ RAID COMBAT =================--
function AttackRaidMob()
    local char = Player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _,mob in pairs(enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0 then

            pcall(function()
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,10,0)
            end)

            -- chọn vũ khí theo setting
            EquipFarmWeapon()

            -- đánh
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.1)
            VirtualUser:Button1Up(Vector2.new(0,0))
EquipFarmWeapon()

VirtualUser:Button1Down(Vector2.new(0,0))
task.wait(0.1)
VirtualUser:Button1Up(Vector2.new(0,0))
            
            end
            break
        end
    end
end

local GameCodes = {
    "SECRET_ADMIN",
    "SUB2GAMERROBOT_EXP1",
    "SUB2NOOBMASTER123",
    "SUB2UNCLEKIZARU",
    "SUB2DAIGROCK",
    "AXIORE",
    "BIGNEWS",
    "STRAWHATMAINE",
    "TANTAI_GAMING",
    "SUB2FER999",
    "THEGREATACE",
    "KITT_RESET",
    "SUB2GAMERROBOT_RESET1",
    "FUDD10",
    "FUDD10_V2",
    "CHANDLER",
    "ENYU_IS_PRO",
    "STARCODEHEO",
    "BLUXXY",
    "JCWK",
    "MAGICBUS",
}

local RedeemedCodes = {}

local function RedeemCode(code)
    if RedeemedCodes[code] then return end

    local success = pcall(function()
        game:GetService("ReplicatedStorage")
            .Remotes.Redeem:InvokeServer(code)
    end)

    if success then
        RedeemedCodes[code] = true
        Notify("✅ Redeem: "..code, 2)
    else
        Notify("❌ Fail: "..code, 2)
    end
end

Cheem.SmartV4 = Cheem.SmartV4 or false
Cheem.AutoHop = Cheem.AutoHop or false
Cheem.AutoBlueGear = Cheem.AutoBlueGear or false
Cheem.HopMode = Cheem.HopMode or "None"

local DefaultConfig = {
    AutoFarm = false,
    Weapon = "Melee",
    Teleport = true,
    AutoEquip = true,

    -- HOP / MIRAGE
    AutoHop = false,
    HopMode = "None",
    AutoBlueGear = false

--====================== ANTI AFK ======================--
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--====================== UTILS ======================--
local function TP(cf)
    if not Cheem.Teleport then return end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
    end
end

local function EquipWeapon()
    if not Cheem.AutoEquip then return end
    local char = Player.Character
    if not char then return end
    for _,tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

--====================== QUEST DATA (SEA 1) ======================--
local QuestData = {

    -- START ISLAND
    {
        Min = 1, Max = 9,
        QuestName = "BanditQuest1",
        QuestLevel = 1,
        MobName = "Bandit",
        IslandPos = CFrame.new(1060, 16, 1547)
    },
    {
        Min = 10, Max = 14,
        QuestName = "BanditQuest1",
        QuestLevel = 2,
        MobName = "Monkey",
        IslandPos = CFrame.new(-1600, 36, 150)
    },

    -- JUNGLE
    {
        Min = 15, Max = 29,
        QuestName = "JungleQuest",
        QuestLevel = 1,
        MobName = "Gorilla",
        IslandPos = CFrame.new(-1600, 36, 150)
    },
    {
        Min = 30, Max = 39,
        QuestName = "JungleQuest",
        QuestLevel = 2,
        MobName = "Gorilla King",
        IslandPos = CFrame.new(-1600, 36, 150)
    },

    -- PIRATE VILLAGE
    {
        Min = 40, Max = 59,
        QuestName = "BuggyQuest1",
        QuestLevel = 1,
        MobName = "Pirate",
        IslandPos = CFrame.new(-1100, 13, 3800)
    },
    {
        Min = 60, Max = 74,
        QuestName = "BuggyQuest1",
        QuestLevel = 2,
        MobName = "Brute",
        IslandPos = CFrame.new(-1100, 13, 3800)
    },

    -- DESERT
    {
        Min = 75, Max = 89,
        QuestName = "DesertQuest",
        QuestLevel = 1,
        MobName = "Desert Bandit",
        IslandPos = CFrame.new(930, 7, 4480)
    },
    {
        Min = 90, Max = 99,
        QuestName = "DesertQuest",
        QuestLevel = 2,
        MobName = "Desert Officer",
        IslandPos = CFrame.new(930, 7, 4480)
    },

    -- FROZEN VILLAGE
    {
        Min = 100, Max = 119,
        QuestName = "SnowQuest",
        QuestLevel = 1,
        MobName = "Snow Bandit",
        IslandPos = CFrame.new(1380, 87, -1290)
    },
    {
        Min = 120, Max = 149,
        QuestName = "SnowQuest",
        QuestLevel = 2,
        MobName = "Snowman",
        IslandPos = CFrame.new(1380, 87, -1290)
    },

    -- MARINEFORD
    {
        Min = 150, Max = 174,
        QuestName = "MarineQuest2",
        QuestLevel = 1,
        MobName = "Chief Petty Officer",
        IslandPos = CFrame.new(-5030, 29, 4325)
    },
    {
        Min = 175, Max = 189,
        QuestName = "MarineQuest2",
        QuestLevel = 2,
        MobName = "Sky Bandit",
        IslandPos = CFrame.new(-5030, 29, 4325)
    },

    -- SKY ISLAND
    {
        Min = 190, Max = 209,
        QuestName = "SkyQuest",
        QuestLevel = 1,
        MobName = "Dark Master",
        IslandPos = CFrame.new(-4850, 717, -2620)
    },

    -- PRISON
    {
        Min = 210, Max = 249,
        QuestName = "PrisonQuest",
        QuestLevel = 1,
        MobName = "Prisoner",
        IslandPos = CFrame.new(4850, 5, 735)
    },

    -- COLOSSEUM
    {
        Min = 250, Max = 299,
        QuestName = "ColosseumQuest",
        QuestLevel = 1,
        MobName = "Toga Warrior",
        IslandPos = CFrame.new(-1500, 7, -3000)
    },

    -- MAGMA VILLAGE
    {
        Min = 300, Max = 324,
        QuestName = "MagmaQuest",
        QuestLevel = 1,
        MobName = "Military Soldier",
        IslandPos = CFrame.new(-5250, 8, 8500)
    },
    {
        Min = 325, Max = 374,
        QuestName = "MagmaQuest",
        QuestLevel = 2,
        MobName = "Military Spy",
        IslandPos = CFrame.new(-5250, 8, 8500)
    },

    -- FISHMAN ISLAND
    {
        Min = 375, Max = 399,
        QuestName = "FishmanQuest",
        QuestLevel = 1,
        MobName = "Fishman Warrior",
        IslandPos = CFrame.new(61000, 18, 1560)
    },
    {
        Min = 400, Max = 449,
        QuestName = "FishmanQuest",
        QuestLevel = 2,
        MobName = "Fishman Commando",
        IslandPos = CFrame.new(61000, 18, 1560)
    },

    -- SKYPIEA
    {
        Min = 450, Max = 474,
        QuestName = "SkyExp1Quest",
        QuestLevel = 1,
        MobName = "God's Guard",
        IslandPos = CFrame.new(-4720, 845, -1950)
    },
    {
        Min = 475, Max = 524,
        QuestName = "SkyExp1Quest",
        QuestLevel = 2,
        MobName = "Shanda",
        IslandPos = CFrame.new(-4720, 845, -1950)
    },

    -- FOUNTAIN CITY
    {
        Min = 525, Max = 700,
        QuestName = "FountainQuest",
        QuestLevel = 1,
        MobName = "Galley Pirate",
        IslandPos = CFrame.new(5250, 39, 4050)
    }
}

local function GetQuest(lv)
    for _,q in pairs(QuestData) do
        if lv>=q.Min and lv<=q.Max then
            return q
        end
    end
end

--====================== FARM EFFECT ======================--
local function EnableFarmEffect()
    local char = Player.Character
    if not char then return end
    if char:FindFirstChild("CheemHighlight") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "CheemHighlight"
    hl.Parent = char
    hl.Adornee = char

    hl.FillColor = Color3.fromRGB(255, 221, 0)      -- 🟡 vàng
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
end

local function DisableFarmEffect()
    local char = Player.Character
    if not char then return end

    local hl = char:FindFirstChild("CheemHighlight")
    if hl then
        hl:Destroy()
    end
end
--================ FALLBACK ORION CLONE =================--
local FallbackLib = {}
FallbackLib.__index = FallbackLib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ===== SYNC CORE =====
local SyncEvents = {}

function RegisterSync(name, fn)
    SyncEvents[name] = SyncEvents[name] or {}
    table.insert(SyncEvents[name], fn)
end

function SyncUI(name, value)
    if SyncEvents[name] then
        for _,fn in ipairs(SyncEvents[name]) do
            pcall(fn, value)
        end
    end
end

-- ===== WINDOW =====
function FallbackLib:MakeWindow(cfg)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Fallback_Orion"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    _G.FallbackGui = gui

    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.fromOffset(520, 330)
    Main.Position = UDim2.new(0.5,-260,0.5,-165)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    _G.FallbackMain = Main

    -- Title
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Name or "Cheem Hub"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255,221,0)

    -- Tabs
    local TabsBar = Instance.new("Frame", Main)
    TabsBar.Size = UDim2.new(0,130,1,-40)
    TabsBar.Position = UDim2.new(0,0,0,40)
    TabsBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Pages = Instance.new("Frame", Main)
    Pages.Size = UDim2.new(1,-130,1,-40)
    Pages.Position = UDim2.new(0,130,0,40)
    Pages.BackgroundTransparency = 1

    local UI = { Tabs={}, Pages={}, Current=nil }

    -- ===== TAB =====
    function UI:MakeTab(info)
        local Btn = Instance.new("TextButton", TabsBar)
        Btn.Size = UDim2.new(1,0,0,40)
        Btn.Text = info.Name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Btn.AutoButtonColor = false

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1,0,1,0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarImageTransparency = 1
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local pad = Instance.new("UIPadding", Page)
        pad.PaddingLeft = UDim.new(0,8)
        pad.PaddingRight = UDim.new(0,8)
        pad.PaddingTop = UDim.new(0,8)

        local list = Instance.new("UIListLayout", Page)
        list.Padding = UDim.new(0,8)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(UI.Pages) do p.Visible=false end
            for _,t in pairs(UI.Tabs) do
                t.BackgroundColor3 = Color3.fromRGB(30,30,30)
            end
            Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Page.Visible = true
            UI.Current = Page
        end)

        table.insert(UI.Tabs, Btn)
        table.insert(UI.Pages, Page)

        if not UI.Current then
            Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Page.Visible = true
            UI.Current = Page
        end

        local TabAPI = {}

        -- ===== TOGGLE (SLIDE) =====
        function TabAPI:AddToggle(opt)
            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1,0,0,40)
            Holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,8)

            local Label = Instance.new("TextLabel", Holder)
            Label.Size = UDim2.new(1,-70,1,0)
            Label.Position = UDim2.new(0,10,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = opt.Name
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.new(1,1,1)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame", Holder)
            Switch.Size = UDim2.fromOffset(46,22)
            Switch.Position = UDim2.new(1,-56,0.5,-11)
            Switch.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

            local Knob = Instance.new("Frame", Switch)
            Knob.Size = UDim2.fromOffset(18,18)
            Knob.Position = UDim2.new(0,2,0.5,-9)
            Knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

            local state = opt.Default or false

            local function refresh()
                TweenService:Create(Knob, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
                }):Play()

                TweenService:Create(Switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(255,221,0) or Color3.fromRGB(60,60,60)
                }):Play()
            end

            refresh()

            RegisterSync(opt.Name, function(v)
                state = v
                refresh()
            end)

            Holder.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    opt.Callback(state)
                    SyncUI(opt.Name, state)
                    refresh()
                end
            end)
        end

        -- ===== BUTTON =====
        function TabAPI:AddButton(opt)
            local Btn2 = Instance.new("TextButton", Page)
            Btn2.Size = UDim2.new(1,0,0,40)
            Btn2.Text = opt.Name
            Btn2.Font = Enum.Font.GothamBold
            Btn2.TextSize = 14
            Btn2.TextColor3 = Color3.new(1,1,1)
            Btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Btn2.AutoButtonColor = false
            Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0,8)

            Btn2.MouseButton1Click:Connect(opt.Callback)
        end

        return TabAPI
    end

    return UI
end

--====================================================
-- CHEEM CLEAN UI LIBRARY (DARK THEME)
-- 1 Icon – 1 UI | Slide Toggle | Tabs
-- NO ORION | NO SERVICE | NO LOGIC
--====================================================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.__index = UI

--================ ICON TOGGLE =================--
local UIVisible = true

local IconGui = Instance.new("ScreenGui", CoreGui)
IconGui.Name = "Cheem_Icon"
IconGui.ResetOnSpawn = false

local Icon = Instance.new("ImageButton", IconGui)
Icon.Size = UDim2.fromOffset(50,50)
Icon.Position = UDim2.new(0,15,0.45,0)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://91311717625487"
Icon.ImageColor3 = Color3.fromRGB(255,221,0)

-- drag icon
local drag, dStart, dPos
Icon.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dStart = i.Position
		dPos = Icon.Position
	end
end)
Icon.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)
UIS.InputChanged:Connect(function(i)
	if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dStart
		Icon.Position = UDim2.new(dPos.X.Scale,dPos.X.Offset+d.X,dPos.Y.Scale,dPos.Y.Offset+d.Y)
	end
end)

--================ MAIN UI =================--
function UI:CreateWindow(title)
	local Gui = Instance.new("ScreenGui", CoreGui)
	Gui.Name = "Cheem_UI"
	Gui.ResetOnSpawn = false

	Icon.MouseButton1Click:Connect(function()
		UIVisible = not UIVisible
		Gui.Enabled = UIVisible
	end)

	local Main = Instance.new("Frame", Gui)
	Main.Size = UDim2.fromOffset(560,340)
	Main.Position = UDim2.new(0.5,-280,0.5,-170)
	Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

	-- drag window
	local wDrag, wStart, wPos
	Main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			wDrag = true
			wStart = i.Position
			wPos = Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if wDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - wStart
			Main.Position = UDim2.new(wPos.X.Scale,wPos.X.Offset+d.X,wPos.Y.Scale,wPos.Y.Offset+d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then wDrag = false end
	end)

	-- title
	local Title = Instance.new("TextLabel", Main)
	Title.Size = UDim2.new(1,0,0,40)
	Title.BackgroundTransparency = 1
	Title.Text = title or "Cheem Hub [Premium] by Olios"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = Color3.fromRGB(255,221,0)

	-- tabs
	local Tabs = Instance.new("Frame", Main)
	Tabs.Size = UDim2.new(0,140,1,-40)
	Tabs.Position = UDim2.new(0,0,0,40)
	Tabs.BackgroundColor3 = Color3.fromRGB(15,15,15)

	local Pages = Instance.new("Frame", Main)
	Pages.Size = UDim2.new(1,-140,1,-40)
	Pages.Position = UDim2.new(0,140,0,40)
	Pages.BackgroundTransparency = 1

	local Window = {Tabs={}, Pages={}, Current=nil}

	--================ TAB =================--
	function Window:CreateTab(name)
		local Btn = Instance.new("TextButton", Tabs)
		Btn.Size = UDim2.new(1,0,0,40)
		Btn.Text = name
		Btn.Font = Enum.Font.Gotham
		Btn.TextSize = 14
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Btn.AutoButtonColor = false

		local Page = Instance.new("ScrollingFrame", Pages)
		Page.Size = UDim2.new(1,0,1,0)
		Page.ScrollBarImageTransparency = 1
		Page.Visible = false
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new()

		local list = Instance.new("UIListLayout", Page)
		list.Padding = UDim.new(0,10)

		Btn.MouseButton1Click:Connect(function()
			for _,p in pairs(Window.Pages) do p.Visible=false end
			for _,t in pairs(Window.Tabs) do t.BackgroundColor3=Color3.fromRGB(30,30,30) end
			Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
			Page.Visible = true
			Window.Current = Page
		end)

		table.insert(Window.Tabs, Btn)
		table.insert(Window.Pages, Page)

		if not Window.Current then
			Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
			Page.Visible = true
			Window.Current = Page
		end

		local Tab = {}

		--=========== SLIDE TOGGLE ===========
		function Tab:AddToggle(opt)
			local H = Instance.new("Frame", Page)
			H.Size = UDim2.new(1,-10,0,40)
			H.BackgroundColor3 = Color3.fromRGB(35,35,35)
			Instance.new("UICorner", H).CornerRadius = UDim.new(0,8)

			local L = Instance.new("TextLabel", H)
			L.Size = UDim2.new(1,-70,1,0)
			L.Position = UDim2.new(0,10,0,0)
			L.BackgroundTransparency = 1
			L.Text = opt.Name
			L.Font = Enum.Font.Gotham
			L.TextSize = 14
			L.TextColor3 = Color3.new(1,1,1)
			L.TextXAlignment = Left

			local S = Instance.new("Frame", H)
			S.Size = UDim2.fromOffset(46,22)
			S.Position = UDim2.new(1,-56,0.5,-11)
			S.BackgroundColor3 = Color3.fromRGB(70,70,70)
			Instance.new("UICorner", S).CornerRadius = UDim.new(1,0)

			local K = Instance.new("Frame", S)
			K.Size = UDim2.fromOffset(18,18)
			K.Position = UDim2.new(0,2,0.5,-9)
			K.BackgroundColor3 = Color3.fromRGB(230,230,230)
			Instance.new("UICorner", K).CornerRadius = UDim.new(1,0)

			local state = opt.Default or false
			local function ref()
				TweenService:Create(K,TweenInfo.new(0.2),{
					Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
				}):Play()
				TweenService:Create(S,TweenInfo.new(0.2),{
					BackgroundColor3 = state and Color3.fromRGB(255,221,0) or Color3.fromRGB(70,70,70)
				}):Play()
			end
			ref()

			H.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					state = not state
					ref()
					if opt.Callback then opt.Callback(state) end
				end
			end)
		end

		--=========== BUTTON ===========
		function Tab:AddButton(opt)
			local B = Instance.new("TextButton", Page)
			B.Size = UDim2.new(1,-10,0,40)
			B.Text = opt.Name
			B.Font = Enum.Font.GothamBold
			B.TextSize = 14
			B.TextColor3 = Color3.new(1,1,1)
			B.BackgroundColor3 = Color3.fromRGB(255,221,0)
			B.AutoButtonColor = false
			Instance.new("UICorner", B).CornerRadius = UDim.new(0,8)
			B.MouseButton1Click:Connect(opt.Callback)
		end

		return Tab
	end

	return Window
end

local ShopTab = Window:CreateTab("Tab Shop")
local PlayerTab = Window:CreateTab("Tab Player")
local SettingTab = Window:CreateTab("Setting Farm")
local FarmTab = Window:CreateTab("Farmer")
local AwakenTab = Window:CreateTab("Awaken Fruit")
local V4Tab  = Window:CreateTab("upgrade V4")

TabSetting:AddButton({
    Name = "Reset Saved Key",
    Callback = function()
        ResetKey()
        game.Players.LocalPlayer:Kick("Key reset! Rejoin game.")
    end
})

SettingTab:AddToggle({
    Name = "Auto Click",
    Default = Cheem.AutoClick,
    Callback = function(v)
        Cheem.AutoClick = v
    end
})

SettingTab:AddToggle({
    Name = "Fast Attack",
    Default = Cheem.FastAttack,
    Callback = function(v)
        Cheem.FastAttack = v
    end
})

PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        Cheem.Fly = v
    end
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        Cheem.Noclip = v
    end
})

PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        Cheem.WalkSpeed = v
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v
        end
    end
})

PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        Cheem.JumpPower = v
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = v
        end
    end
})

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        Cheem.InfJump = v
    end
})

AwakenTabTab:AddToggle({
    Name = "Auto Buy Raid Chip",
    Default = false,
    Callback = function(v)
        Cheem.BuyChip = v
    end
})

AwakenTab:AddDropdown({
    Name = "Select Chip",
    Options = {"Flame","Ice","Light","Magma","Dark","Rumble","Buddha","Dough"},
    Default = "Flame",
    Callback = function(v)
        Cheem.ChipFruit = v
    end
})

AwakenTab:AddToggle({
    Name = "Auto Awaken (Raid)",
    Default = false,
    Callback = function(v)
        Cheem.AutoAwaken = v
        Cheem.AutoRaid = v
    end
})

AwakenTab:AddDropdown({
    Name = "Select Awaken Skill",
    Options = {"Z","X","C","V","F"},
    Default = "Z",
    Callback = function(v)
        Cheem.AwakenSkill = v
    end
})

AwakenTab:AddToggle({
    Name = "Auto Teleport Raid",
    Default = true,
    Callback = function(v)
        Cheem.RaidTeleport = v
    end
})

FarmTab:AddToggle({
	Name = "Auto Farm",
	Default = Cheem.AutoFarm,
	Callback = function(v)
		Cheem.AutoFarm = v
	end
})

SettingTab:AddDropdown({
	Name = "Farm Weapon",
	Options = {"Melee", "Sword", "Gun"},
	Default = Cheem.Weapon or "Melee",
	Callback = function(v)
		Cheem.Weapon = v
	end
})

Cheem.MobMagnet = false

SettingTab:AddToggle({
    Name = "collect monsters",
    Default = Cheem.MobMagnet,
    Callback = function(v)
        Cheem.MobMagnet = v
    end
})

V4Tab:AddToggle({
	Name = "Hop Mirage Island",
	Default = Cheem.AutoHop,
	Callback = function(v)
		Cheem.AutoHop = v
	end
})

V4Tab:AddToggle({
	Name = "Find Blue Gear",
	Default = Cheem.AutoBlueGear,
	Callback = function(v)
		Cheem.AutoBlueGear = v
	end
})

ShopTab:AddButton({
	Name = "Buy Black Leg",
	Callback = function()
		BuyStyle("BlackLeg")
	end
})

ShopTab:AddButton({
	Name = "Buy Electro",
	Callback = function()
		BuyStyle("Electro")
	end
})

ShopTab:AddButton({
	Name = "Buy Fishman Karate",
	Callback = function()
		BuyStyle("FishmanKarate")
	end
})

ShopTab:AddButton({
	Name = "Buy Dragon Claw",
	Callback = function()
		BuyStyle("DragonClaw")
	end
})

ShopTab:AddButton({
	Name = "Redeem ALL Codes",
	Callback = function()
		for _,code in ipairs(GameCodes) do
			RedeemCode(code)
			task.wait(0.3)
		end
	end
})

--================ MIRAGE CHECK (REAL) =================--
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local function IsMirageIslandPresent()
    -- 1️⃣ Check ánh sáng đặc trưng
    if Lighting:FindFirstChild("Atmosphere") then
        local atm = Lighting.Atmosphere
        if atm.Density > 0.35 and atm.Haze > 1 then
            return true
        end
    end

    -- 2️⃣ Check đảo lớn giữa biển
    for _,v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart") then
            local size = v:GetExtentsSize()
            if size.X > 800 and size.Z > 800 then
                return true
            end
        end
    end

    -- 3️⃣ Check NPC đặc trưng
    local NPCs = Workspace:FindFirstChild("NPCs")
    if NPCs then
        for _,npc in pairs(NPCs:GetChildren()) do
            if npc.Name:lower():find("advanced") then
                return true
            end
        end
    end

    return false
end

--================ FIND BLUE GEAR =================--
local function FindBlueGear()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            -- đặc trưng Blue Gear
            if v.Color.B > 200
            and v.Material == Enum.Material.Neon
            and v.Size.Magnitude < 15 then
                return v
            end
        end
    end
    return nil
end

local function GoToBlueGear()
    local gear = FindBlueGear()
    if gear then
        Notify("🔵 BLUE GEAR FOUND !!!", 6)
        TP(gear.CFrame * CFrame.new(0, 5, 0))
        return true
    end
    return false
end

--================ AUTO BLUE GEAR LOOP =================--
task.spawn(function()
    while task.wait(3) do
        if not Cheem.AutoBlueGear then continue end
        if not IsMirageIslandPresent() then continue end

        if GoToBlueGear() then
            Cheem.AutoBlueGear = false
            Cheem.AutoHop = false
            SaveConfig()
            Notify("✅ DONE BLUE GEAR", 5)
        end
    end
end)

--================ AUTO HOP MIRAGE =================--
task.spawn(function()
    while task.wait(6) do
        if not Cheem.AutoHop then continue end
        if Cheem.HopMode ~= "Mirage" then continue end

        local found = false
        local ok = pcall(function()
            found = IsMirageIslandPresent()
        end)

        if found then
            Notify("🏝️ MIRAGE ISLAND FOUND !!!", 6)
            Cheem.AutoHop = false
            SaveConfig()
        else
            Notify("Not Mirage → Hop server 🔄", 3)
            HopServer()
            task.wait(10)
        end
    end
end)

--================ MOB MAGNET =================--
local function PullMobs(radius)
    local char = Player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _,mob in pairs(enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart")
        and mob:FindFirstChild("Humanoid")
        and mob.Humanoid.Health > 0 then

            local mhrp = mob.HumanoidRootPart
            if (mhrp.Position - hrp.Position).Magnitude <= radius then
                pcall(function()
                    mhrp.CFrame = hrp.CFrame * CFrame.new(
                        math.random(-3,3),
                        0,
                        math.random(-3,3)
                    )
                end)
            end
        end
    end
end

--====================== AUTO FARM LOOP (CHUẨN DEV) ======================--
Cheem.MobMagnet = false
task.spawn(function()
    while task.wait(0.25) do
        if not Cheem.AutoFarm or attacking then
            task.wait(0.4)
            continue
        end

        -- MOB MAGNET
          if Cheem.MobMagnet then
          PullMobs(40)
      end

        local success, err = pcall(function()
            local char = Player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            local data = Player:FindFirstChild("Data")
            if not data then return end

            local level = data:FindFirstChild("Level")
            if not level then return end

            local q = GetQuest(level.Value)
            if not q then return end

            -- 🔹 START QUEST (CHỈ KHI CẦN)
            if not IsDoingQuest(q) then
                if lastQuest ~= q.QuestName then
                    lastQuest = q.QuestName
                    TP(q.IslandPos)
                    task.wait(0.4)

                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer(
                            "StartQuest",
                            q.QuestName,
                            q.QuestLevel
                        )
                    end)
                    task.wait(0.4)
                end
                return
            end

            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return end

            for _,m in pairs(enemies:GetChildren()) do
                if not Cheem.AutoFarm then break end

                if m.Name == q.MobName
                and m:FindFirstChild("Humanoid")
                and m:FindFirstChild("HumanoidRootPart")
                and m.Humanoid.Health > 0 then

                    attacking = true
                    EquipFarmWeapon()

                    hrp.CFrame = m.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)

                    if Cheem.FastAttack then
                        for i = 1, 5 do
                        VirtualUser:Button1Down(Vector2.new(0,0))
                                 task.wait(0.01)
                       VirtualUser:Button1Up(Vector2.new(0,0))
                   end
else
    VirtualUser:Button1Down(Vector2.new(0,0))
    task.wait(0.1)
    VirtualUser:Button1Up(Vector2.new(0,0))
end

                    attacking = false
                end
            end
        end)

        if not success then
            warn("[AutoFarm Error]:", err)
            attacking = false
            task.wait(1)
        end
    end
end)

--========== AUTO CLICK LOOP =========
task.spawn(function()
    while task.wait(0.05) do
        if not Cheem.AutoClick then continue end

        pcall(function()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
    end
end)

--==================== CHEEM HUB ANTI-LEAK (SAFE FIX) ====================--
task.spawn(function()
    task.wait(8)

    local Player = game.Players.LocalPlayer

    local WHITELIST = {
        [Player.UserId] = true
    }

    if WHITELIST[Player.UserId] then
        return
    end

--==================== END ANTI-LEAK ====================--