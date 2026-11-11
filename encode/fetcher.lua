local http = require("socket.http") or require("http")
local ltn12 = require("ltn12")

local function decodeString(encoded)
    local decoded = ""
    local i = 1
    while i <= #encoded do
        if string.sub(encoded, i, i) == "\\" then
            local byteStr = string.sub(encoded, i + 1, i + 3)
            local byte = tonumber(byteStr)
            if byte then
                decoded = decoded .. string.char(byte)
                i = i + 4
            else
                decoded = decoded .. string.sub(encoded, i, i)
                i = i + 1
            end
        else
            decoded = decoded .. string.sub(encoded, i, i)
            i = i + 1
        end
    end
    return decoded
end

local function decryptCode(encrypted)
    local decrypted = {}
    for i = 1, #encrypted do
        local byte = string.byte(encrypted, i)
        local shifted = (byte - 13 + 256) % 256
        table.insert(decrypted, string.char(shifted))
    end
    return table.concat(decrypted)
end

local function extractEncodedData(code)
    local pattern = 'local _d=function%(s%)local r=""for i=1,#s,3 do local b=tonumber%(string%.sub%(s,i%+1,i%+3%)%)r=r%.%.string%.char%(b%)end;return r end;local _e=_d%("([^"]+)"%)'
    local encoded = string.match(code, pattern)
    
    if not encoded then
        pattern = '_d%("([^"]+)"%)'
        encoded = string.match(code, pattern)
    end
    
    return encoded
end

local function fetchURL(url)
    local response = {}
    local success, status = http.request{
        url = url,
        sink = ltn12.sink.table(response)
    }
    
    if not success then
        return nil
    end
    
    return table.concat(response)
end

local OBFUSCATED_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/script.lua"

local code = fetchURL(OBFUSCATED_URL)
if not code then
    print("Error: Cannot fetch obfuscated code")
    return
end

local encodedData = extractEncodedData(code)
if not encodedData then
    print("Error: Could not extract encoded data")
    return
end

local decodedData = decodeString(encodedData)
local decryptedCode = decryptCode(decodedData)

local func, err = loadstring(decryptedCode)
if not func then
    print("Error loading code: " .. tostring(err))
    return
end

local success, result = pcall(func)
if not success then
    print("Error executing code: " .. tostring(result))
    return
end
