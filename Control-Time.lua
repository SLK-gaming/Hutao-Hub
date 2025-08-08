-- Time Reverse Troll Script v4 + Death Fix + Quay Lại Quá Khứ + Infinite Jump Toggle
if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Biến lưu
local HRP, Character
local lastDeathPosition = nil
local positionHistory = {}
local maxHistory = 80
local minMoveDist = 1
local toggled = false
local reversing = false
local infiniteJumpEnabled = false -- trạng thái nhảy vô hạn

-- Hàm setup lại HRP & Character khi respawn
local function setupCharacter(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        if HRP and HRP.Parent then
            lastDeathPosition = HRP.Position
        else
            lastDeathPosition = nil
        end
        positionHistory = {}
        toggled = false
        reversing = false
        ToggleButton.Text = "Điều khiển thời gian: OFF"
    end)
end

-- Lưu vị trí di chuyển
local function recordPosition()
    if HRP and HRP.Parent and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
        if #positionHistory == 0 or (HRP.Position - positionHistory[#positionHistory]).Magnitude >= minMoveDist then
            table.insert(positionHistory, HRP.Position)
            if #positionHistory > maxHistory then
                table.remove(positionHistory, 1)
            end
        end
    end
end

-- Tua ngược thời gian
local function reverseTime()
    if reversing then return end
    reversing = true
    for i = #positionHistory, 1, -1 do
        if not toggled then break end
        if HRP and HRP.Parent and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
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

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Bắt đầu lắng nghe vị trí
task.spawn(function()
    while task.wait(0.25) do
        recordPosition()
    end
end)

-- Lấy character ban đầu
setupCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(setupCharacter)

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
MainFrame.Size = UDim2.new(0, 200, 0, 210) -- tăng chiều cao
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

-- Toggle Time Reverse
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

-- Nút Quay Lại Quá Khứ
local ReturnButton = Instance.new("TextButton")
ReturnButton.Size = UDim2.new(1, -20, 0, 40)
ReturnButton.Position = UDim2.new(0, 10, 0, 90)
ReturnButton.BackgroundColor3 = Color3.fromRGB(70,50,50)
ReturnButton.TextColor3 = Color3.fromRGB(255,255,255)
ReturnButton.Text = "Quay Lại Quá Khứ"
Roundify(ReturnButton, 8)
ReturnButton.Parent = MainFrame

ReturnButton.MouseButton1Click:Connect(function()
    if lastDeathPosition and HRP and HRP.Parent and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
        HRP.CFrame = CFrame.new(lastDeathPosition)
    else
        ReturnButton.Text = "Không có vị trí chết"
        task.delay(1.5, function()
            ReturnButton.Text = "Quay Lại Quá Khứ"
        end)
    end
end)

-- Nút Toggle Infinite Jump
local JumpButton = Instance.new("TextButton")
JumpButton.Size = UDim2.new(1, -20, 0, 40)
JumpButton.Position = UDim2.new(0, 10, 0, 140)
JumpButton.BackgroundColor3 = Color3.fromRGB(50,70,50)
JumpButton.TextColor3 = Color3.fromRGB(255,255,255)
JumpButton.Text = "Nhảy vô hạn: OFF"
Roundify(JumpButton, 8)
JumpButton.Parent = MainFrame

JumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    JumpButton.Text = "Nhảy vô hạn: " .. (infiniteJumpEnabled and "ON" or "OFF")
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
