local Runtime = {}

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

function Runtime.executeURL(url)
    local http = require("socket.http") or require("http")
    local ltn12 = require("ltn12")
    
    local response = {}
    local success, status, headers = http.request{
        url = url,
        sink = ltn12.sink.table(response)
    }
    
    if not success then
        print("Error: Cannot fetch URL: " .. url)
        return false
    end
    
    local code = table.concat(response)
    
    local encodedData = extractEncodedData(code)
    if not encodedData then
        print("Error: Could not extract encoded data from URL")
        return false
    end
    
    local decodedData = decodeString(encodedData)
    local decryptedCode = decryptCode(decodedData)
    
    local func, err = loadstring(decryptedCode)
    if not func then
        print("Error loading code: " .. tostring(err))
        return false
    end
    
    local success, result = pcall(func)
    if not success then
        print("Error executing code: " .. tostring(result))
        return false
    end
    
    return result
end

function Runtime.loadURL(url)
    local http = require("socket.http") or require("http")
    local ltn12 = require("ltn12")
    
    local response = {}
    local success, status, headers = http.request{
        url = url,
        sink = ltn12.sink.table(response)
    }
    
    if not success then
        print("Error: Cannot fetch URL: " .. url)
        return nil
    end
    
    local code = table.concat(response)
    
    local encodedData = extractEncodedData(code)
    if not encodedData then
        print("Error: Could not extract encoded data from URL")
        return nil
    end
    
    local decodedData = decodeString(encodedData)
    local decryptedCode = decryptCode(decodedData)
    
    local func, err = loadstring(decryptedCode)
    if not func then
        print("Error loading code: " .. tostring(err))
        return nil
    end
    
    return func
end

function Runtime.execute(obfuscatedFile)
    local file = io.open(obfuscatedFile, "r")
    if not file then
        print("Error: Cannot open file: " .. obfuscatedFile)
        return false
    end
    
    local code = file:read("*all")
    file:close()
    
    local encodedData = extractEncodedData(code)
    if not encodedData then
        print("Error: Could not extract encoded data")
        return false
    end
    
    local decodedData = decodeString(encodedData)
    local decryptedCode = decryptCode(decodedData)
    
    local func, err = loadstring(decryptedCode)
    if not func then
        print("Error loading code: " .. tostring(err))
        return false
    end
    
    local success, result = pcall(func)
    if not success then
        print("Error executing code: " .. tostring(result))
        return false
    end
    
    return result
end

if arg and arg[1] then
    if string.match(arg[1], "^https?://") then
        Runtime.executeURL(arg[1])
    else
        Runtime.execute(arg[1])
    end
else
    print("Usage: lua runtime.lua <file.lua or URL>")
end

return Runtime
