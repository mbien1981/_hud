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
		english = "Color code player and deployable contours",
		spanish = "Utilizar colores de jugador en los contornos del jugador y desplegables",
	},
	["_hud_use_custom_health_panel"] = {
		english = "Use custom health panel",
		spanish = "Usar panel de vida personalizado",
	},
	["_hud_custom_health_panel_layout"] = {
		english = "Health Panel Layout",
		spanish = "Diseño del panel de salud",
	},
	["_hud_vanilla_style"] = {
		english = "Vanilla Style",
		spanish = "Estilo Vanilla",
	},
	["_hud_raid_style"] = {
		english = "Raid Style",
		spanish = "Raid",
	},
	["_hud_raid_alt_style"] = {
		english = "Alternative Raid Style",
		spanish = "Raid alternativo",
	},
	["_hud_display_armor_and_health_values"] = {
		english = "Display armor and health values",
		spanish = "Mostrar valores de armadura y vida",
	},
	["_hud_display_armor_and_health_values_help"] = {
		english = "Show text items that indicate your raw armor and health values.",
		spanish = "Muestra textos que indican los valores armadura y vida.",
	},
	["_hud_display_armor_regen_timer"] = {
		english = "Display armor regen timer",
		spanish = "Mostrar tiempo de regeneración de armadura",
	},
	["_hud_display_armor_regen_timer_help"] = {
		english = "Shows a timer that indicates the time remaining for your armor to regenerate.",
		spanish = "Muestra un temporizador que indica el tiempo restante para que tu armadura se regenere.",
	},
	["_hud_reposition_chat_input"] = {
		english = "Reposition chat input panel",
		spanish = "Reposicionar el panel de chat",
	},
	["_hud_reposition_chat_input_help"] = {
		english = "Move the chat input panel above the top player mugshot.",
		spanish = "Mueve la entrada de texto del chat para que este sobre el último panel de jugador.",
	},
	["_hud_use_custom_inventory_panel"] = {
		english = "Use custom inventory panel",
		spanish = "Utilizar el panel de inventario personalizado",
	},
	["_hud_mugshot_name"] = {
		english = "Mugshot name",
		spanish = "Nombre de la foto policial",
	},
	["_hud_mugshot_name_help"] = {
		english = "Select what to display as your username in the custom health panel.",
		spanish = "Selecciona qué mostrar como tu nombre de usuario en el panel de vida personalizado.",
	},
	["_hud_character_name"] = {
		english = "Character name",
		spanish = "Nombre del personaje",
	},
	["_hud_steam_username"] = {
		english = "Steam username",
		spanish = "Nombre de Steam",
	},
	["_hud_short_username"] = {
		english = "Shortened Steam username",
		spanish = "Nombre de Steam acortado",
	},
	["_hud_custom_username"] = {
		english = "Custom username",
		spanish = "Nombre de usuario personalizado",
	},
	["_hud_custom_mugshot_name"] = {
		english = "Custom mugshot name",
		spanish = "Nombre personalizado",
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
	["_hud_ammo_panel_show_real_ammo"] = {
		english = "Show real ammo values",
		spanish = "Mostrar valores de municion verdaderos",
	},
	["_hud_ammo_panel_show_real_ammo_help"] = {
		english = "Show total ammo count without taking in mind the munition inside your current clip.",
		spanish = "Muestra el valor total de tu minición sin tomar en cuenta la munición de tu cargador.",
	},
	["_hud_enable_deployable_spy"] = {
		english = "Enable deployable spy",
		spanish = "Habilidar espía de desplegables",
	},
	["_hud_enable_deployable_spy_help"] = {
		english = "Show remaining bag charges and sentry gun ammo and health.",
		spanish = "Muestra la cantidad de cargas restantes en las bolsas y la cantidad de vida y munición restante en una torreta.",
	},
	["_hud_medic_bag_spy"] = { english = "Medic Bag text format" },
	["_hud_medic_bag_spy_help"] = {
		english = "$CARGES; = Shows remaining charges.\n$PERCENT; = Shows remaining percentage.\n\nSupports DAHM Color tags.",
	},
	["_hud_ammo_bag_spy"] = { english = "Ammo Bag text format" },
	["_hud_ammo_bag_spy_help"] = {
		english = "$CARGES; = Shows remaining charges.\n$PERCENT; = Shows remaining percentage.\n\nSupports DAHM Color tags.",
	},
	["_hud_sentry_gun_spy"] = { english = "Sentry Gun text format" },
	["_hud_sentry_gun_spy_help"] = {
		english = "$AMMO; = Shows current ammo.\n$AMMO_MAX; = Shows max ammo.\n$HEALTH; Shows current health.\n\nSupports color tags.",
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
		spanish = "No",
	},
	["_hud_use_custom_control_panel"] = {
		english = "Use custom control panel",
	},
	["_hud_assault_title"] = {
		english = "Police Assault in Progress",
	},
	["_hud_reinforced_assault_title"] = {
		english = "Reinforced Police Assault in Progress",
	},
	["_hud_use_custom_ponr_panel"] = {
		english = "Use custom point of no return panel",
	},
	["_hud_ponr_title"] = {
		english = "Point of no return in $TIME;",
	},
}

for key, translations in pairs(strings) do
	module:add_localization_string(key, translations)
end
