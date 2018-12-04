_G.BotArmorSkins = _G.BotArmorSkins or {}
BotArmorSkins.ModPath = ModPath
BotArmorSkins.SaveFile = BotArmorSkins.SaveFile or SavePath .. "BotArmorSkins.txt"

Hooks:PostHook(EconomyTweakData, "_init_armor_skins", "BotArmorSkins__EconomyTweakData_init_armor_skins", function(self, ...)
	local _file = io.open(BotArmorSkins.SaveFile, "w+")
	if not _file then
		return
	end
	local _skins_list = {}
	self.armor_skins = self.armor_skins or {}
	for skin_name, skin_data in pairs(self.armor_skins) do
		if skin_data.name_id then
			table.insert(_skins_list, skin_name)
		end
	end
	if #_skins_list > 0 then
		BotArmorSkins.Skins_List = _skins_list
		_file:write(json.encode(_skins_list))
	else
		_file:write('[{}]')
	end
	_file:close()
end)