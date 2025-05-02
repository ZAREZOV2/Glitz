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

-- Добавление элементов управления
local Toggle = Tabs.Main:CreateToggle(
    "MyToggle", {
        Title = "Fly", 
        Default = false 
    })

Toggle:OnChanged(function()
    local FlyKey = Enum.KeyCode.V 
    local SpeedKey = Enum.KeyCode.LeftControl 
     
    local SpeedKeyMultiplier = 3 
    local FlightSpeed = 256 
    local FlightAcceleration = 4 
    local TurnSpeed = 16 
      
    local UserInputService = game:GetService("UserInputService") 
    local StarterGui = game:GetService("StarterGui") 
    local RunService = game:GetService("RunService") 
    local Players = game:GetService("Players") 
    local User = Players.LocalPlayer 
    local Camera = workspace.CurrentCamera 
    local UserCharacter = nil 
    local UserRootPart = nil 
    local Connection = nil 
     
    workspace.Changed:Connect(function() 
        Camera = workspace.CurrentCamera 
    end) 
     
    local setCharacter = function(c) 
        UserCharacter = c 
        UserRootPart = c:WaitForChild("HumanoidRootPart") 
    end 
     
    User.CharacterAdded:Connect(setCharacter) 
    if User.Character then 
        setCharacter(User.Character) 
    end 
     
    local CurrentVelocity = Vector3.new(0,0,0) 
    local Flight = function(delta) 
        local BaseVelocity = Vector3.new(0,0,0) 
        if not UserInputService:GetFocusedTextBox() then 
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                BaseVelocity = BaseVelocity + (Camera.CFrame.LookVector * FlightSpeed) 
            end 
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                BaseVelocity = BaseVelocity - (Camera.CFrame.RightVector * FlightSpeed) 
            end 
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                BaseVelocity = BaseVelocity - (Camera.CFrame.LookVector * FlightSpeed) 
            end 
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                BaseVelocity = BaseVelocity + (Camera.CFrame.RightVector * FlightSpeed) 
            end 
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                BaseVelocity = BaseVelocity + (Camera.CFrame.UpVector * FlightSpeed) 
            end 
            if UserInputService:IsKeyDown(SpeedKey) then 
                BaseVelocity = BaseVelocity * SpeedKeyMultiplier 
            end 
        end 
        if UserRootPart then 
            local car = UserRootPart:GetRootPart() 
            if car.Anchored then return end 
            if not isnetworkowner(car) then return end 
            CurrentVelocity = CurrentVelocity:Lerp( 
                BaseVelocity, 
                math.clamp(delta * FlightAcceleration, 0, 1) 
            ) 
            car.Velocity = CurrentVelocity + Vector3.new(0,2,0) 
            if car ~= UserRootPart then 
                car.RotVelocity = Vector3.new(0,0,0) 
                car.CFrame = car.CFrame:Lerp(CFrame.lookAt( 
                    car.Position, 
                    car.Position + CurrentVelocity + Camera.CFrame.LookVector 
                ), math.clamp(delta * TurnSpeed, 0, 1)) 
            end 
        end 
    end

    StarterGui:SetCore("SendNotification",{ 
        Title = "Fly activated!", 
        Text = "Press [V] On/Off" 
    })    
    
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes{}

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()