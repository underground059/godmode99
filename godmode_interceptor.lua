--[[
    Скрипт бессмертия v3: Перехватчик событий (__namecall hook)

    Этот скрипт не меняет здоровье. Вместо этого он перехватывает и блокирует
    сетевые события, которые сообщают серверу о получении урона.
    Сервер не будет знать, что вас атакуют, и не сможет вас убить.
]]

-- Проверяем, поддерживается ли hookmetamethod вашим исполнителем.
if not hookmetamethod then
    error("Ваш исполнитель не поддерживает hookmetamethod. Этот скрипт не будет работать.")
    return
end

-- Имена функций/событий, которые мы хотим заблокировать. 
-- Возможно, этот список придется пополнять.
local BlockedEvents = {
    "Damage",
    "TakeDamage",
    "hit",
    "HIT",
    -- Добавим общие имена, которые могут использоваться для урона
    "DealDamage",
    "Fire", -- Иногда используется для общих событий, включая урон
    "Event" 
}

local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    -- Проверяем, есть ли вызываемый метод в нашем черном списке
    -- table.find может не работать, используем надежный цикл for
    local isBlocked = false
    for _, eventName in ipairs(BlockedEvents) do
        -- Используем tostring и lower для более надежного сравнения
        if tostring(method):lower() == eventName:lower() then
            isBlocked = true
            break
        end
    end

    if isBlocked then
        -- Если метод в списке, мы его блокируем (ничего не делаем и возвращаем nil)
        print("Перехвачено и заблокировано потенциально опасное событие: " .. tostring(method))
        return nil
    end

    -- Если событие не в списке, пропускаем его дальше, чтобы не сломать игру
    return oldNamecall(self, ...)
end)

print("Перехватчик событий для бессмертия активен.")
print("Заблокированные ключевые слова: " .. table.concat(BlockedEvents, ", "))
