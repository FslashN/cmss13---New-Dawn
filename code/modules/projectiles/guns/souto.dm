//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               SOUTO SLINGER SUPREMO                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/souto
	name = "\improper Souto Slinger Supremo"
	desc = "This appears to be a T-shirt cannon modified to fire cans of Souto at speeds fast enough to get them up into the top stands of a stadium. This can't be safe. Cobbled together in Havana."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/event.dmi'
	icon_state = "supremo_w"
	item_state = "supremo_w"
	w_class = SIZE_SMALL
	fire_sound = 'sound/items/syringeproj.ogg'
	attachable_allowed = list()
	has_empty_icon = 0
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER|GUN_NO_SAFETY_SWITCH
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBER_IS_STATIC
	current_mag = null
	auto_retrieval_slot = WEAR_IN_BACK
	start_automatic = TRUE
	var/range = 6 // This var is used as range for the weapon/toy.
	var/obj/item/storage/backpack/souto/soutopack

	//=========// GUN STATS //==========//
	accuracy_mult = BASE_ACCURACY_MULT + 2*HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10

	autofire_slow_mult = 0.8 //Fires FASTER when in Full Auto, that is the power of Souta
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/souto/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	if(!soutopack)
		if(!link_soutopack(user))
			to_chat(user, "You must equip the specialized Backpack Souto Vending Machine to use the Souto Slinger Supremo!")
			GUN_CLICK_EMPTY(user)
			unlink_soutopack()
			return NONE
	if(soutopack)
		if(!current_mag)
			current_mag = soutopack.internal_mag
		// Check we're actually firing the right fuel tank
		if(current_mag != soutopack.internal_mag)
			current_mag = soutopack.internal_mag
		return ..()

/obj/item/weapon/gun/souto/reload(mob/user, obj/item/ammo_magazine/magazine)
	to_chat(user, SPAN_WARNING("[src]'s feed system cannot be reloaded manually."))
	return

/obj/item/weapon/gun/souto/unload(mob/user, reload_override = 0, drop_override = 0, loc_override = 0)
	to_chat(user, SPAN_WARNING("You cannot unload [src]."))
	return

/obj/item/weapon/gun/souto/check_additional_able_to_fire(mob/user)
	if(!current_mag || !current_mag.current_rounds) //Can apparently be false. Todo: fix this whatever it is.
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return FALSE

	if(!istype(H.back, /obj/item/storage/backpack/souto))
		GUN_CLICK_EMPTY(H)
		return FALSE

/obj/item/weapon/gun/souto/recalculate_user_attributes(mob/living/user)
	if(!skillcheck(user, SKILL_SPEC_WEAPONS,  SKILL_SPEC_ALL))
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()

//Ughhh.
/obj/item/weapon/gun/souto/create_bullet(datum/ammo/chambered, bullet_source)
	var/obj/projectile/P = ..()
	var/datum/ammo/souto/S = in_chamber
	S.can_type = new S.shrapnel_type
	P.icon_state = S.can_type.icon_state
	S.can_type.forceMove(P)
	S.can_type.sharp = 1
	. = P

/obj/item/weapon/gun/souto/proc/link_soutopack(mob/user)
	if(user.back)
		if(istype(user.back, /obj/item/storage/backpack/souto))
			soutopack = user.back
			return TRUE
	return FALSE

/obj/item/weapon/gun/souto/proc/unlink_soutopack()
	soutopack = null

/obj/item/weapon/gun/souto/retrieval_check(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_IN_BACK)
		if(istype(user.back, /obj/item/storage/backpack/souto))
			return TRUE
		return FALSE
	return ..()

/obj/item/ammo_magazine/internal/souto
	name = "\improper Souto Slinger Supremo internal magazine"
	caliber = "Cans"
	max_rounds = 100
	default_ammo = /datum/ammo/souto
	gun_type = /obj/item/weapon/gun/souto
