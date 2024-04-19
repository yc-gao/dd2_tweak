local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('true_warfarer.json') or {}
config = utils.tbl_merge({
    currentPreset = 0,
    presetSet = {}
}, config)

local gui_manager = sdk.get_managed_singleton('app.GuiManager')

local character_manager = sdk.get_managed_singleton('app.CharacterManager')
local manual_player = character_manager:get_ManualPlayer()
local human = manual_player:get_human()

local job_context = human:get_JobContext()
local skill_context = human:get_SkillContext()

re.on_draw_ui(function()
    -- TODO: impl
    if imgui.tree_node('True Warfarer') then
    end
end)
re.on_config_save(function() json.dump_file('true_warfarer.json', config) end)
