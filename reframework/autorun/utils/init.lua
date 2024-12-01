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

function utils.func_cache(f)
    local val = nil
    return function()
        if val == nil then
            val = f()
        end
        return val
    end
end

function utils.sequence(st, ed)
    local tmp = {}
    for i = st, ed - 1 do
        tmp[#tmp + 1] = i
    end
    return tmp
end

function utils.transform(seq, f)
    local tmp = {}
    for idx, val in pairs(seq) do
        tmp[idx] = f(val)
    end
    return tmp
end

return utils
