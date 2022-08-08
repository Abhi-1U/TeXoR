--[[
Math Filter – Fix Math environments to be MathJax safe
License:   MIT – see LICENSE file for details
--]]

--[[
Applies the filter to Math elements
--]]
function Math(el)
    str_math =  pandoc.utils.stringify(el.text)
    --    if str_math:match'$' then
     --   str_math = str_math:gsub("^{$\\s*", "")
       -- str_math = str_math:gsub("\\s*$}$", "")
    --end
    if str_math:match'mbox' then
        str_math = str_math:gsub("\\mbox", "")
        str_math = str_math:gsub("%$"," ")
    end
    if str_math:match'textup' then
        str_math = str_math:gsub("\\textup", "\\mathrm")
    end
    if str_math:match'boldmath' then
        str_math = str_math:gsub("\\boldmath","\\mathbf")
    end
    print(str_math)
    el.text = str_math
    return(el)
end
