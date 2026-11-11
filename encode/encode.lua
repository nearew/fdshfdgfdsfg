local Obfuscator = {}

local function generateGarbage()
    local garbage = {}
    local varNames = {"_g", "_h", "_j", "_k", "_l", "_m"}
    
    for i = 1, math.random(5, 10) do
        local varName = varNames[math.random(#varNames)] .. tostring(math.random(100, 999))
        local value = math.random(1000, 9999)
        table.insert(garbage, string.format("local %s = %d", varName, value))
        
        if math.random() > 0.5 then
            table.insert(garbage, string.format("if %s > %d then %s = %s + 1 end", varName, math.random(500), varName, varName))
        end
    end
    
    return table.concat(garbage, ";")
end

local function encodeString(str)
    local encoded = {}
    for i = 1, #str do
        local byte = string.byte(str, i)
        table.insert(encoded, string.format("\\%03d", byte))
    end
    return '"' .. table.concat(encoded) .. '"'
end

local function encryptCode(code)
    local encrypted = {}
    for i = 1, #code do
        local byte = string.byte(code, i)
        local shifted = (byte + 13) % 256
        table.insert(encrypted, string.char(shifted))
    end
    return table.concat(encrypted)
end

local function removeSpaces(code)
    code = string.gsub(code, "%s+", "")
    code = string.gsub(code, "(%w)%s+(%w)", "%1%2")
    return code
end

function Obfuscator.obfuscate(inputFile, outputFile)
    local file = io.open(inputFile, "r")
    if not file then
        print("Error: Cannot open input file: " .. inputFile)
        return false
    end
    
    local code = file:read("*all")
    file:close()
    
    local obfuscated = {}
    
    table.insert(obfuscated, "-- Obfuscated with LuaObfuscator")
    table.insert(obfuscated, generateGarbage())
    table.insert(obfuscated, ";")
    
    local encryptedCode = encryptCode(code)
    local encodedData = encodeString(encryptedCode)
    
    local decoder = string.format([[
local _d=function(s)local r=""for i=1,#s,3 do local b=tonumber(string.sub(s,i+1,i+3))r=r..string.char(b)end;return r end;local _e=_d(%s);local _f=function(s)local r=""for i=1,#s do local b=(string.byte(s,i)-13+256)%%256;r=r..string.char(b)end;return r end;loadstring(_f(_e))();]], encodedData)
    
    table.insert(obfuscated, removeSpaces(decoder))
    
    for i = 1, math.random(3, 7) do
        table.insert(obfuscated, ";" .. generateGarbage())
    end
    
    local output = io.open(outputFile, "w")
    if not output then
        print("Error: Cannot create output file: " .. outputFile)
        return false
    end
    
    output:write(table.concat(obfuscated, "\n"))
    output:close()
    
    print("Successfully obfuscated: " .. inputFile .. " -> " .. outputFile)
    return true
end

if arg and arg[1] then
    local input = arg[1]
    Obfuscator.obfuscate(input, input)
else
    print("Usage: lua obfuscator.lua <file.lua>")
end

return Obfuscator
