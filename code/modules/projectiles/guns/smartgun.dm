//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     M56B SMARTGUN                  ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
Come get some.
Should be a child of machinegun.
Note: because smartguns are hardcoded with two ammo types, it's not possible to "cock" them. It instead switches ammo types. If the two ammo types are removed, normal cycling behavior should be restored. see unique_action() in gun_helpers.dm.
This all just means that the smartgun should not be allowed to jam, as there would be no way to clear the malfunction. It also means that untrained people in firearms (civs), will not be able to cock it on reload at all. Not they can use it to begin with. /N
*/

/obj/item/weapon/gun/smartgun
	name = "\improper M56B smartgun"
	desc = "The actual firearm in the 4-piece M56B Smartgun System. Essentially a heavy, mobile machinegun.\nYou may toggle firing restrictions by using a special action.\nAlt-click it to open the feed cover and allow for reloading."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m56"
	item_state = "m56"
	fire_sound = "gun_smartgun"
	fire_rattle = "gun_smartgun_rattle"
	reload_sound = 'sound/weapons/handling/gun_sg_reload.ogg'
	unload_sound = 'sound/weapons/handling/gun_sg_unload.ogg'
	current_mag = /obj/item/ammo_magazine/smartgun
	motion_detector = /obj/item/device/motiondetector/integrated
	integrated_battery = /obj/item/smartgun_battery
	force = 20
	flags_equip_slot = NO_FLAGS
	w_class = SIZE_HUGE
	flags_gun_features = GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_MOTION_DETECTOR|GUN_IFF_SYSTEM
	flags_gun_toggles = GUN_IFF_SYSTEM_ON
	flags_gun_receiver = GUN_CHAMBERED_CYCLE|GUN_CHAMBER_BELT_FED|GUN_CHAMBER_BATTERY_FED
	gun_category = GUN_CATEGORY_HEAVY
	auto_retrieval_slot = WEAR_J_STORE
	start_semiauto = FALSE
	start_automatic = TRUE
	charge_drain = 11

	//Toggled ammo types 1 and 2.
	var/datum/ammo/ammo_primary = /datum/ammo/bullet/smartgun
	var/datum/ammo/ammo_secondary = /datum/ammo/bullet/smartgun/armor_piercing

	//=========// GUN STATS //==========//
	malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO

	fire_delay = FIRE_DELAY_TIER_SG
	burst_amount = BURST_AMOUNT_TIER_1
	burst_delay = FIRE_DELAY_TIER_5

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_1 //+= HIT_ACCURACY_MULT_TIER_2 with accuracy improvement.
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_6 //SCATTER_AMOUNT_TIER_10 with recoil comp
	burst_scatter_mult = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_6

	damage_mult = BULLET_DAMAGE_MULT_BASE
	damage_falloff_mult = DAMAGE_FALLOFF_TIER_10
	damage_buildup_mult = DAMAGE_BUILDUP_TIER_1
	velocity_add = BASE_VELOCITY_BONUS
	recoil = RECOIL_AMOUNT_TIER_3 //ECOIL_OFF with recoil comp
	recoil_unwielded = RECOIL_AMOUNT_TIER_3 //Have to wield it though.
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_1

	effective_range_min = EFFECTIVE_RANGE_OFF
	effective_range_max = EFFECTIVE_RANGE_OFF

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_8
	fa_max_scatter = SCATTER_AMOUNT_TIER_9

	recoil_buildup_limit = RECOIL_AMOUNT_TIER_1 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER

	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	wield_delay = WIELD_DELAY_FAST
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/smartgun/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/m56))
	INHERITLIST(attachable_allowed, list(/obj/item/attachable/barrel/m56, /obj/item/attachable/flashlight,))
	INHERITLIST(attachable_offset, list("barrel_x" = 33, "barrel_y" = 16, "rail_x" = 17, "rail_y" = 18, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 14))
	INHERITORADDLIST(actions_types, list(
			/datum/action/item_action/gun/toggle_accuracy_improvement,
			/datum/action/item_action/gun/toggle_ammo_type,
			/datum/action/item_action/gun/toggle_auto_fire,
			/datum/action/item_action/gun/toggle_lethal_mode,
			/datum/action/item_action/gun/toggle_recoil_compensation
		))

	..()

/obj/item/weapon/gun/smartgun/Initialize(mapload, ...)
	ammo_primary = GLOB.ammo_list[ammo_primary] //Initialize these first so they show up properly before everything else is processed.
	ammo_secondary = GLOB.ammo_list[ammo_secondary]
	. = ..()

/obj/item/weapon/gun/smartgun/racked/Initialize(mapload, spawn_empty = TRUE)
	. = ..()

/obj/item/weapon/gun/smartgun/Destroy()
	ammo_primary = null
	ammo_secondary = null
	. = ..()

/obj/item/weapon/gun/smartgun/attackby(obj/item/attacking_object, mob/user)
	if(istype(attacking_object, /obj/item/smartgun_battery))
		var/obj/item/smartgun_battery/new_cell = attacking_object
		visible_message(SPAN_NOTICE("[user] swaps out the power cell in [src]."),
			SPAN_NOTICE("You swap out the power cell in [src] and drop the old one."))
		to_chat(user, SPAN_NOTICE("The new cell contains: [new_cell.power_cell.charge] power."))
		integrated_battery.update_icon()
		var/obj/item/smartgun_battery/B = integrated_battery.loc
		B.forceMove(get_turf(user)) //Move the old battery itself.
		integrated_battery = new_cell.power_cell
		user.drop_inv_item_to_loc(new_cell, src)
		playsound(src, 'sound/machines/click.ogg', 25, 1)
		return

	return ..()

/obj/item/weapon/gun/smartgun/check_additional_able_to_fire(mob/living/user)
	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!H.wear_suit || !(H.wear_suit.flags_inventory & SMARTGUN_HARNESS))
		to_chat(H, SPAN_WARNING("You need a harness suit to be able to fire [src]..."))
		return FALSE

	return TRUE

/obj/item/weapon/gun/smartgun/recalculate_user_attributes(mob/living/user)
	if(!skillcheckexplicit(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_SMARTGUN) && !skillcheckexplicit(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL))
		unable_to_fire_message = "You don't seem to know how to use [src]..."
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	..()

/obj/item/weapon/gun/smartgun/unique_action(mob/user, smartgun_override = TRUE) //Snowflake processing for smartguns, for now.
	. = ..()
	if(.)
		var/datum/action/item_action/A = locate(/datum/action/item_action/gun/toggle_ammo_type) in actions
		A.action_activate()

//This can be done better, but it will do for now.
/obj/item/weapon/gun/smartgun/dropped(mob/user) //We want to turn off a few things when the gun is dropped.
	. = ..()

	if(flags_gun_toggles & GUN_AUTOMATIC_AIM_ASSIST_ON) //Because the checks necessary can't fire, we need to clear this manually.
		var/datum/action/item_action/A
		toggle_auto_fire(user, FALSE)
		A = locate(/datum/action/item_action/gun/toggle_auto_fire) in actions
		A.button.icon_state = initial(A.action_icon_state)

//I don't like smartguns having two ammunition types. That isn't how smartguns work in the lore or how guns work in general.
//In the future I want ammo to be fed as normal, through the magazine only. For now this will suffice until a smartgun rework.
/obj/item/weapon/gun/smartgun/ready_in_chamber()
	if(--current_mag.feeder_contents[2] <= 0)
		current_mag.feeder_contents.Cut(1, 3)
	current_mag.current_rounds--
	in_chamber = flags_gun_toggles & GUN_SECONDARY_MODE_ON ? ammo_secondary : ammo_primary
	return in_chamber

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                    SMARTGUN BATTERY                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//This is a roundabout hacky way to prevent this battery from being used elsewhere. For now it works, I guess, but I would like to see it made system-compliant later.

/obj/item/smartgun_battery
	name = "smartgun DV9 battery"
	desc = "A standard-issue 9-volt lithium dry-cell battery, most commonly used within the USCMC to power smartguns. Per the manual, one battery is good for up to 50000 rounds and plugs directly into the smartgun's power receptacle, which is only compatible with this type of battery. Various auxiliary modes usually bring the round count far lower. While this cell is incompatible with most standard electrical system, it can be charged by common rechargers in a pinch. USCMC smartgunners often guard them jealously."
	icon = 'icons/obj/structures/machinery/power.dmi'
	icon_state = "smartguncell"
	force = 5
	throwforce = 5
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	w_class = SIZE_SMALL
	var/obj/item/cell/high/power_cell

/obj/item/smartgun_battery/Initialize(mapload)
	. = ..()
	power_cell = new(src)

/obj/item/smartgun_battery/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("The power indicator reads [power_cell.charge] charge out of [power_cell.maxcharge] total.")

/obj/item/smartgun_battery/emp_act(severity)
	. = ..()
	power_cell.use(round(power_cell.maxcharge / severity))
	update_icon()

/obj/item/weapon/gun/smartgun/proc/drain_battery(mob/living/carbon/human/user, charge_to_drain)
	var/actual_drain = rand(charge_to_drain / 2, charge_to_drain) / 25
	if(integrated_battery?.charge >= actual_drain) integrated_battery.charge -= actual_drain
	else
		to_chat(user, SPAN_WARNING("[src] emits a low power warning as it is unable to fire!"))
		return FALSE
	return TRUE

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      ACTIONS DATUM       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------
//Now with no overlays. /N

//These defines are text string "names" of the procs that are toggled through actions.
#define SMARTGUN_CALL_TOGGLE_DETECTOR "toggle_motion_detector"
#define SMARTGUN_CALL_TOGGLE_AUTO "toggle_auto_fire"
#define SMARTGUN_CALL_TOGGLE_ACCURACY "toggle_accuracy_improvement"
#define SMARTGUN_CALL_TOGGLE_RECOIL "toggle_recoil_compensation"
#define SMARTGUN_CALL_TOGGLE_LETHAL "toggle_lethal_mode"
#define SMARTGUN_CALL_TOGGLE_AMMO "toggle_ammo_type"
#define SMARTGUN_CALL_TOGGLE_LOCK "toggle_id_lock"

/datum/action/item_action/gun
	flags_ui_actions = UI_ACTIONS_ITEM_CUSTOM
	var/activating_gun_flag //This gun flag is what toggles the button.
	var/activating_proc_name //What proc call we'll be using to activate whatever.

/datum/action/item_action/gun/New(Target)
	. = ..()
	var/obj/item/weapon/gun/smartgun/G = holder_item
	button.icon_state = G.flags_gun_toggles & activating_gun_flag ? initial(action_icon_state) + "_on" : initial(action_icon_state)

/datum/action/item_action/gun/action_activate(show_message = TRUE)
	var/obj/item/weapon/gun/smartgun/G = holder_item
	if(G.get_active_firearm(owner, FALSE) != holder_item) return //get_active_firearm checks for human, incapacitated, burst firing, etc.
	if(call(G, activating_proc_name)(owner, show_message)) //Here is where the magic happens. Dynamically call the procs we need based on the name and item.
		button.icon_state = G.flags_gun_toggles & activating_gun_flag ? initial(action_icon_state) + "_on" : initial(action_icon_state)

/datum/action/item_action/gun/toggle_accuracy_improvement
	name = "Toggle Accuracy Improvement"
	action_icon_state = "accuracy_improvement"
	activating_gun_flag = GUN_ACCURACY_ASSIST_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_ACCURACY

/datum/action/item_action/gun/toggle_recoil_compensation
	name = "Toggle Recoil Compensation"
	action_icon_state = "recoil_compensation"
	activating_gun_flag = GUN_RECOIL_COMP_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_RECOIL

/datum/action/item_action/gun/toggle_auto_fire
	name = "Toggle Auto Fire"
	action_icon_state = "autofire"
	activating_gun_flag = GUN_AUTOMATIC_AIM_ASSIST_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_AUTO

/datum/action/item_action/gun/toggle_lethal_mode
	name = "Toggle IFF"
	action_icon_state = "iff_toggle"
	activating_gun_flag = GUN_IFF_SYSTEM_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_LETHAL

/datum/action/item_action/gun/toggle_lethal_mode/action_activate(show_message = TRUE)
	..() //Special processing here. If we turn off IFF, we want to turn off armor piercing.
	var/obj/item/weapon/gun/smartgun/G = holder_item
	if(!(G.flags_gun_toggles & GUN_IFF_SYSTEM_ON) && G.flags_gun_toggles & GUN_SECONDARY_MODE_ON) //IFF is off, secondary is on.
		var/datum/action/item_action/A = locate(/datum/action/item_action/gun/toggle_ammo_type) in holder_item.actions
		A.action_activate(FALSE)

/datum/action/item_action/gun/toggle_ammo_type
	name = "Toggle Ammo Type"
	action_icon_state = "ammo_swap"
	activating_gun_flag = GUN_SECONDARY_MODE_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_AMMO

/datum/action/item_action/gun/toggle_motion_detector
	name = "Toggle Motion Detector"
	action_icon_state = "motion_detector"
	activating_gun_flag = GUN_MOTION_DETECTOR_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_DETECTOR

//Cpecific to the CO smartgun.
/datum/action/item_action/gun/toggle_id_lock
	name = "Toggle ID lock"
	action_icon_state = "id_lock"
	activating_gun_flag = GUN_ID_LOCK_ON
	activating_proc_name = SMARTGUN_CALL_TOGGLE_LOCK

#undef SMARTGUN_CALL_TOGGLE_DETECTOR
#undef SMARTGUN_CALL_TOGGLE_AUTO
#undef SMARTGUN_CALL_TOGGLE_ACCURACY
#undef SMARTGUN_CALL_TOGGLE_RECOIL
#undef SMARTGUN_CALL_TOGGLE_LETHAL
#undef SMARTGUN_CALL_TOGGLE_AMMO
#undef SMARTGUN_CALL_TOGGLE_LOCK

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	   GENERAL SMARTGUN PROCS   	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/smartgun/proc/toggle_ammo_type(mob/user, show_message = TRUE)
	if(!(flags_gun_toggles & GUN_IFF_SYSTEM_ON) && !(flags_gun_toggles & GUN_SECONDARY_MODE_ON))
		to_chat(user, "[icon2html(src, user.client)] Can't switch ammunition type when [src]'s fire restriction is disabled.")
		return
	flags_gun_toggles ^= GUN_SECONDARY_MODE_ON
	if(show_message)
		to_chat(user, "[icon2html(src, usr)] You changed [src]'s ammo preparation procedures. You now fire [flags_gun_toggles & GUN_SECONDARY_MODE_ON ? "armor shredding rounds" : "highly precise rounds"].")
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	if(in_chamber) in_chamber = flags_gun_toggles & GUN_SECONDARY_MODE_ON ? ammo_secondary : ammo_primary //These are hardcoded references on spawn.
	return TRUE

/obj/item/weapon/gun/proc/toggle_lethal_mode(mob/user, show_message = TRUE)
	if(show_message)
		to_chat(user, "[icon2html(src, user.client)] You [flags_gun_toggles & GUN_IFF_SYSTEM_ON? "<B>disable</b>" : "<B>enable</b>"] [src]'s fire restriction. You will [flags_gun_toggles & GUN_IFF_SYSTEM_ON ? "harm anyone in your way" : "target through IFF"].")
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	flags_gun_toggles ^= GUN_IFF_SYSTEM_ON

	if(flags_gun_toggles & GUN_IFF_SYSTEM_ON)
		add_bullet_trait(BULLET_TRAIT_ENTRY_ID("iff", /datum/element/bullet_trait_iff))
		charge_drain += 10
		motion_detector.iff_signal = initial(motion_detector.iff_signal)
	else
		remove_bullet_trait("iff")
		charge_drain -= 10
		motion_detector.iff_signal = null
	return TRUE

/obj/item/weapon/gun/proc/toggle_recoil_compensation(mob/user, show_message = TRUE)
	if(show_message)
		to_chat(user, "[icon2html(src, usr)] You [flags_gun_toggles & GUN_RECOIL_COMP_ON? "<B>disable</b>" : "<B>enable</b>"] [src]'s recoil compensation.")
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	flags_gun_toggles ^= GUN_RECOIL_COMP_ON
	charge_drain += (flags_gun_toggles & GUN_RECOIL_COMP_ON) ? 50 : -50
	recalculate_attachment_bonuses()
	return TRUE

/obj/item/weapon/gun/proc/toggle_accuracy_improvement(mob/user, show_message = TRUE)
	if(show_message)
		to_chat(user, "[icon2html(src, usr)] You [flags_gun_toggles & GUN_ACCURACY_ASSIST_ON? "<B>disable</b>" : "<B>enable</b>"] [src]'s accuracy improvement.")
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	flags_gun_toggles ^= GUN_ACCURACY_ASSIST_ON
	charge_drain += (flags_gun_toggles & GUN_ACCURACY_ASSIST_ON) ? 50 : -50
	recalculate_attachment_bonuses()
	return TRUE

/obj/item/weapon/gun/proc/toggle_motion_detector(mob/user, show_message = TRUE)
	if(show_message)
		to_chat(user, "[icon2html(src, user.client)] You [flags_gun_toggles & GUN_MOTION_DETECTOR_ON? "<B>disable</b>" : "<B>enable</b>"] [src]'s motion detector.")
		if(GUN_MOTION_DETECTOR_ON) playsound(loc, 'sound/items/detector_turn_off.ogg', 30, FALSE, 5, 2)
		else playsound(loc, 'sound/items/detector_turn_on.ogg', 30, FALSE, 5, 2)
	flags_gun_toggles ^= GUN_MOTION_DETECTOR_ON

	if(flags_gun_toggles & GUN_MOTION_DETECTOR_ON)
		motion_detector.turn_on(user)
		charge_drain += 15
	else
		motion_detector.turn_off(user)
		charge_drain -= 15
	return TRUE

/obj/item/weapon/gun/proc/remove_motion_detector()
	if(flags_gun_features & GUN_MOTION_DETECTOR)
		vis_contents -= motion_detector
		if(flags_gun_toggles & GUN_MOTION_DETECTOR_ON) //If it was on, turn it off.
			var/datum/action/item_action/A
			toggle_motion_detector(null, FALSE)
			A = locate(/datum/action/item_action/gun/toggle_motion_detector) in actions
			A.button.icon_state = initial(A.action_icon_state)

/obj/item/weapon/gun/smartgun/proc/toggle_auto_fire(mob/user, show_message = TRUE)
	if(!(flags_item & WIELDED) && !(flags_gun_toggles & GUN_AUTOMATIC_AIM_ASSIST_ON))
		to_chat(user, "[icon2html(src, user.client)] You need to wield [src] to enable autofire.")
		return //Have to actually be wielded.
	if(show_message)
		to_chat(user, "[icon2html(src, user.client)] You [flags_gun_toggles & GUN_AUTOMATIC_AIM_ASSIST_ON? "<B>disable</b>" : "<B>enable</b>"] [src]'s auto fire mode.")
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	flags_gun_toggles ^= GUN_AUTOMATIC_AIM_ASSIST_ON
	auto_fire()
	return TRUE

/obj/item/weapon/gun/smartgun/proc/auto_fire()
	if(flags_gun_toggles & GUN_AUTOMATIC_AIM_ASSIST_ON)
		charge_drain += 150
		START_PROCESSING(SSobj, src)
	else
		charge_drain -= 150
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/gun/smartgun/process()
	if(flags_gun_toggles & GUN_AUTOMATIC_AIM_ASSIST_ON)
		auto_prefire()
	else STOP_PROCESSING(SSobj, src)

/obj/item/weapon/gun/smartgun/proc/auto_prefire(warned) //To allow the autofire delay to properly check targets after waiting.
	if(ishuman(loc) && flags_item & WIELDED)
		var/human_user = loc
		target = get_target(human_user)
		process_shot(human_user, warned)
	else
		var/datum/action/item_action/gun/A = locate(/datum/action/item_action/gun/toggle_auto_fire) in actions //We want to turn off autofire if the they are not wielding the smartgun.
		A.action_activate(FALSE) //Hide the message.

#define SMARTGUN_AUTO_SHOT_RANGE 7 //The range the gun can fire.
#define SMARTGUN_AUTO_SHOT_ANGLE 135 //The angle the gun will check for. Set to 0 for the gun to ignore angle. Possible choices: 180, 90, 60, 30
//This appears to be a system that didn't go anywhere. I changed it to a define instead of a variable. Should be changed back if this becomes relevant.

/obj/item/weapon/gun/smartgun/proc/get_target(mob/living/user)
	var/list/conscious_targets = list()
	var/list/unconscious_targets = list()
	var/list/turf/path = list()
	var/turf/T

	for(var/mob/living/M in orange(SMARTGUN_AUTO_SHOT_RANGE, user)) // orange allows sentry to fire through gas and darkness
		if((M.stat & DEAD)) continue // No dead or non living.

		if(M.get_target_lock(user.faction_group)) continue
		if(SMARTGUN_AUTO_SHOT_ANGLE) //If there is maximum angle allowed.
			var/opp
			var/adj

			switch(user.dir)
				if(NORTH)
					opp = user.x-M.x
					adj = M.y-user.y
				if(SOUTH)
					opp = user.x-M.x
					adj = user.y-M.y
				if(EAST)
					opp = user.y-M.y
					adj = M.x-user.x
				if(WEST)
					opp = user.y-M.y
					adj = user.x-M.x

			var/r = 9999
			if(adj != 0) r = abs(opp/adj)
			var/angledegree = arcsin(r/sqrt(1+(r*r)))
			if(adj < 0) continue
			if((angledegree*2) > SMARTGUN_AUTO_SHOT_ANGLE) continue

		path = getline2(user, M)

		if(path.len)
			var/blocked = FALSE
			for(T in path)
				if(T.density || T.opacity)
					blocked = TRUE
					break
				for(var/obj/structure/S in T)
					if(S.opacity)
						blocked = TRUE
						break
				for(var/obj/structure/machinery/MA in T)
					if(MA.opacity)
						blocked = TRUE
						break
				if(blocked)
					break
			if(blocked)
				continue
			if(M.stat & UNCONSCIOUS)
				unconscious_targets += M
			else
				conscious_targets += M

	if(conscious_targets.len)
		. = pick(conscious_targets)
	else if(unconscious_targets.len)
		. = pick(unconscious_targets)

#undef SMARTGUN_AUTO_SHOT_RANGE
#undef SMARTGUN_AUTO_SHOT_ANGLE

/obj/item/weapon/gun/smartgun/proc/process_shot(mob/living/user, warned)
	set waitfor = 0


	if(!target)
		return //Acquire our victim.

	if(target && (world.time-last_fired >= 3)) //Practical firerate is limited mainly by process delay; this is just to make sure it doesn't fire too soon after a manual shot or slip a shot into an ongoing burst.
		if(world.time-last_fired >= 300 && !warned) //if we haven't fired for a while, beep first
			playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
			addtimer(CALLBACK(src, /obj/item/weapon/gun/smartgun/proc/auto_prefire, TRUE), 3)
			return

		Fire(target,user)

	target = null

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 CO CAVALIER SMARTGUN               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smartgun/co
	name = "\improper M56C 'Cavalier' smartgun"
	desc = "The actual firearm in the 4-piece M56C Smartgun system. Back order only. Besides a more robust weapons casing, an ID lock system and a fancy paintjob, the gun's performance is identical to the standard-issue M56B.\nAlt-click it to open the feed cover and allow for reloading."
	icon_state = "m56c"
	item_state = "m56c"
	flags_gun_features = GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_MOTION_DETECTOR|GUN_IDENTITY_PROTECTED|GUN_IFF_SYSTEM
	var/mob/living/carbon/human/linked_human

/obj/item/weapon/gun/smartgun/co/check_additional_able_to_fire(mob/user)
	. = ..()

	if(flags_gun_toggles & GUN_ID_LOCK_ON && linked_human && linked_human != user) //This should be a component/element signal check. The flag should only be set if the human target is perma gone.
		if(linked_human.is_revivable() || linked_human.stat != DEAD)
			to_chat(user, SPAN_WARNING("[icon2html(src, user.client)] Trigger locked by [src]. Unauthorized user."))
			playsound(loc,'sound/weapons/gun_empty.ogg', 25, 1)
			return FALSE

		linked_human = null
		var/datum/action/item_action/gun/A = locate(/datum/action/item_action/gun/toggle_id_lock) in actions
		A.button.icon_state = initial(A.action_icon_state)
		flags_gun_toggles &= ~GUN_ID_LOCK_ON //We don't want to fire the proc here, just reset everything.
		UnregisterSignal(linked_human, COMSIG_PARENT_QDELETING)

/obj/item/weapon/gun/smartgun/co/proc/toggle_id_lock(mob/user, show_message = TRUE)
	if(linked_human && user != linked_human)
		to_chat(usr, SPAN_WARNING("[icon2html(src, user.client)] Action denied by [src]. Unauthorized user."))
		return
	else if(!linked_human)
		name_after_co(usr)

	flags_gun_toggles ^= GUN_ID_LOCK_ON
	if(show_message)
		to_chat(usr, SPAN_NOTICE("[icon2html(src, usr)] You [flags_gun_toggles & GUN_ID_LOCK_ON? "lock": "unlock"] [src]."))
		playsound(loc,'sound/machines/click.ogg', 25, 1)
	return TRUE

/obj/item/weapon/gun/smartgun/co/pickup(mob/user)
	if(!linked_human)
		name_after_co(user, src)
		to_chat(usr, SPAN_NOTICE("[icon2html(src, user.client)] You pick up [src], registering yourself as its owner."))
	..()

/obj/item/weapon/gun/smartgun/co/proc/name_after_co(mob/living/carbon/human/H, obj/item/weapon/gun/smartgun/co/I)
	linked_human = H
	RegisterSignal(linked_human, COMSIG_PARENT_QDELETING, PROC_REF(remove_idlock))

/obj/item/weapon/gun/smartgun/co/get_additional_gun_examine_text(mob/user)
	. = ..()
	if(linked_human)
		if(flags_gun_toggles & GUN_ID_LOCK_ON)
			. += SPAN_NOTICE("It is registered to [linked_human].")
		else
			. += SPAN_NOTICE("It is registered to [linked_human] but has its fire restrictions unlocked.")
	else
		. += SPAN_NOTICE("It's unregistered. Pick it up to register yourself as its owner.")

/obj/item/weapon/gun/smartgun/co/proc/remove_idlock()
	SIGNAL_HANDLER //???
	linked_human = null

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                M56D DIRTY SMART GUN                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M56D 'Dirty' smartgun"
	desc = "The actual firearm in the 4-piece M56D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way.\nYou may toggle firing restrictions by using a special action.\nAlt-click it to open the feed cover and allow for reloading."
	current_mag = /obj/item/ammo_magazine/smartgun/dirty
	motion_detector = /obj/item/device/motiondetector/integrated/pmc
	ammo_primary = /datum/ammo/bullet/smartgun/dirty//Toggled ammo type
	ammo_secondary = /datum/ammo/bullet/smartgun/dirty/armor_piercing///Toggled ammo type
	flags_gun_features = GUN_WY_RESTRICTED|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_MOTION_DETECTOR|GUN_IFF_SYSTEM

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_12
	burst_amount = BURST_AMOUNT_TIER_5
	burst_delay = FIRE_DELAY_TIER_12

	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_10
	fa_max_scatter = SCATTER_AMOUNT_NONE
	//=========// GUN STATS //==========//

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               M56D TERMINATOR SMARTGUN             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smartgun/dirty/elite
	name = "\improper M56T 'Terminator' smartgun"
	desc = "The actual firearm in the 4-piece M56T Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way.\nYou may toggle firing restrictions by using a special action.\nAlt-click it to open the feed cover and allow for reloading."
	motion_detector = /obj/item/device/motiondetector/integrated/deathsquad

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[             M56B FREEDOM / CLF SMARTGUN            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smartgun/clf
	name = "\improper M56B 'Freedom' smartgun"
	desc = "The actual firearm in the 4-piece M56B Smartgun System. Essentially a heavy, mobile machinegun. This one has the CLF logo carved over the manufacturing stamp.\nYou may toggle firing restrictions by using a special action.\nAlt-click it to open the feed cover and allow for reloading."
	motion_detector = /obj/item/device/motiondetector/integrated/clf

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[            L56A2 SMARTGUN / ROYAL MARINES          ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/smartgun/rmc
	name = "\improper L56A2 smartgun"
	desc = "The actual firearm in the 2-piece L56A2 Smartgun System. This Variant is used by the Three World Empires Royal Marines Commando units.\nYou may toggle firing restrictions by using a special action.\nAlt-click it to open the feed cover and allow for reloading."
	current_mag = /obj/item/ammo_magazine/smartgun/holo_targetting
	motion_detector = /obj/item/device/motiondetector/integrated/twe
	ammo_primary = /datum/ammo/bullet/smartgun/holo_target //Toggled ammo type
	ammo_secondary = /datum/ammo/bullet/smartgun/holo_target/ap ///Toggled ammo type
	flags_gun_features = GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_MOTION_DETECTOR|GUN_IFF_SYSTEM
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/twe_guns.dmi'
	icon_state = "magsg"
	item_state = "magsg"

/obj/item/weapon/gun/smartgun/rmc/initialize_gun_lists()
	INHERITLIST(starting_attachment_types, list(/obj/item/attachable/barrel/l56a2))

	..()

//Why does this exist? Hack solution to something that I may delete later.
//Doesn't care about harness, battery, or even the number of bullets in the drum (but does care about the drum being present). Fire it with one hand! Also doesn't care about being a specialist.
/obj/item/weapon/gun/smartgun/admin
	flags_gun_features = GUN_AMMO_COUNTER|GUN_MOTION_DETECTOR|GUN_IFF_SYSTEM
	flags_gun_receiver = GUN_CHAMBERED_CYCLE|GUN_CHAMBER_BELT_FED

/obj/item/weapon/gun/smartgun/admin/check_additional_able_to_fire(mob/living/user)
	return TRUE

/obj/item/weapon/gun/smartgun/admin/ready_in_chamber(mob/living/user)
	in_chamber = flags_gun_toggles & GUN_SECONDARY_MODE_ON ? ammo_secondary : ammo_primary
	return in_chamber


