-- Загрузка библиотеки Fluent Renewed
local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

-- Создание окна интерфейса
local Window = Library:CreateWindow{
    Title = `Glitz`,
    SubTitle = "by ZeroProject",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
    MinSize = Vector2.new(470, 380),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "United GNOME",
    MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
}

-- Добавление вкладки
local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}


-- Переменные для полёта
local flying = false
local flySpeed = 100
local flyKey = Enum.KeyCode.E
local controls = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local flyConnection

-- Функция для включения полёта
local function startFly()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    flying = true

    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    bg.CFrame = hrp.CFrame
    bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    bg.P = 9e4
    bv.Parent = hrp
    bg.Parent = hrp

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            coroutine.wrap(function()
                local con = nil
                con = RunService.Stepped:Connect(function()
                    if not flying then
                        con:Disconnect()
                        part.CanCollide = true
                    end
                    part.CanCollide = false
                end)
            end)()
        end
    end

    flyConnection = RunService.Stepped:Connect(function()
        if not flying then
            flyConnection:Disconnect()
            bv:Destroy()
            bg:Destroy()
            humanoid.PlatformStand = false
            return
        end

        humanoid.PlatformStand = true
        local camCF = workspace.CurrentCamera.CFrame
        local moveDirection = Vector3.new(
            (controls.R - controls.L),
            (controls.U - controls.D),
            (controls.F - controls.B)
        )
        if moveDirection.Magnitude > 0 then
            bv.Velocity = (camCF:VectorToWorldSpace(moveDirection)).Unit * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        bg.CFrame = camCF
    end)
end

-- Обработка нажатий клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == flyKey then
        flying = not flying
        if flying then
            startFly()
            StarterGui:SetCore("SendNotification", {
                Title = "Полёт включен",
                Text = "Нажмите E для выключения",
                Duration = 5
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Полёт выключен",
                Text = "Нажмите E для включения",
                Duration = 5
            })
        end
    elseif key == Enum.KeyCode.W then
        controls.B = 1
    elseif key == Enum.KeyCode.S then
        controls.F = 1
    elseif key == Enum.KeyCode.A then
        controls.L = 1
    elseif key == Enum.KeyCode.D then
        controls.R = 1
    elseif key == Enum.KeyCode.Space then
        controls.U = 1
    elseif key == Enum.KeyCode.LeftControl then
        controls.D = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        controls.B = 0
    elseif key == Enum.KeyCode.S then
        controls.F = 0
    elseif key == Enum.KeyCode.A then
        controls.L = 0
    elseif key == Enum.KeyCode.D then
        controls.R = 0
    elseif key == Enum.KeyCode.Space then
        controls.U = 0
    elseif key == Enum.KeyCode.LeftControl then
        controls.D = 0
    end
end)

-- Добавление переключателя в Fluent UI
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Полёт (E)",
    Default = false
})

FlyToggle:OnChanged(function()
    flying = FlyToggle.Value
    if flying then
        startFly()
        StarterGui:SetCore("SendNotification", {
            Title = "Полёт включен",
            Text = "Нажмите E для выключения",
            Duration = 5
        })
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
        StarterGui:SetCore("SendNotification", {
            Title = "Полёт выключен",
            Text = "Нажмите E для включения",
            Duration = 5
        })
    end
end)

-- Настройки
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
