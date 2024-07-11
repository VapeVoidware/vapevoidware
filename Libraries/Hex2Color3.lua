local LibraryFunctions = {}
LibraryFunctions.GetColor3 = function(hex)
    hex = hex and string.gsub(hex, "#", "") or "FFFFFF"
    return Color3.fromRGB(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

LibraryFunctions.UnpackColor3 = function(hex)
    hex = hex and string.gsub(hex, "#", "") or "FFFFFF"
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

return LibraryFunctions