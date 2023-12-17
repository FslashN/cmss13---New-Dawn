//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   GENERIC REVOLVER                 ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Revolvers generally don't (and should not) have ammo counters, but the functionality works. Revolvers by and large don't have safeties.

//Generic parent object.
/obj/item/weapon/gun/revolver
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_MEDIUM

	matter = list("metal" = 2000)
	fire_sound = 'sound/weapons/gun_44mag_v3.ogg'
	reload_sound = 'sound/weapons/gun_44mag_speed_loader.wav'
	cocked_sound = 'sound/weapons/gun_revolver_cocked.ogg'
	unload_sound = 'sound/weapons/gun_44mag_open_chamber.wav'
	var/chamber_close_sound = 'sound/weapons/gun_44mag_close_chamber.wav'
	var/hand_reload_sound = 'sound/weapons/gun_revolver_load3.ogg'
	var/spin_sound = 'sound/effects/spin.ogg'
	var/thud_sound = 'sound/effects/thud.ogg'
	var/trick_delay = 2.5 SECONDS //Yeah, 4 seconds is too long.
	var/recent_trick //So they're not spamming tricks.
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_NO_SAFETY_SWITCH
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBER_CAN_OPEN|GUN_CHAMBER_ROTATES|GUN_ACCEPTS_HANDFUL|GUN_ACCEPTS_SPEEDLOADER
	gun_category = GUN_CATEGORY_HANDGUN
	wield_delay = WIELD_DELAY_VERY_FAST //If you modify your revolver to be two-handed, it will still be fast to aim
	movement_onehanded_acc_penalty_mult = 3
	has_empty_icon = FALSE
	has_open_icon = TRUE
	current_mag = /obj/item/ammo_magazine/internal/revolver
	projectile_casing = PROJECTILE_CASING_BULLET

	//=========// GUN STATS //==========//
	cycle_chamber_delay = FIRE_DELAY_TIER_8 //Almost no cocking delay.

	fire_delay = FIRE_DELAY_TIER_5

	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_3
	//=========// GUN STATS //==========//

/*
The chamber counts up (to simulate clockwise rotation), resetting when it reaches the max; this behavior is the same for right side up and upside down cylinders (counter clockwise rotation).

	  1		  4
	2	6	3	5
	3	5	2	6
	  4		  1

Alternative setup that would count down instead (this was originally used). Changed in favor of loading bullets sequentially.

  	  1		  4
	6	2	5	3
	5	3	6	2
  	  4		  1

The chamber rotates before each bullet is fired, so the first firing position is usually 2.

GUN_ROTATE_CYLINDER is a macro that calls for one space cylinder rotation (1-2). GUN_ROTATE_CYLINDER_BACK is the same but in the opposite direction (2-1).
*/

/obj/item/weapon/gun/revolver/get_additional_gun_examine_text(mob/user)
	. = ..() + ( flags_gun_receiver & GUN_CHAMBER_IS_OPEN ? "The cylinder is open with [current_mag.current_rounds] round\s loaded." : "The cylinder is closed." )

/obj/item/weapon/gun/revolver/unique_action(mob/user)
	if(flags_gun_receiver & GUN_CHAMBER_IS_OPEN && current_mag.current_rounds)
		sort_cylinder_ammo(user)
		to_chat(user, SPAN_NOTICE("You clear the cylinder of [src]."))
	else
		cycle_chamber(user)
		update_icon()

/obj/item/weapon/gun/revolver/cycle_chamber(mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	if(cycle_chamber_cooldown > world.time)
		return

	cycle_chamber_cooldown = world.time + cycle_chamber_delay

	play_chamber_cycle_sound(user, cocked_sound)

	flags_gun_receiver ^= GUN_HAMMER_IS_COCKED //Cock/decock the hammer.
	if(flags_gun_receiver & GUN_HAMMER_IS_COCKED && !(flags_gun_receiver & GUN_CHAMBER_IS_OPEN)) //Only rotates if the cylinder is closed and the hammer was pulled back.
		GUN_ROTATE_CYLINDER

//The cylinder is always emptied out before a reload takes place.
/obj/item/weapon/gun/revolver/replace_magazine(mob/user, ammunition_reference)
	playsound(user, hand_reload_sound, 25, 1)
	return TRUE

/obj/item/weapon/gun/revolver/unload(mob/user, reloading_override = FALSE)
	if(flags_gun_toggles & GUN_BURST_FIRING) return

	if(flags_gun_receiver & GUN_CHAMBER_IS_OPEN)
		playsound(src, chamber_close_sound, 25, 1)

		if(current_mag.current_rounds && current_mag.current_rounds != current_mag.max_rounds && user_skill_level > SKILL_FIREARMS_CIVILIAN) //Civs won't know to do this ahead of time.
			for(var/i = 1 to current_mag.max_rounds) //We're trying to find the next position with some ammo, so that if the gun is not full, it can fire the most rounds in sequence.
			//When hand reloading, it spins to the next position, which may be empty. So spin back, we're shooting a blank for the first round. Have to locate something we can fire, then spin back.
				if(current_mag.feeder_contents["[current_mag.chamber_position]"]) //Find the first position that has rounds.
					ROTATE_CYLINDER_BACK(current_mag)
					break
				ROTATE_CYLINDER(current_mag)
	else
		if(make_casing(projectile_casing) || reloading_override) //If we have some spent rounds in the chamber or we're reloading manually,
			sort_cylinder_ammo(user) //First sort before the cylinder is dumped.
			to_chat(user, SPAN_NOTICE("You clear the cylinder of [src]."))

		flags_gun_toggles &= ~GUN_PLAYING_RUS_ROULETTE //Resets the RR variable.
		playsound(src, unload_sound, 25, 1)

	flags_gun_receiver ^= GUN_CHAMBER_IS_OPEN
	update_icon()

/*
We want the ammo with the most rounds first, so it gets placed in hand if possible. We don't care to sort the entire list,
and there generally will be only two possible ammo types if not fewer. If mixed handfuls are introduced, this proc will not be necessary.
*/
/obj/item/weapon/gun/revolver/proc/sort_cylinder_ammo(mob/user)
	var/ammo_available[0] //we need a list of all the different ammo in the cylinder.
	var/leading_ammo //This is the ammo with the most rounds.
	var/ammo_path //Our generic path tracker.

	//This will give us an associated list of the ammo and how many "rounds" each ammo had.
	for(var/i = 1 to current_mag.max_rounds)
		ammo_path = current_mag.feeder_contents["[i]"]
		if(ammo_path) //Is it null or not?
			current_mag.feeder_contents -= "[i]" //Remove it.
			if(ammo_path in ammo_available) //Is it already in the list?
				ammo_available[ammo_path]++ //Move up the number.
			else //If it's not, add it to make the association.
				ammo_available[ammo_path] = 1

			if(ammo_available[ammo_path] > ammo_available[leading_ammo])
				leading_ammo = ammo_path

	if(ammo_available.len) //We have some ammo.
		ammo_available = list(leading_ammo) | ammo_available //We simply make a new list with both elements. Leading ammo in the first position, so it gets added first.
		for(var/i in ammo_available)
			current_mag.create_handful(user, null, ammo_available[i], i)

// FLUFF
/obj/item/weapon/gun/revolver/alt_click_action(mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING) return

	if(usr.is_mob_incapacitated() || !usr.loc || !isturf(usr.loc))
		to_chat(usr, "Not right now.")
		return

	if(!locate(src) in list(user.get_active_hand(), user.get_inactive_hand()))
		to_chat(usr, "Cannot locate the revolver.")
		return TRUE

	current_mag.chamber_position = rand(1,current_mag.max_rounds)
	to_chat(user, SPAN_NOTICE("You spin the cylinder."))
	playsound(user, 'sound/weapons/gun_revolver_spun.ogg', 25, 1)
	flags_gun_toggles |= GUN_PLAYING_RUS_ROULETTE //Sets to play RR. Resets when the gun is emptied.

/obj/item/weapon/gun/revolver/proc/revolver_basic_spin(mob/living/carbon/human/user, direction = 1, obj/item/weapon/gun/revolver/double)
	set waitfor = 0
	playsound(user, spin_sound, 25, 1)
	if(double)
		user.visible_message("[user] deftly flicks and spins [src] and [double]!", SPAN_NOTICE("You flick and spin [src] and [double]!"),  null, 3)
		animation_wrist_flick(double, 1)
	else
		user.visible_message("[user] deftly flicks and spins [src]!",SPAN_NOTICE("You flick and spin [src]!"),  null, 3)

	animation_wrist_flick(src, direction)
	sleep(3)
	if(loc && user) playsound(user, thud_sound, 25, 1)

/obj/item/weapon/gun/revolver/proc/revolver_throw_catch(mob/living/carbon/human/user)
	set waitfor = 0
	user.visible_message("[user] deftly flicks [src] and tosses it into the air!", SPAN_NOTICE("You flick and toss [src] into the air!"), null, 3)
	var/img_layer = MOB_LAYER+0.1
	var/image/trick = image(icon,user,icon_state,img_layer)
	switch(pick(1,2))
		if(1) animation_toss_snatch(trick)
		if(2) animation_toss_flick(trick, pick(1,-1))

	invisibility = 100
	var/list/client/displayed_for = list()
	for(var/mob/M as anything in viewers(user))
		var/client/C = M.client
		if(C)
			C.images += trick
			displayed_for += C

	sleep(6) // BOO

	for(var/client/C in displayed_for)
		C.images -= trick
	trick = null
	invisibility = 0

	if(loc && user)
		playsound(user, thud_sound, 25, 1)
		if(user.get_inactive_hand())
			user.visible_message("[user] catches [src] with the same hand!", SPAN_NOTICE("You catch [src] as it spins in to your hand!"), null, 3)
		else
			user.visible_message("[user] catches [src] with \his other hand!", SPAN_NOTICE("You snatch [src] with your other hand! Awesome!"), null, 3)
			user.temp_drop_inv_item(src)
			user.put_in_inactive_hand(src)
			user.swap_hand()
			user.update_inv_l_hand(0)
			user.update_inv_r_hand()

/obj/item/weapon/gun/revolver/proc/revolver_trick(mob/living/carbon/human/user)
	if(world.time < (recent_trick + trick_delay) ) return //Don't spam it.
	if(!istype(user)) return //Not human.
	var/chance = -5
	chance = user.health < 6 ? 0 : user.health - 5

	//Pain is largely ignored, since it deals its own effects on the mob. We're just concerned with health.
	//And this proc will only deal with humans for now.

	recent_trick = world.time //Turn on the delay for the next trick.
	var/obj/item/weapon/gun/revolver/double = user.get_inactive_hand()
	if(prob(chance)) //I love this proc so much.
		switch(rand(1,8))
			if(1)
				revolver_basic_spin(user, -1)
			if(2)
				revolver_basic_spin(user, 1)
			if(3)
				revolver_throw_catch(user)
			if(4)
				revolver_basic_spin(user, 1)
			if(5)
				revolver_basic_spin(user, 1)
			if(6)
				var/arguments[] = istype(double) ? list(user, 1, double) : list(user, -1)
				revolver_basic_spin(arglist(arguments))
			if(7)
				var/arguments[] = istype(double) ? list(user, -1, double) : list(user, 1)
				revolver_basic_spin(arglist(arguments))
			if(8)
				if(istype(double))
					spawn(0)
						double.revolver_throw_catch(user)
					revolver_throw_catch(user)
				else
					revolver_throw_catch(user)
		return TRUE
	else
		user.visible_message(SPAN_INFO("<b>[user]</b> fumbles with [src] like a huge idiot!"), null, null, 3)
		to_chat(user, SPAN_WARNING("You fumble with [src] like an idiot... Uncool."))
		return FALSE

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  M44 COMBAT REVOLVER               ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/revolver/m44
	name = "\improper M44 combat revolver"
	desc = "A bulky revolver, occasionally carried by assault troops and officers in the Colonial Marines, as well as civilian law enforcement. Fires .44 Magnum rounds."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m44r"
	item_state = "m44r"
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44
	force = 8
	var/folded = FALSE // Used for the stock attachment, to check if we can shoot or not

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_7

	accuracy_mult = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	damage_mult = BULLET_DAMAGE_MULT_BASE
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	//=========// GUN STATS //==========//


/obj/item/weapon/gun/revolver/m44/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/stock/revolver,
			/obj/item/attachable/scope,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini_iff,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 21,"rail_x" = 12, "rail_y" = 23, "under_x" = 21, "under_y" = 18, "stock_x" = 16, "stock_y" = 20)

	..()

/obj/item/weapon/gun/revolver/m44/check_additional_able_to_fire(mob/user)
	if(folded)
		to_chat(user, SPAN_NOTICE("You need to unfold the stock to fire!"))
		return FALSE
	. = ..()

/obj/item/weapon/gun/revolver/m44/mp //No differences (yet) beside spawning with marksman ammo loaded
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44/marksman

/obj/item/weapon/gun/revolver/m44/custom //loadout
	name = "\improper M44 custom combat revolver"
	desc = "A bulky combat revolver. The handle has been polished to a pearly perfection, and the body is silver plated. Fires .44 Magnum rounds."
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44
	icon_state = "m44rc"
	item_state = "m44rc"

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[             M2019 BLASTER / PKD SPECIAL            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
// Blade Runner Blasters.

/obj/item/weapon/gun/revolver/m44/custom/pkd_special
	name = "\improper M2019 Blaster"
	desc = "Properly known as the Pflager Katsumata Series-D Blaster, the M2019 is a relic of a handgun used by detectives and blade runners, having replaced the snub nose .38 detective special in 2019. Fires .44 custom packed sabot magnum rounds. Legally a revolver, the unconventional but robust internal design has made this model incredibly popular amongst collectors and enthusiasts."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "lapd_2019"
	item_state = "highpower" //placeholder
	fire_sound = "gun_pkd"
	fire_rattle = 'sound/weapons/gun_pkd_fire01_rattle.ogg'
	reload_sound = 'sound/weapons/handling/pkd_speed_load.ogg'
	cocked_sound = 'sound/weapons/handling/pkd_cock.wav'
	unload_sound = 'sound/weapons/handling/pkd_open_chamber.ogg'
	chamber_close_sound = 'sound/weapons/handling/pkd_close_chamber.ogg'
	hand_reload_sound = 'sound/weapons/gun_revolver_load3.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/m44/pkd

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_11

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/m44/custom/pkd_special/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/lasersight,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	..()

/obj/item/weapon/gun/revolver/m44/custom/pkd_special/k2049
	name = "\improper M2049 Blaster"
	desc = "In service since 2049, the LAPD 2049 .44 special has been used to retire more replicants than there are colonists in the American Corridor. The top mounted picatinny rail allows this revised version to mount a wide variety of optics for the aspiring detective. Although replicants aren't permitted past the outer core systems, this piece occasionally finds its way to the rim in the hand of defects, collectors, and thieves."
	icon_state = "lapd_2049"
	item_state = "m4a3c" //placeholder

/obj/item/weapon/gun/revolver/m44/custom/pkd_special/k2049/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/lasersight,
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/scope/mini_iff,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	..()

/obj/item/weapon/gun/revolver/m44/custom/pkd_special/l_series
	name = "\improper PKL 'Double' Blaster"
	desc = "Sold to civilians and private corporations, the Pflager Katsumata Series-L Blaster is a premium double barrel sidearm that can fire two rounds at the same time. Usually found in the hands of combat synths and replicants, this hand cannon is worth more than the combined price of three Emanators. Originally commissioned by the Wallace Corporation, it has since been released onto public market as a luxury firearm."
	icon_state = "pkd_double"
	item_state = "88m4" //placeholder

	//=========// GUN STATS //==========//
	burst_amount = BURST_AMOUNT_TIER_2
	burst_delay = FIRE_DELAY_TIER_12

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	fire_delay = FIRE_DELAY_TIER_11
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/m44/custom/pkd_special/l_series/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/flashlight,
			/obj/item/attachable/lasersight,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[             WEBLEY MK VI SERVICE PISTOL            ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun/revolver/m44/custom/webley //Van Bandolier's Webley.
	name = "\improper Webley Mk VI service pistol"
	desc = "A heavy top-break revolver. Bakelite grips, and older than most nations. .455 was good enough for angry tribesmen and <i>les boche</i>, and by Gum it'll do for Colonial Marines and xenomorphs as well."
	current_mag = /obj/item/ammo_magazine/internal/revolver/webley
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "webley"
	item_state = "m44r"

	//=========// GUN STATS //==========//
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/m44/custom/webley/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/bayonet,
			/obj/item/attachable/bayonet/upp,
		)

	..()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[             RUSSIAN REVOLVER / ZHNK-72             ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//RUSSIAN REVOLVER //Based on the 7.62mm Russian revolvers.

/obj/item/weapon/gun/revolver/upp
	name = "\improper ZHNK-72 revolver"
	desc = "The ZHNK-72 is a UPP designed revolver. The ZHNK-72 is used by the UPP armed forces in a policing role as well as limited numbers in the hands of SNCOs."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "zhnk72"
	item_state = "zhnk72"

	fire_sound = "gun_pkd" //sounds stolen from bladerunner revolvers bc they arent used and sound awesome
	fire_rattle = 'sound/weapons/gun_pkd_fire01_rattle.ogg'
	reload_sound = 'sound/weapons/handling/pkd_speed_load.ogg'
	cocked_sound = 'sound/weapons/handling/pkd_cock.wav'
	unload_sound = 'sound/weapons/handling/pkd_open_chamber.ogg'
	chamber_close_sound = 'sound/weapons/handling/pkd_close_chamber.ogg'
	hand_reload_sound = 'sound/weapons/gun_revolver_load3.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/upp
	force = 8

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_9

	accuracy_mult = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_6
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_4
	recoil = RECOIL_OFF
	recoil_unwielded = RECOIL_OFF
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/upp/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/scope,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/bayonet, // Muzzle
			/obj/item/attachable/bayonet/upp,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/lasersight, // Underbarrel
			)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 21,"rail_x" = 14, "rail_y" = 23, "under_x" = 19, "under_y" = 17, "stock_x" = 24, "stock_y" = 19)

	..()

/obj/item/weapon/gun/revolver/upp/shrapnel
	current_mag = /obj/item/ammo_magazine/internal/revolver/upp/shrapnel

/obj/item/weapon/gun/revolver/upp/shrapnel/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types =list(/obj/item/attachable/lasersight)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[         S&W .38 MODEL 37 / TRICK REVOLVER          ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//357 REVOLVER //Based on the generic S&W 357.
//a lean mean machine, pretty inaccurate unless you play its dance. It is now single action, too! What fun.

/obj/item/weapon/gun/revolver/small
	name = "\improper S&W .38 model 37 revolver"
	desc = "A lean .38 made by Smith & Wesson. A timeless classic, from antiquity to the future. This specific model is known to be wildly inaccurate, yet extremely lethal."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "sw357"
	item_state = "ny762" //PLACEHOLDER
	fire_sound = 'sound/weapons/gun_44mag2.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/small
	force = 6
	flags_gun_features = GUN_ANTIQUE|GUN_ONE_HAND_WIELDED|GUN_CAN_POINTBLANK|GUN_NO_SAFETY_SWITCH
	flags_gun_receiver = GUN_INTERNAL_MAG|GUN_CHAMBER_CAN_OPEN|GUN_CHAMBER_ROTATES|GUN_ACCEPTS_HANDFUL|GUN_ACCEPTS_SPEEDLOADER|GUN_MANUAL_CYCLE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6

	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_5
	damage_mult = BULLET_DAMAGE_MULT_BASE * 2
	recoil = RECOIL_OFF
	recoil_unwielded = RECOIL_OFF
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/small/initialize_gun_lists()

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)

	..()

/obj/item/weapon/gun/revolver/small/unique_action(mob/user)
	if(flags_gun_receiver & GUN_CHAMBER_IS_OPEN)
		make_casing(projectile_casing)
		sort_cylinder_ammo(user)
		to_chat(user, SPAN_NOTICE("You clear the cylinder of [src]."))
	else
		if(revolver_trick(user))
			to_chat(user, SPAN_NOTICE("Your badass trick inspires you. Your next few shots will be focused!"))
			accuracy_mult = BASE_ACCURACY_MULT * 2
			accuracy_mult_unwielded = BASE_ACCURACY_MULT * 2
			addtimer(CALLBACK(src, PROC_REF(recalculate_attachment_bonuses)), 2 SECONDS)

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[          MATEBA AUTOREVOLVER AND VARIANTS          ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//BURST REVOLVER //Mateba is pretty well known. The cylinder folds up instead of to the side. <----- This is the 2006M.
//TODO: Revise. There appears to be some confusion here. The sprite looks more like the Sei Unica auto-revolver, but the function is more like
//the 2006M. The difference is that the 2006M is more like a traditional revolver but has an non-standard barrel position, and the cylinder is
//essentially flipped over. The Unica functions as a combination of a revolver and handgun. It has a moving "slide" just like most pistols
//and it has a cylinder chamber with a non-standard barrel position. It also has an exposed cylinder, meaning there is nothing above it holding
//it in place.

/obj/item/weapon/mateba_key
	name = "mateba barrel key"
	desc = "Used to swap the barrels of a mateba revolver."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "matebakey"
	flags_atom = FPRINT|CONDUCT
	force = 5
	w_class = SIZE_TINY
	throwforce = 5
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	attack_verb = list("stabbed")

/obj/item/weapon/gun/revolver/mateba
	name = "\improper Mateba autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It fires heavy .454 rounds."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "mateba"
	item_state = "mateba"
	fire_sound = 'sound/weapons/gun_mateba.ogg'
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba
	force = 15
	black_market_value = 100
	var/is_locked = TRUE
	var/can_change_barrel = TRUE

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_3
	burst_amount = BURST_AMOUNT_TIER_3
	burst_delay = FIRE_DELAY_TIER_8

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_10
	recoil = RECOIL_AMOUNT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/mateba/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/barrel/mateba,
			/obj/item/attachable/barrel/mateba/long,
			/obj/item/attachable/barrel/mateba/short,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 24, "under_x" = 19, "under_y" = 17, "stock_x" = 19, "stock_y" = 17, "barrel_x" = 23, "barrel_y" = 22)

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/barrel/mateba)

	..()

/obj/item/weapon/gun/revolver/mateba/can_attach_to_gun(mob/user, obj/item/attachable/attachment)
	. = ..()
	if(attachment.slot == ATTACHMENT_SLOT_MUZZLE && !attachments[ATTACHMENT_SLOT_BARREL])
		to_chat(user, SPAN_WARNING("You need to attach a barrel first!"))
		return FALSE

/obj/item/weapon/gun/revolver/mateba/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mateba_key) && can_change_barrel)
		if(attachments[ATTACHMENT_SLOT_BARREL])
			var/obj/item/attachable/R = attachments[ATTACHMENT_SLOT_BARREL]
			visible_message(SPAN_NOTICE("[user] begins stripping [R] from [src]."),
			SPAN_NOTICE("You begin stripping [R] from [src]."), null, 4)

			if(!do_after(usr, 35, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
				return

			if(R != attachments[R.slot])
				return

			visible_message(SPAN_NOTICE("[user] unlocks and removes [R] from [src]."),
			SPAN_NOTICE("You unlock and remove [R] from [src]."), null, 4)
			Detach(R, user)
			if(attachments[ATTACHMENT_SLOT_MUZZLE]) //Also detaches anything on the muzzle.
				Detach(attachments[ATTACHMENT_SLOT_MUZZLE], user)
			playsound(src, 'sound/handling/attachment_remove.ogg', 15, 1, 4)

	. = ..()

/obj/item/weapon/gun/revolver/mateba/pmc
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/ap

/obj/item/weapon/gun/revolver/mateba/general
	name = "\improper golden Mateba autorevolver custom"
	desc = "Boasting a gold-plated frame and grips made of a critically-endangered rosewood tree, this heavily-customized Mateba revolver's pretentious design rivals only the power of its wielder. Fit for a king. Or a general."
	icon_state = "amateba"
	item_state = "amateba"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/impact
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/barrel/mateba/dark,
		/obj/item/attachable/barrel/mateba/long/dark,
		/obj/item/attachable/barrel/mateba/short/dark,
	)

/obj/item/weapon/gun/revolver/mateba/general/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/barrel/mateba/long/dark)

	..()

/obj/item/weapon/gun/revolver/mateba/general/santa
	name = "\improper Festeba"
	desc = "The Mateba used by SANTA himself. Rumoured to be loaded with explosive ammunition."
	icon_state = "amateba"
	item_state = "amateba"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/explosive
	color = "#FF0000"
	fire_sound = null

/obj/item/weapon/gun/revolver/mateba/general/santa/initialize_gun_lists()
	if(fire_sound)
		fire_sound = list('sound/voice/alien_queen_xmas.ogg', 'sound/voice/alien_queen_xmas_2.ogg')

/obj/item/weapon/gun/revolver/mateba/general/santa/initialize_gun_lists()

	if(!starting_attachment_types)
		starting_attachment_types = list(/obj/item/attachable/barrel/mateba/long/dark, /obj/item/attachable/heavy_barrel)

	..()

/obj/item/weapon/gun/revolver/mateba/engraved
	name = "\improper engraved Mateba autorevolver"
	desc = "With a matte black chassis, ebony wooden grips, and gold-trimmed cylinder, this statement of a Mateba is as much a work of art as it is a bringer of death."
	icon_state = "aamateba"
	item_state = "aamateba"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/impact

/obj/item/weapon/gun/revolver/mateba/cmateba
	name = "\improper Mateba autorevolver custom"
	desc = "The .454 Mateba 6 Unica autorevolver is a semi-automatic handcannon that uses its own recoil to rotate the cylinders. Extremely rare, prohibitively costly, and unyieldingly powerful, it's found in the hands of a select few high-ranking USCM officials. Stylish, sophisticated, and above all, extremely deadly."
	icon_state = "cmateba"
	item_state = "cmateba"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/impact
	map_specific_decoration = TRUE

/obj/item/weapon/gun/revolver/mateba/special
	name = "\improper Mateba autorevolver special"
	desc = "An old, heavily modified version of the Mateba Autorevolver. It sports a smooth wooden grip, and a much larger barrel to it's unmodified counterpart. It's clear that this weapon has been cared for over a long period of time."
	icon_state = "cmateba_special"
	item_state = "cmateba_special"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/impact
	can_change_barrel = FALSE

	//=========// GUN STATS //==========//
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/mateba/special/initialize_gun_lists()

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/reddot,
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 23,"rail_x" = 9, "rail_y" = 24, "under_x" = 19, "under_y" = 17, "stock_x" = 19, "stock_y" = 17, "barrel_x" = 23, "barrel_y" = 22)

	..()

	if(!starting_attachment_types) //Barrel is included in the sprite.
		starting_attachment_types = list()

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[   CMB SPEARHEAD AUTOREVOLVER / MARSHALL REVOLVER   ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//MARSHALS REVOLVER //Spearhead exists in Alien cannon.

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB Spearhead autorevolver"
	desc = "An automatic revolver chambered in .357, often loaded with hollowpoint on spaceships to prevent hull damage. Commonly issued to Colonial Marshals."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "spearhead"
	item_state = "spearhead"
	fire_sound = null
	fire_rattle = 'sound/weapons/gun_cmb_rattle.ogg'
	force = 12
	current_mag = /obj/item/ammo_magazine/internal/revolver/cmb/hollowpoint

	//=========// GUN STATS //==========//
	fire_delay = FIRE_DELAY_TIER_6

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BULLET_DAMAGE_MULT_BASE + BULLET_DAMAGE_MULT_TIER_3
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	//=========// GUN STATS //==========//

/obj/item/weapon/gun/revolver/cmb/initialize_gun_lists()

	if(!fire_sound)
		fire_sound = list('sound/weapons/gun_cmb_1.ogg', 'sound/weapons/gun_cmb_2.ogg')

	if(!click_empty_sound)
		click_empty_sound = list('sound/weapons/handling/gun_cmb_click1.ogg', 'sound/weapons/handling/gun_cmb_click2.ogg')

	if(!attachable_allowed)
		attachable_allowed = list(
			/obj/item/attachable/suppressor, // Muzzle
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/compensator,
			/obj/item/attachable/reddot, // Rail
			/obj/item/attachable/reflex,
			/obj/item/attachable/flashlight,
			/obj/item/attachable/scope/mini,
			/obj/item/attachable/gyro, // Under
			/obj/item/attachable/lasersight,
		)

	if(!attachable_offset)
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	..()

/obj/item/weapon/gun/revolver/cmb/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	playsound('sound/weapons/gun_cmb_bass.ogg') // badass shooting bass
	return ..()

/obj/item/weapon/gun/revolver/cmb/normalpoint
	current_mag = /obj/item/ammo_magazine/internal/revolver/cmb
