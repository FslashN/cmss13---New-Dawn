//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                OL'PAINLESS MINIGUN                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//This gun is very powerful, but also has a kick.

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. This thing will no doubt pack a punch."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/event.dmi'
	icon_state = "painless"
	item_state = "painless"

	fire_sound = 'sound/weapons/gun_minigun.ogg'
	chamber_cycle_sound = 'sound/weapons/gun_minigun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	projectile_casing = PROJECTILE_CASING_CARTRIDGE
	w_class = SIZE_HUGE
	force = 20
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_RECOIL_BUILDUP|GUN_CAN_POINTBLANK|GUN_NO_SAFETY_SWITCH
	gun_category = GUN_CATEGORY_HEAVY
	start_semiauto = FALSE
	start_automatic = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_9 // Most of the scatter should come from the recoil
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_buildup_limit = RECOIL_AMOUNT_TIER_3 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/minigun/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/magnetic_harness/hidden))

	..()

//Minigun UPP
/obj/item/weapon/gun/minigun/upp
	name = "\improper GSh-7.62 rotary machine gun"
	desc = "A gas-operated rotary machine gun used by UPP heavies. Its enormous volume of fire and ammunition capacity allows the suppression of large concentrations of enemy forces. Heavy weapons training is required control its recoil."

/obj/item/weapon/gun/minigun/upp/recalculate_user_attributes(mob/living/user)
	if(!skillcheck(user, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED)) //Skills are set up in the parent, which is ran after.
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	if(!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_UPP)
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  GENERIC MACHINE GUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/machinegun
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_CAN_POINTBLANK
	flags_gun_receiver = GUN_CHAMBERED_CYCLE|GUN_CHAMBER_BELT_FED
	gun_category = GUN_CATEGORY_HEAVY
	start_semiauto = FALSE
	start_automatic = TRUE
	w_class = SIZE_LARGE
	projectile_casing = PROJECTILE_CASING_CARTRIDGE
	empty_sound = 'sound/weapons/gun_empty.ogg'

	//=========// GUN STATS //==========//
	malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO

	fire_delay = FIRE_DELAY_TIER_12
	burst_amount = BURST_AMOUNT_TIER_5
	burst_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_10

	damage_mult = BULLET_DAMAGE_MULT_BASE
	damage_falloff_mult = DAMAGE_FALLOFF_TIER_10
	damage_buildup_mult = DAMAGE_BUILDUP_TIER_1
	velocity_add = BASE_VELOCITY_BONUS
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_OFF
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_1

	effective_range_min = EFFECTIVE_RANGE_OFF
	effective_range_max = EFFECTIVE_RANGE_OFF

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_BASE
	fa_max_scatter = FULL_AUTO_SCATTER_MAX_BASE

	recoil_buildup_limit = RECOIL_AMOUNT_TIER_1 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER

	aim_slowdown = SLOWDOWN_ADS_NONE
	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                    M60 MACHINE GUN                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/machinegun/m60
	name = "\improper M60 General Purpose Machine Gun"
	desc = "The M60. The Pig. The Action Hero's wet dream. \n<b>Alt-click it to open the feed cover and allow for reloading.</b>"
	force = 25
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "m60"
	item_state = "m60"
	fire_sound = 'sound/weapons/gun_m60.ogg'
	chamber_cycle_sound = 'sound/weapons/gun_m60_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/m60

/obj/item/weapon/gun/machinegun/m60/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/barrel/m60, /obj/item/attachable/bipod/m60))
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/m60, /obj/item/attachable/bipod/m60))
	INHERITLIST(attachable_offset, list("barrel_x" = 34, "barrel_y" = 16,"rail_x" = 0, "rail_y" = 0, "under_x" = 39, "under_y" = 7, "stock_x" = 0, "stock_y" = 0))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 PKP/QYJ-72 MACHINE GUN             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/machinegun/pkp
	name = "\improper QYJ-72 General Purpose Machine Gun"
	desc = "The QYJ-72 is the standard GPMG of the Union of Progressive Peoples, chambered in 7.62x54mmR, it fires a hard-hitting cartridge with a high rate of fire. With an extremely large box at 250 rounds, the QJY-72 is designed with suppressing fire and accuracy by volume of fire at its forefront. \n<b>Alt-click it to open the feed cover and allow for reloading.</b>"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "qjy72"
	item_state = "qjy72"
	force = 30 //the image of a upp machinegunner beating someone to death with a gpmg makes me laugh
	fire_sound = 'sound/weapons/gun_mg.ogg'
	chamber_cycle_sound = 'sound/weapons/gun_m60_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/pkp
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_CAN_POINTBLANK|GUN_SPECIALIST|GUN_AMMO_COUNTER


/obj/item/weapon/gun/machinegun
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_CAN_POINTBLANK
	flags_gun_receiver = GUN_CHAMBERED_CYCLE|GUN_CHAMBER_BELT_FED
	gun_category = GUN_CATEGORY_HEAVY
	start_semiauto = FALSE
	start_automatic = TRUE
	w_class = SIZE_LARGE
	projectile_casing = PROJECTILE_CASING_CARTRIDGE
	empty_sound = 'sound/weapons/gun_empty.ogg'

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_10
	burst_amount = BURST_AMOUNT_TIER_6
	burst_delay = FIRE_DELAY_TIER_9

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	fa_max_scatter = SCATTER_AMOUNT_TIER_8
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/machinegun/pkp/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/pkp, /obj/item/attachable/magnetic_harness/hidden,/obj/item/attachable/stock/pkp))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/barrel/pkp, /obj/item/attachable/stock/pkp))
	INHERITLIST(attachable_offset, list("barrel_x" = 34, "barrel_y" = 18,"rail_x" = 5, "rail_y" = 5, "under_x" = 39, "under_y" = 7, "stock_x" = 10, "stock_y" = 13))

	..()

/obj/item/weapon/gun/machinegun/pkp/recalculate_user_attributes(mob/living/user)
	if(!skillcheck(user, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED))
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	if(!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_UPP)
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     TECH RAILGUN                   ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/techweb_railgun
	name = "railgun"
	desc = "A poggers hellbliterator"
	icon_state = "m42a"
	item_state = "m42a"
	unacidable = TRUE
	indestructible = 1
	force = 12
	fire_sound = 'sound/weapons/gun_sniper.ogg'
	current_mag = /obj/item/ammo_magazine/techweb_railgun
	zoomdevicename = "scope"
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_UNUSUAL_DESIGN|GUN_NO_SAFETY_SWITCH
	map_specific_decoration = TRUE
	// Hellpullverizer ready or not??
	var/charged = FALSE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6*5
	burst_amount = BURST_AMOUNT_TIER_1

	accuracy_mult = BASE_ACCURACY_MULT * 3 //you HAVE to be able to hit
	scatter = SCATTER_AMOUNT_TIER_8
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_5

	wield_delay = WIELD_DELAY_HORRIBLE //Ends up being 1.6 seconds due to scope
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/techweb_railgun/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/scope/hidden))
	INHERITLIST(actions_types, list(/datum/action/item_action/techweb_railgun_start_charge, /datum/action/item_action/techweb_railgun_abort_charge))

	..()

/obj/item/weapon/gun/rifle/techweb_railgun/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/rifle/techweb_railgun/check_additional_able_to_fire()
	return charged //???? WHAT IS THIS WEAPON ???? It's a mystery wrapped in an enigma.

/obj/item/weapon/gun/rifle/techweb_railgun/proc/start_charging(user)
	if (charged)
		to_chat(user, SPAN_WARNING("Your railgun is already charged."))
		return

	to_chat(user, SPAN_WARNING("You start charging your railgun."))
	if (!do_after(user, 8 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		to_chat(user, SPAN_WARNING("You stop charging your railgun."))
		return

	to_chat(user, SPAN_WARNING("You finish charging your railgun."))

	charged = TRUE
	return

/obj/item/weapon/gun/rifle/techweb_railgun/on_enter_storage()
	if (charged)
		abort_charge()
	. = ..()

/obj/item/weapon/gun/rifle/techweb_railgun/proc/abort_charge(user)
	if (!charged)
		return
	charged = FALSE
	if (user)
		to_chat(user, SPAN_WARNING("You depower your railgun to store it."))
	return

/obj/item/weapon/gun/rifle/techweb_railgun/unique_action(mob/user)
	if (in_chamber)
		to_chat(user, SPAN_WARNING("There's already a round chambered!"))
		return

	var/result = load_into_chamber()
	if (result)
		to_chat(user, SPAN_WARNING("You run the bolt on [src], chambering a round!"))
	else
		to_chat(user, SPAN_WARNING("You run the bolt on [src], but it's out of rounds!"))

// normally, ready_in_chamber gets called by this proc. However, it never gets called because we override.
// so we don't need to override ready_in_chamber, which is what makes the bullet and puts it in the chamber var.
/obj/item/weapon/gun/rifle/techweb_railgun/reload_into_chamber(mob/user)
	charged = FALSE
	in_chamber = null // blackpilled again
	return null

/datum/action/item_action/techweb_railgun_start_charge
	name = "Start Charging"

/datum/action/item_action/techweb_railgun_start_charge/action_activate()
	if (target)
		var/obj/item/weapon/gun/rifle/techweb_railgun/TR = target
		TR.start_charging(owner)

/datum/action/item_action/techweb_railgun_abort_charge
	name = "Abort Charge"

/datum/action/item_action/techweb_railgun_abort_charge/action_activate()
	if (target)
		var/obj/item/weapon/gun/rifle/techweb_railgun/TR = target
		TR.abort_charge(owner)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                       PILL GUN                     ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE

/obj/effect/syringe_gun_dummy/Initialize()
	create_reagents(15)
	. = ..()

/obj/item/ammo_magazine/internal/pillgun
	name = "pill tube"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = /datum/ammo/pill
	caliber = "pill"
	max_rounds = 1
	var/list/pills

/obj/item/ammo_magazine/internal/pillgun/Initialize(mapload, spawn_empty)
	. = ..()
	current_rounds = LAZYLEN(pills)

/obj/item/ammo_magazine/internal/pillgun/Entered(Obj, OldLoc)
	. = ..()
	if(!istype(Obj, /obj/item/reagent_container/pill))
		return

	LAZYADD(pills, Obj)
	current_rounds = LAZYLEN(pills)

/obj/item/ammo_magazine/internal/pillgun/Exited(Obj, newloc)
	. = ..()
	if(!istype(Obj, /obj/item/reagent_container/pill))
		return

	LAZYREMOVE(pills, Obj)
	current_rounds = LAZYLEN(pills)

/obj/item/ammo_magazine/internal/pillgun/super
	max_rounds = 5

// upgraded version, currently no way of getting it
/obj/item/weapon/gun/pill/super
	name = "large pill gun"
	current_mag = /obj/item/ammo_magazine/internal/pillgun/super

/obj/item/weapon/gun/pill
	name = "pill gun"
	desc = "A spring-loaded rifle designed to fit pills, designed to inject patients from a distance."
	icon = 'icons/obj/items/weapons/guns/legacy/old_cmguns.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = SIZE_MEDIUM
	throw_speed = SPEED_SLOW
	throw_range = 10
	force = 4

	current_mag = /obj/item/ammo_magazine/internal/pillgun

	flags_gun_receiver = GUN_INTERNAL_MAG

	matter = list("metal" = 2000)

/obj/item/weapon/gun/pill/attackby(obj/item/I as obj, mob/user as mob)
	if(I.loc == current_mag)
		return

	if(!istype(I, /obj/item/reagent_container/pill))
		return

	if(current_mag.current_rounds >= current_mag.max_rounds)
		to_chat(user, SPAN_WARNING("[src] is at maximum ammo capacity!"))
		return

	user.drop_inv_item_on_ground(I)
	I.forceMove(current_mag)

/obj/item/weapon/gun/pill/update_icon()
	. = ..()
	if(!current_mag || !current_mag.current_rounds)
		icon_state = base_gun_icon
	else
		icon_state = base_gun_icon + "_e"

/obj/item/weapon/gun/pill/unload(mob/user, reload_override, drop_override, loc_override)
	var/obj/item/ammo_magazine/internal/pillgun/internal_mag = current_mag

	if(!istype(internal_mag))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/reagent_container/pill/pill_to_use = LAZYACCESS(internal_mag.pills, 1)

	if(!pill_to_use)
		return

	pill_to_use.forceMove(get_turf(H.loc))
	H.put_in_active_hand(pill_to_use)

/obj/item/weapon/gun/pill/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	if(!able_to_fire(user))
		return NONE

	if(!current_mag.current_rounds)
		GUN_CLICK_EMPTY(user)
		return NONE

	if(!istype(current_mag, /obj/item/ammo_magazine/internal/pillgun))
		return NONE

	var/obj/item/ammo_magazine/internal/pillgun/internal_mag = current_mag
	var/obj/item/reagent_container/pill/pill_to_use = LAZYACCESS(internal_mag.pills, 1)

	if(QDELETED(pill_to_use))
		GUN_CLICK_EMPTY(user)
		return NONE

	var/obj/projectile/pill/P = new /obj/projectile/pill(src, user, src)
	P.generate_bullet(GLOB.ammo_list[/datum/ammo/pill], 0, 0)

	pill_to_use.forceMove(P)
	P.source_pill = pill_to_use

	playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

	P.fire_at(target, user, src)
	return AUTOFIRE_CONTINUE

/datum/ammo/pill
	name = "syringe"
	icon_state = "syringe"
	flags_ammo_behavior = AMMO_IGNORE_ARMOR|AMMO_ALWAYS_FF

	damage = 0

/datum/ammo/pill/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()

	if(!ishuman(M))
		return

	if(!istype(P, /obj/projectile/pill))
		return

	var/obj/projectile/pill/pill_projectile = P

	if(QDELETED(pill_projectile.source_pill))
		pill_projectile.source_pill = null
		return

	var/datum/reagents/pill_reagents = pill_projectile.source_pill.reagents

	pill_reagents.trans_to(M, pill_reagents.total_volume)

/obj/projectile/pill
	var/obj/item/reagent_container/pill/source_pill

/obj/projectile/pill/Destroy()
	. = ..()
	source_pill = null
