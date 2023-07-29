--[[
Image numbering filter V3 - Numbering Images in caption
License:   MIT - see LICENSE file for details
adapted from: Albert Krewinkel implementation
original License: CC0
Pandoc : > 3.0
--]]

-- Image counter variable
figures = 0
-- Algorithm counter variable
algorithms = 0
-- codeblock counter variable
codes = 0
-- widetables counter variable
wdtables = 0
is_alg = 0
-- temp variable to check for figure image
is_fig = 0
-- temp variable to check for code block
is_code = 0
-- temp variable to check for widetable
is_wdtable = 0

tikz_syle = 0
-- para filter for tikz content
p_filter = {
    Para = function(el)
        string_el = pandoc.utils.stringify(el)
        if string_el:find('^(= %[)') then
            print("removing leftover tikz style")
            print(el.content)
            el.content = pandoc.Plain( pandoc.Space())
            print(el.content)
            return el
        end
        return el
    end
}
--[[
Applies the filter to Image elements
--]]
filter = {
 Image = function(el)
 	if el.src:match('alg/') then
        is_alg = 1
        is_fig = 0
    else
        is_fig = 1
        is_alg = 0
    end
 end,
 Para = function(el)
        string_el = pandoc.utils.stringify(el)
        if string_el:find('^(= %[)') then
            tikz_style = 1
        end
 end,
CodeBlock = function(el)
        is_code = 1
end,
Table = function(el)
        is_wdtable = 1
end
}

function Figure(el)
    local label = ""
    pandoc.walk_block(el,filter)
    if is_alg == 1 then
    	algorithms = algorithms + 1
    	label = "Algorithm " .. tostring(algorithms) .. ":"
    end
    if is_fig == 1 and is_alg == 0 then
    	figures = figures + 1
    	label = "Figure " .. tostring(figures) .. ":"
    end
    if is_code == 1 and is_fig == 0 and is_alg == 0 then
        codes = codes + 1
    	label = "CodeBlock " .. tostring(codes) .. ":"
    end
    if is_wdtable == 1 and is_code == 0 and is_fig == 0 and is_alg == 0 then
        wdtables = wdtables + 1
    	label = "WideTable " .. tostring(wdtables) .. ":"
    end
    local caption = pandoc.utils.stringify(el.caption)
    if not caption then
      -- Figure has no caption, just add the label
      caption = label
    else
      caption = label .. " " .. caption
    end
    if tikz_style == 1 then
        print(el.content[2])
        if pandoc.utils.stringify(el.content[2]):match('^(= %[)') then
            print("removing leftover tikz style")
            el.content[2] = pandoc.Plain( pandoc.Space())
        end
        print(el.content[2])
        tikz_style = 0
    end
    el.caption.long[1] = caption
    is_fig = 0
    is_alg = 0
    is_code = 0
    is_wdtable = 0
    return el
end

function Image(el)
    local old_attr = el.attributes[1]
    if old_attr == nil then
        -- Figure has no attributes
        el.attributes[1] = {"width", "100%"}
    else
        -- Add label as plain block element
        attribute_1 = el.attributes
        if el.attributes[1][2]:match('%\\') then
            local width = tonumber(attribute_1[1][2]:match('%d+.%d+'))
            if(attribute_1[1][2]:match('%d+.%d+') == nil) then
                el.attributes[1] = {"width", "100%"}
            else
                width_as_percent = tostring(width*100)
                el.attributes[1] = {"width", width_as_percent .. [[%]]}
            end
        else
            --pass
        end
    end
    return el
end
