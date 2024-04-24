local utils = {}

function utils.tbl_merge(...)
    local result = {}
    local args = { ... }
    for _, t in ipairs(args) do
        if type(t) == 'table' then
            for k, v in pairs(t) do
                if type(result[k]) == 'table' and type(v) == 'table' then
                    result[k] = utils.tbl_merge(result[k], v)
                else
                    result[k] = v
                end
            end
        else
            error("invalid value")
        end
    end
    return result
end

return utils

