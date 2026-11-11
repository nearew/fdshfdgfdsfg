local function testObfuscator()
    local Obfuscator = require("obfuscator")
    local Deobfuscator = require("deobfuscator")
    
    local testCode = [[
local function greet(name)
    print("Hello, " .. name)
end

greet("World")
]]
    
    local testFile = io.open("test_input.lua", "w")
    testFile:write(testCode)
    testFile:close()
    
    print("Testing obfuscation...")
    Obfuscator.obfuscate("test_input.lua", "test_obfuscated.lua")
    
    print("\nTesting deobfuscation...")
    Deobfuscator.deobfuscate("test_obfuscated.lua", "test_restored.lua")
    
    local restored = io.open("test_restored.lua", "r")
    if restored then
        local content = restored:read("*all")
        restored:close()
        
        if string.find(content, 'print("Hello, "') then
            print("\n✓ Test passed! Code successfully restored.")
        else
            print("\n✗ Test failed! Restored code doesn't match.")
        end
    else
        print("\n✗ Test failed! Could not read restored file.")
    end
    
    os.remove("test_input.lua")
    os.remove("test_obfuscated.lua")
    os.remove("test_restored.lua")
end

testObfuscator()
