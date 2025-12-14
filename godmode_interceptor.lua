--[[
    Скрипт бессмертия v4: Перехватчик событий (__namecall hook)

    Финальная версия, нацеленная на блокировку сетевых сообщений об уроне.
    Этот скрипт не меняет здоровье и не отключает другие скрипты. Он работает
    на более низком уровне, перехватывая и блокируя исходящие "жалобы" на урон,
    прежде чем они будут отправлены на сервер.
]]

-- Проверяем, поддерживается ли hookmetamethod вашим исполнителем.
if not hookmetamethod then
    getgenv().warn = getgenv().warn or print
    warn("!!! ВНИМАНИЕ: Ваш исполнитель не поддерживает hookmetamethod. Этот скрипт не будет работать. !!!")
    return
end

-- Имена функций/событий, которые мы хотим заблокировать.
-- Это наш "черный список" для сообщений об уроне.
local BlockedEvents = {
    "Damage",
    "TakeDamage",
    "hit",
    "HIT",
    "DealDamage",
    -- В некоторых играх событие может называться просто "Event" или "Remote"
    "FireServer", -- Блокируем общее название функции отправки
    "Send",
    "UpdateHealth"
}

-- Создаем копию оригинальной функции, чтобы не сломать всю игру
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    -- Получаем имя вызываемого метода/события
    local method = getnamecallmethod()
    
    -- Проверяем, есть ли оно в нашем черном списке
    local isBlocked = false
    for _, eventName in ipairs(BlockedEvents) do
        -- Сравниваем без учета регистра для большей надежности
        if string.lower(tostring(method)) == string.lower(eventName) then
            isBlocked = true
            break
        end
    end

    if isBlocked then
        -- Если метод в списке, мы его блокируем (ничего не делаем и возвращаем nil)
        -- Это не дает сообщению уйти на сервер
        print("Перехвачено и заблокировано событие урона: " .. tostring(method))
        return nil
    end

    -- Если событие "чистое", пропускаем его дальше к оригинальной функции,
    -- чтобы не сломать другие механики игры (чат, движение и т.д.)
    return oldNamecall(self, ...)
end)

print("ФИНАЛЬНАЯ ВЕРСИЯ: Перехватчик событий для бессмертия активен.")
print("Заблокированные ключевые слова: " .. table.concat(BlockedEvents, ", "))
