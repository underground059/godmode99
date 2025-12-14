--[[
    GUI для бессмертия в "99 night in the forest"
    Стратегия:
    1. Найти и отключить кастомный скрипт "Health".
    2. Установить стандартное здоровье Humanoid на бесконечность.
    3. Повторять при каждом возрождении персонажа, если функция активна.
]]

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isGodmodeOn = false -- Переменная для отслеживания состояния

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false -- GUI не будет пропадать после смерти

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Position = UDim2.new(1, -160, 0, 10) -- Правый верхний угол
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 80, 80)
ToggleButton.BorderSizePixel = 2
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Text = "Бессмертие [OFF]"

-- Основная функция для активации бессмертия
local function applyGodmode(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local customHealthScript = character:FindFirstChild("Health")

    -- Шаг 1: Отключаем кастомный скрипт здоровья, если он есть
    if customHealthScript then
        print("Найден кастомный скрипт 'Health'. Отключаю.")
        customHealthScript.Disabled = true
    else
        print("Кастомный скрипт 'Health' не найден.")
    end

    -- Шаг 2: Устанавливаем здоровье Humanoid на бесконечность
    if humanoid then
        print("Устанавливаю здоровье на бесконечность.")
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

-- Функция для кнопки
ToggleButton.MouseButton1Click:Connect(function()
    isGodmodeOn = not isGodmodeOn -- Меняем состояние (вкл/выкл)

    if isGodmodeOn then
        ToggleButton.Text = "Бессмертие [ON]"
        ToggleButton.BorderColor3 = Color3.fromRGB(80, 255, 80) -- Зеленая рамка
        -- Применяем на текущего персонажа
        if Player.Character then
            applyGodmode(Player.Character)
        end
    else
        ToggleButton.Text = "Бессмертие [OFF]"
        ToggleButton.BorderColor3 = Color3.fromRGB(255, 80, 80) -- Красная рамка
        print("Бессмертие отключено. Для полного сброса может потребоваться перезаход или смерть.")
    end
end)

-- Следим за появлением нового персонажа (после смерти)
Player.CharacterAdded:Connect(function(character)
    -- Если бессмертие было включено, применяем его на нового персонажа
    if isGodmodeOn then
        print("Персонаж возродился. Повторно применяю бессмертие.")
        wait(0.5) -- Даем игре время создать все скрипты
        applyGodmode(character)
    end
end)

print("Скрипт бессмертия с GUI загружен.")