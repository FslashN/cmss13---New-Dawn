//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     GENERIC RIFLE                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Most rifles manufactured in the future feature an auto-ejector. Antiques and cheapo garbage guns do not have one. The ammo counter is only specific to some guns. Those gun generally have a pixel or two in their sprite to show it.

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg'
	chamber_cycle_sound = 'sound/weapons/gun_cocked2.ogg'

	flags_equip_slot = SLOT_BACK
	w_class = SIZE_LARGE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	flags_gun_receiver = GUN_CHAMBERED_CYCLE
	gun_category = GUN_CATEGORY_RIFLE
	projectile_casing = PROJECTILE_CASING_CARTRIDGE

	//=========// GUN STATS //==========//
	malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO

	fire_delay = FIRE_DELAY_TIER_5
	burst_amount = BURST_AMOUNT_TIER_3
	burst_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_2

	damage_mult = BULLET_DAMAGE_MULT_BASE
	damage_falloff_mult = DAMAGE_FALLOFF_TIER_10
	damage_buildup_mult = DAMAGE_BUILDUP_TIER_1
	velocity_add = BASE_VELOCITY_BONUS
	recoil = RECOIL_OFF
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_1

	effective_range_min = EFFECTIVE_RANGE_OFF
	effective_range_max = EFFECTIVE_RANGE_OFF

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_BASE
	fa_max_scatter = FULL_AUTO_SCATTER_MAX_BASE

	recoil_buildup_limit = RECOIL_AMOUNT_TIER_1 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER

	aim_slowdown = SLOWDOWN_ADS_RIFLE
	wield_delay = WIELD_DELAY_NORMAL
	//=========// GUN STATS //==========//

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                M41A MK2 PULSE RIFLE                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/m41a
	name = "\improper M41A pulse rifle MK2"
	desc = "The standard issue rifle of the Colonial Marines. Commonly carried by most combat personnel. Uses 10x24mm caseless ammunition."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m41a"
	item_state = "m41a"
	fire_sound = "gun_pulse"
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	map_specific_decoration = TRUE
	start_automatic = TRUE
	pixel_width_offset = -2

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4 + 2*HIT_ACCURACY_MULT_TIER_1
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m41a/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/attached_gun/grenade, /obj/item/attachable/stock/rifle/collapsible))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle/collapsible,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13))

	..()

//variant without ugl attachment
/obj/item/weapon/gun/rifle/m41a/stripped
	starting_attachment_types = list()

/obj/item/weapon/gun/rifle/m41a/racked //spawns empty and with no UGL.
	starting_attachment_types = list(/obj/item/attachable/stock/rifle/collapsible)

/obj/item/weapon/gun/rifle/m41a/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

/obj/item/weapon/gun/rifle/m41a/training
	current_mag = /obj/item/ammo_magazine/rifle/rubber

/obj/item/weapon/gun/rifle/m41a/tactical
	current_mag = /obj/item/ammo_magazine/rifle/ap
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/suppressor, /obj/item/attachable/angledgrip, /obj/item/attachable/stock/rifle/collapsible)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 M41A/2 PULSE RIFLE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M41A PMC VARIANT

/obj/item/weapon/gun/rifle/m41a/elite
	name = "\improper M41A/2 pulse rifle"
	desc = "A modified version M41A Pulse Rifle MK2, re-engineered for better weight, handling and accuracy. Fires precise two-round bursts. Given only to elite units."
	icon_state = "m41a2"
	item_state = "m41a2"

	current_mag = /obj/item/ammo_magazine/rifle/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED
	map_specific_decoration = FALSE
	random_attachment_chance = 100

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_2
	burst_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_5

	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m41a/elite/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list( /obj/item/attachable/reddot, /obj/item/attachable/reflex, /obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/extended_barrel, /obj/item/attachable/heavy_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/angledgrip, /obj/item/attachable/attached_gun/shotgun, /obj/item/attachable/lasersight, /obj/item/attachable/attached_gun/flamer/advanced))

	..()

/obj/item/weapon/gun/rifle/m41a/elite/whiteout //special version for whiteout, has preset attachments and HEAP mag loaded.
	random_attachment_chance = 0 //So they get their starting attachments.
	current_mag = /obj/item/ammo_magazine/rifle/heap

/obj/item/weapon/gun/rifle/m41a/elite/whiteout/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible, /obj/item/attachable/magnetic_harness, /obj/item/attachable/angledgrip, /obj/item/attachable/suppressor))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  M41A MK2 CORPORATE                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/m41a/corporate
	desc = "A Weyland-Yutani creation, this M41A MK2 comes equipped in corporate white. Uses 10x24mm caseless ammunition."
	icon = 'icons/obj/items/weapons/guns/guns_by_map/snow/guns_obj.dmi'
	item_icons = list(
		WEAR_L_HAND = 'icons/obj/items/weapons/guns/guns_by_map/snow/guns_lefthand.dmi',
		WEAR_R_HAND = 'icons/obj/items/weapons/guns/guns_by_map/snow/guns_righthand.dmi',
		WEAR_BACK = 'icons/obj/items/weapons/guns/guns_by_map/snow/back.dmi',
		WEAR_J_STORE = 'icons/obj/items/weapons/guns/guns_by_map/snow/suit_slot.dmi'
	)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED
	map_specific_decoration = FALSE

/obj/item/weapon/gun/rifle/m41a/corporate/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible))

	..()

/obj/item/weapon/gun/rifle/m41a/corporate/no_lock //for PMC nightmares.
	desc = "A Weyland-Yutani creation, this M41A MK2 comes equipped in corporate white. Uses 10x24mm caseless ammunition. This one had its IFF electronics removed."
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

/obj/item/weapon/gun/rifle/m41a/corporate/detainer //for chem ert
	current_mag = /obj/item/ammo_magazine/rifle/ap

/obj/item/weapon/gun/rifle/m41a/corporate/detainer/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible, /obj/item/attachable/attached_gun/flamer/advanced))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex, /obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/extended_barrel))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  XM40 PULSE RIFLE                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M40-SD AKA SOF RIFLE FROM HELL (It's actually an M41A, don't tell!)
//The ammo feeder accepting propriety mags and M41A mags is a little nonsensical but I'll let it be.

/obj/item/weapon/gun/rifle/m41a/elite/xm40
	name = "\improper XM40 pulse rifle"
	desc = "One of the experimental predecessors to the M41 line that never saw widespread adoption beyond elite marine units. Of the rifles in the USCM inventory that are still in production, this is the only one to feature an integrated suppressor. Features its own proprietary ammo feed system that accepts common M41A mags as well as its own. Extremely lethal in burstfire mode."
	icon_state = "m40sd"
	item_state = "m40sd"
	reload_sound = 'sound/weapons/handling/m40sd_reload.ogg'
	unload_sound = 'sound/weapons/handling/m40sd_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/xm40/heap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	map_specific_decoration = FALSE
	random_attachment_chance = 0
	pixel_width_offset = 0

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_3

	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m41a/elite/xm40/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/suppressor/xm40_integral, /obj/item/attachable/magnetic_harness/hidden))
	//no rail attachies
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor/xm40_integral,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/gyro,
			/obj/item/attachable/bipod,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/attached_gun/extinguisher,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13))

	..()

/obj/item/weapon/gun/rifle/m41a/elite/xm40/ap
	current_mag = /obj/item/ammo_magazine/rifle/xm40

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[           M41A MK1 ORIGINAL ALIENS RIFLE           ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M41A TRUE AND ORIGINAL

/obj/item/weapon/gun/rifle/m41aMK1
	name = "\improper M41A pulse rifle"
	desc = "An older design of the Pulse Rifle commonly used by Colonial Marines. Uses 10x24mm caseless ammunition."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m41amk1" //Placeholder.
	item_state = "m41amk1" //Placeholder.
	fire_sound = "gun_pulse"
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	start_automatic = TRUE
	pixel_width_offset = -2

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11
	burst_amount = BURST_AMOUNT_TIER_4
	burst_delay  = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m41aMK1/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/attached_gun/grenade/mk1, /obj/item/attachable/stock/rifle/collapsible))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/reflex,
			/obj/item/attachable/attached_gun/grenade/mk1,
			/obj/item/attachable/stock/rifle/collapsible,
			/obj/item/attachable/attached_gun/shotgun,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 24, "stock_y" = 14))

	..()

/obj/item/weapon/gun/rifle/m41aMK1/ap //for making it start with ap loaded
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1/ap

/obj/item/weapon/gun/rifle/m41aMK1/tactical
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/mk1, /obj/item/attachable/suppressor, /obj/item/attachable/magnetic_harness, /obj/item/attachable/stock/rifle/collapsible)
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1/ap

/obj/item/weapon/gun/rifle/m41aMK1/anchorpoint
	desc = "A classic M41 MK1 Pulse Rifle painted in a fresh coat of the classic Humbrol 170 camoflauge. This one appears to be used by the Colonial Marine contingent aboard Anchorpoint Station, and is equipped with an underbarrel shotgun. Uses 10x24mm caseless ammunition."
	starting_attachment_types = list(/obj/item/attachable/stock/rifle/collapsible, /obj/item/attachable/attached_gun/shotgun)
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1/ap

/obj/item/weapon/gun/rifle/m41aMK1/anchorpoint/gl
	desc = "A classic M41 MK1 Pulse Rifle painted in a fresh coat of the classic Humbrol 170 camoflauge. This one appears to be used by the Colonial Marine contingent aboard Anchorpoint Station, and is equipped with an underbarrel grenade launcher. Uses 10x24mm caseless ammunition."

/obj/item/weapon/gun/rifle/m41aMK1/anchorpoint/gl/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible, /obj/item/attachable/attached_gun/grenade/mk1))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                NSG 23 ASSAULT RIFLE                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//PMC PRIMARY RIFLE

/obj/item/weapon/gun/rifle/nsg23
	name = "\improper NSG 23 assault rifle"
	desc = "A rare sight, this rifle is seen most commonly in the hands of Weyland-Yutani PMCs. Compared to the M41A MK2, it has noticeably improved handling and vastly improved performance at long and medium range, but compares similarly up close."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/wy.dmi'
	icon_state = "nsg23"
	item_state = "nsg23"
	fire_sound = "gun_nsg23"
	reload_sound = 'sound/weapons/handling/nsg23_reload.ogg'
	unload_sound = 'sound/weapons/handling/nsg23_unload.ogg'
	chamber_cycle_sound = 'sound/weapons/handling/nsg23_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/nsg23
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_WY_RESTRICTED|GUN_AMMO_COUNTER
	start_semiauto = FALSE
	start_automatic = TRUE
	pixel_width_offset = -3

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7
	burst_delay  = FIRE_DELAY_TIER_9

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	damage_falloff_mult = DAMAGE_FALLOFF_OFF
	fa_max_scatter = SCATTER_AMOUNT_TIER_5

	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/nsg23/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/scope/mini/nsg23, /obj/item/attachable/attached_gun/flamer/advanced, /obj/item/attachable/stock/nsg23))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/stock/nsg23,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/scope/mini/nsg23,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 16,"rail_x" = 13, "rail_y" = 22, "under_x" = 21, "under_y" = 10, "stock_x" = 5, "stock_y" = 17))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/extended_barrel))

	..()

/obj/item/weapon/gun/rifle/nsg23/Initialize(mapload, spawn_empty)
	. = ..()
	update_icon()

//has no scope or underbarrel
/obj/item/weapon/gun/rifle/nsg23/stripped/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/nsg23)) //starts with the stock only.

	..()

/obj/item/weapon/gun/rifle/nsg23/no_lock
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

/obj/item/weapon/gun/rifle/nsg23/no_lock/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/scope/mini/nsg23, /obj/item/attachable/attached_gun/flamer)) //non-op flamer for normal spawns

	..()

/obj/item/weapon/gun/rifle/nsg23/no_lock/stripped/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/nsg23)) //starts with the stock only.

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   M46 PULSE RIFLE                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Special gun for the CO to replace the smartgun

/obj/item/weapon/gun/rifle/m46c
	name = "\improper M46C pulse rifle"
	desc = "A prototype M46C, an experimental rifle platform built to outperform the standard M41A. Back issue only. Uses standard MK1 & MK2 rifle magazines."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m46c"
	item_state = "m46c"
	fire_sound = "gun_pulse"
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/incendiary
	flags_gun_toggles = GUN_IFF_SYSTEM_ON
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	indestructible = TRUE
	auto_retrieval_slot = WEAR_J_STORE
	map_specific_decoration = TRUE
	random_attachment_chance = 100
	var/mob/living/carbon/human/linked_human

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9
	burst_amount = BURST_AMOUNT_TIER_4
	burst_delay  = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_8
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_3
	fa_max_scatter = SCATTER_AMOUNT_TIER_7
	//=========// GUN STATS //==========//
//somewhere in between the mk1 and mk2
/obj/item/weapon/gun/rifle/m46c/initialize_gun_lists()
	INHERITLIST(additional_type_magazines, list(
			/obj/item/ammo_magazine/rifle,
			/obj/item/ammo_magazine/rifle/rubber,
			/obj/item/ammo_magazine/rifle/extended,
			/obj/item/ammo_magazine/rifle/ap,
			/obj/item/ammo_magazine/rifle/incendiary,
			/obj/item/ammo_magazine/rifle/toxin,
			/obj/item/ammo_magazine/rifle/penetrating,
			/obj/item/ammo_magazine/rifle/m41aMK1,
			/obj/item/ammo_magazine/rifle/m41aMK1/ap,
			/obj/item/ammo_magazine/rifle/m41aMK1/incendiary,
			/obj/item/ammo_magazine/rifle/m41aMK1/heap,
			/obj/item/ammo_magazine/rifle/m41aMK1/toxin,
			/obj/item/ammo_magazine/rifle/m41aMK1/penetrating,
		))
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/rifle/collapsible/m46c))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/stock/rifle/collapsible,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 17, "rail_x" = 11, "rail_y" = 19, "under_x" = 24, "under_y" = 12, "stock_x" = 24, "stock_y" = 13))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/scope/mini))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/extended_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/angledgrip, /obj/item/attachable/verticalgrip, /obj/item/attachable/attached_gun/shotgun))

	..()

/obj/item/weapon/gun/rifle/m46c/Initialize(mapload, ...)
	LAZYADD(actions_types, /datum/action/item_action/m46c/toggle_lethal_mode)
	LAZYADD(actions_types, /datum/action/item_action/m46c/toggle_id_lock)
	. = ..()
	if(flags_gun_toggles & GUN_IFF_SYSTEM_ON)
		LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff)
		))
	recalculate_attachment_bonuses()

/obj/item/weapon/gun/rifle/m46c/Destroy()
	linked_human = null
	. = ..()

/obj/item/weapon/gun/rifle/m46c/check_additional_able_to_fire(mob/user)
	if(flags_gun_toggles & GUN_ID_LOCK_ON && linked_human && linked_human != user)
		if(linked_human.is_revivable() || linked_human.stat != DEAD)
			to_chat(user, SPAN_WARNING("[icon2html(src, usr)] Trigger locked by [src]. Unauthorized user."))
			playsound(loc,'sound/weapons/gun_empty.ogg', 25, 1)
			return FALSE

		linked_human = null
		flags_gun_toggles &= ~GUN_ID_LOCK_ON
		UnregisterSignal(linked_human, COMSIG_PARENT_QDELETING)

/obj/item/weapon/gun/rifle/m46c/pickup(user)
	if(!linked_human)
		name_after_co(user)
		to_chat(usr, SPAN_NOTICE("[icon2html(src, usr)] You pick up \the [src], registering yourself as its owner."))
	..()

//---ability actions--\\

/datum/action/item_action/m46c/action_activate()
	var/obj/item/weapon/gun/rifle/m46c/protag_gun = holder_item
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/protagonist = owner
	if(protagonist.is_mob_incapacitated() || protag_gun.get_active_firearm(protagonist, FALSE) != holder_item)
		return

/datum/action/item_action/m46c/update_button_icon()
	return

/datum/action/item_action/m46c/toggle_lethal_mode/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle IFF"
	action_icon_state = "iff_toggle_on"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/m46c/toggle_lethal_mode/action_activate()
	. = ..()
	var/obj/item/weapon/gun/rifle/m46c/protag_gun = holder_item
	protag_gun.toggle_iff(usr)
	if(protag_gun.flags_gun_toggles & GUN_IFF_SYSTEM_ON)
		action_icon_state = "iff_toggle_on"
	else
		action_icon_state = "iff_toggle_off"
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/m46c/toggle_id_lock/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle ID lock"
	action_icon_state = "id_lock_locked"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/m46c/toggle_id_lock/action_activate()
	. = ..()
	var/obj/item/weapon/gun/rifle/m46c/protag_gun = holder_item
	protag_gun.toggle_lock()
	if(protag_gun.flags_gun_toggles & GUN_ID_LOCK_ON)
		action_icon_state = "id_lock_locked"
	else
		action_icon_state = "id_lock_unlocked"
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)


// -- ability actions procs -- \\

/obj/item/weapon/gun/rifle/m46c/proc/toggle_lock(mob/user)
	if(linked_human && usr != linked_human)
		to_chat(usr, SPAN_WARNING("[icon2html(src, usr)] Action denied by [src]. Unauthorized user."))
		return
	else if(!linked_human)
		name_after_co(usr)

	flags_gun_toggles ^= GUN_ID_LOCK_ON
	to_chat(usr, SPAN_NOTICE("[icon2html(src, usr)] You [flags_gun_toggles & GUN_ID_LOCK_ON? "lock": "unlock"] [src]."))
	playsound(loc,'sound/machines/click.ogg', 25, 1)

/obj/item/weapon/gun/rifle/m46c/proc/toggle_iff(mob/user)
	if(flags_gun_toggles & GUN_ID_LOCK_ON && linked_human && usr != linked_human)
		to_chat(usr, SPAN_WARNING("[icon2html(src, usr)] Action denied by [src]. Unauthorized user."))
		return

	gun_firemode = GUN_FIREMODE_SEMIAUTO
	flags_gun_toggles ^= GUN_IFF_SYSTEM_ON
	to_chat(usr, SPAN_NOTICE("[icon2html(src, usr)] You [flags_gun_toggles & GUN_IFF_SYSTEM_ON? "enable": "disable"] the IFF on [src]."))
	playsound(loc,'sound/machines/click.ogg', 25, 1)

	recalculate_attachment_bonuses()
	if(flags_gun_toggles & GUN_IFF_SYSTEM_ON)
		add_bullet_trait(BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff))
	else
		remove_bullet_trait("iff")

/obj/item/weapon/gun/rifle/m46c/recalculate_attachment_bonuses()
	. = ..()
	if(flags_gun_toggles & GUN_IFF_SYSTEM_ON)
		modify_fire_delay(FIRE_DELAY_TIER_12)
		remove_firemode(GUN_FIREMODE_BURSTFIRE)
		remove_firemode(GUN_FIREMODE_AUTOMATIC)

	else
		add_firemode(GUN_FIREMODE_BURSTFIRE)
		add_firemode(GUN_FIREMODE_AUTOMATIC)

/obj/item/weapon/gun/rifle/m46c/proc/name_after_co(mob/living/carbon/human/H)
	linked_human = H
	RegisterSignal(linked_human, COMSIG_PARENT_QDELETING, PROC_REF(remove_idlock))

/obj/item/weapon/gun/rifle/m46c/get_additional_gun_examine_text(mob/user)
	. = ..()
	if(linked_human)
		if(flags_gun_toggles & GUN_ID_LOCK_ON)
			. += SPAN_NOTICE("It is registered to [linked_human].")
		else
			. += SPAN_NOTICE("It is registered to [linked_human] but has its fire restrictions unlocked.")
	else
		. += SPAN_NOTICE("It's unregistered. Pick it up to register yourself as its owner.")
	if(!(flags_gun_toggles & GUN_IFF_SYSTEM_ON))
		. += SPAN_WARNING("Its IFF restrictions are disabled.")

/obj/item/weapon/gun/rifle/m46c/proc/remove_idlock()
	SIGNAL_HANDLER
	linked_human = null

/obj/item/weapon/gun/rifle/m46c/stripped
	random_attachment_chance = 0//no extra attachies on spawn, still gets its stock though.

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  MAR-40 BATTLE RIFLE               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//MAR-40 AK CLONE //AK47 and FN FAL together as one.

/obj/item/weapon/gun/rifle/mar40
	name = "\improper MAR-40 battle rifle"
	desc = "A cheap, reliable assault rifle chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries, or in the hands of the UPP or CLF."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mar40"
	item_state = "mar40"
	fire_sound = 'sound/weapons/gun_mar40.ogg'
	reload_sound = 'sound/weapons/handling/gun_mar40_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_mar40_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/mar40
	flags_gun_features = GUN_CAN_POINTBLANK
	start_automatic = TRUE
	random_attachment_chance = 38

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7
	burst_amount = BURST_AMOUNT_TIER_4

	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	recoil = RECOIL_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/mar40/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/scope/slavic,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 28, "muzzle_y" = 17,"rail_x" = 16, "rail_y" = 20, "under_x" = 24, "under_y" = 15, "stock_x" = 24, "stock_y" = 13))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/scope/slavic, /obj/item/attachable/magnetic_harness))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet/upp, /obj/item/attachable/extended_barrel, /obj/item/attachable/compensator))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(
			/obj/item/attachable/gyro,
			/obj/item/attachable/bipod,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/burstfire_assembly,
		))

	..()

/obj/item/weapon/gun/rifle/mar40/tactical
	desc = "A cheap, reliable assault rifle chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries, or in the hands of the UPP or CLF. This one has been equipped with an after-market ammo-counter."
	flags_gun_features = GUN_AMMO_COUNTER|GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	random_attachment_chance = 0

/obj/item/weapon/gun/rifle/mar40/tactical/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/angledgrip, /obj/item/attachable/suppressor, /obj/item/attachable/magnetic_harness))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     MAR-30 CARBINE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/mar40/carbine
	name = "\improper MAR-30 battle carbine"
	desc = "A cheap, reliable carbine chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries."
	icon_state = "mar30"
	item_state = "mar30"
	fire_sound = 'sound/weapons/gun_mar40.ogg'
	reload_sound = 'sound/weapons/handling/gun_mar40_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_mar40_unload.ogg'
	random_attachment_chance = 35

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9

	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE - BULLET_DAMAGE_MULT_TIER_2
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_3

	aim_slowdown = SLOWDOWN_ADS_QUICK //Carbine is more lightweight
	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/mar40/carbine/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
		))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/scope/mini, /obj/item/attachable/magnetic_harness))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet/upp, /obj/item/attachable/extended_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/bipod,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/lasersight,
		))

	..()

/obj/item/weapon/gun/rifle/mar40/carbine/tactical
	desc = "A cheap, reliable carbine chambered in 7.62x39mm. Commonly found in the hands of criminals or mercenaries. This one has been equipped with an after-market ammo-counter."
	flags_gun_features = GUN_AMMO_COUNTER|GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	random_attachment_chance = 0

/obj/item/weapon/gun/rifle/mar40/carbine/tactical/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/angledgrip, /obj/item/attachable/suppressor, /obj/item/attachable/magnetic_harness))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               MAR-50 LIGHT MACHINE GUN             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/mar40/lmg
	name = "\improper MAR-50 light machine gun"
	desc = "A cheap, reliable LMG chambered in 7.62x39mm. Commonly found in the hands of slightly better funded criminals."
	icon_state = "mar50"
	item_state = "mar50"
	fire_sound = 'sound/weapons/gun_mar40.ogg'
	reload_sound = 'sound/weapons/handling/gun_mar40_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_mar40_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/mar40/lmg
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_WIELDED_FIRING_ONLY
	random_attachment_chance = 38

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9
	burst_amount = BURST_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/mar40/lmg/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/mar50)) //This cannot be removed.
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/slavic,
		))
	INHERITLIST(attachable_offset, list("barrel_x" = 32, "barrel_y" = 16,"rail_x" = 16, "rail_y" = 20, "under_x" = 26, "under_y" = 16, "stock_x" = 24, "stock_y" = 13))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex, /obj/item/attachable/scope/slavic, /obj/item/attachable/magnetic_harness))

	..()

/obj/item/weapon/gun/rifle/mar40/lmg/tactical
	desc = "A cheap, reliable LMG chambered in 7.62x39mm. Commonly found in the hands of slightly better funded criminals. This one has been equipped with an after-market ammo-counter."
	flags_gun_features = GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK|GUN_WIELDED_FIRING_ONLY
	random_attachment_chance = 0

/obj/item/weapon/gun/rifle/mar40/lmg/tactical/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/mar50, /obj/item/attachable/bipod, /obj/item/attachable/magnetic_harness))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                         M16                        ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/m16
	name = "\improper M16 rifle"
	desc = "An old, reliable design first adopted by the U.S. military in the 1960s. Something like this belongs in a museum of war history. It is chambered in 5.56x45mm."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "m16"
	item_state = "m16"
	fire_sound = 'sound/weapons/gun_m16.ogg'
	reload_sound = 'sound/weapons/handling/gun_m16_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_m16_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE
	random_attachment_chance = 42
	pixel_width_offset = -4

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_6
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m16/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/m16))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/attached_gun/grenade,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/stock/m16,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 9, "rail_y" = 20, "under_x" = 22, "under_y" = 14, "stock_x" = 15, "stock_y" = 14))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/scope/mini))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/compensator, /obj/item/attachable/extended_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/gyro,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/bipod,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/lasersight,
		))

	..()

/obj/item/weapon/gun/rifle/m16/grenadier
	name = "\improper M16 grenadier rifle"
	desc = "An old, reliable design first adopted by the U.S. military in the 1960s. Something like this belongs in a museum of war history. It is chambered in 5.56x45mm. This one has an irremovable M203 grenade launcher attached to it, holds one propriatary 40mm shell at a time, it lacks modern IFF systems and will impact the first target it hits; introduce your little friend."
	icon_state = "m16g"
	item_state = "m16"
	fire_sound = 'sound/weapons/gun_m16.ogg'
	reload_sound = 'sound/weapons/handling/gun_m16_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_m16_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16

/obj/item/weapon/gun/rifle/m16/grenadier/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/m16, /obj/item/attachable/attached_gun/grenade/m203/grenadier))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/attached_gun/grenade/m203,
		))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex/,
			/obj/item/attachable/scope/mini,
		))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/compensator,
			/obj/item/attachable/extended_barrel,
		))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list()) //We want to make sure the grenade launcher spawns.

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                M16 DUTCH TEAM / ELITE              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/m16/dutch
	name = "\improper Dutch's M16A1"
	desc = "A modified M16 employed by Dutch's Dozen mercenaries. It has 'CLOAKER KILLER' printed on a label on the side. Chambered in 5.56x45mm."
	icon_state = "m16a1"
	current_mag = /obj/item/ammo_magazine/rifle/m16/ap

	//=========// GUN STATS //==========//
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m16/dutch/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/m16, /obj/item/attachable/bayonet)) //Will always spawn with a bayo in case random attachments do not spawn.
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/extended_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/lasersight,
		))

	..()

/obj/item/weapon/gun/rifle/m16/grenadier/dutch
	name = "\improper Dutch's Grenadier M16A1"
	desc = "A modified M16 employed by Dutch's Dozen mercenaries. It has 'CLOAKER KILLER' printed on a label on the side. It is chambered in 5.56x45mm. This one has an irremovable M203 grenade launcher attached to it, holds one propriatary 40mm shell at a time, it lacks modern IFF systems and will impact the first target it hits; introduce your little friend."
	current_mag = /obj/item/ammo_magazine/rifle/m16/ap

	//=========// GUN STATS //==========//
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m16/grenadier/dutch/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/m16, /obj/item/attachable/attached_gun/grenade/m203/grenadier, /obj/item/attachable/scope/mini, /obj/item/attachable/bayonet))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list()) //Make sure to spawn with the under grenade launcher.

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                    XM177E2 CARBINE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//awesome vietnam era special forces carbine version of the M16

/obj/item/weapon/gun/rifle/xm177
	name = "\improper XM177E2 carbine"
	desc = "An old design, essentially a shortened M16A1 with a collapsable stock. It is chambered in 5.56x45mm. The short length inhibits the attachment of most underbarrel attachments, and the barrel moderator prohibits the attachment of all muzzle devices."
	desc_lore = "A carbine similar to the M16A1, with a collapsible stock and a distinct flash suppressor. A stamp on the receiver reads: 'COLT AR-15 - PROPERTY OF U.S. GOVT - XM177E2 - CAL 5.56MM' \nA design originating from the Vietnam War, the XM177, also known as the Colt Commando or GAU-5/A, was an improvement on the CAR-15 Model 607, fixing multiple issues found with the limited service of the Model 607 with Special Forces. The XM177 saw primary use with Army Special Forces and Navy Seals operating as commandos. \nHow this got here is a mystery."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "xm177"
	item_state = "m16"
	fire_sound = 'sound/weapons/gun_m16.ogg'
	reload_sound = 'sound/weapons/handling/gun_m16_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_m16_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE
	random_attachment_chance = 75
	pixel_width_offset = -4

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay  = FIRE_DELAY_TIER_SMG

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_6
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/xm177/initialize_gun_lists()
	INHERITLIST(additional_type_magazines, list(/obj/item/ammo_magazine/rifle/m16, /obj/item/ammo_magazine/rifle/m16/ap,))
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/m16/xm177))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/stock/m16/xm177,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 30, "muzzle_y" = 18,"rail_x" = 9, "rail_y" = 20, "under_x" = 19, "under_y" = 13, "stock_x" = 15, "stock_y" = 14))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/flashlight))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/verticalgrip, /obj/item/attachable/lasersight))

	..()

/obj/item/weapon/gun/rifle/xm177/dutch
	name = "\improper Dutch's XM177E2 Carbine"
	desc = "A modified XM177 employed by Dutch's Dozen mercenaries. It has 'CLOAKER KILLER' printed on a label on the side. It is chambered in 5.56x45mm. The short length inhibits the attachment of most underbarrel attachments, and the barrel moderator prohibits the attachment of all muzzle devices."
	desc_lore = "A carbine similar to the M16A1, with a collapsible stock and a distinct flash suppressor. A stamp on the receiver reads: 'COLT AR-15 - PROPERTY OF U.S. GOVT - XM177E2 - CAL 5.56MM', above the receiver is a crude sketching of some sort of mask? with the words 'CLOAKER KILLER' and seven tally marks etched on. \nA design originating from the Vietnam War, the XM177, also known as the Colt Commando or GAU-5/A, was an improvement on the CAR-15 Model 607, fixing multiple issues found with the limited service of the Model 607 with Special Forces. The XM177 saw primary use with Army Special Forces and Navy Seals operating as commandos. \nHow this got here is a mystery."
	icon_state = "xm177"
	current_mag = /obj/item/ammo_magazine/rifle/m16/ap

	//=========// GUN STATS //==========//
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	//=========// GUN STATS //==========//

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                         AR10                       ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//basically an early M16

/obj/item/weapon/gun/rifle/ar10
	name = "\improper AR10 rifle"
	desc = "An earlier version of the more widespread M16 rifle. Considered to be the father of the 20th century rifle. How one of these ended up here is a mystery of its own. It is chambered in 7.62x51mm."
	desc_lore = "The AR10 was initially manufactured by the Armalite corporation (bought by Weyland-Yutani in 2002) in the 1950s. It was the first production rifle to incorporate many new and innovative features, such as a gas operated bolt and carrier system. Only 10,000 were ever produced, and the only national entities to use them were Portugal and Sudan. Since the end of the 20th century, these rifles - alongside the far more common M16 and AR15 - have floated around the less civillised areas of space, littering jungles and colony floors with their uncommon cased ammunition - a rarity since the introduction of pulse munitions. This rifle has the word \"Salazar\" engraved on its side."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "ar10"
	item_state = "ar10"
	fire_sound = 'sound/weapons/gun_ar10.ogg'
	reload_sound = 'sound/weapons/handling/gun_m16_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_ar10_unload.ogg'
	chamber_cycle_sound = 'sound/weapons/handling/gun_ar10_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/ar10
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE
	random_attachment_chance = 10
	pixel_width_offset = -4

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7
	burst_delay  = FIRE_DELAY_TIER_7

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_8
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/ar10/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/ar10))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/stock/ar10,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 8, "rail_y" = 20, "under_x" = 22, "under_y" = 14, "stock_x" = 15, "stock_y" = 14))
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reddot, /obj/item/attachable/reflex/, /obj/item/attachable/scope/mini))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet, /obj/item/attachable/compensator, /obj/item/attachable/extended_barrel))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/angledgrip, /obj/item/attachable/verticalgrip, /obj/item/attachable/bipod))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               M41AE2 HEAVY PULSE RIFLE             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/lmg
	name = "\improper M41AE2 heavy pulse rifle"
	desc = "A large squad support weapon capable of laying down sustained suppressing fire from a mounted position. While unstable and less accurate, it can be lugged and shot with two hands. Like it's smaller brothers, the M41A MK2 and M4RA, the M41AE2 is chambered in 10mm."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m41ae2"
	item_state = "m41ae2"
	reload_sound = 'sound/weapons/handling/hpr_reload.ogg'
	unload_sound = 'sound/weapons/handling/hpr_unload.ogg'
	fire_sound = 'sound/weapons/gun_hpr.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/lmg
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SUPPORT_PLATFORM
	gun_category = GUN_CATEGORY_HEAVY

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_LMG
	burst_amount = BURST_AMOUNT_TIER_5
	burst_delay  = FIRE_DELAY_TIER_LMG

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_3
	fa_max_scatter = SCATTER_AMOUNT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

	aim_slowdown = SLOWDOWN_ADS_LMG
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/lmg/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/bipod,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/magnetic_harness,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 23, "under_x" = 23, "under_y" = 12, "stock_x" = 24, "stock_y" = 12))

	..()

/obj/item/weapon/gun/rifle/lmg/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[         TYPE 71 PULSE RIFLE / UPP RIFLE            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/type71
	name = "\improper Type 71 pulse rifle"
	desc = "The primary service rifle of the UPP space forces, the Type 71 is an ergonomic, lightweight pulse rifle chambered in 5.45x39mm. In accordance with doctrinal principles of overmatch and suppression, the rifle has a high rate of fire and a high-capacity casket magazine. Despite lackluster precision, an integrated recoil-dampening mechanism makes the rifle surprisingly controllable in bursts."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type71"
	item_state = "type71"
	fire_sound = 'sound/weapons/gun_type71.ogg'
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/type71
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER //Roughly the same as the USCM
	flags_equip_slot = SLOT_BACK
	start_automatic = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_8
	burst_amount = BURST_AMOUNT_TIER_4
	burst_delay  = FIRE_DELAY_TIER_9

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_3

	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/type71/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/type71))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			))
	INHERITLIST(attachable_offset, list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 10, "rail_y" = 23, "under_x" = 20, "under_y" = 13, "stock_x" = 11, "stock_y" = 13))

	..()

/obj/item/weapon/gun/rifle/type71/rifleman
	//add GL
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/type71/rifleman/initialize_gun_lists()
	LAZYINITLIST(random_attachment_spawn_chance)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL], 40)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], 70)
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex,/obj/item/attachable/flashlight,))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/bayonet/upp))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/verticalgrip))

	..()

/obj/item/weapon/gun/rifle/type71/dual
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/type71/dual/initialize_gun_lists()
	LAZYINITLIST(random_attachment_spawn_chance)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL], 70)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER], 40)
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex, /obj/item/attachable/flashlight))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/bayonet/upp))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/lasersight, /obj/item/attachable/verticalgrip))

	..()

/obj/item/weapon/gun/rifle/type71/sapper
	current_mag = /obj/item/ammo_magazine/rifle/type71/ap
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/type71/sapper/initialize_gun_lists()
	LAZYINITLIST(random_attachment_spawn_chance)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL], 80)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE], 80)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER], 90)
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex, /obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/suppressor, /obj/item/attachable/bayonet/upp,))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/attached_gun/extinguisher,))

	..()

/obj/item/weapon/gun/rifle/type71/flamer
	name = "\improper Type 71-F pulse rifle"
	desc = " This appears to be a less common variant of the Type 71 with an integrated flamethrower that seems especially powerful."

/obj/item/weapon/gun/rifle/type71/flamer/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/attached_gun/flamer/advanced/integrated))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
		))

	..()

/obj/item/weapon/gun/rifle/type71/flamer/leader
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/type71/flamer/leader/initialize_gun_lists()
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex,/obj/item/attachable/flashlight,/obj/item/attachable/magnetic_harness,/obj/item/attachable/scope/mini))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/bayonet/upp))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                TYPE 71 PULSE CARBINE               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/type71/carbine
	name = "\improper Type 71 pulse carbine"
	desc = "A carbine variant of the Type 71, easier to handle at the cost of lesser damage, but negative soldier reviews have shifted it out of active use, given only to reserves or troops not expected to face much combat."
	icon_state = "type71c"
	item_state = "type71c"
	force = 20 //integrated melee mod from stock, which doesn't fit on the gun but is still clearly there on the sprite

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11//same fire rate as m41

	damage_mult = BULLET_DAMAGE_MULT_BASE - BULLET_DAMAGE_MULT_TIER_4//same damage as m41 reg bullets probably
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_4

	aim_slowdown = SLOWDOWN_ADS_QUICK //Carbine is more lightweight
	wield_delay = WIELD_DELAY_VERY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/type71/carbine/initialize_gun_lists()
	LAZYINITLIST(starting_attachment_types)
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/burstfire_assembly,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 14, "rail_y" = 23, "under_x" = 25, "under_y" = 14, "stock_x" = 24, "stock_y" = 13))

	..()

/obj/item/weapon/gun/rifle/type71/carbine/dual
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/type71/carbine/dual/initialize_gun_lists()
	LAZYINITLIST(random_attachment_spawn_chance)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL], 70)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER], 40)
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex, /obj/item/attachable/flashlight))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_MUZZLE], list(/obj/item/attachable/bayonet/upp))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/verticalgrip))

	..()

/obj/item/weapon/gun/rifle/type71/carbine/commando
	name = "\improper Type 71 'Commando' pulse carbine"
	desc = "A much rarer variant of the Type 71, this version contains an integrated suppressor, integrated scope, and extensive fine-tuning. Many parts have been replaced, filed down, and improved upon. As a result, this variant is rarely seen outside of commando units."
	icon_state = "type73"
	item_state = "type73"
	current_mag = /obj/item/ammo_magazine/rifle/type71/ap
	random_attachment_chance = 0 //Will not spawn with anything random.

	//=========// GUN STATS //==========//
	burst_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8

	wield_delay = WIELD_DELAY_NONE //Ends up being .5 seconds due to scope
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/type71/carbine/commando/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/suppressor/type73, /obj/item/attachable/scope/mini/hidden))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/verticalgrip))
	INHERITLIST(attachable_offset, list("muzzle_x" = 35, "muzzle_y" = 17,"rail_x" = 10, "rail_y" = 22, "under_x" = 23, "under_y" = 14, "stock_x" = 21, "stock_y" = 18))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   M4RA BATTLE RIFLE                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M4RA Battle Rifle, standard USCM DMR

/obj/item/weapon/gun/rifle/m4ra
	name = "\improper M4RA battle rifle"
	desc = "The M4RA battle rifle is a designated marksman rifle in service with the USCM. Sporting a bullpup configuration, the M4RA battle rifle is perfect for reconnaissance and fire support teams.\nTakes *only* non-high-velocity M4RA magazines."
	icon_state = "m4ra"
	item_state = "m4ra"
	fire_sound = 'sound/weapons/gun_m4ra.ogg'
	reload_sound = 'sound/weapons/handling/l42_reload.ogg'
	unload_sound = 'sound/weapons/handling/l42_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m4ra
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER //Has an ammo counter in lore.
	map_specific_decoration = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9
	burst_amount = BURST_AMOUNT_TIER_1 //No burst.

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_8
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	damage_falloff_mult = DAMAGE_FALLOFF_OFF
	scatter = SCATTER_AMOUNT_TIER_8

	wield_delay = WIELD_DELAY_VERY_FAST
	aim_slowdown = SLOWDOWN_ADS_QUICK
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m4ra/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/m4ra))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/bipod,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini_iff,
			/obj/item/attachable/flashlight/grip,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 43, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 21, "under_x" = 30, "under_y" = 13, "stock_x" = 24, "stock_y" = 13, "barrel_x" = 37, "barrel_y" = 16))

	..()

/obj/item/weapon/gun/rifle/m4ra/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

/obj/item/weapon/gun/rifle/m4ra/training
	current_mag = /obj/item/ammo_magazine/rifle/m4ra/rubber

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  L42A BATTLE RIFLE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/l42a
	name = "\improper L42A battle rifle"
	desc = "The L42A Battle Rifle, found commonly around the frontiers of the Galaxy. It's commonly used by colonists for self defense, as well as many colonial militias, whomever they serve due to it's rugged reliability and ease of use without much training. This rifle was put up for adoption by the USCM and tested for a time, but ultimately lost to the M4RA already in service."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "l42mk1"
	item_state = "l42mk1"
	reload_sound = 'sound/weapons/handling/l42_reload.ogg'
	unload_sound = 'sound/weapons/handling/l42_unload.ogg'
	fire_sound = 'sound/weapons/gun_carbine.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/l42a
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	map_specific_decoration = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9
	burst_amount = BURST_AMOUNT_TIER_1

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_6
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	damage_falloff_mult = DAMAGE_FALLOFF_OFF
	scatter = SCATTER_AMOUNT_TIER_8

	wield_delay = WIELD_DELAY_VERY_FAST
	aim_slowdown = SLOWDOWN_ADS_QUICK
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/l42a/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/carbine))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/stock/carbine,
			/obj/item/attachable/stock/carbine/wood,
			/obj/item/attachable/bipod,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini_iff,
			/obj/item/attachable/flashlight/grip,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 20, "under_x" = 18, "under_y" = 15, "stock_x" = 22, "stock_y" = 10))

	..()

/obj/item/weapon/gun/rifle/l42a/training
	current_mag = /obj/item/ammo_magazine/rifle/l42a/rubber

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 ABR-40 HUNTING RIFLE               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
// Civilian version of the L42A, used for hunting, and also by undersupplied paramilitary groups.

/obj/item/weapon/gun/rifle/l42a/abr40
	name = "\improper ABR-40 hunting rifle"
	desc = "The civilian version of the L42A battle rifle. Almost identical and even cross-compatible with L42 magazines, just don't take the stock off.."
	desc_lore = "The ABR-40 was created along-side the L42A as a hunting rifle for civilians. Sporting faux wooden furniture and a legally-mandated 12 round magazine, it's still highly accurate and deadly, a favored pick of experienced hunters and retired Marines. However, it's very limited in attachment selection, only being able to fit rail attachments, and the differences in design from the L42 force an awkward pose when attempting to hold it one-handed. Removing the stock is not recommended."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "abr40"
	item_state = "abr40"
	current_mag = /obj/item/ammo_magazine/rifle/l42a/abr40
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_WIELDED_FIRING_ONLY
	map_specific_decoration = FALSE
	civilian_usable_override = TRUE
	pixel_width_offset = -4

	//Identical to the L42 in stats, *except* for extra recoil and scatter that are nulled by keeping the stock on.
	//=========// GUN STATS //==========//
	accuracy_mult = (BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5) - HIT_ACCURACY_MULT_TIER_10
	recoil = RECOIL_AMOUNT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8 + SCATTER_AMOUNT_TIER_5

	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/l42a/abr40/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/carbine/wood, /obj/item/attachable/scope/mini/hunting))
	INHERITLIST(attachable_allowed, list(
			//Barrel,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			//Rail,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini/hunting,
			//Stock,
			/obj/item/attachable/stock/carbine,
			/obj/item/attachable/stock/carbine/wood,
			/obj/item/attachable/stock/carbine/wood/tactical,
		))

	..()

/obj/item/weapon/gun/rifle/l42a/abr40/tactical
	desc = "The civilian version of the L42A battle rifle that is often wielded by Marines. Almost identical and even cross-compatible with L42 magazines, just don't take the stock off. This rifle seems to have unique tacticool blue-black furniture alongside some miscellaneous aftermarket modding."
	desc_lore = "The ABR-40 was created after the striking popularity of the L42 battle rifle as a hunting rifle for civilians, and naturally fell into the hands of many underfunded paramilitary groups and insurrections in turn, due to its smooth and simple handling and cross-compatibility with L42A magazines."
	icon_state = "abr40_tac"
	item_state = "abr40_tac"
	current_mag = /obj/item/ammo_magazine/rifle/l42a/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_WIELDED_FIRING_ONLY
	random_attachment_chance = 100

/obj/item/weapon/gun/rifle/l42a/abr40/tactical/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/stock/carbine/wood/tactical, /obj/item/attachable/suppressor))
	INHERITLIST(attachable_allowed, list(
			//Barrel,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			//Rail,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini/hunting,
			//Under,
			/obj/item/attachable/flashlight/grip,
			//Stock,
			/obj/item/attachable/stock/carbine,
			/obj/item/attachable/stock/carbine/wood,
			/obj/item/attachable/stock/carbine/wood/tactical,
		))
	LAZYINITLIST(random_attachment_spawn_chance)
	INHERITLIST(random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER], 50)
	LAZYINITLIST(random_attachments_possible)
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_RAIL], list(/obj/item/attachable/reflex, /obj/item/attachable/magnetic_harness, /obj/item/attachable/scope, /obj/item/attachable/scope/mini/hunting))
	INHERITLIST(random_attachments_possible[ATTACHMENT_SLOT_UNDER], list(/obj/item/attachable/flashlight/grip))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[            F903A1 / ROYAL MARINE RIFLE             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/rmc_f90
	name = "\improper F903A1 Rifle"
	desc = "The standard issue rifle of the royal marines. Uniquely the royal marines are the only modern military to not use a pulse weapon. Uses 10x24mm caseless ammunition."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/twe_guns.dmi'
	icon_state = "aug"
	item_state = "aug"
	fire_sound = "gun_pulse"
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/rmc_f90
	projectile_casing = PROJECTILE_CASING_CASELESS
	flags_equip_slot = NO_FLAGS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	map_specific_decoration = FALSE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_8
	burst_delay = FIRE_DELAY_TIER_8

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4 + 2*HIT_ACCURACY_MULT_TIER_1
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2

	aim_slowdown = SLOWDOWN_ADS_QUICK
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/rmc_f90/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/suppressor,
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/magnetic_harness,
		))

	INHERITLIST(attachable_offset, list("muzzle_x" = 36, "muzzle_y" = 16,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13))

	..()

/obj/item/weapon/gun/rifle/rmc_f90/a_grip
	name = "\improper F903A2 Rifle"
	desc = "A non-standard issue rifle of the royal marines the F903A2 is currently being phased into the royal marines as their new mainline rifle but currently only sees use by unit leaders. Uniquely the royal marines are the only modern military to not use a pulse weapon. Uses 10x24mm caseless ammunition."
	icon_state = "aug_com"
	item_state = "aug_com"

/obj/item/weapon/gun/rifle/rmc_f90/a_grip/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/angledgrip/hidden))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/suppressor, /obj/item/attachable/reddot, /obj/item/attachable/reflex, /obj/item/attachable/extended_barrel))

	..()

/obj/item/weapon/gun/rifle/rmc_f90/scope
	name = "\improper F903A1 Marksman Rifle"
	desc = "A variation of the F903 rifle used by the royal marines commando. This weapon only accepts the smaller 20 round magazines of 10x24mm."
	icon_state = "aug_dmr"
	item_state = "aug_dmr"
	attachable_allowed = null
	current_mag = /obj/item/ammo_magazine/rifle/rmc_f90/marksman

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7
	burst_amount = BURST_AMOUNT_TIER_1

	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_6
	damage_falloff_mult = DAMAGE_FALLOFF_OFF
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/rmc_f90/scope/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/f90/dmr, /obj/item/attachable/scope/mini/f90, /obj/item/attachable/angledgrip/hidden))
	INHERITLIST(attachable_allowed, list()) //Nothing allowed since it has a full set that cannot be removed.
	INHERITLIST(attachable_offset, attachable_offset = list("barrel_x" = 33, "barrel_y" = 16,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13))

	..()

/obj/item/weapon/gun/rifle/rmc_f90/shotgun
	name = "\improper F903A1/B 'Breacher' Rifle"
	desc = "A variation of the F903 rifle used by the royal marines commando. Modified to be used in one hand with a shield. Uses 10x24mm caseless ammunition."
	icon_state = "aug_mkey"
	item_state = "aug_mkey"

	//=========// GUN STATS //==========//
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	recoil_unwielded = RECOIL_OFF
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/rmc_f90/shotgun/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/f90/shotgun, /obj/item/attachable/attached_gun/shotgun/hidden))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/reddot, /obj/item/attachable/reflex))
	INHERITLIST(attachable_offset, list("barrel_x" = 33, "barrel_y" = 16,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13))

	..()
