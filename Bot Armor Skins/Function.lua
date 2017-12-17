_G.BotWeapons = _G.BotWeapons or {}

Hooks:Add("LocalizationManagerPostInit", "BotArmorSkins_loc", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_action_select_armor_skins_name"] = "Select Armor Skins",
		["menu_action_random_armor_skins_name"] = "Random Armor Skins",
		["menu_action_unequip_armor_skins"] = "Unequip Armor Skins",
	})
end)

_G.BotArmorSkins = _G.BotArmorSkins or {}
BotArmorSkins.ModPath = ModPath
BotArmorSkins.SaveFile = BotArmorSkins.SaveFile or SavePath .. "BotArmorSkins.txt"
BotArmorSkins.Skins_List = json.decode('["ast_armor6","cas_gensec","drm_tree_stump","none","ast_armor1","drm_somber_woodland","cvc_avenger","cvc_bone","ast_armor4","ast_armor2","cvc_tan","drm_khaki_eclipse","cas_miami","drm_desert_tech","cas_m90","drm_misted_grey","drm_navy_breeze","cas_police","drm_gray_raider","ast_armor5","cvc_swat","cvc_grey","cvc_green","ast_armor3","cvc_woodland_camo","cvc_black","cvc_desert_camo","cvc_city_camo","drm_desert_twilight","cas_trash","drm_khaki_regular","drm_woodland_tech","cas_slayer","cvc_navy_blue"]')

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

if CrewManagementGui then
	Hooks:PostHook(CrewManagementGui, "open_armor_category_menu", "BotArmorSkins:Overrides", function(them, value)
		local menu_title = managers.localization:text("menu_action_select_name")
		local menu_message = managers.localization:text("menu_action_select_desc")
		local menu_options = {}
		table.insert(menu_options,
			{
				text = managers.localization:text("menu_action_select_armor_skins_name"),
				callback = function () 
					BotArmorSkins:Menu_Armor_Skins({henchman_index = value, them = them})
					them:reload()
				end
			}
		)
		table.insert(menu_options, {})
		table.insert(menu_options,
			{
				text = managers.localization:text("menu_action_random_armor_skins_name"),
				callback = function () 
					BotArmorSkins:Menu_Armor_Skins({henchman_index = value, random = true})
					them:reload()
				end
			}
		)
		table.insert(menu_options, {})
		table.insert(menu_options,
			{
				text = managers.localization:text("menu_action_unequip_armor_skins"),
				callback = function () 
					BotArmorSkins:Menu_Armor_Skins({henchman_index = value, unequip = true})
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
	end)
end

function BotArmorSkins:special_materials_fix(unit, character_id, data)
	character_id = CriminalsManager.convert_old_to_new_character_workname(character_id)
	if tweak_data.blackmarket.characters[character_id] and tweak_data.blackmarket.characters[character_id].special_materials then
		local special_material = nil
		local special_materials = tweak_data.blackmarket.characters[character_id].special_materials
		for sequence, chance in pairs(special_materials) do
			if type(chance) == "number" then
				local rand = math.rand(chance)
				if rand <= 1 then
					special_material = sequence
					break
				end
			end
		end
		special_material = special_material or table.random(special_materials)
		special_material = special_material .. "_cc"
		local special_material_ids = Idstring(special_material)
		if not DB:has(Idstring("material_config"), special_material_ids) then
		
		else
			unit:set_material_config(special_material_ids, true)
		end
	else
		local shared_char_seq = nil
		shared_char_seq = tweak_data.blackmarket.characters.locked[character_id] and tweak_data.blackmarket.characters.locked[character_id].sequence or tweak_data.blackmarket.characters[character_id] and tweak_data.blackmarket.characters[character_id].sequence
		
		local cc_sequences = {
			"var_mtr_chains",
			"var_mtr_dallas",
			"var_mtr_hoxton",
			"var_mtr_dragan",
			"var_mtr_jacket",
			"var_mtr_old_hoxton",
			"var_mtr_wolf",
			"var_mtr_john_wick",
			"var_mtr_sokol",
			"var_mtr_jiro",
			"var_mtr_bodhi",
			"var_mtr_jimmy"
		}
		
		if table.contains(cc_sequences, shared_char_seq) then
			shared_char_seq = shared_char_seq .. "_cc"
			log("shared_char_seq: "..shared_char_seq)
		end
	end
		
	call_on_next_update(function ()
		if type(shared_char_seq) == "string" then
			unit:damage():run_sequence_simple(shared_char_seq)
		end
		if type(data) == "string" then
			unit:base()._bot_armor_skin:set_cosmetics_data(data, true)
			unit:base()._bot_armor_skin:_apply_cosmetics()
			unit:base()._bot_armor_skin._request_update = nil
		end
	end)
end