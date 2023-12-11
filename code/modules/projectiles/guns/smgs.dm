//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               GENERIC SUBMACHINE GUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Most smgs manufactured in the future feature an auto-ejector. Antiques and cheapo garbage guns do not have one. The ammo counter is only specific to some guns.

/obj/item/weapon/gun/smg
	reload_sound = 'sound/weapons/handling/smg_reload.ogg'
	unload_sound = 'sound/weapons/handling/smg_unload.ogg'
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	fire_sound = 'sound/weapons/gun_m39.ogg'
	force = 5
	w_class = SIZE_LARGE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	flags_gun_receiver = GUN_CHAMBERED_CYCLE
	gun_category = GUN_CATEGORY_SMG
	projectile_casing = PROJECTILE_CASING_BULLET
	start_automatic = TRUE

	//=========// GUN STATS //==========//
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_2
	fa_max_scatter = SCATTER_AMOUNT_TIER_5

	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
		)

	..()

/obj/item/weapon/gun/smg/Initialize(mapload, spawn_empty)
	. = ..()
	ready_in_chamber()

/obj/item/weapon/gun/smg/unique_action(mob/user)
	cycle_chamber(user)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                        M39                         ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 submachinegun"
	desc = "The Armat Battlefield Systems M-39 submachinegun. Occasionally carried by light-infantry, scouts, engineers and medics. A lightweight, lower caliber alternative to the various Pulse weapons used the USCM. Fires 10x20mm rounds out of 48 round magazines."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m39"
	item_state = "m39"
	flags_equip_slot = SLOT_BACK
	current_mag = /obj/item/ammo_magazine/smg/m39
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	map_specific_decoration = TRUE
	pixel_width_offset = -2

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_4
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_M39
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/m39/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg/collapsible,
			/obj/item/attachable/compensator,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/gyro,
			/obj/item/attachable/stock/smg/collapsible/brace,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 14, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 24, "stock_y" = 15)

	..()

/obj/item/weapon/gun/smg/m39/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

/obj/item/weapon/gun/smg/m39/training
	current_mag = /obj/item/ammo_magazine/smg/m39/rubber

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  M39B/2 ELITE SMG                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B/2 submachinegun"
	desc = "A modified version M-39 submachinegun, re-engineered for better weight, handling and accuracy. Given only to elite units."
	icon_state = "m39b2"
	item_state = "m39b2"
	current_mag = /obj/item/ammo_magazine/smg/m39/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED
	map_specific_decoration = FALSE
	random_attachment_chance = 100

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult =  BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_7
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/m39/elite/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible)

	if(!random_attachments_possible[ATTACHMENT_SLOT_RAIL])
		random_attachments_possible[ATTACHMENT_SLOT_RAIL] = list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_MUZZLE])
		random_attachments_possible[ATTACHMENT_SLOT_MUZZLE] = list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/extended_barrel
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_UNDER])
		random_attachments_possible[ATTACHMENT_SLOT_UNDER] = list(
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/flashlight/grip
		)

	..()

/obj/item/weapon/gun/smg/m39/elite/whiteout//attachies + heap mag for whiteout.
	current_mag = /obj/item/ammo_magazine/smg/m39/heap
	random_attachment_chance = 0 //So they actually get their starting attachments. Starting attachments are handled after randoms, only if randoms don't spawn in the slot.

/obj/item/weapon/gun/smg/m39/elite/whiteout/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/smg, /obj/item/attachable/suppressor, /obj/item/attachable/angledgrip, /obj/item/attachable/magnetic_harness)

	..()


//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                          MP5                       ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M5, a classic SMG used in a lot of action movies.

/obj/item/weapon/gun/smg/mp5
	name = "\improper MP5 submachinegun"
	desc = "A German design, this was one of the most widely used submachine guns in the world. It's still possible to find this firearm in the hands of collectors or gun fanatics."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mp5"
	item_state = "mp5"
	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp5
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/mp5/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor, // Barrel
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/lasersight, // Under
			/obj/item/attachable/gyro,
			/obj/item/attachable/bipod,
			/obj/item/attachable/burstfire_assembly
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 19, "under_x" = 23, "under_y" = 15, "stock_x" = 28, "stock_y" = 17)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                         MP27                       ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//based on the M7.

/obj/item/weapon/gun/smg/mp27
	name = "\improper MP27 submachinegun"
	desc = "An archaic design going back almost a century, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms. An extremely ergonomic and lightweight design allows easy mass production and surpisingly good handling, but the cheap materials used hurt the weapon's scatter noticeably."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mp7"
	item_state = "mp7"
	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp27
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_NO_SAFETY_SWITCH
	pixel_width_offset = -2

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_2

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_4 + (SCATTER_AMOUNT_TIER_10 * 0.5)
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8 + (SCATTER_AMOUNT_TIER_10 * 0.5)
	scatter_unwielded = SCATTER_AMOUNT_TIER_4 + SCATTER_AMOUNT_TIER_10
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

	aim_slowdown = SLOWDOWN_ADS_NONE
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/mp27/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor, // Barrel
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/lasersight, // Under
			/obj/item/attachable/gyro,
			/obj/item/attachable/bipod,
			/obj/item/attachable/burstfire_assembly,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 20, "under_x" = 23, "under_y" = 16, "stock_x" = 28, "stock_y" = 17)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                       PPSH-17B                     ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Based on the PPSh-41.

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "ppsh17b"
	item_state = "ppsh17b"
	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/ppsh
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE|GUN_NO_SAFETY_SWITCH //Prototype copy, so no safety.

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_4
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

	fa_max_scatter = SCATTER_AMOUNT_TIER_9
	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_PPSH // Seems a bit funny, but it works pretty well in the end
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/ppsh/initialize_gun_lists()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15)

	..()

/obj/item/weapon/gun/smg/ppsh/with_drum_mag
	current_mag = /obj/item/ammo_magazine/smg/ppsh/extended

/obj/item/weapon/gun/smg/ppsh/unload(mob/user, reload_override, drop_override, loc_override)
	. = ..()
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST

/obj/item/weapon/gun/smg/ppsh/reload(mob/user, obj/item/ammo_magazine/magazine)
	var/obj/item/ammo_magazine/smg/ppsh/ppsh_mag = magazine

	if( (ppsh_mag.bonus_mag_aim_slowdown || ppsh_mag.bonus_mag_wield_delay) && user)
		to_chat(user, SPAN_WARNING("\The [src] feels noticeably bulkier with \the [magazine]. It's probably going to have a lot worse handling than usual."))

	aim_slowdown = SLOWDOWN_ADS_QUICK + ppsh_mag.bonus_mag_aim_slowdown
	wield_delay = WIELD_DELAY_VERY_FAST + ppsh_mag.bonus_mag_wield_delay
	update_icon()
	. = ..()

/obj/item/weapon/gun/smg/ppsh/update_icon()
	..()
	var/obj/item/ammo_magazine/smg/ppsh/ppsh_mag = current_mag
	if(ppsh_mag && ppsh_mag.new_item_state)
		item_state = ppsh_mag.new_item_state
		ppsh_mag.update_icon()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                      TYPE-19                       ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smg/pps43
	name = "\improper Type-19 Submachinegun" //placeholder
	desc = "An outdated, but reliable and powerful, submachinegun originating in the Union of Progressive Peoples, it is still in limited service in the UPP but is most often used by paramilitary groups or corporate security forces. It is usually used with a 35 round stick magazine, or a 71 round drum."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "insasu"
	item_state = "insasu"
	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/pps43
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	pixel_width_offset = -1

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/pps43/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/magnetic_harness,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 20,"rail_x" = 20, "rail_y" = 24, "under_x" = 25, "under_y" = 17, "stock_x" = 26, "stock_y" = 15)

	..()

/obj/item/weapon/gun/smg/pps43/extended_mag
	current_mag = /obj/item/ammo_magazine/smg/pps43/extended

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                    TYPE 64 / BIZON                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smg/bizon
	name = "\improper Type 64 Submachinegun"
	desc = "The standard submachinegun of the UPP, sporting an unusual 64 round helical magazine, it has a high fire-rate, but is unusually accurate. This one has a faux-wood grip, denoting it as civilian use or as an export model."
	desc_lore = "The Type 64 finds its way into the hands of more than just UPP soldiers, it has an active life with rebel groups, corporate security forces, mercenaries, less well-armed militaries, and just about everything or everyone in between."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type64"
	item_state = "type64"
	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/bizon
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER //Roughly the same as the USCM

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_4

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

	wield_delay = WIELD_DELAY_MIN
	aim_slowdown = SLOWDOWN_ADS_QUICK_MINUS
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/bizon/initialize_gun_lists()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 23, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15)

	..()

/obj/item/weapon/gun/smg/bizon/upp
	name = "\improper Type 64 Submachinegun"
	desc = "The standard submachinegun of the UPP, sporting an unusual 64 round helical magazine, it has a high fire-rate, but is unusually accurate. This one has a black polymer grip, denoting it as in-use by the UPP military."
	desc_lore = "The Type 64 finds its way into the hands of more than just UPP soldiers, it has an active life with rebel groups, corporate security forces, mercenaries, less well-armed militaries, and just about everything or everyone in between."
	icon_state = "type64_u"
	item_state = "type64"

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   MAC-15 / UZI COPY                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Based on the uzi submachinegun, of course.

/obj/item/weapon/gun/smg/mac15
	name = "\improper MAC-15 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age." //Includes proprietary 'full-auto' mode, banned in several Geneva Suggestions rim-wide.
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mac15"
	item_state = "mac15"
	fire_sound = 'sound/weapons/gun_mac15.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mac15
	flags_gun_features = GUN_ANTIQUE|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED //|GUN_HAS_FULL_AUTO|GUN_FULL_AUTO_ON|GUN_FULL_AUTO_ONLY commented out until better fullauto code
	pixel_width_offset = -3

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_12
	accuracy_mult = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	damage_mult = BULLET_DAMAGE_MULT_BASE - BULLET_DAMAGE_MULT_TIER_2

	wield_delay = WIELD_DELAY_NONE
	aim_slowdown = SLOWDOWN_ADS_NONE

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_7
	fa_max_scatter = SCATTER_AMOUNT_TIER_3
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/mac15/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor, // Barrel
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/lasersight, // Under
			/obj/item/attachable/burstfire_assembly,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20,"rail_x" = 16, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

	..()

/obj/item/weapon/gun/smg/mac15/extended
	current_mag = /obj/item/ammo_magazine/smg/mac15/extended

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     THE REAL UZI                   ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
// DAS REAL UZI

/obj/item/weapon/gun/smg/uzi
	name = "\improper UZI"
	desc = "Exported to over 90 countries, somehow this relic has managed to end up here. Couldn't be simpler to use."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "uzi"
	item_state = "uzi"
	flags_equip_slot = SLOT_WAIST
	fire_sound = 'sound/weapons/gun_uzi.ogg'
	current_mag = /obj/item/ammo_magazine/smg/uzi
	flags_gun_features = GUN_ANTIQUE|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_NO_SAFETY_SWITCH
	start_semiauto = FALSE
	start_automatic = TRUE
	pixel_width_offset = -5

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_3
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

	wield_delay = WIELD_DELAY_MIN
	aim_slowdown = SLOWDOWN_ADS_QUICK

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/uzi/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor, // Barrel
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/lasersight, // Under
			/obj/item/attachable/burstfire_assembly,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                      FN FP9000                    ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Based on the FN P90

/obj/item/weapon/gun/smg/fp9000
	name = "\improper FN FP9000 Submachinegun"
	desc = "An old design, but one that's stood the test of time. A leaked and unencrypted 3D-printing pattern alongside an extremely robust and reasonably cheap to manufacture frame have ensured this weapon be a mainstay of rim colonies and private security firms for over a century."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "fp9000"
	item_state = "fp9000"
	fire_sound = 'sound/weapons/gun_p90.ogg'
	current_mag = /obj/item/ammo_magazine/smg/fp9000
	flags_gun_features = GUN_CAN_POINTBLANK
	random_attachment_chance = 65

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/fp9000/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/scope/mini/fp9000)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/compensator,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 20, "rail_y" = 21, "under_x" = 26, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)

	if(!random_attachments_possible)
		random_attachments_possible = list()

	if(!random_attachments_possible[ATTACHMENT_SLOT_MUZZLE])
		random_attachments_possible[ATTACHMENT_SLOT_MUZZLE] = list(
			/obj/item/attachable/compensator,
			/obj/item/attachable/extended_barrel,
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_UNDER])
		random_attachments_possible[ATTACHMENT_SLOT_UNDER] = list(
			/obj/item/attachable/lasersight,
		)

	..()

/obj/item/weapon/gun/smg/fp9000/pmc
	name = "\improper FN FP9000/2 Submachinegun"
	desc = "Despite the rather ancient design, the FN FP9K sees frequent use in PMC teams due to its extreme reliability and versatility, allowing it to excel in any situation, especially due to the fact that they use the patented, official version of the gun, which has recieved several upgrades and tuning to its design over time."
	icon_state = "fp9000_pmc"
	item_state = "fp9000_pmc"
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	random_attachment_chance = 100

	//=========// GUN STATS //==========//
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_9
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/fp9000/pmc/initialize_gun_lists()

	if(!random_attachments_possible)
		random_attachments_possible = list()

	if(!random_attachments_possible[ATTACHMENT_SLOT_RAIL]) //This will replace the mini-scope.
		random_attachments_possible[ATTACHMENT_SLOT_RAIL] = list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
		)

	..()


//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                       NAILGUN                      ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smg/nailgun
	name = "nailgun"
	desc = "A carpentry tool, used to drive nails into tough surfaces. Of course, if there isn't anything there, that's just a very sharp nail launching at high velocity..."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "nailgun"
	item_state = "nailgun"

	current_mag = /obj/item/ammo_magazine/smg/nailgun
	projectile_casing = PROJECTILE_CASING_CASELESS
	reload_sound = 'sound/weapons/handling/smg_reload.ogg'
	unload_sound = 'sound/weapons/handling/smg_unload.ogg'
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	fire_sound = 'sound/weapons/nailgun_fire.ogg'
	force = 5
	w_class = SIZE_MEDIUM
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_UNUSUAL_DESIGN|GUN_NO_SAFETY_SWITCH //Why wasn't wasn't an unusual design originally? I do believe nail guns have tip safety, so realistically, you shouldn't be able to fire them at people in the first place.
	flags_gun_receiver = null
	civilian_usable_override = TRUE
	start_automatic = FALSE
	var/nailing_speed = 2 SECONDS //Time to apply a sheet for patching. Also haha name. Try to keep sync with soundbyte duration
	var/repair_sound = 'sound/weapons/nailgun_repair_long.ogg'

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	movement_onehanded_acc_penalty_mult = 4

	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smg/nailgun/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list()

	..()

//We're making our own reload proc because we're chads.
/obj/item/weapon/gun/reload(mob/user, obj/item/ammo_magazine/magazine, reload_override = TRUE)
	. = ..() //We override to restore normal reloading behavior.

/obj/item/weapon/gun/unload(mob/user, reload_override = TRUE)
	. = ..()

/obj/item/weapon/gun/smg/nailgun/unique_action(mob/user)
	return //Cannot cycle it.

/obj/item/weapon/gun/smg/nailgun/compact
	name = "compact nailgun"
	desc = "A carpentry tool, used to drive nails into tough surfaces. Cannot fire nails offensively due to a lack of a gas seal around the nail, meaning it cannot build up the pressure to fire."
	icon_state = "cnailgun"
	item_state = "nailgun"
	w_class = SIZE_SMALL

/obj/item/weapon/gun/smg/nailgun/compact/able_to_fire(mob/living/user)
	. = ..()

	if(.)
		click_empty(user)
	return FALSE
