require("lib/units/ArmorSkinExt")

Hooks:PostHook(TeamAIBase, "post_init", "BotArmorSkins__TeamAIBase_post_init", function(self, ...)
	self._armor_skin = ArmorSkinExt:new(self._unit)
end)