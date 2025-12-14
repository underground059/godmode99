--[[
    Скрипт бессмертия v3: Целевое отключение клиентского скрипта Health

    Стратегия:
    1. Создаем GUI-кнопку для управления бессмертием.
    2. При активации/возрождении персонажа:
        a. Находим и отключаем клиентский скрипт 'Health' (который находится в StarterCharacterScripts).
        b. Устанавливаем Humanoid.MaxHealth и Humanoid.Health на очень большое значение.
        c. Подписываемся на событие HealthChanged Humanoid'а, чтобы мгновенно восстанавливать здоровье.
]]

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isGodmodeOn = false
local connections = {} -- Таблица для хранения активных подключений к событиям

-- Создание GUI
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

-- Функция для очистки старых подключений к событиям
local function disableGodmodeConnections()
    for _, conn in ipairs(connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(connections)
    print("Отключены подключения к Humanoid.HealthChanged.")
end

-- Функция для применения бессмертия к персонажу
local function applyGodmodeToCharacter(character)
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    -- Ждем до 5 секунд появления скрипта Health в персонаже
    local customHealthScript = character:WaitForChild("Health", 5) 

    if customHealthScript then
        -- Убеждаемся, что это действительно скрипт, прежде чем отключать
        if customHealthScript:IsA("LocalScript") or customHealthScript:IsA("Script") then
            print("Найден клиентский скрипт 'Health' в персонаже. Отключаю его.")
            customHealthScript.Disabled = true
        else
            print("'Health' найден, но это не скрипт. Не отключаем.")
        end
    else
        print("Клиентский скрипт 'Health' не найден в персонаже за 5 секунд.")
    end

    if humanoid then
        -- Устанавливаем здоровье на очень большое число
        humanoid.MaxHealth = 9e9 -- 9 миллиардов
        humanoid.Health = 9e9
        
        -- Очищаем предыдущие подключения, чтобы избежать дублирования
        disableGodmodeConnections()

        -- Подключаемся к событию HealthChanged для мгновенного восстановления
        local healthChangedConn = humanoid.HealthChanged:Connect(function(newHealth)
            if isGodmodeOn and newHealth < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        table.insert(connections, healthChangedConn) -- Сохраняем подключение
        print("Humanoid.HealthChanged перехват активен.")
    end
end

-- Логика кнопки
ToggleButton.MouseButton1Click:Connect(function()
    isGodmodeOn = not isGodmodeOn

    if isGodmodeOn then
        ToggleButton.Text = "Бессмертие [ON]"
        ToggleButton.BorderColor3 = Color3.fromRGB(80, 255, 80)
        print("Активация бессмертия...")
        if Player.Character then
            applyGodmodeToCharacter(Player.Character)
        end
    else
        ToggleButton.Text = "Бессмертие [OFF]"
        ToggleButton.BorderColor3 = Color3.fromRGB(255, 80, 80)
        disableGodmodeConnections() -- Отключаем все, когда выключаем
        print("Бессмертие отключено. Возможно, потребуется возрождение для полного сброса.")
    end
end)

-- Обработка возрождения персонажа
Player.CharacterAdded:Connect(function(character)
    if isGodmodeOn then
        print("Персонаж возродился. Применяю бессмертие к новому персонажу.")
        -- Даем игре немного времени для копирования StarterCharacterScripts
        task.wait(0.5) 
        applyGodmodeToCharacter(character)
    end
end)

print("Скрипт бессмертия v3 (целевое отключение Health) загружен.")
