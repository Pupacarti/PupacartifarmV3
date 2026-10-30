local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("✅ [DEBUG] สคริปต์โหลดสำเร็จแล้ว!")

local scriptActive = true -- ตั้งให้เปิดใช้งานทันทีเพื่อทดสอบง่ายๆ
local aiming = false

-- 1. ฟังก์ชันหา NPC/ซอมบี้ทุกตัวในแมพ (ไม่จำกัดชื่อ)
local function getClosestNPC()
    local closestNPC = nil
    local shortestDistance = math.huge

    -- ค้นหาใน Workspace ทั้งหมด
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            -- ต้อง "ไม่ใช่ตัวละครของผู้เล่น"
            if not Players:GetPlayerFromCharacter(obj) and obj ~= LocalPlayer.Character then
                if obj.Humanoid.Health > 0 then
                    local headPosition, onScreen = Camera:WorldToViewportPoint(obj.Head.Position)
                    if onScreen then
                        local mouseLocation = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(headPosition.X, headPosition.Y) - mouseLocation).Magnitude

                        if distance < shortestDistance then
                            closestNPC = obj
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestNPC
end

-- 2. ตรวจจับการกดคลิกขวา
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
        print("🎯 [DEBUG] กำลังกดคลิกขวาค้างเพื่อเล็ง...")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        print("❌ [DEBUG] ปล่อยคลิกขวาแล้ว")
    end
end)

-- 3. ระบบล็อกเป้ากล้อง
RunService.RenderStepped:Connect(function()
    if scriptActive and aiming then
        local target = getClosestNPC()
        if target and target:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        end
    end
end)

-- 4. ระบบ Auto-E (กด E อัตโนมัติเมื่อเข้าใกล้ ProximityPrompt)
task.spawn(function()
    while task.wait(0.2) do
        if scriptActive then
            for _, prompt in pairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - prompt.Parent.Position).Magnitude
                        if distance <= prompt.MaxActivationDistance then
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration)
                                prompt:InputHoldEnd()
                            end
                            print("กด E อัตโนมัติเรียบร้อย!")
                        end
                    end
                end
            end
        end
    end
end)
