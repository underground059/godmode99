--[[
    GUI для бессмертия v2: Агрессивный метод
    Стратегия:
    1. Постоянно находить и УНИЧТОЖАТЬ кастомный скрипт "Health".
    2. Подписаться на событие изменения здоровья и мгновенно восстанавливать его.
]]

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isGodmodeOn = false
local connections = {} -- Таблица для хранения активных подключений к событиям

-- Создание GUI (код без изменений)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Position = UDim2.new(1, -160, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 80, 80)
ToggleButton.BorderSizePixel = 2
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Text = "Бессмертие [OFF]"

-- Функция отключения
local function disableGodmode()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    table.clear(connections)
    print("Соединения для восстановления здоровья разорваны.")
end

-- Новая, более агрессивная функция активации
local function applyGodmode(character)
    if not character then return end
    disableGodmode() -- Сбрасываем старые подключения на всякий случай

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- Тактика 1: Цикл уничтожения кастомного скрипта
    local destroyerThread = coroutine.create(function()
        while isGodmodeOn and character and character.Parent do
            local customHealthScript = character:FindFirstChild("Health")
            if customHealthScript then
                customHealthScript:Destroy()
                print("Агрессивный режим: скрипт 'Health' уничтожен.")
            end
            wait(0.2)
        end
    end)
    coroutine.resume(destroyerThread)

    -- Тактика 2: Мгновенное восстановление при получении урона
    if humanoid then
        -- Иногда math.huge вызывает проблемы, попробуем очень большое число
        humanoid.MaxHealth = 9e9 
        humanoid.Health = 9e9
        
        local healthChangedConn = humanoid.HealthChanged:Connect(function(newHealth)
            if isGodmodeOn and newHealth < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        table.insert(connections, healthChangedConn) -- Сохраняем соединение, чтобы можно было его отключить
        print("Агрессивный режим: перехват изменения здоровья активен.")
    end
end

-- Логика кнопки
ToggleButton.MouseButton1Click:Connect(function()
    isGodmodeOn = not isGodmodeOn

    if isGodmodeOn then
        ToggleButton.Text = "Бессмертие [ON]"
        ToggleButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
        print("Активация агрессивного бессмертия...")
        if Player.Character then
            applyGodmode(Player.Character)
        end
    else
        ToggleButton.Text = "Бессмертие [OFF]"
        ToggleButton.BorderColor3 = Color3.fromRGB(255, 80, 80)
        disableGodmode()
        print("Агрессивное бессмертие отключено. Требуется возрождение для полного сброса.")
    end
end)

-- Применение на нового персонажа после смерти
Player.CharacterAdded:Connect(function(character)
    if isGodmodeOn then
        print("Персонаж возродился. Повторно применяю агрессивное бессмертие.")
        wait(0.5)
        applyGodmode(character)
    end
end)

print("Скрипт бессмертия v2 (агрессивный) загружен.")
