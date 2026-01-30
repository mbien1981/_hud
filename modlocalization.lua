local module = ... or D:mod("_hud")

-- Credits:
-- German translation by neonsynth -- https://steamcommunity.com/profiles/76561198844370238

-- general mod localization
module:add_localization_string("_hud_drop_in_peer_info", {
	english = "Level: $LEVEL;\nMask set: $MASK;\nDeployable: $DEPLOYABLE;\nCrew bonus: $CREW_BONUS;\nReady: $READY;",
	german = "Level: $LEVEL;\nMaskenset: $MASK;\nEinsetzbares: $DEPLOYABLE;\nTeambonus: $CREW_BONUS;\nBereit: $READY;",
	spanish = "Nivel: $LEVEL;\nSet de máscara: $MASK;\nEquipamiento desplegable: $DEPLOYABLE;\nBono de equipo: $CREW_BONUS;\nPreparado: $READY;",
	chinese = "等级：$LEVEL;\n面具：$MASK;\n 可放置物：$DEPLOYABLE;\n小组加成：$CREW_BONUS;\n准备状态：$READY;",
})
module:add_localization_string("_hud_drop_in_mod_list_title", {
	english = "Gameplay changing mods",
	german = "Gameplay-verändernde Mods",
	spanish = "Mods que alteran la jugabilidad",
	chinese = "会影响游戏体验/玩法的模组",
})
module:add_localization_string("_hud_assault_title", {
	english = "Police Assault in Progress",
	german = "Polizeivorstoß im Gange",
	spanish = "Asalto policial en progreso",
	chinese = "警方突击进行中",
})
module:add_localization_string("_hud_reinforced_assault_title", {
	english = "Reinforced Police Assault in Progress",
	german = "Verstärkter Polizeivorstoß im Gange",
	spanish = "Asalto Policial Reforzado en Progreso",
	chinese = "警方增援突击中",
	
})
module:add_localization_string("_hud_ponr_title", {
	english = "Point of no return in $TIME;",
	german = "Kein Zurück mehr in $TIME;",
	spanish = "Punto de no retorno en $TIME;",
	chinese = "任务失败于：$TIME;",
})
module:add_localization_string("_hud_none_selected", {
	english = "None selected",
	german = "Nichts ausgewählt",
	spanish = "Ninguno seleccionado",
	chinese = "无选项",
})
module:add_localization_string("_hud_yes", {
	english = "Yes",
	german = "Ja",
	spanish = "Sí",
	chinese = "是",
})
module:add_localization_string("_hud_no", {
	english = "No",
	german = "Nein",
	spanish = "No",
	chinese = "否",
})
