require("lib/units/ArmorSkinExt")

Hooks:PostHook(TeamAIBase, "post_init", "BotArmorSkins_TeamAIBase_post_init", function(self)
	self._bot_armor_skin = ArmorSkinExt:new(self._unit)
end)