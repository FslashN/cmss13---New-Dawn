//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               GENERIC SNIPER RIFLE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.
//Because this parent type did not exist
//Note that this means that snipers will have a slowdown of 3, due to the scope

/obj/item/weapon/gun/rifle/sniper
	var/has_aimed_shot = TRUE
	var/aiming_time = 1.25 SECONDS
	var/aimed_shot_cooldown
	var/aimed_shot_cooldown_delay = 2.5 SECONDS

	var/enable_aimed_shot_laser = TRUE
	var/sniper_lockon_icon = "sniper_lockon"
	var/obj/effect/ebeam/sniper_beam_type = /obj/effect/ebeam/laser
	var/sniper_beam_icon = "laser_beam"
	var/skill_locked = TRUE

	//=========// GUN STATS //==========//
	malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO

	fire_delay = FIRE_DELAY_TIER_5
	burst_amount = BURST_AMOUNT_TIER_1
	burst_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_2

	damage_mult = BULLET_DAMAGE_MULT_BASE
	damage_falloff_mult = DAMAGE_FALLOFF_OFF //Changed this to off to be consistent with the scout rifles and the SVD. Shouldn't matter as sniper ammo itself has no falloff.
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

	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	wield_delay = WIELD_DELAY_SLOW
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/sniper/get_additional_gun_examine_text(mob/user)
	. = ..()
	if(!has_aimed_shot)
		return
	. += SPAN_NOTICE("This weapon has an unique ability, Aimed Shot, allowing it to deal great damage after a windup.<br><b> Additionally, the aimed shot can be sped up with a tracking laser, which is enabled by default but may be disabled.</b>")

/obj/item/weapon/gun/rifle/sniper/Initialize(mapload, spawn_empty)
	if(has_aimed_shot)
		LAZYADD(actions_types, list(/datum/action/item_action/specialist/aimed_shot, /datum/action/item_action/specialist/toggle_laser))
	return ..()

/obj/item/weapon/gun/rifle/sniper/recalculate_user_attributes(mob/living/user)
	if(skill_locked && !skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_SNIPER)
		unable_to_fire_message = "You don't seem to know how to use \the [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()

// Aimed shot ability
/datum/action/item_action/specialist/aimed_shot
	ability_primacy = SPEC_PRIMARY_ACTION_2
	var/minimum_aim_distance = 2

/datum/action/item_action/specialist/aimed_shot/New(mob/living/user, obj/item/holder)
	..()
	name = "Aimed Shot"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "sniper_aim")
	button.overlays += IMG
	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item
	sniper_rifle.aimed_shot_cooldown = world.time

/*
		ACTIONS SPECIALSIT SNIPER CAN TAKE
*/
/datum/action/item_action/specialist/aimed_shot/action_activate()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(H.selected_ability == src)
		to_chat(H, "You will no longer use [name] with \
			[H.client && H.client.prefs && H.client.prefs.toggle_prefs & TOGGLE_MIDDLE_MOUSE_CLICK ? "middle-click" : "shift-click"].")
		button.icon_state = "template"
		H.selected_ability = null
	else
		to_chat(H, "You will now use [name] with \
			[H.client && H.client.prefs && H.client.prefs.toggle_prefs & TOGGLE_MIDDLE_MOUSE_CLICK ? "middle-click" : "shift-click"].")
		if(H.selected_ability)
			H.selected_ability.button.icon_state = "template"
			H.selected_ability = null
		button.icon_state = "template_on"
		H.selected_ability = src

/datum/action/item_action/specialist/aimed_shot/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(istype(H) && !H.is_mob_incapacitated() && (holder_item == H.r_hand || holder_item || H.l_hand))
		return TRUE

/datum/action/item_action/specialist/aimed_shot/proc/use_ability(atom/A)
	var/mob/living/carbon/human/human = owner
	if(!istype(A, /mob/living))
		return

	var/mob/living/target = A

	if(target.stat == DEAD || target == human)
		return

	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item
	if(world.time < sniper_rifle.aimed_shot_cooldown)
		return

	if(!check_can_use(target))
		return

	human.face_atom(target)

	///Add a decisecond to the default 1.5 seconds for each two tiles to hit.
	var/distance = round(get_dist(target, human) * 0.5)
	var/f_aiming_time = sniper_rifle.aiming_time + distance

	var/aim_multiplier = 1
	var/aiming_buffs

	if(sniper_rifle.enable_aimed_shot_laser)
		aim_multiplier = 0.6
		aiming_buffs++

	if(HAS_TRAIT(target, TRAIT_SPOTTER_LAZED))
		aim_multiplier = 0.5
		aiming_buffs++

	if(aiming_buffs > 1)
		aim_multiplier = 0.35

	f_aiming_time *= aim_multiplier

	var/image/lockon_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = sniper_rifle.sniper_lockon_icon)

	var/x_offset =  -target.pixel_x + target.base_pixel_x
	var/y_offset = (target.icon_size - world.icon_size) * 0.5 - target.pixel_y + target.base_pixel_y

	lockon_icon.pixel_x = x_offset
	lockon_icon.pixel_y = y_offset
	target.overlays += lockon_icon

	var/image/lockon_direction_icon
	if(!sniper_rifle.enable_aimed_shot_laser)
		lockon_direction_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = "[sniper_rifle.sniper_lockon_icon]_direction", dir = get_cardinal_dir(target, human))
		lockon_direction_icon.pixel_x = x_offset
		lockon_direction_icon.pixel_y = y_offset
		target.overlays += lockon_direction_icon
	if(human.client)
		playsound_client(human.client, 'sound/weapons/TargetOn.ogg', human, 50)
	playsound(target, 'sound/weapons/TargetOn.ogg', 70, FALSE, 8, falloff = 0.4)

	var/datum/beam/laser_beam
	if(sniper_rifle.enable_aimed_shot_laser)
		laser_beam = target.beam(human, sniper_rifle.sniper_beam_icon, 'icons/effects/beam.dmi', (f_aiming_time + 1 SECONDS), beam_type = sniper_rifle.sniper_beam_type)
		laser_beam.visuals.alpha = 0
		animate(laser_beam.visuals, alpha = initial(laser_beam.visuals.alpha), f_aiming_time, easing = SINE_EASING|EASE_OUT)

	////timer is (f_spotting_time + 1 SECONDS) because sometimes it janks out before the doafter is done. blame sleeps or something

	if(!do_after(human, f_aiming_time, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, NO_BUSY_ICON))
		target.overlays -= lockon_icon
		target.overlays -= lockon_direction_icon
		qdel(laser_beam)
		return

	target.overlays -= lockon_icon
	target.overlays -= lockon_direction_icon
	qdel(laser_beam)

	if(!check_can_use(target, TRUE) || target.is_dead())
		return

	var/obj/projectile/aimed_proj = sniper_rifle.in_chamber
	aimed_proj.projectile_flags |= PROJECTILE_BULLSEYE
	aimed_proj.AddComponent(/datum/component/homing_projectile, target, human)
	sniper_rifle.Fire(target, human)

/datum/action/item_action/specialist/aimed_shot/proc/check_can_use(mob/M, cover_lose_focus)
	var/mob/living/carbon/human/H = owner
	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item

	if(!can_use_action())
		return FALSE

	if(sniper_rifle != H.r_hand && sniper_rifle != H.l_hand)
		to_chat(H, SPAN_WARNING("How do you expect to do this without your sniper rifle?"))
		return FALSE

	if(!(sniper_rifle.flags_item & WIELDED))
		to_chat(H, SPAN_WARNING("Your aim is not stable enough with one hand. Use both hands!"))
		return FALSE

	if(!sniper_rifle.in_chamber)
		to_chat(H, SPAN_WARNING("\The [sniper_rifle] is unloaded!"))
		return FALSE

	if(get_dist(H, M) < minimum_aim_distance)
		to_chat(H, SPAN_WARNING("\The [M] is too close to get a proper shot!"))
		return FALSE

	var/obj/projectile/P = sniper_rifle.in_chamber
	// TODO: Make the below logic only occur in certain circumstances. Check goggles, maybe? -Kaga
	if(check_shot_is_blocked(H, M, P))
		to_chat(H, SPAN_WARNING("Something is in the way, or you're out of range!"))
		if(cover_lose_focus)
			to_chat(H, SPAN_WARNING("You lose focus."))
			COOLDOWN_START(sniper_rifle, aimed_shot_cooldown, sniper_rifle.aimed_shot_cooldown_delay * 0.5)
		return FALSE

	COOLDOWN_START(sniper_rifle, aimed_shot_cooldown, sniper_rifle.aimed_shot_cooldown_delay)
	return TRUE

/datum/action/item_action/specialist/aimed_shot/proc/check_shot_is_blocked(mob/firer, mob/target, obj/projectile/P)
	var/list/turf/path = getline2(firer, target, include_from_atom = FALSE)
	if(!path.len || get_dist(firer, target) > P.ammo.max_range)
		return TRUE

	var/blocked = FALSE
	for(var/turf/T in path)
		if(T.density || T.opacity)
			blocked = TRUE
			break

		for(var/obj/O in T)
			if(O.get_projectile_hit_boolean(P))
				blocked = TRUE
				break

		for(var/obj/effect/particle_effect/smoke/S in T)
			blocked = TRUE
			break

	return blocked

// Snipers may enable or disable their laser tracker at will.
/datum/action/item_action/specialist/toggle_laser

/datum/action/item_action/specialist/toggle_laser/New(mob/living/user, obj/item/holder)
	..()
	name = "Toggle Tracker Laser"
	button.name = name
	button.overlays.Cut()
	var/image/IMG = image('icons/mob/hud/actions.dmi', button, "sniper_toggle_laser_on")
	button.overlays += IMG
	update_button_icon()

/datum/action/item_action/specialist/toggle_laser/update_button_icon()
	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item

	var/icon = 'icons/mob/hud/actions.dmi'
	var/icon_state = "sniper_toggle_laser_[sniper_rifle.enable_aimed_shot_laser ? "on" : "off"]"

	button.overlays.Cut()
	var/image/IMG = image(icon, button, icon_state)
	button.overlays += IMG

/datum/action/item_action/specialist/toggle_laser/can_use_action()
	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item

	if(owner.is_mob_incapacitated())
		return FALSE

	if(owner.get_held_item() != sniper_rifle)
		to_chat(owner, SPAN_WARNING("How do you expect to do this without the sniper rifle in your hand?"))
		return FALSE
	return TRUE

/datum/action/item_action/specialist/toggle_laser/action_activate()
	var/obj/item/weapon/gun/rifle/sniper/sniper_rifle = holder_item

	if(owner.get_held_item() != sniper_rifle)
		to_chat(owner, SPAN_WARNING("How do you expect to do this without the sniper rifle in your hand?"))
		return FALSE
	sniper_rifle.toggle_laser(owner, src)

/obj/item/weapon/gun/rifle/sniper/proc/toggle_laser(mob/user, datum/action/toggling_action)
	enable_aimed_shot_laser = !enable_aimed_shot_laser
	to_chat(user, SPAN_NOTICE("You flip a switch on \the [src] and [enable_aimed_shot_laser ? "enable" : "disable"] its targeting laser."))
	playsound(user, 'sound/machines/click.ogg', 15, TRUE)
	if(!toggling_action)
		toggling_action = locate(/datum/action/item_action/specialist/toggle_laser) in actions
	if(toggling_action)
		toggling_action.update_button_icon()

/obj/item/weapon/gun/rifle/sniper/verb/toggle_gun_laser()
	set category = "Weapons"
	set name = "Toggle Laser"
	set desc = "Toggles your laser on or off."
	set src = usr.contents

	var/obj/item/weapon/gun/rifle/sniper/sniper = get_active_firearm(usr)
	if((sniper == src) && has_aimed_shot)
		toggle_laser(usr)

//Pow! Headshot.

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  M42A SCOPED RIFLE                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/sniper/M42A
	name = "\improper M42A scoped rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 15-round magazine.\n'Peace Through Superior Firepower'"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m42a"
	item_state = "m42a"
	fire_sound = 'sound/weapons/gun_sniper.ogg'
	force = 12
	current_mag = /obj/item/ammo_magazine/sniper
	zoomdevicename = "scope"
	flags_item = TWOHANDED|NO_CRYO_STORE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	map_specific_decoration = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7 * 3

	accuracy_mult = BASE_ACCURACY_MULT * 3 //you HAVE to be able to hit
	scatter = SCATTER_AMOUNT_TIER_8
	recoil = RECOIL_AMOUNT_TIER_5

	wield_delay = WIELD_DELAY_HORRIBLE //Ends up being 1.6 seconds due to scope
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/sniper/M42A/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/sniper, /obj/item/attachable/scope/variable_zoom/hidden))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/bipod))
	INHERITLIST(attachable_offset, list("barrel_x" = 39, "barrel_y" = 17,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14))

	..()

/obj/item/weapon/gun/rifle/sniper/M42A/verb/toggle_scope_zoom_level()
	set name = "Toggle Scope Zoom Level"
	set category = "Weapons"
	set src in usr
	var/obj/item/attachable/scope/variable_zoom/S = attachments[ATTACHMENT_SLOT_RAIL]
	S.toggle_zoom_level()

/obj/item/weapon/gun/rifle/sniper/M42A/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/rifle/sniper/XM43E1
	name = "\improper XM43E1 experimental anti-materiel rifle"
	desc = "An experimental anti-materiel rifle produced by Armat Systems, recently reacquired from the deep storage of an abandoned prototyping facility. This one in particular is currently undergoing field testing. Chambered in 10x99mm Caseless."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "xm43e1"
	item_state = "xm43e1"
	fire_sound = 'sound/weapons/sniper_heavy.ogg'
	force = 12
	current_mag = /obj/item/ammo_magazine/sniper/anti_materiel //Renamed from anti-tank to align with new identity/description. Other references have been changed as well. -Kaga
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	zoomdevicename = "scope"
	sniper_beam_type = /obj/effect/ebeam/laser/intense
	sniper_beam_icon = "laser_beam_intense"
	sniper_lockon_icon = "sniper_lockon_intense"

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6 * 6//Big boy damage, but it takes a lot of time to fire a shot.
	//Kaga: Adjusted from 56 (Tier 4, 7*8) -> 30 (Tier 6, 5*6) ticks. 95 really wasn't big-boy damage anymore, although I updated it to 125 to remain consistent with the other 10x99mm caliber weapon (M42C). Now takes only twice as long as the M42A.

	accuracy_mult = BASE_ACCURACY_MULT + 2*HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_10
	recoil = RECOIL_AMOUNT_TIER_1

	wield_delay = WIELD_DELAY_HORRIBLE //Ends up being 1.6 seconds due to scope
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/sniper/XM43E1/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/sniper/pmc, /obj/item/attachable/scope/variable_zoom/pmc))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/bipod))
	INHERITLIST(attachable_offset, list("barrel_x" = 32, "barrel_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15))

	..()

/obj/item/weapon/gun/rifle/sniper/XM43E1/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff),
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating),
		BULLET_TRAIT_ENTRY_ID("turfs", /datum/element/bullet_trait_damage_boost, 11, GLOB.damage_boost_turfs),
		BULLET_TRAIT_ENTRY_ID("breaching", /datum/element/bullet_trait_damage_boost, 11, GLOB.damage_boost_breaching),
		//At 1375 per shot it'll take 1 shot to break resin turfs, and a full mag of 8 to break reinforced walls.
		BULLET_TRAIT_ENTRY_ID("pylons", /datum/element/bullet_trait_damage_boost, 6, GLOB.damage_boost_pylons)
		//At 750 per shot it'll take 3 to break a Pylon (1800 HP). No Damage Boost vs other xeno structures yet, those will require a whole new list w/ the damage_boost trait.
	))

/*
//Disabled until an identity is better defined. -Kaga
/obj/item/weapon/gun/rifle/sniper/M42B/afterattack(atom/target, mob/user, flag)
	if(able_to_fire(user))
		if(get_dist(target,user) <= 8)
			to_chat(user, SPAN_WARNING("The [src.name] beeps, indicating that the target is within an unsafe proximity to the rifle, refusing to fire."))
			return
		else ..()
*/

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[             M42C ANTI-TANK SNIPER RIFLE            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
	desc = "A high-end superheavy magrail sniper rifle from Weyland-Armat chambered in a specialized variant of the heaviest ammo available, 10x99mm Caseless. This weapon requires a specialized armor rig for recoil mitigation in order to be used effectively."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/wy.dmi'
	icon_state = "m42c"
	item_state = "m42c" //NEEDS A TWOHANDED STATE
	fire_sound = 'sound/weapons/sniper_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/elite
	zoomdevicename = "scope"
	force = 17
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WY_RESTRICTED|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	sniper_beam_type = /obj/effect/ebeam/laser/intense
	sniper_beam_icon = "laser_beam_intense"
	sniper_lockon_icon = "sniper_lockon_intense"

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6 * 5

	accuracy_mult = BASE_ACCURACY_MULT * 3 //Was previously BAM + HAMT10, similar to the XM42B, and coming out to 1.5? Changed to be consistent with M42A. -Kaga
	scatter = SCATTER_AMOUNT_TIER_10 //Was previously 8, changed to be consistent with the XM42B.
	recoil = RECOIL_AMOUNT_TIER_1
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/sniper/elite/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/sniper/pmc, /obj/item/attachable/scope/pmc))
	INHERITLIST(attachable_offset, list("barrel_x" = 32, "barrel_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15))

	..()

/obj/item/weapon/gun/rifle/sniper/elite/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/rifle/sniper/elite/simulate_recoil(total_recoil = 0, mob/user, atom/target)
	. = ..()
	if(.)
		var/mob/living/carbon/human/PMC_sniper = user
		if(PMC_sniper.body_position == STANDING_UP && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner/veteran/pmc) && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/veteran))
			PMC_sniper.visible_message(SPAN_WARNING("[PMC_sniper] is blown backwards from the recoil of the [src.name]!"),SPAN_HIGHDANGER("You are knocked prone by the blowback!"))
			step(PMC_sniper,turn(PMC_sniper.dir,180))
			PMC_sniper.apply_effect(5, WEAKEN)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                TYPE 88 MARKSMAN RIFLE              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Based on the actual Dragunov DMR rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper Type 88 designated marksman rifle"
	desc = "The standard issue DMR of the UPP, the Type 88 is sought after by competitive shooters and terrorists alike for its high degree of accuracy. Typically loaded with armor-piercing 7.62x54mmR rounds in a 12 round magazine."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type88"
	item_state = "type88"
	fire_sound = 'sound/weapons/gun_mg.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/svd
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_CAN_POINTBLANK
	sniper_beam_type = null
	skill_locked = FALSE
	has_aimed_shot = FALSE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6

	accuracy_mult = BASE_ACCURACY_MULT * 3
	scatter = SCATTER_AMOUNT_TIER_8
	recoil = RECOIL_AMOUNT_TIER_5
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/rifle/sniper/svd/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/scope/variable_zoom/hidden, /obj/item/attachable/barrel/type88))
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp_replica,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/verticalgrip,
			/obj/item/attachable/bipod,
			/obj/item/attachable/barrel/type88,
		))
	INHERITLIST(attachable_offset, list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 26, "under_y" = 14, "stock_x" = 24, "stock_y" = 13, "barrel_x" = 39, "barrel_y" = 18))

	..()



