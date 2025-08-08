-- Time Reverse Troll Script v4 (Stop Anytime + Death Fix)
if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm lấy HRP mới khi respawn
local function GetHRP()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return Character:WaitForChild("HumanoidRootPart"), Character
end

local HRP, Character = GetHRP()

-- Lịch sử vị trí
local positionHistory = {}
local maxHistory = 80 -- ~20s
local minMoveDist = 1 -- khoảng cách tối thiểu để lưu

-- Trạng thái
local toggled = false
local reversing = false

-- Lưu vị trí
local function recordPosition()
    if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") and HRP.Parent.Humanoid.Health > 0 then
        if #positionHistory == 0 or (HRP.Position - positionHistory[#positionHistory]).Magnitude >= minMoveDist then
            table.insert(positionHistory, HRP.Position)
            if #positionHistory > maxHistory then
                table.remove(positionHistory, 1)
            end
        end
    end
end

-- Ghi liên tục
task.spawn(function()
    while task.wait(0.25) do
        recordPosition()
    end
end)

-- Tua ngược
local function reverseTime()
    if reversing then return end
    reversing = true
    for i = #positionHistory, 1, -1 do
        if not toggled then break end -- dừng nếu tắt giữa chừng
        if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") and HRP.Parent.Humanoid.Health > 0 then
            local tween = TweenService:Create(HRP, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(positionHistory[i])
            })
            tween:Play()
            tween.Completed:Wait()
        else
            break
        end
    end
    reversing = false
    toggled = false
    ToggleButton.Text = "Điều khiển thời gian: OFF"
end

-- Khi chết
local function onDeath()
    positionHistory = {}
    toggled = false
    reversing = false
    ToggleButton.Text = "Điều khiển thời gian: OFF"
end

Character:WaitForChild("Humanoid").Died:Connect(function()
    onDeath()
    LocalPlayer.CharacterAdded:Wait()
    HRP, Character = GetHRP()
    Character:WaitForChild("Humanoid").Died:Connect(onDeath)
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local function Roundify(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Active = true
MainFrame.Draggable = true
Roundify(MainFrame, 10)
MainFrame.Parent = ScreenGui

-- Nút X
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
Roundify(CloseButton, 5)
CloseButton.Parent = MainFrame

-- Toggle
ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "Điều khiển thời gian: OFF"
Roundify(ToggleButton, 8)
ToggleButton.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    toggled = not toggled
    ToggleButton.Text = "Điều khiển thời gian: " .. (toggled and "ON" or "OFF")
    if toggled and not reversing then
        task.spawn(reverseTime)
    end
end)

-- Nút ⏱️ thu nhỏ
local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Position = UDim2.new(0.4, 0, 0.4, 0)
MiniButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
MiniButton.Text = "⏱️"
MiniButton.Visible = false
MiniButton.TextScaled = true
MiniButton.TextColor3 = Color3.fromRGB(255,255,255)
MiniButton.Parent = ScreenGui
MiniButton.Active = true
MiniButton.Draggable = true
Roundify(MiniButton, 25)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    MiniButton.Visible = false
    MainFrame.Visible = true
end)
