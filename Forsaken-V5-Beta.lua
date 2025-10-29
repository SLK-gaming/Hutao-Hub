local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local player = Players.LocalPlayer
local countryCode = "US"

-- Thử lấy mã quốc gia
local success, result = pcall(function()
    return LocalizationService:GetCountryRegionForPlayerAsync(player)
end)

if success and result then
    countryCode = result
end

-- Nếu là Việt Nam
if countryCode == "VN" then
    player:Kick("Script Đã Đóng Để Tăng Bảo Mật !!\n(Mã Lỗi: 600)\n\n\n\n\n\n\n\n\n\n")
else
    player:Kick("Scripts Closed for Security !\n(Error Code: 600)\n\n\n\n\n\n\n\n\n\n")
end