local module = ... or D:module("_hud")

local strings = {
	["_hud_scaling"] = {
		english = "HUD Scale",
		spanish = "Escala del HUD",
	},
	["_hud_font_scaling"] = {
		english = "HUD Font Scale",
		spanish = "Escala de la fuente del HUD",
	},
	["_hud_use_custom_name_labels"] = {
		english = "Use custom name labels",
		spanish = "Utilizar etiquetas de vida personalizadas",
	},
	["_hud_peer_contour_colors"] = {
		english = "Color code player contours",
		spanish = "Utilizar colores de jugador en los contornos",
	},
	["_hud_use_custom_health_panel"] = {
		english = "Use custom health panel",
		spanish = "Usar panel de vida personalizado",
	},
	["_hud_custom_health_panel_layout"] = {
		english = "Health Panel Layout",
	},
	["_hud_vanilla_style"] = {
		english = "Vanilla Style",
	},
	["_hud_raid_style"] = {
		english = "Raid Style",
	},
	["_hud_raid_alt_style"] = {
		english = "Alternative Raid Style",
	},
	["_hud_display_armor_and_health_values"] = {
		english = "Display armor and health values",
		spanish = "Mostrar valores de armadura y vida",
	},
	["_hud_display_armor_and_health_values_help"] = {
		english = "Show text items that indicate your raw armor and health values.",
		spanish = "Muestra textos que indican los valores armadura y vida.",
	},
	-- ["_hud_enable_armor_timer"] = {
	-- 	english = "Enable armor regen timer",
	-- 	spanish = "Mostrar tiempo de regeneración de armadura",
	-- },
	-- ["_hud_enable_armor_timer_help"] = {
	-- 	english = "Shows a timer that indicates the time remaining for your armor to regenerate.",
	-- 	spanish = "Muestra un temporizador que indica el tiempo restante para que tu armadura se regenere.",
	-- },
	["_hud_use_custom_inventory_panel"] = {
		english = "Use custom inventory panel",
	},
	["_hud_long_name_splitting"] = {
		english = "Display short player name",
		spanish = "Mostrar nombre de usuario recortado",
	},
	["_hud_long_name_splitting_help"] = {
		english = "Displays the only the longest word in your username if it exceeds the 16 character limit.",
		spanish = "Muestra solo la palabra más larga de tu nombre de usuario si supera el límite de 16 caracteres.",
	},
	["_hud_name_use_peer_color"] = {
		english = "Use peer color in custom health bar",
		spanish = "Utilizar color del jugador en el panel de vida",
	},
	["_hud_name_use_peer_color_help"] = {
		english = "Sets your name color to match your chat color.",
		spanish = "Colorea tu nombre para que coincida con tu color de chat.",
	},
	["_hud_enable_custom_ammo_panel"] = {
		english = "Use custom ammo panel",
		spanish = "Utilizar indicador de munición personalizado.",
	},
	["_hud_enable_deployable_spy"] = {
		english = "Enable deployable spy",
	},
	["_hud_enable_deployable_spy_help"] = {
		english = "Show remaining bag charges and sentry gun ammo and health.",
	},
	["_hud_use_custom_drop_in_panel"] = {
		english = "Use custom drop-in panel",
		spanish = "Utilizar panel personalizado de entrada de jugador.",
	},
	["_hud_drop_in_peer_info"] = {
		english = "Level: %d\nMask set: %s\nDeployable: %s\nCrew bonus: %s\nReady: %s",
		spanish = "Nivel: %d\nSet de máscara: %s\nEquipamiento desplegable: %s\nBono de equipo: %s\nPreparado: %s",
	},
	["_hud_drop_in_show_peer_info"] = {
		english = "Show peer info in drop in",
		spanish = "Mostrar información del jugador mientras se une",
	},
	["_hud_drop_in_show_peer_info_help"] = {
		english = "Shows loadout info about the joining peer.",
		spanish = "Muestra información sobre el equipamiento del jugador que se esta uniendo a la partida.",
	},
	["_hud_leftbottom"] = {
		english = "Left Bottom",
		spanish = "Abajo a la izquierda",
	},
	["_hud_lefttop"] = {
		english = "Left Top",
		spanish = "Arriba a la izquierda",
	},
	["_hud_centertop"] = {
		english = "Center Top",
		spanish = "Centrado arriba",
	},
	["_hud_righttop"] = {
		english = "Right Top",
		spanish = "Arriba a la derecha",
	},
	["_hud_centerright"] = {
		english = "Center Right",
		spanish = "Centrado a la derecha",
	},
	["_hud_rightbottom"] = {
		english = "Right Bottom",
		spanish = "Abajo a la derecha",
	},
	["_hud_centerbottom"] = {
		english = "Bottom Center",
		spanish = "Centrado abajo",
	},
	["_hud_mod_list_position"] = {
		english = "Player mod list position",
		spanish = "Posición de la lista de mods del jugador",
	},
	["_hud_mod_list_title"] = {
		english = "Gameplay altering mods:%s",
		spanish = "Mods que alteran el juego:%s",
	},
	["_hud_reload_timer"] = {
		english = "Show reload timer",
		spanish = "Mostrar el tiempo de recarga",
	},
	["_hud_shotgun_fire_timer"] = {
		english = "Show shotgun fire timer",
		spanish = "Mostrar el tiempo de disparo de escopetas",
	},
	["_hud_yes"] = {
		english = "Yes",
		spanish = "Sí",
	},
	["_hud_no"] = {
		english = "No",
	},
}

for key, translations in pairs(strings) do
	module:add_localization_string(key, translations)
end
