//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[              M4RA CUSTOM BATTLE RIFLE              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//M4RA custom marksman rifle
//Made this into a proper child of the m4ra.

/obj/item/weapon/gun/rifle/m4ra/custom
	name = "\improper M4RA custom battle rifle"
	desc = "This is a further improvement upon the already rock-solid M4RA. Made by the USCM armorers on Chinook station - This variant of the M4RA has a specifically milled magazine well to accept A19 rounds. It sports a light-weight titantium-alloy frame, better responsive to the heavy kick of the tailor-made A19 rounds."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m4ra_custom"
	item_state = "m4ra_custom"
	fire_sound = 'sound/weapons/gun_m4ra.ogg'
	reload_sound = 'sound/weapons/handling/l42_reload.ogg'
	unload_sound = 'sound/weapons/handling/l42_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m4ra/custom
	force = 26
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	flags_item = TWOHANDED|NO_CRYO_STORE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6
	burst_amount = BURST_AMOUNT_TIER_2
	burst_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

	wield_delay = WIELD_DELAY_NORMAL
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/m4ra/custom/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/m4ra_custom))
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
			/obj/item/attachable/attached_gun/shotgun,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/angledgrip,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/flashlight/grip,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 43, "muzzle_y" = 17,"rail_x" = 23, "rail_y" = 21, "under_x" = 30, "under_y" = 11, "stock_x" = 24, "stock_y" = 13, "barrel_x" = 37, "barrel_y" = 16))

	..()

/obj/item/weapon/gun/rifle/m4ra/custom/recalculate_user_attributes(mob/living/user)
	if(!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_SCOUT)
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()