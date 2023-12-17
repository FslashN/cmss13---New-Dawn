//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   GENERIC SHOTGUN                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
Shotguns always start with an ammo buffer and they work by alternating ammo and ammo_buffer1
in order to fire off projectiles. This is only done to enable burst fire for the shotgun.
Consequently, the shotgun should never fire more than three projectiles on burst as that
can cause issues with ammo types getting mixed up during the burst.

Changed shotguns a bit. Ammo in their referenced tube list[], if empty, is just null.
This is better than "empty" as a text string has value. null is easier to account for.
*/

/obj/item/weapon/gun/shotgun
	w_class = SIZE_LARGE
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	reload_sound = "shell_load"
	cocked_sound = 'sound/weapons/gun_shotgun_reload.ogg'
	var/break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	var/seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'
	accuracy_mult = 1.15
	flags_gun_features = GUN_CAN_POINTBLANK
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBERED_CYCLE|GUN_ACCEPTS_HANDFUL
	gun_category = GUN_CATEGORY_SHOTGUN
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN
	wield_delay = WIELD_DELAY_NORMAL //Shotguns are as hard to pull up as a rifle. They're quite bulky afterall
	has_empty_icon = FALSE
	has_open_icon = FALSE
	fire_delay_group = list(FIRE_DELAY_GROUP_SHOTGUN)
	projectile_casing = PROJECTILE_CASING_SHELL

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_5

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/unique_action(mob/user)
	cycle_chamber(user)

/obj/item/weapon/gun/shotgun/play_chamber_cycle_sound(mob/user, cocked_sound, volume = 20, sound_delay) //Quieter sound for cocking.
	..()

/obj/item/weapon/gun/shotgun/replace_magazine(mob/user, selection) //Shells are added forward, into the back of the tube.
	//We move the position up when loading ammo. New rounds are always fired first though, in position 1. Index tracks where the last shell was inserted.
	if(!(flags_gun_receiver & GUN_MANUAL_CYCLE) && !in_chamber) //Round has been loaded but nothing is chambered, for semi-auto shotguns.
		if(user_skill_level > SKILL_FIREARMS_CIVILIAN) //If we're skilled with firearms, automatically cock the gun.
			ready_in_chamber()
			play_chamber_cycle_sound(user, null, null, 0.5 SECONDS) //To account for loading the shell.

	playsound(user, reload_sound, 25, TRUE)

/obj/item/weapon/gun/shotgun/unload(mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	//Default behavior is that it will attempt to remove whatever is in the tube first, not the chamber.
	//We want to override that for pump actions and such.
	if(!current_mag.current_rounds && !in_chamber)
		if(user) to_chat(user, SPAN_WARNING("[src] is already empty."))	//If the gun is dry, cancel out.
		update_icon()
		return

	//We know there is something loaded in the gun, and we want to remove it.
	if(in_chamber) //Let's check the chamber first.
		//If there's nothing in the tube this will clear out first. Alternatively, pumps will try to remove a shell from the chamber first.
		if(!current_mag.current_rounds || ( flags_gun_receiver & GUN_MANUAL_CYCLE && !(flags_gun_receiver & GUN_CHAMBER_CAN_OPEN)) ) //The latter is for checking whether it's a pump or double.
			retrieve_shell(in_chamber.type, user)
			in_chamber = null

			GUN_DISPLAY_ROUNDS_REMAINING
			return //Exit out early, we don't evaluate the next if().

	if(current_mag.current_rounds) //It has some rounds. We'll fall back to this.
		var/current_rounds_string = "[current_mag.current_rounds--]" //Let's not forget to subtract a bullet.
		if(current_rounds_string in current_mag.feeder_contents) //Remove break point and switch ammo.
			current_mag.feeding_ammo = current_mag.feeder_contents[current_rounds_string]
			current_mag.feeder_contents -= current_rounds_string
		retrieve_shell(current_mag.feeding_ammo, user)

	GUN_DISPLAY_ROUNDS_REMAINING

/obj/item/weapon/gun/shotgun/proc/retrieve_shell(selection, mob/user)
	if(user) //Want to put into hand first.
		var/obj/item/ammo_magazine/handful/H = new
		H.generate_handful(selection, caliber, 1) //This updates the handful stats.
		user.put_in_hands(H)
		playsound(user, reload_sound, 25, 1)
	else //Otherwise we eject it on to the turf, combining handfuls as needed. User should exist, but maybe in the future that will change.
		eject_handful_to_turf(null, 1, selection)


//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                CUSTOM / MERC SHOTGUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Not really based on anything.

/obj/item/weapon/gun/shotgun/merc
	name = "custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "cshotgun"
	item_state = "cshotgun"
	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/merc
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_NO_SAFETY_SWITCH //No rules, no safety,

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6*2
	burst_amount = BURST_AMOUNT_TIER_2
	burst_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/merc/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/compensator,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 17, "under_y" = 14, "stock_x" = 17, "stock_y" = 14)

	..()

/obj/item/weapon/gun/shotgun/merc/damaged
	name = "damaged custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it. Well, it had one, this one's barrel has apparently exploded outwards like an overripe grape. Guess that's what happens when you DIY a shotgun."
	icon_state = "cshotgun_bad"

	//=========// GUN STATS //==========//
	fire_delay = 1.5 SECONDS
	burst_amount = BURST_AMOUNT_TIER_1

	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_3
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BULLET_DAMAGE_MULT_BASE - BULLET_DAMAGE_MULT_TIER_2
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	//=========// GUN STATS //==========//

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               MK221 TACTICAL SHOTGUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 tactical shotgun"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "mk221"
	item_state = "mk221"

	fire_sound = "gun_shotgun_tactical"
	firesound_volume = 20
	current_mag = /obj/item/ammo_magazine/internal/shotgun

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_5*2

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/combat/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/hidden, /obj/item/attachable/stock/tactical)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/stock/tactical,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 11, "stock_y" = 13.)

	..()

/obj/item/weapon/gun/shotgun/combat/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

/obj/item/weapon/gun/shotgun/combat/riot
	name = "\improper MK221 riot shotgun"
	icon_state = "mp220"
	item_state = "mp220"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate. Equipped with a steel blue finish to signify use in riot control. It has been modified to only fire 20G beanbags."
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat/riot

/obj/item/weapon/gun/shotgun/combat/guard
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate. Equipped with a red handle to signify its use with Military Police Honor Guards."
	icon_state = "mp221"
	item_state = "mp221"
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet)
	current_mag = /obj/item/ammo_magazine/internal/shotgun/buckshot

/obj/item/weapon/gun/shotgun/combat/covert
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/extended_barrel)
	current_mag = /obj/item/ammo_magazine/internal/shotgun/buckshot

//SOF MK210, an earlier developmental variant of the MK211 tactical used by USCM SOF.
/obj/item/weapon/gun/shotgun/combat/marsoc
	name = "\improper XM38 tactical shotgun"
	desc = "Way back in 2168, Wey-Yu began testing the MK221. The USCM picked up an early prototype, and later adopted it with a limited military contract. But the USCM Special Operations Forces wasn't satisfied, and iterated on the early prototypes they had access to; eventually, their internal armorers and tinkerers produced the MK210, designated XM38, a lightweight folding shotgun that snaps to the belt. And to boot, it's fully automatic, made of stamped medal, and keeps the UGL. Truly an engineering marvel."
	icon_state = "mk210"
	item_state = "mk210"
	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	auto_retrieval_slot = WEAR_J_STORE
	current_mag = /obj/item/ammo_magazine/internal/shotgun/buckshot
	start_automatic = TRUE
	pixel_width_offset = -3

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3 - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/combat/marsoc/initialize_gun_lists()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16)

	..()

/obj/item/weapon/gun/shotgun/combat/marsoc/retrieve_to_slot(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_J_STORE) //If we are using a magharness...
		if(..(user, WEAR_WAIST)) //...first try to put it onto the waist.
			return TRUE
	return ..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                TYPE 23 RIOT SHOTGUN                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//SEMI-AUTO UPP SHOTGUN, BASED ON KS-23

/obj/item/weapon/gun/shotgun/type23
	name = "\improper Type 23 riot shotgun"
	desc = "As UPP soldiers frequently reported being outmatched by enemy combatants, UPP High Command commissioned a large amount of Type 23 shotguns, originally used for quelling defector colony riots. This slow semi-automatic shotgun chambers 8 gauge, and packs a mean punch."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type23"
	item_state = "type23"
	fire_sound = 'sound/weapons/gun_type23.ogg' //not perfect, too small
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	flags_equip_slot = SLOT_BACK
	map_specific_decoration = FALSE

	//=========// GUN STATS //==========//
	fire_delay = 2.5 SECONDS //TODO Make it into its own define?

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/type23/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/type23)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/bayonet, // Muzzle
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/verticalgrip, // Underbarrel
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/burstfire_assembly,
			/obj/item/attachable/stock/type23, // Stock
			)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 21, "under_x" = 24, "under_y" = 15, "stock_x" = -1, "stock_y" = 17)

	..()

/obj/item/weapon/gun/shotgun/type23/breacher
	random_attachment_chance = 100

/obj/item/weapon/gun/shotgun/type23/breacher/initialize_gun_lists()

	if(!random_attachment_spawn_chance)
		random_attachment_spawn_chance = list()

	if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER])
		random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER] = 40 //Everything else 100.

	if(!random_attachments_possible)
		random_attachments_possible = list()

	if(!random_attachments_possible[ATTACHMENT_SLOT_RAIL])
		random_attachments_possible[ATTACHMENT_SLOT_RAIL] = list(
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/flashlight
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_MUZZLE])
		random_attachments_possible[ATTACHMENT_SLOT_MUZZLE]	= list(
			/obj/item/attachable/bayonet/upp
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_UNDER])
		random_attachments_possible[ATTACHMENT_SLOT_UNDER] = list(
			/obj/item/attachable/verticalgrip
		)

	..()

/obj/item/weapon/gun/shotgun/type23/breacher/slug
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/slug

/obj/item/weapon/gun/shotgun/type23/breacher/flechette
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/flechette

/obj/item/weapon/gun/shotgun/type23/dual
	random_attachment_chance = 100

/obj/item/weapon/gun/shotgun/type23/dual/initialize_gun_lists()

	if(!random_attachment_spawn_chance)
		random_attachment_spawn_chance = list()

	if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE])
		random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE] = 80

	if(!random_attachments_possible)
		random_attachments_possible = list()

	if(!random_attachments_possible[ATTACHMENT_SLOT_RAIL])
		random_attachments_possible[ATTACHMENT_SLOT_RAIL] = list(
			/obj/item/attachable/magnetic_harness
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_MUZZLE])
		random_attachments_possible[ATTACHMENT_SLOT_MUZZLE]	= list(
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/heavy_barrel
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_UNDER])
		random_attachments_possible[ATTACHMENT_SLOT_UNDER] = list(
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/verticalgrip
		)

	..()

/obj/item/weapon/gun/shotgun/type23/dragon
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/dragonsbreath

/obj/item/weapon/gun/shotgun/type23/dragon/initialize_gun_lists()

	if(!random_attachment_spawn_chance)
		random_attachment_spawn_chance = list()

	if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE])
		random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE] = 70

	if(!random_attachments_possible)
		random_attachments_possible = list()

	if(!random_attachments_possible[ATTACHMENT_SLOT_RAIL])
		random_attachments_possible[ATTACHMENT_SLOT_RAIL] = list(
			/obj/item/attachable/magnetic_harness
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_MUZZLE])
		random_attachments_possible[ATTACHMENT_SLOT_MUZZLE]	= list(
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/heavy_barrel
		)

	if(!random_attachments_possible[ATTACHMENT_SLOT_UNDER])
		random_attachments_possible[ATTACHMENT_SLOT_UNDER] = list(
			/obj/item/attachable/attached_gun/extinguisher
		)

	..()

/obj/item/weapon/gun/shotgun/type23/riot_control
	name = "\improper Type 23-R riot control shotgun"
	desc = "This slow semi-automatic shotgun chambers 8 gauge, and packs a mean punch. The -R version is designed for UPP colony security personnel and handling colony rioting, sporting an integrated vertical grip but lacking in attachment choices."
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/beanbag
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	flags_equip_slot = SLOT_BACK
	map_specific_decoration = FALSE

/obj/item/weapon/gun/shotgun/type23/riot_control/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/type23, /obj/item/attachable/verticalgrip/integrated)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot, //Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/verticalgrip, //Underbarrel
			/obj/item/attachable/stock/type23, //Stock
		)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[         SPEARHEAD RIVAL 78 / DOUBLE SHOTTY         ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/shotgun/double
	name = "\improper Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. Only holds two 12g shells at a time."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "dshotgun"
	item_state = "dshotgun"
	fire_sound = 'sound/weapons/gun_shotgun_heavy.ogg'
	break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'//replace w/ uniques
	cocked_sound = null //We don't want this.
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_MANUAL_CYCLE|GUN_CHAMBER_CAN_OPEN|GUN_ACCEPTS_HANDFUL
	has_open_icon = TRUE
	civilian_usable_override = TRUE // Come on. It's THE survivor shotgun.
	pixel_width_offset = -4

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_2
	fire_delay = FIRE_DELAY_TIER_11
	burst_delay = FIRE_DELAY_BURST_OFF //So doubleshotty can doubleshot

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

	cycle_chamber_delay = 5 //Small delay between opening/closing the shotgun.
	additional_fire_group_delay = 1.5 SECONDS
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/double/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/stock/double,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 20, "under_x" = 15, "under_y" = 14, "stock_x" = 13, "stock_y" = 14)

	..()

/obj/item/weapon/gun/shotgun/double/get_additional_gun_examine_text(mob/user)
	. = ..() + ( flags_gun_receiver & GUN_CHAMBER_IS_OPEN ? "It's open with [current_mag.current_rounds? current_mag.current_rounds : "no"] shell\s loaded." : "It's closed." )

/obj/item/weapon/gun/shotgun/double/unique_action(mob/user)
	if(flags_item & WIELDED) unwield(user)
	cycle_chamber(user)

/obj/item/weapon/gun/shotgun/double/unload(mob/user)
	if(flags_gun_receiver & GUN_CHAMBER_IS_OPEN)
		..()
	else
		cycle_chamber(user)

//This opens or closes the shotgun.
/obj/item/weapon/gun/shotgun/double/cycle_chamber(mob/user)
	if(cycle_chamber_cooldown > world.time)
		return

	cycle_chamber_cooldown = world.time + cycle_chamber_delay

	flags_gun_receiver ^= GUN_CHAMBER_IS_OPEN
	make_casing(projectile_casing)
	update_icon()

	play_chamber_cycle_sound(user, ( flags_gun_receiver & GUN_CHAMBER_IS_OPEN ? seal_sound : break_sound ), 20)

/obj/item/weapon/gun/shotgun/double/with_stock/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/double)

	..()

/obj/item/weapon/gun/shotgun/double/damaged
	name = "semi-sawn-off Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. For some reason it seems that someone tried to saw through the barrel and gave up halfway through. This probably isn't going to be the greatest gun for combat.."
	icon_state = "dshotgun_bad"

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = 0.9 SECONDS

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BULLET_DAMAGE_MULT_BASE - BULLET_DAMAGE_MULT_TIER_7
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/double/sawn
	name = "\improper sawn-off Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. It has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = SLOT_WAIST

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3 - HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_7
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/double/sawn/initialize_gun_lists()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 19, "rail_x" = 11, "rail_y" = 20, "under_x" = 15, "under_y" = 14,  "stock_x" = 18, "stock_y" = 16)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                CANE / HIDDEN SHOTGUN?              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
// COULDN'T THINK OF ANOTHER WAY SORRY!!!! SOMEONE ADD A GUN COMPONENT!! <---- Original comment.
//I'm not really sure what to make of this. The text referred to this as a cane revolver, yet it didn't load or behave like a revolver.
//I have decided to change the text for now.

/obj/item/weapon/gun/shotgun/double/cane
	name = "fancy cane"
	desc = "An ebony cane with a fancy, seemingly-golden tip. Feels hollow to the touch."
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "fancy_cane"
	item_state = "fancy_cane"
	pickup_sound = null
	drop_sound = null
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_0.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_0.dmi'
		)
	force = 15 // hollow. also too hollow to support one's weight like normal canes
	attack_speed = 1.5 SECONDS
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/cane
	break_sound = 'sound/weapons/handling/pkd_open_chamber.ogg'
	seal_sound = 'sound/weapons/handling/pkd_close_chamber.ogg'
	projectile_casing = PROJECTILE_CASING_BULLET
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_ANTIQUE|GUN_NO_DESCRIPTION|GUN_UNUSUAL_DESIGN
	flags_gun_toggles = GUN_TRIGGER_SAFETY_ON
	flags_item = NO_FLAGS

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = FIRE_DELAY_TIER_7

	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_5
	recoil = RECOIL_AMOUNT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/double/cane/initialize_gun_lists()

	if(!fire_sound)
		fire_sound = list('sound/weapons/gun_silenced_oldshot1.ogg', 'sound/weapons/gun_silenced_oldshot2.ogg') // Uses the old sounds because they're more 'James Bond'-y

	if(!attachable_allowed)
		attachable_allowed = list() //Reset this.

	if(!inherent_traits)
		inherent_traits = list(TRAIT_GUN_IS_SILENCED)

	..()

/obj/item/weapon/gun/shotgun/double/cane/Initialize(mapload, spawn_empty)
	. = ..()
	AddElement(/datum/element/traitbound/gun_silenced)

/obj/item/weapon/gun/shotgun/double/cane/gun_safety_handle(mob/user)
	if(flags_gun_toggles & GUN_TRIGGER_SAFETY_ON)
		to_chat(user, SPAN_NOTICE("You turn [src] back into its normal cane stance."))
		playsound(user, 'sound/weapons/handling/nsg23_unload.ogg', 25, 1)
	else
		to_chat(user, SPAN_DANGER("You unlock the safety and change [src] into its gun stance!"))
		playsound(user, 'sound/weapons/handling/smg_reload.ogg', 25, 1)

	if(flags_gun_receiver & GUN_CHAMBER_IS_OPEN) // close the chamber
		cycle_chamber(user, TRUE)

	update_icon()

	playsound(user, 'sound/weapons/handling/safety_toggle.ogg', 25, 1)

/obj/item/weapon/gun/shotgun/double/cane/cycle_chamber(mob/user, override)
	if(flags_gun_toggles & GUN_TRIGGER_SAFETY_ON && !override)
		to_chat(user, SPAN_WARNING("Not with the safety on!"))
		return
	. =  ..()

/obj/item/weapon/gun/shotgun/double/cane/update_icon()
	if(flags_gun_toggles & GUN_TRIGGER_SAFETY_ON)
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
	else
		name = "cane gun"
		desc = initial(desc) + " Apparently, because it's also a gun. Who'da thunk it?" //Was "revolver" instead of gun, but I'm not sure how that makes sense.
		icon_state = initial(icon_state) + (flags_gun_receiver & GUN_CHAMBER_IS_OPEN ? "_gun_open" : "_gun")

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 MOU53 BREAK ACTION                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Marine mid-range slug/flechette only coach gun (except its an over-under). Support weapon for slug stuns / flechette DOTS (when implemented). Buckshot in this thing is just stupidly strong, hence the denial.

/obj/item/weapon/gun/shotgun/double/mou53
	name = "\improper MOU53 break action shotgun"
	desc = "A limited production Kerchner MOU53 triple break action classic. Respectable damage output at medium ranges, while the ARMAT M37 is the king of CQC, the Kerchner MOU53 is what hits the broadside of that barn. This specific model cannot safely fire buckshot shells."
	icon_state = "mou"
	item_state = "mou"
	fire_sound = 'sound/weapons/gun_mou53.ogg'
	reload_sound = 'sound/weapons/handling/gun_mou_reload.ogg'//unique shell insert
	flags_equip_slot = SLOT_BACK
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/mou53 //Take care, she comes loaded!
	map_specific_decoration = TRUE
	civilian_usable_override = FALSE
	pixel_width_offset = -1

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/double/mou53/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/gyro,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/stock/mou53,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 11, "rail_y" = 21, "under_x" = 17, "under_y" = 15, "stock_x" = 10, "stock_y" = 9) //Weird stock values, make sure any new stock matches the old sprite placement in the .dmi

	..()

/obj/item/weapon/gun/shotgun/double/mou53/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(ispath(magazine.default_ammo, /datum/ammo/bullet/shotgun/buckshot)) // No buckshot in this gun
		to_chat(user, SPAN_WARNING("\the [src] cannot safely fire this type of shell!"))
		return
	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[              TWO-BORE RIFLE / SHOTGUN              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Van Bandolier's ginormous elephant gun.

/datum/action/item_action/specialist/twobore_brace
	ability_primacy = SPEC_PRIMARY_ACTION_1

/datum/action/item_action/specialist/twobore_brace/New(mob/living/user, obj/item/holder)
	..()
	name = "Brace for Recoil"
	action_icon_state = "twobore_brace"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/specialist/twobore_brace/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(H.is_mob_incapacitated() || H.get_active_hand() != holder_item)
		return
	if(H.action_busy)
		to_chat(H, SPAN_WARNING("You're already doing something!"))
		return
	return TRUE

/datum/action/item_action/specialist/twobore_brace/action_cooldown_check()
	var/obj/item/weapon/gun/shotgun/double/twobore/G = holder_item
	if(G.braced)
		return TRUE

/datum/action/item_action/specialist/twobore_brace/action_activate()
	var/obj/item/weapon/gun/shotgun/double/twobore/G = holder_item
	if(G.braced)
		return
	var/mob/living/carbon/human/H = owner
	if(!do_after(H, 0.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE)) //Takes a moment to brace to fire.
		to_chat(H, SPAN_WARNING("You were interrupted!"))
		return
	H.visible_message(SPAN_WARNING("[H] braces himself to fire the [initial(G.name)]."),\
			SPAN_WARNING("You brace yourself to fire the [initial(G.name)]."))
	G.brace(H)
	update_button_icon()

/obj/item/weapon/gun/shotgun/double/twobore
	name = "two-bore rifle"
	desc = "An enormously heavy double-barreled rifle with a bore big enough to fire the Moon. If you want an intact trophy, don't aim for the head. \nThe recoil is apocalyptic: if you aren't highly experienced with it and braced using a Specialist Activation, you won't get a second shot."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/event.dmi'
	icon_state = "twobore"
	item_state = "twobore"
	fire_sound = 'sound/weapons/gun_mateba.ogg'
	break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'//replace w/ uniques
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/twobore
	projectile_casing = PROJECTILE_CASING_TWOBORE
	delay_style = WEAPON_DELAY_NO_FIRE //This is a heavy, bulky weapon, and tricky to snapshot with.
	flags_equip_slot = SLOT_BACK
	aim_slowdown = SLOWDOWN_ADS_LMG //Quite slow, but VB has light-armor slowdown and doesn't feel pain.
	civilian_usable_override = FALSE
	pixel_width_offset = 0
	var/braced = FALSE

	//=========// GUN STATS //==========//
	force = 20 //Big heavy elephant gun.
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = 2 SECONDS//Less than the stun time, but you still have to brace to fire safely.

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_OFF //This is done manually.
	recoil_unwielded = RECOIL_OFF
	//=========// GUN STATS //==========//


/obj/item/weapon/gun/shotgun/double/twobore/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/twobore)

	if(!attachable_allowed)
		attachable_allowed = list()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 0, "stock_y" = 16)

	if(!actions_types)
		actions_types = list(/datum/action/item_action/specialist/twobore_brace)

	..()

/obj/item/weapon/gun/shotgun/double/twobore/proc/brace(mob/living/carbon/human/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(unbrace), user)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(unbrace), user)
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(unbrace), user)
	braced = TRUE

///Returns TRUE if the gun was braced.
/obj/item/weapon/gun/shotgun/double/twobore/proc/unbrace(mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(braced)
		to_chat(user, SPAN_NOTICE("You relax your stance."))
		braced = FALSE
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()
		return TRUE

/obj/item/weapon/gun/shotgun/double/twobore/item_action_slot_check(mob/user, slot)
	if(HAS_TRAIT(user, TRAIT_TWOBORE_TRAINING)) //Only the hunter himself knows how to use this weapon properly.
		return TRUE

/obj/item/weapon/gun/shotgun/double/twobore/Fire(atom/target, mob/living/carbon/human/user, params, reflex = 0, dual_wield) //Using this instead of apply_bullet_effects() as RPG does so I get more granular angles than just user direction.
	. = ..()
	if(.)
		twobore_recoil(user, Get_Compass_Dir(user, target)) //More precise than get_dir().

/obj/item/weapon/gun/shotgun/double/twobore/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(.)
		var/target_angle
		if(M != user && get_turf(M) != get_turf(user))
			target_angle = get_dir(user, M)
		twobore_recoil(user, target_angle)

/obj/item/weapon/gun/shotgun/double/twobore/proc/twobore_recoil(mob/living/carbon/human/user, target_angle)
	var/turf/start_turf = get_turf(user)
	//Muzzle smoke. Black powder is messy.
	var/obj/effect/particle_effect/smoke/newsmoke = new(get_step(start_turf, target_angle), 1, src, user)
	newsmoke.time_to_live = 3

	var/suicide //Target is or is on the same tile as the shooter. Means the gun goes one way and the shooter stays.
	var/behind_angle
	if(target_angle)
		behind_angle = REVERSE_DIR(target_angle)
	else
		suicide = TRUE
		behind_angle = pick(CARDINAL_ALL_DIRS) //Random angle

	if(flags_item & WIELDED)
		if(braced && !suicide) //Recoil and brief stun but nothing more. Gun is huge and you can't brace properly when shooting at extreme (same tile) close range.
			user.visible_message(SPAN_WARNING("[user] rocks back under the heavy recoil of the [initial(name)]."),\
				SPAN_DANGER("The [initial(name)] kicks like an elephant!"))
			unbrace(user)
			user.apply_effect(1, STUN) //Van Bandolier is a human/hero and stuns last half as long for him.
			shake_camera(user, RECOIL_AMOUNT_TIER_2 * 0.5, RECOIL_AMOUNT_TIER_2)
			return
	else //You *do not* fire this one-handed.
		var/obj/limb/shoulder
		if(user.hand) //They're using their left hand.
			shoulder = user.get_limb("l_arm")
			user.apply_damage(15, BRUTE, "l_arm")
		else
			shoulder = user.get_limb("r_arm")
			user.apply_damage(15, BRUTE, "r_arm")
		shoulder.fracture(100)
		if(!(shoulder.status & LIMB_SPLINTED_INDESTRUCTIBLE) && (shoulder.status & LIMB_SPLINTED)) //If they have it splinted, the splint won't hold.
			shoulder.status &= ~LIMB_SPLINTED
			playsound(get_turf(loc), 'sound/items/splintbreaks.ogg', 20)
			to_chat(user, SPAN_DANGER("The splint on your [shoulder.display_name] comes apart under the recoil!"))
			user.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)
			user.update_med_icon()

	//Ruh roh.
	user.visible_message(SPAN_WARNING("[user] is thrown to the ground by the recoiling [initial(name)]!"),\
		SPAN_HIGHDANGER("The world breaks in half!"))
	shake_camera(user, RECOIL_AMOUNT_TIER_1 * 0.5, RECOIL_AMOUNT_TIER_1)

	var/turf/behind_turf = get_step(user, behind_angle)
	if(suicide || !behind_turf) //in case of map edge or w/e. If firing at something on the same tile, we don't throw the gun as far away.
		behind_turf = start_turf

	//Assemble a list of target turfs in a rough cone behind us.
	var/list/throw_turfs = list(
		get_step(behind_turf, behind_angle),
		get_step(behind_turf, turn(behind_angle, 45)),
		get_step(behind_turf, turn(behind_angle, -45))
		)

	//Sift through the turfs to remove ones that don't exist, and move ones that we can't throw the whole way into to a last-resort list.
	var/list/bad_turfs = list()
	add_temp_pass_flags(PASS_OVER_THROW_ITEM) //We'll be using the gun to test objects to see if it can pass over, so we set throw flags on.
	for(var/turf/T in throw_turfs)
		if(!T) //Off edge of map.
			throw_turfs.Remove(T)
			continue
		var/list/turf/path = getline2(get_step_towards(src, T), T) //Same path throw code will calculate from.
		if(!path.len)
			throw_turfs.Remove(T)
			continue
		var/prev_turf = start_turf
		for(var/turf/P in path)
			if(P.density || LinkBlocked(src, prev_turf, P))
				throw_turfs.Remove(T)
				bad_turfs.Add(T)
				break
			prev_turf = P
	remove_temp_pass_flags(PASS_OVER_THROW_ITEM)

	//Pick a turf to throw into.
	var/throw_turf
	var/throw_strength = 1
	if(length(throw_turfs)) //If there's any ideal throwpaths, pick one.
		throw_turf = pick(throw_turfs)
		throw_strength = suicide ? 1 : 2
	else if(length(bad_turfs)) //Otherwise, pick from blocked paths.
		throw_turf = pick(bad_turfs)
	else //If there's nowhere to put it, throw it to the same place we're putting the shooter.
		throw_turf = behind_turf

	user.drop_inv_item_on_ground(src)
	throw_atom(throw_turf, throw_strength, SPEED_AVERAGE, src, TRUE)

	user.apply_effect(2, WEAKEN)
	user.apply_effect(3, DAZE)
	if(!suicide && !step(user, behind_angle))
		user.animation_attack_on(behind_turf)
		playsound(user.loc, "punch", 25, TRUE)
		var/blocker = LinkBlocked(user, start_turf, behind_turf) //returns any objects blocking the user from moving back.
		if(blocker)
			user.visible_message(SPAN_DANGER("[user] slams into [blocker]!"),\
				SPAN_DANGER("The [initial(name)]'s recoil hammers you against [blocker]!"))
		else
			user.visible_message(SPAN_DANGER("[user] slams into an obstacle!"),\
				SPAN_DANGER("The [initial(name)]'s recoil hammers you against an obstacle!"))
		user.apply_damage(5, BRUTE)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 M37A2 PUMP SHOTGUN                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 pump shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Requires a pump, which is a Unique Action."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m37"
	item_state = "m37"
	current_mag = /obj/item/ammo_magazine/internal/shotgun
	flags_equip_slot = SLOT_BACK
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	firesound_volume = 60
	cocked_sound = "shotgunpump"
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBERED_CYCLE|GUN_MANUAL_CYCLE|GUN_ACCEPTS_HANDFUL
	map_specific_decoration = TRUE

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_1
	fire_delay = FIRE_DELAY_TIER_7 * 4

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

	cycle_chamber_delay = FIRE_DELAY_TIER_5*2
	additional_fire_group_delay = FIRE_DELAY_TIER_5*2 //Should be identical to the above.
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/pump/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/bayonet/co2,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/flashlight/grip,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
			/obj/item/attachable/stock/shotgun,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 20, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)

	..()

/obj/item/weapon/gun/shotgun/pump/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

//Modern shotguns normally lock after being pumped; this lock is undone by operating the slide release i.e. unloading a shell manually from the chamber.
//Taking a shell from the gun will attempt to disengage the lock first and clear the chamber before grabbing shells from the tube.
//No more a lock variable. Tracked via in_chamber only now.

/obj/item/weapon/gun/shotgun/pump/cycle_chamber(mob/user) //We can't fire bursts with pumps.
	if(cycle_chamber_cooldown > world.time)
		return

	cycle_chamber_cooldown = world.time + cycle_chamber_delay

	//The chamber is locked when something is loaded.
	if(in_chamber)
		to_chat(user, SPAN_WARNING("<i>[src] already has a shell in the chamber and is locked! Interact with it to release the slide.<i>"))
		return

	make_casing(projectile_casing)

	//Chamber as needed.
	play_chamber_cycle_sound(user, null, 25)
	if(current_mag.current_rounds) ready_in_chamber()
	//We cannot eject shells with this, so counting ammo here is unnecessary.

//You can manually unload a shell when the lock is engaged. Ie, something is chambered.
/obj/item/weapon/gun/shotgun/pump/unload(mob/user)
	if(in_chamber)
		to_chat(user, SPAN_WARNING("You disengage [src]'s pump lock with the slide release."))
	. = ..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               GENERIC DUAL TUBE PUMP               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/shotgun/pump/dual_tube
	name = "generic dual-tube pump shotgun"
	desc = "A twenty-round pump action shotgun with dual internal tube magazines. You can switch the active internal magazine by toggling the shotgun tube."
	current_mag = /obj/item/ammo_magazine/internal/shotgun
	var/obj/item/ammo_magazine/internal/shotgun/primary_tube
	var/obj/item/ammo_magazine/internal/shotgun/secondary_tube

/obj/item/weapon/gun/shotgun/pump/dual_tube/Initialize(mapload, spawn_empty)
	. = ..()
	primary_tube = current_mag
	secondary_tube = new current_mag.type(src, spawn_empty)//Starts with the primary tube.

/obj/item/weapon/gun/shotgun/pump/dual_tube/Destroy()
	QDEL_NULL(primary_tube)
	QDEL_NULL(secondary_tube)
	. = ..()

/obj/item/weapon/gun/shotgun/pump/dual_tube/proc/swap_tube(mob/user)
	if(!ishuman(user) || user.is_mob_incapacitated())
		return FALSE
	var/obj/item/weapon/gun/shotgun/pump/dual_tube/shotgun = user.get_active_hand()
	if(shotgun != src)
		to_chat(user, SPAN_WARNING("You must be holding \the [src] in your active hand to switch the active internal magazine!")) // currently this warning can't show up, but this is incase you get an action button or similar for it instead of current implementation
		return
	if(!current_mag)
		return

	current_mag = current_mag == primary_tube ? secondary_tube : primary_tube

	to_chat(user, SPAN_NOTICE("[icon2html(src, user)] You switch \the [src]'s active magazine to the [(current_mag == primary_tube) ? "<b>first</b>" : "<b>second</b>"] magazine."))

	playsound(src, 'sound/machines/switch.ogg', 15, TRUE)

	GUN_DISPLAY_ROUNDS_REMAINING

	return TRUE

/obj/item/weapon/gun/shotgun/pump/dual_tube/verb/toggle_tube()
	set category = "Weapons"
	set name = "Toggle Shotgun Tube"
	set desc = "Toggles which shotgun tube your gun loads from."
	set src = usr.contents

	var/obj/item/weapon/gun/shotgun/pump/dual_tube/shotgun = get_active_firearm(usr)
	if(shotgun == src)
		swap_tube(usr)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                HG 37-12 PUMP SHOTGUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//SHOTGUN FROM ISOLATION

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb
	name = "\improper HG 37-12 pump shotgun"
	desc = "A eight-round pump action shotgun with four-round capacity dual internal tube magazines allowing for quick reloading and highly accurate fire. Used exclusively by Colonial Marshals. You can switch the active internal magazine by toggling the shotgun tube."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "hg3712"
	item_state = "hg3712"
	fire_sound = 'sound/weapons/gun_shotgun_small.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/cmb
	map_specific_decoration = FALSE
	civilian_usable_override = TRUE // Come on. It's THE, er, other, survivor shotgun.

	//=========// GUN STATS //==========//
	fire_delay = 1.6 SECONDS

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/hg3712)

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/gyro,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/compensator,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/attached_gun/extinguisher,
			/obj/item/attachable/attached_gun/flamer,
			/obj/item/attachable/attached_gun/flamer/advanced,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 8, "rail_y" = 21, "under_x" = 22, "under_y" = 15, "stock_x" = 24, "stock_y" = 10)


	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                HG 37-17 PUMP SHOTGUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/m3717
	name = "\improper M37-17 pump shotgun"
	desc = "A military version of the iconic HG 37-12, this design can fit one extra shell in each of its dual-tube internal magazines, and fires shells with increased velocity, resulting in more damage. Issued to select USCM vessels and stations in the outer veil. A button on the side toggles the internal tubes."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m3717"
	item_state = "m3717"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/cmb/m3717

	//=========// GUN STATS //==========//
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_3
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/m3717/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/stock/hg3712/m3717)

	..()
