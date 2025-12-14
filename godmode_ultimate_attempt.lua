--[[
    Скрипт бессмертия: Ultimate Attempt (Агрессивное уничтожение + Скрытие UI)

    Этот скрипт объединяет все наши знания для максимально агрессивного
    клиентского подхода:
    1. Постоянно и агрессивно уничтожает скрипт 'Health'.
    2. Устанавливает Humanoid.MaxHealth и Humanoid.Health на очень большое значение.
    3. Скрывает полоску здоровья Humanoid.
    4. Подписывается на Humanoid.HealthChanged для мгновенного восстановления.
]]

local Player = game.Players.LocalPlayer
local connections = {} -- Для отслеживания подключений HealthChanged

-- Функция для очистки старых подключений к событиям
local function disconnectAllConnections()
    for _, conn in ipairs(connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(connections)
    print("Все подключения Humanoid.HealthChanged отключены.")
end

-- Функция активации бессмертия для персонажа
local function activateGodmode(character)
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- Тактика 1: Агрессивное, постоянное уничтожение скрипта Health
    -- Запускаем в отдельном потоке, чтобы не блокировать основной скрипт
    local destroyThread = coroutine.create(function()
        while character and character.Parent == game.Workspace do 
            local healthScript = character:FindFirstChild("Health")
            if healthScript and (healthScript:IsA("LocalScript") or healthScript:IsA("Script")) then
                print("Агрессивно уничтожаю скрипт 'Health': " .. healthScript.Name)
                healthScript:Destroy()
            end
            task.wait(0.1) -- Небольшая задержка, чтобы не нагружать систему
        end
        print("Поток уничтожения скрипта 'Health' завершен.")
    end)
    coroutine.resume(destroyThread)

    if humanoid then
        -- Отключаем старые подключения перед созданием новых
        disconnectAllConnections() 

        -- Тактика 2: Устанавливаем здоровье на очень большое число
        humanoid.MaxHealth = 9e9 -- 9 миллиардов
        humanoid.Health = 9e9
        print("Humanoid.MaxHealth и Humanoid.Health установлены на максимум.")

        -- Тактика 3: Скрываем полоску здоровья (UI)
        -- Enum.HumanoidDisplayDistanceType.None скрывает имя и полоску здоровья
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None 
        print("Полоска здоровья скрыта.")

        -- Тактика 4: Мгновенно восстанавливаем здоровье, если оно все-таки изменится
        local healthChangedConn = humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        table.insert(connections, healthChangedConn) -- Сохраняем подключение
        print("Humanoid.HealthChanged перехватчик активен.")
    end
end

-- Запускаем при появлении нового персонажа (после смерти/спавна)
Player.CharacterAdded:Connect(function(character)
    print("Новый персонаж появился. Активирую функции бессмертия.")
    task.wait(0.5) -- Даем игре время на инициализацию
    activateGodmode(character)
end)

-- Запускаем для текущего персонажа, если скрипт загружен уже после спавна
if Player.Character then
    print("Персонаж уже существует. Активирую функции бессмертия.")
    activateGodmode(Player.Character)
end

print("God Mode Ultimate Attempt скрипт загружен.")
