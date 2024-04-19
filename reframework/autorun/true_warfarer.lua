local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('true_warfarer.json') or {}
config = utils.tbl_merge({}, config)

re.on_draw_ui(function()
    -- TODO: impl
end)
re.on_config_save(function() json.dump_file('true_warfarer.json', config) end)
