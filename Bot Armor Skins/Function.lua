_G.BotWeapons = _G.BotWeapons or {}

if not BotWeapons then
	dofile("mods/Bot Weapons/lua/botweapons.lua")
end

if not BotWeapons then
	log('[Bot Armor Skins]: No BotWeapons')
	return
end

_G.BotArmorSkins = _G.BotArmorSkins or {}
BotArmorSkins.ModPath = ModPath
BotArmorSkins.SaveFile = BotArmorSkins.SaveFile or SavePath .. "BotArmorSkins.txt"
BotArmorSkins.Skins_List = {}

function BotArmorSkins:Read()
	local _file = io.open(self.SaveFile, "r")
	if _file then
		local _data = tostring(_file:read("*all"))
		self.Skins_List = json.decode(_data)
		_file:close()
	end
end

BotArmorSkins:Read()

function BotArmorSkins:Menu_Armor_Skins(data)
	if not data or type(data) ~= 'table' or not data.henchman_index then
		return
	end
	if not data or data.random then
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins = nil
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins_random = data and data.random and true
	elseif data.name then
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins = data.name
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins_random = nil
	elseif data.unequip then
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins = nil
		managers.blackmarket:henchman_loadout(data.henchman_index).armor_skins_random = nil	
	elseif data.them then
		local new_node_data = {}
		table.insert(new_node_data, {
			name = "bm_menu_armor_skins",
			on_create_func_name = "populate_armor_skins",
			category = "armor_skins",
			override_slots = {
				3,
				3
			},
			identifier = BlackMarketGui.identifiers.armor_skins
		})
		new_node_data.topic_id = "bm_menu_armor_skins"
		new_node_data.panel_grid_w_mul = 0.6
		new_node_data.skip_blur = true
		new_node_data.use_bgs = true
		new_node_data.hide_detection_panel = true
		new_node_data.custom_callback = {
			as_equip = callback(self, self, "Menu_Select_This_Armor_Skins", data.henchman_index)
		}
		managers.menu:open_node("blackmarket_armor_node", {new_node_data})
	end
end

function BotArmorSkins:Menu_Select_This_Armor_Skins(henchman_index, data)
	if data and type(data) == "table" and data.name then 
		self:Menu_Armor_Skins({name = tostring(data.name), henchman_index = henchman_index})
		QuickMenu:new("Armor Skins", "Apply [".. tostring(data.name_localized) .."] to this AI", {text = managers.localization:text("menu_back"), is_cancel_button = true}, true)
	end
end

function BotArmorSkins:Overrides(them, key, value)
	if not them or not key then
		local _file = io.open("mods/Bot Weapons/lua/crewmanagementgui.lua", "r")
		if _file then
			local _data = tostring(_file:read("*all"))
			if _data:find('self:open_armor_category_menu') then
				_data = _data:gsub('self:open_armor_category_menu%(henchman_index%)', 'BotArmorSkins:Overrides(self, "open_armor_category_menu", henchman_index)')
				_file:close()
				_file = io.open("mods/Bot Weapons/lua/crewmanagementgui.lua", "w+")
				_file:write(_data)
				_file:close()
			else
				_file:close()
			end
		end
	end
	if them and key then
		if key == "open_armor_category_menu" then
			them:open_armor_category_menu(value)
			local menu_title = managers.localization:text("menu_action_select_name")
			local menu_message = managers.localization:text("menu_action_select_desc")
			local menu_options = {}
			table.insert(menu_options,
				{
					text = managers.localization:text("menu_action_select_armor_skins_name"),
					callback = function () 
						self:Menu_Armor_Skins({henchman_index = value, them = them})
						them:reload()
					end
				}
			)
			table.insert(menu_options, {})
			table.insert(menu_options,
				{
					text = managers.localization:text("menu_action_random_armor_skins_name"),
					callback = function () 
						self:Menu_Armor_Skins({henchman_index = value, random = true})
						them:reload()
					end
				}
			)
			table.insert(menu_options, {})
			table.insert(menu_options,
				{
					text = managers.localization:text("menu_action_unequip_armor_skins"),
					callback = function () 
						self:Menu_Armor_Skins({henchman_index = value, unequip = true})
						them:reload()
					end
				}
			)
			table.insert(menu_options, {})
			table.insert(menu_options,
				{
					text = managers.localization:text("menu_back"),
					is_cancel_button = true
				}
			)
			QuickMenu:new(menu_title, menu_message, menu_options, true)
		end
	end
end

BotArmorSkins:Overrides()

Hooks:PostHook(MenuSceneManager, "set_henchmen_loadout", "BotArmorSkins__MenuSceneManager_set_henchmen_loadout", function(self, index, character, loadout)
	local unit = self._henchmen_characters[index]
	if not alive(unit) or not BotArmorSkins.Skins_List then
		return
	end
	if managers.menu_scene then
		loadout = BotWeapons:get_loadout(character, loadout or managers.blackmarket:henchman_loadout(index), true)
		if not loadout.armor_skins and not loadout.armor_skins_random then
		
		elseif loadout.armor_skins_random then
			local Get_This_Skins = tostring(BotArmorSkins.Skins_List[math.random(#BotArmorSkins.Skins_List)])
			managers.menu_scene:set_character_armor_skin(Get_This_Skins, unit)
		elseif loadout.armor_skins and not loadout.armor_skins_random then
			managers.menu_scene:set_character_armor_skin(loadout.armor_skins, unit)
		end
		return
	end
	--[[
	if unit:base()._armor_skin.set_cosmetics_data then
		unit:base()._armor_skin:set_cosmetics_data(Get_This_Skins, true)
		unit:base()._armor_skin:_apply_cosmetics()
		unit:base()._armor_skin._request_update = nil
	end
	]]
end)

Hooks:PostHook(BotWeapons, "set_armor", "BotArmorSkins__BotWeapons_set_armor", function(self, unit, ...)
	if not BotArmorSkins.Skins_List or not managers.criminals or managers.menu_scene then
		return
	end
	local loadout = managers.criminals:get_loadout_for(unit:base()._tweak_table)
	if not loadout or (not loadout.armor_skins and not loadout.armor_skins_random) then
		
	elseif loadout.armor_skins_random then
		local Get_This_Skins = tostring(BotArmorSkins.Skins_List[math.random(#BotArmorSkins.Skins_List)])
		unit:base()._armor_skin:set_cosmetics_data(Get_This_Skins, true)
		unit:base()._armor_skin:_apply_cosmetics()
		unit:base()._armor_skin._request_update = nil
	elseif loadout.armor_skins and not loadout.armor_skins_random then
		unit:base()._armor_skin:set_cosmetics_data(loadout.armor_skins, true)
		unit:base()._armor_skin:_apply_cosmetics()
		unit:base()._armor_skin._request_update = nil
	end
end)

Hooks:Add("LocalizationManagerPostInit", "BotArmorSkins_loc", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_action_select_armor_skins_name"] = "Select Armor Skins",
		["menu_action_random_armor_skins_name"] = "Random Armor Skins",
		["menu_action_unequip_armor_skins"] = "Unequip Armor Skins",
	})
end)