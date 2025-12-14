--[[
    Скрипт бессмертия: Финальная попытка (Замена .Source)

    Стратегия:
    Это последняя попытка, основанная на гипотезе, что мы можем успеть
    изменить исходный код ("Source") вредоносного скрипта "Health"
    на пустой, прежде чем он успеет выполниться.
]]

local Player = game.Players.LocalPlayer

local function neutralizeHealthScript(character)
    if not character then return end
    
    -- Ждем появления скрипта Health
    local healthScript = character:WaitForChild("Health", 5)
    
    if healthScript and healthScript:IsA("LocalScript") then
        print("Обнаружен скрипт 'Health'. Запускаю протокол нейтрализации...")
        
        -- Заворачиваем в pcall, так как свойство .Source часто защищено
        local success, result = pcall(function()
            -- Заменяем код скрипта на комментарий. Это делает его безвредным.
            healthScript.Source = "--[[ Скрипт был нейтрализован ]]"
        end)
        
        if success then
            print("УСПЕХ! Содержимое скрипта 'Health' было стерто.")
            -- Дополнительно отключаем его на всякий случай
            healthScript.Disabled = true
        else
            print("ПРЕДУПРЕЖДЕНИЕ: Не удалось изменить .Source скрипта 'Health'.")
            print("Это свойство, скорее всего, защищено от записи.")
            print("Ошибка: " .. tostring(result))
            print("Пытаюсь применить старый метод отключения...")
            healthScript.Disabled = true -- Как запасной вариант
        end
    else
        print("Скрипт 'Health' не найден в персонаже.")
    end

    -- На всякий случай также применяем старый метод смены здоровья
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = 9e9
        humanoid.Health = 9e9
    end
end

-- Подключаем функцию к событию возрождения персонажа
Player.CharacterAdded:Connect(neutralizeHealthScript)

-- Также запускаем для текущего персонажа, если он уже существует
if Player.Character then
    neutralizeHealthScript(Player.Character)
end

print("Загружена финальная попытка скрипта бессмертия (замена .Source).")
