//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[              GENERIC LEVER ACTION RIFLE            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
LEVER-ACTION RIFLES

I've revised this to be more in line with the new code along with geneal fixing. Compared to the rest of the weapons, which are very much based on real-life functionality, the additional fire rate and damage feel very arcadey here.
I have decided to leave said functioanlity alone, in case CM wants to port the update on to their codebase, but I don't think this fits in particularly well with the other guns. /N
*/

/obj/item/weapon/gun/lever_action
	name = "lever-action rifle"
	desc = "Welcome to the Wild West!\nThis gun is levered via Unique-Action, but it has a bonus feature: Hitting a target directly will grant you a fire rate and damage buff for your next shot during a short interval. Combo precision hits for massive damage."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "r4t-placeholder" //placeholder for a 'base' leveraction
	item_state = "r4t-placeholder"
	w_class = SIZE_LARGE
	fire_sound = 'sound/weapons/gun_lever_action_fire.ogg'
	reload_sound = 'sound/weapons/handling/gun_lever_action_reload.ogg'
	chamber_cycle_sound = 'sound/weapons/handling/gun_lever_action_lever.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_NO_SAFETY_SWITCH
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBERED_CYCLE|GUN_MANUAL_CYCLE|GUN_ACCEPTS_HANDFUL
	current_mag = /obj/item/ammo_magazine/internal/lever_action
	projectile_casing = PROJECTILE_CASING_CARTRIDGE
	gun_category = GUN_CATEGORY_RIFLE
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_FAST
	has_empty_icon = FALSE
	has_open_icon = FALSE
	var/flags_gun_lever_action = MOVES_WHEN_LEVERING|USES_STREAKS|DANGEROUS_TO_ONEHAND_LEVER
	var/lever_super_sound = 'sound/weapons/handling/gun_lever_action_superload.ogg'
	var/lever_hitsound = 'sound/weapons/handling/gun_lever_action_hitsound.ogg'
	var/levering_sprite = "r4t_l" //does it use a unique sprite when levering?
	var/message_cooldown
	var/cur_onehand_chance = 85
	var/reset_onehand_chance = 85
	var/hit_buff_reset_cooldown = 1 SECONDS //how much time after a direct hit until streaks reset
	var/lever_message = "<i>You work the lever.<i>"
	var/lever_name = "lever" //the thing we use to chamber the next round. Lever, button, etc. for to_chats
	var/buff_fire_reduc = 2
	var/streak

	//=========// GUN STATS //==========//
	malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO

	fire_delay = FIRE_DELAY_TIER_1 + FIRE_DELAY_TIER_12
	burst_amount = BURST_AMOUNT_TIER_1
	burst_delay = FIRE_DELAY_TIER_5
	cycle_chamber_delay = FIRE_DELAY_TIER_3

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_NONE
	scatter_unwielded = SCATTER_AMOUNT_TIER_2

	damage_mult = BULLET_DAMAGE_MULT_BASE
	damage_falloff_mult = DAMAGE_FALLOFF_TIER_10
	damage_buildup_mult = DAMAGE_BUILDUP_TIER_1
	velocity_add = BASE_VELOCITY_BONUS
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_1

	effective_range_min = EFFECTIVE_RANGE_OFF
	effective_range_max = EFFECTIVE_RANGE_OFF

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_BASE
	fa_max_scatter = FULL_AUTO_SCATTER_MAX_BASE

	recoil_buildup_limit = RECOIL_AMOUNT_TIER_1 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER

	aim_slowdown = SLOWDOWN_ADS_NONE
	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/lever_action/initialize_gun_lists()
	INHERITLIST(attachable_offset, list("muzzle_x" = 33, "muzzle_y" = 19, "rail_x" = 11, "rail_y" = 21, "under_x" = 24, "under_y" = 16, "stock_x" = 15, "stock_y" = 11))

	..()

/obj/item/weapon/gun/lever_action/wield(mob/M)
	. = ..()
	if(. && (flags_gun_lever_action & USES_STREAKS))
		RegisterSignal(M, COMSIG_BULLET_DIRECT_HIT, PROC_REF(direct_hit_buff))

/obj/item/weapon/gun/lever_action/unwield(mob/M)
	. = ..()
	if(. && (flags_gun_lever_action & USES_STREAKS))
		UnregisterSignal(M, COMSIG_BULLET_DIRECT_HIT)

/obj/item/weapon/gun/lever_action/dropped(mob/user)
	. = ..()
	reset_hit_buff(user)
	addtimer(VARSET_CALLBACK(src, cur_onehand_chance, reset_onehand_chance), 4 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/*
/obj/item/weapon/gun/lever_action/unload(mob/user)
	if(levered)
		to_chat(user, SPAN_WARNING("You open the lever on \the [src]."))
		levered = FALSE
	return empty_chamber(user)
*/

//=================================================================================

//===========================Working the Lever======================================

//Boy, this really is a copy paste of shotgun code.
/obj/item/weapon/gun/lever_action/cycle_chamber(mob/living/carbon/human/user)
	if(world.time < (cycle_chamber_cooldown + cycle_chamber_delay))
		return
	if(in_chamber)
		if (world.time > (message_cooldown + cycle_chamber_delay))
			to_chat(user, SPAN_WARNING("<i>\The [src] already has a bullet in the chamber!<i>"))
			message_cooldown = world.time
		return
	if(in_chamber) //eject the chambered round
		var/obj/item/ammo_magazine/handful/new_handful = new
		new_handful.generate_handful(in_chamber.type, caliber, 1)
		in_chamber = null
		new_handful.forceMove(get_turf(src))

	if(current_mag.used_casings)
		current_mag.used_casings--
		make_casing(projectile_casing)

	cycle_chamber_cooldown = world.time
	if(in_chamber)
		if(levering_sprite)
			flick(levering_sprite, src)
		if(world.time < (last_fired + 2 SECONDS)) //if it's not wielded and you shot recently, one-hand lever
			try_onehand_lever(user)
		else
			twohand_lever(user)

		playsound(user, chamber_cycle_sound, 25, TRUE)

/obj/item/weapon/gun/lever_action/proc/twohand_lever(mob/living/carbon/human/user)
	to_chat(user, SPAN_WARNING(lever_message))
	if(flags_gun_lever_action & MOVES_WHEN_LEVERING)
		animation_move_up_slightly(src)

/obj/item/weapon/gun/lever_action/proc/try_onehand_lever(mob/living/carbon/human/user)
	if(flags_item & WIELDED)
		twohand_lever(user)
		return
	if(flags_gun_lever_action & MOVES_WHEN_LEVERING)
		to_chat(user, SPAN_WARNING("<i>You spin \the [src] one-handed! Fuck yeah!<i>"))
		animation_wrist_flick(src)
	direct_hit_buff(user, ,TRUE)

//=================================================================================

//=================================================================================

//===========================Buff Processing======================================

/obj/item/weapon/gun/lever_action/proc/direct_hit_buff(mob/user, mob/target, one_hand_lever = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = user
	if(one_hand_lever && !(flags_gun_lever_action & DANGEROUS_TO_ONEHAND_LEVER))
		return
	else if(one_hand_lever) //base marines should never be able to easily pass the skillcheck, only specialists and etc.
		if(prob(cur_onehand_chance) || skillcheck(human_user, SKILL_FIREARMS, SKILL_FIREARMS_EXPERT))
			cur_onehand_chance = cur_onehand_chance - 20 //gets steadily worse if you spam it
			return
		else
			to_chat(user, SPAN_DANGER("Augh! Your hand catches on the [lever_name]!!"))
			var/obj/limb/O = human_user.get_limb(human_user.hand ? "l_hand" : "r_hand")
			if(O.status & LIMB_BROKEN)
				O = human_user.get_limb(user.hand ? "l_arm" : "r_arm")
				human_user.drop_held_item()
			O.fracture()
			O.status &= ~LIMB_SPLINTED
			human_user.pain.recalculate_pain()
			return

	if(!istype(target))
		return //sanity...

	else if(target.stat == DEAD || !(flags_gun_lever_action & USES_STREAKS))
		return

	else
		if(streak)
			to_chat(user, SPAN_BOLDNOTICE("Bullseye! [streak + 1] hits in a row!"))
		else
			to_chat(user, SPAN_BOLDNOTICE("Bullseye!"))
		streak++
		playsound(user, lever_hitsound, 25, FALSE)
	if(!(flags_gun_lever_action & USES_STREAKS))
		return
	apply_hit_buff(user, target, one_hand_lever) //this is a separate proc so it's configgable
	addtimer(CALLBACK(src, PROC_REF(reset_hit_buff), user, one_hand_lever), hit_buff_reset_cooldown, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/weapon/gun/lever_action/proc/apply_hit_buff(mob/user, mob/target, one_hand_lever = FALSE)
	chamber_cycle_sound = lever_super_sound
	lever_message = "<b><i>You quickly work the [lever_name]!<i><b>"
	last_fired = world.time - buff_fire_reduc //to shoot the next round faster
	cycle_chamber_delay = FIRE_DELAY_TIER_12
	damage_mult = initial(damage_mult) + BULLET_DAMAGE_MULT_TIER_10
	set_fire_delay(FIRE_DELAY_TIER_5)
	for(var/slot in attachments)
		var/obj/item/attachable/AM = attachments[slot]
		if(AM.damage_mod || AM.delay_mod)
			damage_mult += AM.damage_mod
			modify_fire_delay(AM.delay_mod)
	wield_delay = 0 //for one-handed levering

/obj/item/weapon/gun/lever_action/proc/reset_hit_buff(mob/user, one_hand_lever)
	if(!(flags_gun_lever_action & USES_STREAKS))
		return
	SIGNAL_HANDLER
	streak = 0
	chamber_cycle_sound = initial(chamber_cycle_sound)
	lever_message = initial(lever_message)
	wield_delay = initial(wield_delay)
	cur_onehand_chance = initial(cur_onehand_chance)
	//these are init configs and so cannot be initial()
	cycle_chamber_delay = FIRE_DELAY_TIER_3
	set_fire_delay(FIRE_DELAY_TIER_1)
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recalculate_attachment_bonuses() //stock wield delay
	if(one_hand_lever)
		addtimer(VARSET_CALLBACK(src, cur_onehand_chance, reset_onehand_chance), 4 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)


//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                        R4T                         ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/lever_action/r4t
	name = "\improper R4T lever-action rifle"
	desc = "This lever-action was designed for small scout operations in harsh environments such as the jungle or particularly windy deserts, as such its internal mechanisms are simple yet robust."
	icon_state = "r4t"
	item_state = "r4t"
	flags_equip_slot = SLOT_BACK
	map_specific_decoration = TRUE
	flags_gun_features = GUN_CAN_POINTBLANK
	flags_gun_lever_action = MOVES_WHEN_LEVERING|DANGEROUS_TO_ONEHAND_LEVER|GUN_NO_SAFETY_SWITCH
	civilian_usable_override = TRUE

/obj/item/weapon/gun/lever_action/r4t/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/bayonet/upp, // Barrel
			/obj/item/attachable/bayonet,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/gyro, // Under
			/obj/item/attachable/lasersight,
			/obj/item/attachable/magnetic_harness/lever_sling,
			/obj/item/attachable/stock/r4t, // Stock
			))
	INHERITLIST(attachable_offset, list("muzzle_x" = 33, "muzzle_y" = 19, "rail_x" = 11, "rail_y" = 21, "under_x" = 24, "under_y" = 16, "stock_x" = 15, "stock_y" = 14))

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                        XM88                        ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

#define FLOATING_PENETRATION_TIER_0 0
#define FLOATING_PENETRATION_TIER_1 1
#define FLOATING_PENETRATION_TIER_2 2
#define FLOATING_PENETRATION_TIER_3 3
#define FLOATING_PENETRATION_TIER_4 4

/obj/item/weapon/gun/lever_action/xm88
	name = "\improper XM88 heavy rifle"
	desc = "An experimental man-portable anti-material rifle chambered in .458 SOCOM. It must be manually chambered for every shot.\nIt has a special property - when you obtain multiple direct hits in a row, its armor penetration and damage will increase."
	desc_lore = "Originally developed by ARMAT Battlefield Systems for the government of the state of Greater Brazil for use in the Favela Wars (2161 - Ongoing) against mechanized infantry. The platform features an onboard computerized targeting system, sensor array, and an electronic autoloader; these features work in tandem to reduce and render inert armor on the users target with successive hits. The Almayer was issued a small amount of XM88s while preparing for Operation Swamp Hopper with the USS Nan-Shan."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi' // overriden with camos anyways
	icon_state = "boomslang"
	item_state = "boomslang"
	fire_sound = 'sound/weapons/gun_boomslang_fire.ogg'
	reload_sound = 'sound/weapons/handling/gun_boomslang_reload.ogg'
	chamber_cycle_sound = 'sound/weapons/handling/gun_boomslang_lever.ogg'
	lever_super_sound = 'sound/weapons/handling/gun_lever_action_superload.ogg'
	lever_hitsound = 'sound/weapons/handling/gun_boomslang_hitsound.ogg'
	flags_equip_slot = SLOT_BACK
	map_specific_decoration = TRUE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	levering_sprite = null
	flags_gun_lever_action = USES_STREAKS
	lever_name = "chambering button"
	lever_message = "<i>You press the chambering button.<i>"
	current_mag = /obj/item/ammo_magazine/internal/lever_action/xm88
	hit_buff_reset_cooldown = 2 SECONDS //how much time after a direct hit until streaks reset
	var/floating_penetration = FLOATING_PENETRATION_TIER_0 //holder var
	var/floating_penetration_upper_limit = FLOATING_PENETRATION_TIER_4
	var/direct_hit_sound = 'sound/weapons/gun_xm88_directhit_low.ogg'

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/lever_action/xm88/initialize_gun_lists()
	INHERITLIST(attachable_allowed, list(
			/obj/item/attachable/bayonet/upp, // Barrel
			/obj/item/attachable/bayonet,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/suppressor,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/magnetic_harness,
			/obj/item/attachable/scope/mini/xm88,
			/obj/item/attachable/gyro, // Under
			/obj/item/attachable/lasersight,
			/obj/item/attachable/stock/xm88, // Stock
			))
	INHERITLIST(attachable_offset, list("muzzle_x" = 27, "muzzle_y" = 17, "rail_x" = 11, "rail_y" = 21, "under_x" = 22, "under_y" = 13, "stock_x" = 12, "stock_y" = 15))

	..()

/obj/item/weapon/gun/lever_action/xm88/wield(mob/user)
	. = ..()
	if(.)
		RegisterSignal(src, COMSIG_ITEM_ZOOM, PROC_REF(scope_on))
		RegisterSignal(src, COMSIG_ITEM_UNZOOM, PROC_REF(scope_off))

/obj/item/weapon/gun/lever_action/xm88/proc/scope_on(atom/source, mob/current_user)
	SIGNAL_HANDLER

	RegisterSignal(current_user, COMSIG_MOB_FIRED_GUN, PROC_REF(update_fired_mouse_pointer))
	update_mouse_pointer(current_user)

/obj/item/weapon/gun/lever_action/xm88/proc/scope_off(atom/source, mob/current_user)
	SIGNAL_HANDLER

	UnregisterSignal(current_user, COMSIG_MOB_FIRED_GUN)
	current_user.client?.mouse_pointer_icon = null

/obj/item/weapon/gun/lever_action/xm88/unwield(mob/user)
	. = ..()

	user.client?.mouse_pointer_icon = null
	UnregisterSignal(src, list(COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM))

/obj/item/weapon/gun/lever_action/xm88/proc/update_fired_mouse_pointer(mob/user)
	SIGNAL_HANDLER

	if(!user.client?.prefs.custom_cursors)
		return

	user.client?.mouse_pointer_icon = get_fired_mouse_pointer(floating_penetration)
	addtimer(CALLBACK(src, PROC_REF(update_mouse_pointer), user), 0.4 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_CLIENT_TIME)

/obj/item/weapon/gun/lever_action/xm88/proc/update_mouse_pointer(mob/user)
	if(user.client?.prefs.custom_cursors)
		user.client?.mouse_pointer_icon = get_mouse_pointer(floating_penetration)

/obj/item/weapon/gun/lever_action/xm88/proc/get_mouse_pointer(level)
	switch(level)
		if(FLOATING_PENETRATION_TIER_0)
			return 'icons/effects/mouse_pointer/xm88/xm88-0.dmi'
		if(FLOATING_PENETRATION_TIER_1)
			return 'icons/effects/mouse_pointer/xm88/xm88-1.dmi'
		if(FLOATING_PENETRATION_TIER_2)
			return 'icons/effects/mouse_pointer/xm88/xm88-2.dmi'
		if(FLOATING_PENETRATION_TIER_3)
			return 'icons/effects/mouse_pointer/xm88/xm88-3.dmi'
		if(FLOATING_PENETRATION_TIER_4)
			return 'icons/effects/mouse_pointer/xm88/xm88-4.dmi'
		else
			return 'icons/effects/mouse_pointer/xm88/xm88-0.dmi'


/obj/item/weapon/gun/lever_action/xm88/proc/get_fired_mouse_pointer(level)
	switch(level)
		if(FLOATING_PENETRATION_TIER_0)
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-0.dmi'
		if(FLOATING_PENETRATION_TIER_1)
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-1.dmi'
		if(FLOATING_PENETRATION_TIER_2)
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-2.dmi'
		if(FLOATING_PENETRATION_TIER_3)
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-3.dmi'
		if(FLOATING_PENETRATION_TIER_4)
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-4.dmi'
		else
			return 'icons/effects/mouse_pointer/xm88/xm88-fired-0.dmi'

/obj/item/weapon/gun/lever_action/xm88/apply_hit_buff()
	chamber_cycle_sound = lever_super_sound
	lever_message = "<b><i>You quickly press the [lever_name]!<i><b>"
	last_fired = world.time - buff_fire_reduc //to shoot the next round faster
	set_fire_delay(FIRE_DELAY_TIER_3)
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_4

	if(floating_penetration < floating_penetration_upper_limit)
		floating_penetration++

	for(var/slot in attachments)
		var/obj/item/attachable/AM = attachments[slot]
		if(AM && (AM.damage_mod || AM.delay_mod))
			damage_mult += AM.damage_mod
			modify_fire_delay(AM.delay_mod)
	wield_delay = 0 //for one-handed levering

/obj/item/weapon/gun/lever_action/xm88/Fire(atom/target, mob/living/user, params, reflex, dual_wield)
	if(!able_to_fire(user) || !target) //checks here since we don't want to fuck up applying the increase
		return NONE
	if(floating_penetration && in_chamber) //has to go before actual firing
		var/obj/projectile/P = in_chamber
		switch(floating_penetration)
			if(FLOATING_PENETRATION_TIER_1)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen20]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
			if(FLOATING_PENETRATION_TIER_2)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen30]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(FLOATING_PENETRATION_TIER_3)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen40]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_medium.ogg"
			if(FLOATING_PENETRATION_TIER_4)
				P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88/pen50]
				direct_hit_sound = "sound/weapons/gun_xm88_directhit_high.ogg"
	return ..()

/*
/obj/item/weapon/gun/lever_action/xm88/unload(mob/user)
	if(levered)
		to_chat(user, SPAN_WARNING("You open \the [src]'s breech and take out a round."))
		levered = FALSE
	return empty_chamber(user)
*/
/obj/item/weapon/gun/lever_action/xm88/reset_hit_buff(mob/user, one_hand_lever)
	if(!(flags_gun_lever_action & USES_STREAKS))
		return
	SIGNAL_HANDLER
	if(streak > 0)
		to_chat(user, SPAN_WARNING("[src] beeps as it loses its targeting data, and returns to normal firing procedures."))
	streak = 0
	chamber_cycle_sound = initial(chamber_cycle_sound)
	lever_message = initial(lever_message)
	wield_delay = initial(wield_delay)
	cur_onehand_chance = initial(cur_onehand_chance)
	direct_hit_sound = "sound/weapons/gun_xm88_directhit_low.ogg"
	if(in_chamber)
		var/obj/projectile/P = in_chamber
		P.ammo = GLOB.ammo_list[/datum/ammo/bullet/lever_action/xm88]
	floating_penetration = FLOATING_PENETRATION_TIER_0
	//these are init configs and so cannot be initial()
	set_fire_delay(FIRE_DELAY_TIER_1 + FIRE_DELAY_TIER_12)
	cycle_chamber_delay = FIRE_DELAY_TIER_3
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recalculate_attachment_bonuses() //stock wield delay
	if(one_hand_lever)
		addtimer(VARSET_CALLBACK(src, cur_onehand_chance, reset_onehand_chance), 4 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/weapon/gun/lever_action/xm88/direct_hit_buff(mob/user, mob/target, one_hand_lever = FALSE)
	. = ..()
	playsound(target, direct_hit_sound, 75)

#undef FLOATING_PENETRATION_TIER_0
#undef FLOATING_PENETRATION_TIER_1
#undef FLOATING_PENETRATION_TIER_2
#undef FLOATING_PENETRATION_TIER_3
#undef FLOATING_PENETRATION_TIER_4
