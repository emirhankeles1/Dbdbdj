local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Ayarlar
local SpeedBoost = 36
local BoostStrength = 60

-- Hız ve Boost Uygulama Fonksiyonu
local function applySpeedAndBoost(Character)
	local HRP = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:WaitForChild("Humanoid")

	-- WalkSpeed sürekli kontrol (oyun sıfırlasa bile)
	task.spawn(function()
		while Character.Parent do
			if Humanoid and Humanoid.Health > 0 then
				if Humanoid.WalkSpeed ~= SpeedBoost then
					Humanoid.WalkSpeed = SpeedBoost
				end
			end
			wait(0.5)
		end
	end)

	-- Zıplayınca boost
	Humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Jumping then
			local lookVector = Camera.CFrame.LookVector
			local boost = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * BoostStrength
			HRP.Velocity = HRP.Velocity + boost
		end
	end)

	-- Desync (sabit pozisyon verisiyle serverı zorla)
	task.spawn(function()
		while Character.Parent and Humanoid.Health > 0 do
			wait(0.1)
			local pos = HRP.Position
			HRP.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
		end
	end)
end

-- Mevcut karaktere uygula
if LocalPlayer.Character then
	applySpeedAndBoost(LocalPlayer.Character)
end

-- Yeni karakter geldikçe uygula
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	char:WaitForChild("Humanoid")
	applySpeedAndBoost(char)
end)
