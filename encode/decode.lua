local Deobfuscator = {}

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

local function removeGarbage(code)
    code = string.gsub(code, "local _g%d+=%d+;?", "")
    code = string.gsub(code, "local _h%d+=%d+;?", "")
    code = string.gsub(code, "local _j%d+=%d+;?", "")
    code = string.gsub(code, "local _k%d+=%d+;?", "")
    code = string.gsub(code, "local _l%d+=%d+;?", "")
    code = string.gsub(code, "local _m%d+=%d+;?", "")
    code = string.gsub(code, "if _%a%d+>%d+ then _%a%d+=_%a%d+%+1 end;?", "")
    code = string.gsub(code, "%-%- Obfuscated with LuaObfuscator", "")
    return code
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

function Deobfuscator.deobfuscate(inputFile, outputFile)
    local file = io.open(inputFile, "r")
    if not file then
        print("Error: Cannot open input file: " .. inputFile)
        return false
    end
    
    local code = file:read("*all")
    file:close()
    
    if not string.find(code, "Obfuscated with LuaObfuscator") then
        print("Warning: File does not appear to be obfuscated with this tool")
    end
    
    local encodedData = extractEncodedData(code)
    if not encodedData then
        print("Error: Could not extract encoded data from obfuscated file")
        return false
    end
    
    local decodedData = decodeString(encodedData)
    local decryptedCode = decryptCode(decodedData)
    
    local output = io.open(outputFile, "w")
    if not output then
        print("Error: Cannot create output file: " .. outputFile)
        return false
    end
    
    output:write(decryptedCode)
    output:close()
    
    print("Successfully deobfuscated: " .. inputFile .. " -> " .. outputFile)
    return true
end

if arg and arg[1] then
    local input = arg[1]
    Deobfuscator.deobfuscate(input, input)
else
    print("Usage: lua deobfuscator.lua <file.lua>")
end

return Deobfuscator
