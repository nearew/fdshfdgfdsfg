# Lua Obfuscator

Обфускатор и деобфускатор для Lua скриптов с загрузкой через GitHub.

## Файлы проекта

| Файл | Описание |
|------|----------|
| `encode.lua` | Обфускатор - шифрует код, добавляет мусор, убирает пробелы |
| `decode.lua` | Деобфускатор - восстанавливает оригинальный код из обфусцированного |
| `executor.lua` | Рантайм - читает обфусцированный файл, деобфусцирует в памяти и выполняет |
| `fetcher.lua` | Загрузчик - скачивает обфусцированный код по URL и выполняет в памяти |
| `launcher.lua` | Одна строка - минимальный код для загрузки и запуска по ссылке |
| `rivals.lua` | Пример обфусцированного скрипта |
| `demo.lua` | Тестовый скрипт для проверки работы |

## Как настроить

### 1. Обфускация кода

```bash
lua encode.lua script.lua
```

Это перезапишет `script.lua` обфусцированной версией.

### 2. Загрузка на GitHub

Загрузи обфусцированный файл в репозиторий и получи raw-ссылку:
```
https://raw.githubusercontent.com/ТВОЙ_USERNAME/ТВОЙ_REPO/main/script.lua
```

### 3. Настройка launcher.lua

Открой `launcher.lua` и замени URL на свой:
```lua
loadstring((function(u)local h=require("socket.http")...end)("https://raw.githubusercontent.com/ТВОЙ_USERNAME/ТВОЙ_REPO/main/script.lua"))()
```

### 4. Использование

**Вариант A - Через launcher (одна строка):**
```lua
-- Вставь содержимое launcher.lua в свой код
```

**Вариант B - Через fetcher:**
```lua
require("fetcher")
```

**Вариант C - Локальный запуск:**
```bash
lua executor.lua script.lua
```

### 5. Деобфускация (для себя)

```bash
lua decode.lua script.lua
```

Восстанавливает оригинальный код из обфусцированного файла.

## Требования

- Lua 5.1+
- Для загрузки с GitHub: `luasocket` (`luarocks install luasocket`)

## Лицензия

MIT
