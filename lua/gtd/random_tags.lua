local M = {}

M.map_base_62_digit_to_char = function(digit)
    if digit < 0 or digit >= 62 then
        error("Value is not between 0 and 61, inclusive: " .. digit)
    end

    local n_numerals = 10
    local n_alpha_lower = 26
    local n_alpha_upper = 26
    if digit < n_numerals then
        return string.char(string.byte("0") + digit)
    elseif digit < n_numerals + n_alpha_lower then
        return string.char(string.byte("a") + digit - n_numerals)
    elseif digit < n_numerals + n_alpha_lower + n_alpha_upper then
        return string.char(string.byte("A") + digit - n_numerals - n_alpha_lower)
    end
end

M.base10_to_base62 = function(base10_number)
    local base = 62
    local base62_digits = {}
    while base10_number ~= 0 do
        local rem = base10_number % base
        table.insert(base62_digits, 1, rem)
        base10_number = math.floor(base10_number / base)
    end
    return base62_digits
end

M.base10_to_base62_str = function(base10_number)
    local base62_digits = M.base10_to_base62(base10_number)
    local base62_chars = {}
    for _, digit in ipairs(base62_digits) do
        table.insert(base62_chars, M.map_base_62_digit_to_char(digit))
    end
    return table.concat(base62_chars)
end

M.generate_random_tag = function()
    return M.base10_to_base62_str(math.random(62 ^ 7, 62 ^ 8))
end

--- Append a concealed random tag, if not already present
---@param line string
---@return string
M.ensure_tagged = function(line)
    local tag_pattern = "%[%]%([%a%d]+%)"
    local _, end_ix = line:find(tag_pattern)

    if end_ix ~= #line then
        print("Warning: apparent tag is not at end of line")
    end

    if end_ix ~= nil then
        return line
    end

    return string.format("%s [](%s)", line, M.generate_random_tag())
end

return M
