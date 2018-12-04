_G.BotArmorSkins = _G.BotArmorSkins or {}
BotArmorSkins.Skins_List = BotArmorSkins.Skins_List or json.decode('["ast_armor6","cas_gensec","drm_tree_stump","none","ast_armor1","drm_somber_woodland","cvc_avenger","cvc_bone","ast_armor4","ast_armor2","cvc_tan","drm_khaki_eclipse","cas_miami","drm_desert_tech","cas_m90","drm_misted_grey","drm_navy_breeze","cas_police","drm_gray_raider","ast_armor5","cvc_swat","cvc_grey","cvc_green","ast_armor3","cvc_woodland_camo","cvc_black","cvc_desert_camo","cvc_city_camo","drm_desert_twilight","cas_trash","drm_khaki_regular","drm_woodland_tech","cas_slayer","cvc_navy_blue"]')

Hooks:PostHook(TeamAIMovement, "set_character_anim_variables", "BotArmorSkins_TeamAIMovement_post_init", function(self)
	if not BotArmorSkins.Skins_List or not self._unit or not self._unit:base() or not self._unit:base()._bot_armor_skin then
		return
	end
	local character_id = self._unit:base()._tweak_table
	local Get_This_Skins = ""
	local loadout = managers.criminals:get_loadout_for(character_id)
	if not loadout or (not loadout.armor_skins and not loadout.armor_skins_random) then
		
	elseif loadout.armor_skins_random then
		Get_This_Skins = tostring(BotArmorSkins.Skins_List[math.random(#BotArmorSkins.Skins_List)])
	elseif loadout.armor_skins and not loadout.armor_skins_random then
		Get_This_Skins = loadout.armor_skins
	end
	if Get_This_Skins ~= "" then
		local armor = loadout and loadout.armor or "level_1"
		self._unit:base()._bot_armor_skin:set_armor_id(armor)		
		BotArmorSkins:special_materials_fix(self._unit, character_id, Get_This_Skins)
	end
end)