local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

-- local item_manager_t = sdk.find_type_definition('app.ItemManager')
-- sdk.hook(
--     item_manager_t:get_method(
--         'getItem(System.Int32, System.Int32, app.CharacterID, System.Boolean, System.Boolean, System.Boolean, app.ItemManager.GetItemEventType)'),
--     function(args)
--         log.debug(sdk.to_int64(args[3]))
--     end,
--     function(retval)
--         return retval
--     end
-- )

re.on_draw_ui(function()
    if imgui.tree_node('Inf Item') then
        if imgui.button('Get Ferrystone') then
            local character_manager = sdk.get_managed_singleton('app.CharacterManager')
            local human = character_manager:call('get_ManualPlayerHuman()')

            local item_manager = sdk.get_managed_singleton('app.ItemManager')
            item_manager:call('getItem', 80, 1, item_manager:call('getCharaId(app.Character)', human:call('get_Chara()')),
                true, false, false, 2)
        end

        if imgui.button('Get Portcrystal') then
            local character_manager = sdk.get_managed_singleton('app.CharacterManager')
            local human = character_manager:call('get_ManualPlayerHuman()')

            local item_manager = sdk.get_managed_singleton('app.ItemManager')
            item_manager:call('getItem', 81, 1, item_manager:call('getCharaId(app.Character)', human:call('get_Chara()')),
                true, false, false, 2)
        end
    end
end)
