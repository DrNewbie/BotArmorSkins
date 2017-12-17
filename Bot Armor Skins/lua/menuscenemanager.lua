_G.BotArmorSkins = _G.BotArmorSkins or {}
BotArmorSkins.Skins_List = json.decode('["ast_armor6","cas_gensec","drm_tree_stump","none","ast_armor1","drm_somber_woodland","cvc_avenger","cvc_bone","ast_armor4","ast_armor2","cvc_tan","drm_khaki_eclipse","cas_miami","drm_desert_tech","cas_m90","drm_misted_grey","drm_navy_breeze","cas_police","drm_gray_raider","ast_armor5","cvc_swat","cvc_grey","cvc_green","ast_armor3","cvc_woodland_camo","cvc_black","cvc_desert_camo","cvc_city_camo","drm_desert_twilight","cas_trash","drm_khaki_regular","drm_woodland_tech","cas_slayer","cvc_navy_blue"]')

Hooks:PostHook(MenuSceneManager, "_select_henchmen_pose", "BotArmorSkins_MenuSceneManager", function(self, unit, weapon_id, index)
	local loadout = loadout or managers.blackmarket:henchman_loadout(index)
	if loadout then
		local Get_This_Skins = ""
		if not loadout.armor_skins and not loadout.armor_skins_random then
		
		elseif loadout.armor_skins_random then
			Get_This_Skins = tostring(BotArmorSkins.Skins_List[math.random(#BotArmorSkins.Skins_List)])
		elseif loadout.armor_skins and not loadout.armor_skins_random then
			Get_This_Skins = loadout.armor_skins
		end
		if Get_This_Skins ~= "" then
			for character_id, data in pairs(tweak_data.blackmarket.characters) do
				if Idstring(tostring(data.menu_unit)) == unit:name() then
					BotArmorSkins:special_materials_fix(unit, character_id)
					break
				end
			end
			DelayedCalls:Add('DelayedMod_BotArmorSkins_'..index, 0.5+index*0.5, function()
				managers.menu_scene:set_character_armor_skin(Get_This_Skins, unit)
			end)
		end
		self:set_henchmen_visible(true, index)
	end
end)