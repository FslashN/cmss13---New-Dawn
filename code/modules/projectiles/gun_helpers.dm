//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	 EQUIPMENT AND INTERACTION  	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/clicked(mob/user, list/mods)
	if(mods["alt"])
		if(!CAN_PICKUP(user, src))
			return ..()
		alt_click_action()
		return TRUE
	return (..())

/obj/item/weapon/gun/mob_can_equip(mob/user)
	//Cannot equip wielded items or items burst firing.
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return 0
	unwield(user)
	return ..()

/obj/item/weapon/gun/attack_hand(mob/user)
	var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()

	if(in_hand == src && (flags_item & TWOHANDED))
		if(active_attachable)
			if(active_attachable.unload_attachment(user))
				return
		unload(user)//It has to be held if it's a two hander.
		return
	else
		..()

/obj/item/weapon/gun/proc/alt_click_action(mob/user)
	toggle_gun_safety()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/equipped(mob/living/user, slot)
	if(flags_item & NODROP) return

	unwield(user)
	pull_time = world.time + wield_delay
	if(user.dazed)
		pull_time += 3
	guaranteed_delay_time = world.time + WEAPON_GUARANTEED_DELAY

	var/delay_left = (last_fired + fire_delay + additional_fire_group_delay) - world.time
	if(fire_delay_group && delay_left > 0)
		LAZYSET(user.fire_delay_next_fire, src, world.time + delay_left)

	if(slot in list(WEAR_L_HAND, WEAR_R_HAND))
		set_gun_user(user)
		if(HAS_TRAIT_FROM_ONLY(src, TRAIT_GUN_LIGHT_DEACTIVATED, user))
			force_light(on = TRUE)
			REMOVE_TRAIT(src, TRAIT_GUN_LIGHT_DEACTIVATED, user)

		recalculate_user_attributes(user) //When they pick up a gun or switch it to a different hand, we check if they're able to fire it.

		if(flags_gun_features & GUN_AMMO_COUNTER) //Display ammo already checks for this, but this only runs when the weapon is equipped, not per shot.
			create_ammo_counter()
			vis_contents += ammo_counter
			GUN_DISPLAY_ROUNDS_REMAINING

	else if(flags_gun_features & GUN_AMMO_COUNTER)
		create_ammo_counter()
		vis_contents -= ammo_counter //We don't want to show it anywhere but the hand.

	else
		set_gun_user(null)
		force_light(on = FALSE)
		ADD_TRAIT(src, TRAIT_GUN_LIGHT_DEACTIVATED, user)

	return ..()

/obj/item/weapon/gun/dropped(mob/user)
	. = ..()

	var/delay_left = (last_fired + fire_delay + additional_fire_group_delay) - world.time
	if(fire_delay_group && delay_left > 0)
		LAZYSET(user.fire_delay_next_fire, src, world.time + delay_left)

	for(var/obj/item/attachable/stock/smg/collapsible/brace/current_stock in contents) //SMG armbrace folds to stop it getting stuck on people
		if(current_stock.stock_activated)
			current_stock.activate_attachment(src, user, turn_off = TRUE)

	remove_ammo_counter()

	unwield(user)
	set_gun_user(null)

/obj/item/weapon/gun/pickup(mob/user)
	..()

	unwield(user)

/obj/item/weapon/gun/on_enter_storage() //We do not want the ammo tracker showing in storage.
	..()
	remove_ammo_counter()

/obj/item/weapon/gun/wield(mob/living/user)
	if(!(flags_item & TWOHANDED) || flags_item & WIELDED)
		return

	if(world.time < pull_time) //Need to wait until it's pulled out to aim
		return

	var/obj/item/I = user.get_inactive_hand()
	if(I)
		if(!user.drop_inv_item_on_ground(I))
			return

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/obj/limb/hand = wielder.get_limb(check_hand)
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, SPAN_WARNING("Your other hand can't hold \the [src]!"))
			return

	flags_item ^= WIELDED
	name += " (Wielded)"
	item_state += "_w"
	slowdown = initial(slowdown) + aim_slowdown
	place_offhand(user, initial(name))
	wield_time = world.time + wield_delay
	if(user.dazed)
		wield_time += 5
	guaranteed_delay_time = world.time + WEAPON_GUARANTEED_DELAY
	//slower or faster wield delay depending on skill.
	if(!isnull(user_skill_level))
		wield_time += ( user_skill_level == SKILL_FIREARMS_CIVILIAN && !civilian_usable_override) ? 3 : -(2 * user_skill_level)

	return TRUE

/obj/item/weapon/gun/unwield(mob/user)
	. = ..()
	if(.)
		slowdown = initial(slowdown)

// Checks whether there is anything to put your harness
/obj/item/weapon/gun/proc/retrieval_check(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_J_STORE)
		var/obj/item/suit = user.wear_suit
		if(!istype(suit, /obj/item/clothing/suit/storage/marine))
			return FALSE
	return TRUE

/obj/item/weapon/gun/proc/retrieve_to_slot(mob/living/carbon/human/user, retrieval_slot)
	if (!loc || !user)
		return FALSE
	if (!isturf(loc))
		return FALSE
	if(!retrieval_check(user, retrieval_slot))
		return FALSE
	if(!user.equip_to_slot_if_possible(src, retrieval_slot, disable_warning = TRUE))
		return FALSE
	var/message
	switch(retrieval_slot)
		if(WEAR_BACK)
			message = "[src] snaps into place on your back."
		if(WEAR_IN_BACK)
			message = "[src] snaps back into [user.back]."
		if(WEAR_IN_SCABBARD)
			message = "[src] snaps into place on [user.back]."
		if(WEAR_WAIST)
			message = "[src] snaps into place on your waist."
		if(WEAR_J_STORE)
			message = "[src] snaps into place on [user.wear_suit]."
	to_chat(user, SPAN_NOTICE(message))
	return TRUE

/obj/item/weapon/gun/proc/handle_retrieval(mob/living/carbon/human/user, retrieval_slot)
	if (!ishuman(user))
		return
	if (!retrieval_check(user, retrieval_slot))
		return
	addtimer(CALLBACK(src, PROC_REF(retrieve_to_slot), user, retrieval_slot), 0.3 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/item/weapon/gun/attack_self(mob/user)
	..()

	//There are only two ways to interact here.
	if(flags_item & TWOHANDED)
		if(flags_item & WIELDED)
			unwield(user) // Trying to unwield it
		else
			wield(user) // Trying to wield it
	else
		unload(user) // We just unload it.

//magnetic sling

/obj/item/weapon/gun/proc/handle_sling(mob/living/carbon/human/user)
	if (!ishuman(user))
		return

	addtimer(CALLBACK(src, PROC_REF(sling_return), user), 3, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/weapon/gun/proc/sling_return(mob/living/carbon/human/user)
	if (!loc || !user)
		return
	if (!isturf(loc))
		return

	if(user.equip_to_slot_if_possible(src, WEAR_BACK))
		to_chat(user, SPAN_WARNING("[src]'s magnetic sling automatically yanks it into your back."))

//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/attack_item, mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	if(istype(attack_item, /obj/item/prop/helmetgarb/gunoil))
		var/oil_verb = pick("lubes", "oils", "cleans", "tends to", "gently strokes")
		if(do_after(user, 30, INTERRUPT_NO_NEEDHAND, BUSY_ICON_FRIENDLY, user, INTERRUPT_MOVED, BUSY_ICON_GENERIC))
			user.visible_message("[user] [oil_verb] [src]. It shines like new.", "You oil up and immaculately clean [src]. It shines like new.")
			malfunction_chance_mod = GUN_MALFUNCTION_CHANCE_ZERO //Resets this since you cleaned the gun.
			clean_blood()
		else
			return

	if(istype(attack_item,/obj/item/attachable))
		if(check_inactive_hand(user)) attach_to_gun(user,attack_item)

	//the active attachment is reloadable
	else if(active_attachable && active_attachable.flags_attach_features & ATTACH_RELOADABLE)
		if(check_inactive_hand(user))
			if(istype(attack_item,/obj/item/ammo_magazine))
				var/obj/item/ammo_magazine/attachment_magazine = attack_item
				if(istype(src, attachment_magazine.gun_type))
					to_chat(user, SPAN_NOTICE("You disable [active_attachable]."))
					playsound(user, active_attachable.activation_sound, 15, 1)
					active_attachable.activate_attachment(src, null, TRUE)
					reload(user,attachment_magazine)
					return
			active_attachable.reload_attachment(attack_item, user)

	else if(istype(attack_item,/obj/item/ammo_magazine))
		if(check_inactive_hand(user)) reload(user,attack_item)


//tactical reloads
/obj/item/weapon/gun/MouseDrop_T(atom/dropping, mob/living/carbon/human/user)
	if(istype(dropping, /obj/item/ammo_magazine))
		if(!user.Adjacent(dropping))
			return
		var/obj/item/ammo_magazine/magazine = dropping
		if(!istype(user) || user.is_mob_incapacitated(TRUE))
			return
		if(src != user.r_hand && src != user.l_hand)
			to_chat(user, SPAN_WARNING("[src] must be in your hand to do that."))
			return
		if(flags_gun_receiver & GUN_INTERNAL_MAG)
			to_chat(user, SPAN_WARNING("Can't do tactical reloads with [src]."))
			return
		//no tactical reload for the untrained.
		if(!user_skill_level || user_skill_level == SKILL_FIREARMS_CIVILIAN) //Civillian is 0, but that can change.
			to_chat(user, SPAN_WARNING("You don't know how to do tactical reloads."))
			return
		if(istype(src, magazine.gun_type) || (additional_type_magazines && (magazine.type in additional_type_magazines) ))
			if(current_mag)
				unload(user, FALSE, TRUE)
			to_chat(user, SPAN_NOTICE("You start a tactical reload."))
			var/old_mag_loc = magazine.loc
			var/tac_reload_time = max(15 - (5 * user_skill_level), 5)
			if(do_after(user,tac_reload_time, INTERRUPT_ALL, BUSY_ICON_FRIENDLY) && magazine.loc == old_mag_loc && !current_mag)
				if(isstorage(magazine.loc))
					var/obj/item/storage/master_storage = magazine.loc
					master_storage.remove_from_storage(magazine)
				reload(user, magazine)
	else
		..()

/obj/item/weapon/gun/proc/check_inactive_hand(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
		if( in_hand != src ) //It has to be held.
			to_chat(user, SPAN_WARNING("You have to hold [src] to do that!"))
			return
	return TRUE

/obj/item/weapon/gun/proc/check_both_hands(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_handL = user.l_hand
		var/obj/item/weapon/gun/in_handR = user.r_hand
		if( in_handL != src && in_handR != src ) //It has to be held.
			to_chat(user, SPAN_WARNING("You have to hold [src] to do that!"))
			return
	return TRUE

/mob/living/carbon/human/proc/can_unholster_from_storage_slot(obj/item/storage/slot)
	if(isnull(slot))
		return FALSE
	if(slot == shoes)//Snowflakey check for shoes and uniform
		if(shoes.stored_item && isweapon(shoes.stored_item))
			return shoes
		return FALSE

	if(slot == w_uniform)
		for(var/obj/item/storage/internal/accessory/holster/cycled_holster in w_uniform.accessories)
			if(cycled_holster.current_gun)
				return w_uniform
		for(var/obj/item/clothing/accessory/storage/holster/cycled_holster in w_uniform.accessories)
			var/obj/item/storage/internal/accessory/holster/holster = cycled_holster.hold
			if(holster.current_gun)
				return holster.current_gun

		for(var/obj/item/clothing/accessory/storage/cycled_accessory in w_uniform.accessories)
			var/obj/item/storage/internal/accessory/accessory_storage = cycled_accessory.hold
			if(accessory_storage.storage_flags & STORAGE_ALLOW_QUICKDRAW)
				return accessory_storage

		return FALSE

	if(istype(slot) && (slot.storage_flags & STORAGE_ALLOW_QUICKDRAW))
		for(var/obj/cycled_weapon in slot.return_inv())
			if(isweapon(cycled_weapon))
				return slot

	if(isweapon(slot)) //then check for weapons
		return slot

	return FALSE

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	 ATTACHMENTS AND OVERLAYS  	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------
//I really hate how this proc runs every time a gun changes stats.
//Ideally it should only do the functions needed to reflect the change, not do everything over and over.
//Practically speaking, if there is trait overlap, making changes will be tricky. Probably why it'st set up like this.

/obj/item/weapon/gun/proc/recalculate_attachment_bonuses()
	//reset weight and force mods
	force = initial(force)
	w_class = initial(w_class)

	//reset HUD and pixel offsets
	hud_offset = initial(hud_offset)
	pixel_x = initial(hud_offset)

	//reset traits from attachments
	for(var/slot in attachments)
		REMOVE_TRAITS_IN(src, TRAIT_SOURCE_ATTACHMENT(slot))

	//Get default gun config values
	reset_gun_stat_values()

	//Add attachment bonuses
	var/obj/item/attachable/R
	for(var/slot in attachments)
		R = attachments[slot]
		if(!R)
			continue
		modify_fire_delay(R.delay_mod)
		accuracy_mult += R.accuracy_mod
		accuracy_mult_unwielded += R.accuracy_unwielded_mod
		scatter += R.scatter_mod
		scatter_unwielded += R.scatter_unwielded_mod
		damage_mult += R.damage_mod
		velocity_add += R.velocity_mod
		damage_falloff_mult += R.damage_falloff_mod
		damage_buildup_mult += R.damage_buildup_mod
		effective_range_min += R.range_min_mod
		effective_range_max += R.range_max_mod
		recoil += R.recoil_mod
		burst_scatter_mult += R.burst_scatter_mod
		modify_burst_amount(R.burst_mod)
		recoil_unwielded += R.recoil_unwielded_mod
		aim_slowdown += R.aim_speed_mod
		wield_delay += R.wield_delay_mod
		movement_onehanded_acc_penalty_mult += R.movement_onehanded_acc_penalty_mod
		force += R.melee_mod
		w_class += R.size_mod

		for(var/trait in R.gun_traits)
			ADD_TRAIT(src, trait, TRAIT_SOURCE_ATTACHMENT(slot))

	//Refresh location in HUD.
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

	update_force_list() //This updates the gun to use proper force verbs.
	setup_firemodes()

	SEND_SIGNAL(src, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES)

 //Handle any special cases for when something is attached. This is per attachment. User can be passed as null.
/obj/item/attachable/proc/handle_attaching(mob/user, obj/item/weapon/gun/current_gun)
	return TRUE

/obj/item/weapon/gun/proc/Attach(obj/item/attachable/attachment, mob/user, recalculate_bonuses = TRUE)
	attachment.pixel_x = 0 //We need these to be centered correctly.
	attachment.pixel_y = 0

	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		M.drop_held_item(attachment)

	attachment.forceMove(src)
	attachment.handle_attaching(user, src)
	attachments[attachment.slot] = attachment

	if(recalculate_bonuses) //We may want to only recalculate bonuses once we're done setting up all attachments instead of doing it every individual Attach.
		recalculate_attachment_bonuses()

	var/mob/living/living
	if(isliving(user))
		living = user

	if(attachment.attachment_action_type) //Add actions.
		var/given_action = FALSE
		if(living && (src == living.l_hand || src == living.r_hand))
			give_action(living, attachment.attachment_action_type, attachment, src)
			given_action = TRUE
		if(!given_action)
			new attachment.attachment_action_type(attachment, src)

	// Sharp attachments (bayonet) make weapons sharp as well.
	sharp ^= attachment.sharp //This just flips it

	add_attachment_overlay(attachment) //Handles vis_contents.

//Handle any special cases for when something is detached. This is per attachment. User can be passed as null.
/obj/item/attachable/proc/handle_detaching(mob/user, obj/item/weapon/gun/current_gun)
	return TRUE

//This handles the gun doing something special when detaching an attachment.
/obj/item/weapon/gun/proc/on_detach(obj/item/attachable/attachment)
	return TRUE

/obj/item/weapon/gun/proc/Detach(obj/item/attachable/attachment, mob/user)
	on_detach(user)

	if(attachment.flags_attach_features & ATTACH_ACTIVATION) //Turn it off if it's on.
		attachment.activate_attachment(src, null, TRUE)

	for(var/trait in attachment.gun_traits) //Handle removing traits first. recaculcuating will add traits back if needed.
		REMOVE_TRAIT(src, trait, TRAIT_SOURCE_ATTACHMENT(attachment.slot))

	attachment.handle_detaching(user, src)
	attachments -= attachment.slot
	recalculate_attachment_bonuses()

	for(var/X in actions) //Remove actions.
		var/datum/action/DA = X
		if(DA.target == attachment)
			qdel(X)
			break

	attachment.forceMove(get_turf(src))

	sharp ^= attachment.sharp

	attachment.scatter_item() //Scatter it properly so it doesn't stack on top of itself. Eugh.
	clean_attachment_overlay(attachment)  //Handles vis_contents.

/obj/item/weapon/gun/proc/handle_starting_attachment()
	if(starting_attachment_types?.len)
		var/obj/item/attachable/attachment
		var/slot
		for(var/i = 1 to starting_attachment_types.len)
			attachment = starting_attachment_types[i]
			slot = initial(attachment.slot)

			if(!attachments[slot]) //If there are no random attachments already there.
				attachment = new attachment(src)
				Attach(attachment, null, i == starting_attachment_types.len ? TRUE : FALSE) //Only recalc when on the last attachment, so everything is attached first.

/obj/item/weapon/gun/proc/handle_random_attachments()
	if(random_attachments_possible && prob(random_attachment_chance)) //random_attachments_possible may not exist. Random chance is set to 50 by default, so we check for for both.
		var/selected_path
		var/obj/item/attachable/attachment
		for(var/i in random_attachments_possible)
			if(prob(random_attachment_spawn_chance[i])) //We need to know if the attachment will spawn.
				selected_path = pick(random_attachments_possible[i]) //Get the path to the slot. This grabs the list associated with the slot.
				attachment = new selected_path(src) //Should always be at least one item.
				Attach(attachment)
	//We clear out the information as it doesn't matter now.
	random_attachments_possible	= null
	random_attachment_spawn_chance = null

/obj/item/weapon/gun/proc/has_attachment(obj/item/attachable/attachment)
	if(!istype(attachment)) return FALSE
	if(attachments[attachment.slot] == attachment) return TRUE
	return FALSE

/obj/item/attachable/proc/can_be_attached_to_gun(mob/user, obj/item/weapon/gun/G)
	if( !G.attachable_allowed || !(type in G.attachable_allowed) )
		to_chat(user, SPAN_WARNING("[src] doesn't fit on [G]!"))
		return FALSE
	return TRUE

/obj/item/weapon/gun/proc/can_attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(!attachment.can_be_attached_to_gun(user, src))
		return FALSE

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	if(attachments[attachment.slot])
		var/obj/item/attachable/current_attachment = attachments[attachment.slot]
		if(current_attachment && current_attachment.flags_attach_features & ATTACH_INTEGRATED)
			to_chat(user, SPAN_WARNING("The attachment on [src]'s [attachment.slot] cannot be removed!"))
			return FALSE

	//to prevent headaches with lighting stuff
	if(attachment.light_mod)
		for(var/slot in attachments)
			var/obj/item/attachable/current_attachment = attachments[slot]
			if(!current_attachment)
				continue
			if(current_attachment.light_mod)
				to_chat(user, SPAN_WARNING("You already have a light source attachment on [src]!"))
				return FALSE
	return TRUE

/obj/item/weapon/gun/proc/attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(!can_attach_to_gun(user, attachment))
		return FALSE

	user.visible_message(SPAN_NOTICE("[user] begins attaching [attachment] to [src]."),
	SPAN_NOTICE("You begin attaching [attachment] to [src]."), null, 4)
	if(do_after(user, 1.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, numticks = 2))
		if(attachment && attachment.loc)
			user.visible_message(SPAN_NOTICE("[user] attaches [attachment] to [src]."),
			SPAN_NOTICE("You attach [attachment] to [src]."), null, 4)
			user.temp_drop_inv_item(attachment)
			if(attachments[attachment.slot]) //In case they are swapping it.
				Detach(attachments[attachment.slot], user)
			Attach(attachment, user)
			playsound(user, 'sound/handling/attachment_add.ogg', 15, 1, 4)
			return TRUE

//These two procs implicitly know that there is something to change.
/obj/item/weapon/gun/proc/clean_attachment_overlay(obj/item/attachable/attachment)
	attachment.pixel_x = initial(pixel_x) //We want to reset these.
	attachment.pixel_y = initial(pixel_y)
	if(attachment.attach_icon) //If it has an attach_icon, it may have reset its appearance. Like with foldable stocks and the like. We switch it all back.
		var/updated_attach_icon = attachment.icon_state // This is the current attached appearance.
		attachment.icon_state = attachment.attach_icon //Attach icon contains that UI appearance right now.
		attachment.attach_icon = updated_attach_icon //Then we reset it to the attached appearance.
	vis_contents -= attachment

/obj/item/weapon/gun/proc/add_attachment_overlay(obj/item/attachable/attachment)
	var/slot = attachment.slot
	attachment.pixel_x = attachable_offset["[slot]_x"] - attachment.pixel_shift_x + x_offset_by_attachment_type(attachment.type) //We want to make sure to set these up first.
	attachment.pixel_y = attachable_offset["[slot]_y"] - attachment.pixel_shift_y + y_offset_by_attachment_type(attachment.type)
	if(attachment.attach_icon) //We swap this up in case the attachment likes to toggle states.
		var/UI_icon = attachment.icon_state
		attachment.icon_state = attachment.attach_icon
		attachment.attach_icon = UI_icon
	vis_contents += attachment //And add it to overlays. If it doesn't have an icon, it will be transparent.

/obj/item/weapon/gun/proc/x_offset_by_attachment_type(attachment_type)
	return 0

/obj/item/weapon/gun/proc/y_offset_by_attachment_type(attachment_type)
	return 0

//_______________________________________________________________________________________________________
//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>		   MISC PROCS 		<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/proc/unique_action(mob/user) //moved this up a path to make macroing for other weapons easier -spookydonut
	return

/obj/item/weapon/gun/proc/update_force_list()
	switch(force)
		if(36 to INFINITY) attack_verb = list("slashed", "stabbed", "speared", "torn", "punctured", "pierced", "gored") //Greater than 35
		if(16 to 35) attack_verb = list("smashed", "struck", "whacked", "beaten", "cracked")
		if(-50 to 15) attack_verb = list("struck", "hit", "bashed") //Unlikely to ever be -50, but just to be safe.
		else attack_verb = list("tapped")

/obj/item/weapon/gun/proc/get_active_firearm(mob/user, restrictive = TRUE)
	if(!ishuman(usr))
		return
	if(user.is_mob_incapacitated() || !isturf(usr.loc))
		to_chat(user, SPAN_WARNING("Not right now."))
		return

	var/obj/item/weapon/gun/held_item = user.get_held_item()

	if(!istype(held_item)) // if active hand is not a gun
		if(restrictive) // if restrictive we return right here
			to_chat(user, SPAN_WARNING("You need a gun in your active hand to do that!"))
			return
		else // else check inactive hand
			held_item = user.get_inactive_hand()
			if(!istype(held_item)) // if inactive hand is ALSO not a gun we return
				to_chat(user, SPAN_WARNING("You need a gun in one of your hands to do that!"))
				return

	if(held_item?.flags_gun_toggles & GUN_BURST_FIRING)
		return

	return held_item

/obj/item/weapon/gun/item_action_slot_check(mob/user, slot)
	if(slot != WEAR_L_HAND && slot != WEAR_R_HAND)
		return FALSE
	return TRUE

/*
This proc checks various permissions and then sets skill level for the user. Will return the first error message it finds when the gun fires, if unable to fire the gun.
This was originally all done during the fire cycle, checking several times for some things, which was not optimal.
That means if something changes that allows the user to fire the gun, the user has to pick up the gun/switch the gun to a different hand to recalc their permissions.
May need testing on spawned-in people with equipment, so that their minds are set first before the equipment gets placed on them, so this triggers correctly.
Could potentially add a manual recalc to all guns when a skill or trait or whatever is changed by an admin, but that seems snowflakey.
Perhaps add a callback?
*/
/obj/item/weapon/gun/proc/recalculate_user_attributes(mob/living/user)
	flags_gun_toggles &= ~GUN_UNABLE_TO_FIRE //Reset it.

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.allow_gun_usage)
			unable_to_fire_message = issynth(user) ? "Your programming does not allow you to use firearms." : "You are unable to use firearms."
			return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	else if(!user.IsAdvancedToolUser())
		unable_to_fire_message = "You don't have the dexterity to do this!"
		return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	if(flags_gun_features & GUN_WY_RESTRICTED && !CONFIG_GET(flag/remove_gun_restrictions)) //Checks only if config doesn't disable restrictions.
		var/WY_authorized = FALSE
		if(user.mind)
			switch(user.job)
				if(
					"PMC",
					"WY Agent",
					"Corporate Liaison",
					"Event",
					"UPP Armsmaster", //this rank is for the Fun - Ivan preset, it allows him to use the PMC guns randomly generated from his backpack
				) WY_authorized = TRUE

			switch(user.faction)
				if(
					FACTION_WY_DEATHSQUAD,
					FACTION_PMC,
					FACTION_MERCENARY,
					FACTION_FREELANCER,
				) WY_authorized = TRUE

			for(var/faction in user.faction_group)
				if(faction in FACTION_LIST_WY)
					WY_authorized = TRUE
					break

			if(user.faction in FACTION_LIST_WY)
				WY_authorized = TRUE

		if(!WY_authorized)
			unable_to_fire_message = "[src] flashes a warning sign indicating unauthorized use!"
			return flags_gun_toggles |= GUN_UNABLE_TO_FIRE

	//Looks like we're authorized, let's set skill levels and such so we don't need to check them later.
	user_skill_level = (user.mind && user.skills) ? user.skills.get_skill_level(SKILL_FIREARMS) : null
	//And the civ override. Return whatever non-null value it has set. If it's null, check in the list and set it to true if it's in there.
	civilian_usable_override = !isnull(civilian_usable_override) ? civilian_usable_override : ( (gun_category in UNTRAINED_USABLE_CATEGORIES) ? TRUE : initial(civilian_usable_override) )

///Helper proc that processes a clicked target, if the target is not black tiles, it will not change it. If they are it will return the turf of the black tiles. It will return null if the object is a screen object other than black tiles.
/proc/get_turf_on_clickcatcher(atom/target, mob/user, params)
	var/list/modifiers = params2list(params)
	if(!istype(target, /atom/movable/screen))
		return target
	if(!istype(target, /atom/movable/screen/click_catcher))
		return null
	return params2turf(modifiers["screen-loc"], get_turf(user), user.client)

/// This function actually turns the lights on the gun off
/obj/item/weapon/gun/proc/turn_off_light(mob/bearer)
	if (!(flags_gun_toggles & GUN_FLASHLIGHT_ON))
		return FALSE
	var/obj/item/attachable/attachment
	for (var/slot in attachments)
		attachment = attachments[slot]
		if (!attachment || !attachment.light_mod)
			continue
		attachment.activate_attachment(src, bearer)
		return TRUE
	return FALSE

/// If this gun has a relevant flashlight attachable attached, (de)activate it
/obj/item/weapon/gun/proc/force_light(on)
	var/obj/item/attachable/flashlight/torch
	for(var/slot in attachments)
		torch = attachments[slot]
		if(istype(torch))
			break
	if(!torch)
		return FALSE
	torch.turn_light(toggle_on = on, forced = TRUE)
	return TRUE

/obj/item/weapon/gun/attack_alien(mob/living/carbon/xenomorph/xeno)
	..()
	var/slashed_light = FALSE
	for(var/slot in attachments)
		if(istype(attachments[slot], /obj/item/attachable/flashlight))
			var/obj/item/attachable/flashlight/flashlight = attachments[slot]
			if(flashlight.activate_attachment(src, xeno, TRUE))
				slashed_light = TRUE
	if(slashed_light)
		playsound(loc, "alien_claw_metal", 25, 1)
		xeno.animation_attack_on(src)
		xeno.visible_message(SPAN_XENOWARNING("\The [xeno] slashes the lights on \the [src]!"), SPAN_XENONOTICE("You slash the lights on \the [src]!"))
	return XENO_ATTACK_ACTION

//_______________________________________________________________________________________________________
//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>		   GUN VERBS PROCS			<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

//For the holster hotkey
/mob/living/silicon/robot/verb/holster_verb(unholster_number_offset = 1 as num)
	set name = "holster"
	set hidden = TRUE
	uneq_active()

/mob/living/carbon/human/verb/holster_verb(unholster_number_offset = 1 as num)
	set name = "holster"
	set hidden = TRUE
	if(usr.is_mob_incapacitated(TRUE) || usr.is_mob_restrained())
		to_chat(src, SPAN_WARNING("You can't draw a weapon in your current state."))
		return

	var/obj/item/active_hand = get_active_hand()
	if(active_hand)
		if(w_uniform)
			for(var/obj/accessory in w_uniform.accessories)
				var/obj/item/storage/internal/accessory/holster/holster = accessory
				if(istype(holster) && !holster.current_gun && holster.can_be_inserted(active_hand))
					holster._item_insertion(active_hand, src)
					return

				var/obj/item/clothing/accessory/storage/holster/holster_ammo = accessory
				if(istype(holster_ammo))
					var/obj/item/storage/internal/accessory/holster/storage = holster_ammo.hold
					if(storage.can_be_inserted(active_hand, src, stop_messages = TRUE))
						storage.handle_item_insertion(active_hand, user = src)
						return

		quick_equip()
	else //empty hand, start checking slots and holsters

		//default order: suit, belt, back, pockets, uniform, shoes
		var/list/slot_order = list("s_store", "belt", "back", "l_store", "r_store", "w_uniform", "shoes")

		var/obj/item/slot_selected

		for(var/slot in slot_order)
			var/slot_type = can_unholster_from_storage_slot(vars[slot])
			if(slot_type)
				slot_selected = slot_type
				if(unholster_number_offset == 1)
					break
				else
					unholster_number_offset--

		if(slot_selected)
			slot_selected.attack_hand(src)


/obj/item/weapon/gun/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."
	set src = usr.contents //We want to make sure one is picked at random, hence it's not in a list.

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr, FALSE) // don't see why it should be restrictive

	if(!active_firearm)
		return

	src = active_firearm

	if(usr.action_busy)
		return

	if(zoom)
		to_chat(usr, SPAN_WARNING("You cannot conceivably do that while looking down \the [src]'s scope!"))
		return

	var/list/choices = list()
	var/list/choice_to_attachment = list()
	for(var/slot in attachments)
		var/obj/item/attachable/attached_attachment = attachments[slot]
		if(attached_attachment && !(attached_attachment.flags_attach_features & ATTACH_INTEGRATED))
			var/capitalized_name = capitalize_first_letters(attached_attachment.name)
			choices[capitalized_name] = image(icon = attached_attachment.icon, icon_state = attached_attachment.icon_state)
			choice_to_attachment[capitalized_name] = attached_attachment

	if(!length(choices))
		to_chat(usr, SPAN_WARNING("[src] has no removable attachments."))
		return

	var/obj/item/attachable/attachment
	if(length(choices) == 1)
		attachment = choice_to_attachment[choices[1]]
	else
		var/use_radials = usr.client.prefs?.no_radials_preference ? FALSE : TRUE
		var/choice = use_radials ? show_radial_menu(usr, usr, choices, require_near = TRUE) : tgui_input_list(usr, "Which attachment to remove?", "Remove Attachment", choices)
		attachment = choice_to_attachment[choice]

	if(!attachment || get_active_firearm(usr) != src || usr.action_busy || zoom || (!(attachment == attachments[attachment.slot])) || attachment.flags_attach_features & ATTACH_INTEGRATED)
		return

	usr.visible_message(SPAN_NOTICE("[usr] begins stripping [attachment] from [src]."),
	SPAN_NOTICE("You begin stripping [attachment] from [src]."), null, 4)

	if(!do_after(usr, 1.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
		return

	if(attachment != attachments[attachment.slot])
		return

	if(attachment.flags_attach_features & ATTACH_INTEGRATED)
		return

	if(zoom)
		return

	usr.visible_message(SPAN_NOTICE("[usr] strips [attachment] from [src]."),
	SPAN_NOTICE("You strip [attachment] from [src]."), null, 4)
	Detach(attachment, usr)

	playsound(src, 'sound/handling/attachment_remove.ogg', 15, 1, 4)

/obj/item/weapon/gun/proc/do_toggle_firemode(datum/source, datum/keybinding, new_firemode)
	SIGNAL_HANDLER
	if(flags_gun_toggles & GUN_BURST_FIRING)//can't toggle mid burst
		return

	if(!length(gun_firemode_list))
		CRASH("[src] called do_toggle_firemode() with an empty gun_firemode_list")

	if(length(gun_firemode_list) == 1)
		to_chat(source, SPAN_NOTICE("[icon2html(src, source)] This gun only has one firemode."))
		return

	if(new_firemode)
		if(!(new_firemode in gun_firemode_list))
			CRASH("[src] called do_toggle_firemode() with [new_firemode] new_firemode, not on gun_firemode_list")
		gun_firemode = new_firemode
	else
		var/mode_index = gun_firemode_list.Find(gun_firemode)
		if(++mode_index <= length(gun_firemode_list))
			gun_firemode = gun_firemode_list[mode_index]
		else
			gun_firemode = gun_firemode_list[1]

	playsound(source, 'sound/weapons/handling/gun_burst_toggle.ogg', 15, 1)

	if(ishuman(source))
		to_chat(source, SPAN_NOTICE("[icon2html(src, source)] You switch to <b>[gun_firemode]</b>."))
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, gun_firemode)

/obj/item/weapon/gun/proc/add_firemode(added_firemode, mob/user)
	gun_firemode_list |= added_firemode

	if(!length(gun_firemode_list))
		CRASH("add_firemode called with a resulting gun_firemode_list length of [length(gun_firemode_list)].")

/obj/item/weapon/gun/proc/remove_firemode(removed_firemode, mob/user)
	if(!(removed_firemode in gun_firemode_list))
		return

	if(!length(gun_firemode_list) || (length(gun_firemode_list) == 1))
		CRASH("remove_firemode called with gun_firemode_list length [length(gun_firemode_list)].")

	gun_firemode_list -= removed_firemode

	if(gun_firemode == removed_firemode)
		gun_firemode = gun_firemode_list[1]
		do_toggle_firemode(user, gun_firemode)

/obj/item/weapon/gun/proc/setup_firemodes()
	var/old_firemode = gun_firemode
	gun_firemode_list.len = 0

	if(start_automatic)
		gun_firemode_list |= GUN_FIREMODE_AUTOMATIC

	if(start_semiauto)
		gun_firemode_list |= GUN_FIREMODE_SEMIAUTO

	if(burst_amount > BURST_AMOUNT_TIER_1)
		gun_firemode_list |= GUN_FIREMODE_BURSTFIRE

	if(!length(gun_firemode_list))
		CRASH("[src] called setup_firemodes() with an empty gun_firemode_list")

	else if(old_firemode in gun_firemode_list)
		gun_firemode = old_firemode

	else
		gun_firemode = gun_firemode_list[1]

/obj/item/weapon/gun/verb/use_toggle_burst()
	set category = "Weapons"
	set name = "Toggle Firemode"
	set desc = "Cycles through your gun's firemodes. Automatic modes greatly reduce accuracy."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr)
	if(!active_firearm)
		return
	src = active_firearm

	do_toggle_firemode(usr)

/obj/item/weapon/gun/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Weapon"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."
	set src = usr.contents

	var/mob/user = usr
	var/obj/item/weapon/gun/active_firearm = get_active_firearm(user)
	if(!active_firearm)
		return
	src = active_firearm
	if(active_firearm.active_attachable)
		// unload the attachment
		var/drop_to_ground = TRUE
		if(user.client?.prefs && (user.client?.prefs?.toggle_prefs & TOGGLE_EJECT_MAGAZINE_TO_HAND))
			drop_to_ground = FALSE
			unwield(user)
		if(active_firearm.active_attachable.unload_attachment(usr, FALSE, drop_to_ground))
			return

	//unloading a regular gun
	var/drop_to_ground = TRUE
	if(user.client?.prefs && (user.client?.prefs?.toggle_prefs & TOGGLE_EJECT_MAGAZINE_TO_HAND))
		drop_to_ground = FALSE
		unwield(user)
		if(!(active_firearm.flags_gun_receiver & GUN_INTERNAL_MAG))
			user.swap_hand()

	unload(user, FALSE, drop_to_ground) //We want to drop the mag on the ground.

/obj/item/weapon/gun/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver. If you have an active attachment, this will activate on the attachment instead."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr)
	if(!active_firearm)
		return
	if(active_firearm.active_attachable)
		src = active_firearm.active_attachable
	else
		src = active_firearm

	unique_action(usr)


/obj/item/weapon/gun/verb/toggle_gun_safety()
	set category = "Weapons"
	set name = "Toggle Gun Safety"
	set desc = "Toggle the safety of the held gun."
	set src = usr.contents //We want to make sure one is picked at random, hence it's not in a list.

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr,FALSE) // safeties shouldn't be restrictive

	if(!active_firearm)
		return

	src = active_firearm

	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	if(flags_gun_features & GUN_NO_SAFETY_SWITCH)
		to_chat(usr, SPAN_WARNING("[src] does not have a safety mechanism!"))
		return

	if(!ishuman(usr))
		return

	if(usr.is_mob_incapacitated() || !usr.loc || !isturf(usr.loc))
		to_chat(usr, "Not right now.")
		return

	flags_gun_toggles ^= GUN_TRIGGER_SAFETY_ON
	gun_safety_handle(usr)


/obj/item/weapon/gun/proc/gun_safety_handle(mob/user)
	to_chat(user, SPAN_NOTICE("You toggle the safety [SPAN_BOLD(flags_gun_toggles & GUN_TRIGGER_SAFETY_ON ? "on" : "off")]."))
	playsound(user, 'sound/weapons/handling/safety_toggle.ogg', 25, 1)

/obj/item/weapon/gun/verb/activate_attachment_verb()
	set category = "Weapons"
	set name = "Use Attachment"
	set desc = "Activates one of the attached attachments on the gun."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr, FALSE)
	if(!active_firearm)
		return
	src = active_firearm

	var/obj/item/attachable/chosen_attachment

	var/usable_attachments[] = list() //Basic list of attachments to compare later.
	for(var/slot in attachments)
		var/obj/item/attachable/attachment = attachments[slot]
		if(attachment && (attachment.flags_attach_features & ATTACH_ACTIVATION) )
			usable_attachments += attachment

	if(!usable_attachments.len) //No usable attachments.
		to_chat(usr, SPAN_WARNING("[src] does not have any usable attachments!"))
		return

	if(usable_attachments.len == 1) //Activates the only attachment if there is only one.
		chosen_attachment = usable_attachments[1]
	else
		chosen_attachment = tgui_input_list(usr, "Which attachment to activate?", "Activate attachment", usable_attachments)
		if(!chosen_attachment || chosen_attachment.loc != src)
			return
	if(chosen_attachment)
		chosen_attachment.activate_attachment(src, usr)

/obj/item/weapon/gun/verb/activate_rail_attachment_verb()
	set category = "Weapons"
	set name = "Use Rail Attachment"
	set desc = "Use the attachment that is mounted on your rail."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr, FALSE)
	if(!active_firearm)
		return
	src = active_firearm

	var/obj/item/attachable/attachment = attachments[ATTACHMENT_SLOT_RAIL]
	if(attachment)
		attachment.activate_attachment(src, usr)
	else
		to_chat(usr, SPAN_WARNING("[src] does not have any usable rail attachments!"))
		return

/obj/item/weapon/gun/verb/toggle_auto_eject_verb()
	set category = "Weapons"
	set name = "Toggle Auto Eject"
	set desc = "Toggles the auto-ejector between ejecting on the ground (default), ejecting to hand, and off."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr)
	if(!active_firearm)
		return

	src = active_firearm

	if( !(flags_gun_features & GUN_AUTO_EJECTOR) )
		to_chat(usr, SPAN_WARNING("[src] has no automatic ejection system!"))
		return
	else //We can't switch here, so we have to check them in order.
		var/m = "You toggle the auto ejector"

		if(flags_gun_toggles & GUN_AUTO_EJECTING_OFF) //If it was off, we return to default.
			flags_gun_toggles &= ~GUN_AUTO_EJECTING_OFF
			m += " to <b>MODE 1</b>, ejecting on to the ground (default)."
		else if(flags_gun_toggles & GUN_AUTO_EJECTING_TO_HAND) //If it was returning to hand, we turn it off.
			flags_gun_toggles &= ~GUN_AUTO_EJECTING_TO_HAND
			flags_gun_toggles |= GUN_AUTO_EJECTING_OFF
			m += " to <b>OFF</b>."
		else //If neither is true, we eject to hand, as we were in the default state.
			flags_gun_toggles |= GUN_AUTO_EJECTING_TO_HAND
			m += " to <b>MODE 2</b>, ejecting to your inactive hand."

		to_chat(usr, SPAN_INFO(m))

/obj/item/weapon/gun/verb/toggle_underbarrel_attachment_verb()
	set category = "Weapons"
	set name = "Toggle Underbarrel Attachment"
	set desc = "Use the attachment that is mounted on your underbarrel."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr,FALSE)
	if(!active_firearm)
		return
	src = active_firearm

	var/obj/item/attachable/attachment = attachments[ATTACHMENT_SLOT_UNDER]
	if(attachment)
		attachment.activate_attachment(src, usr)
	else
		to_chat(usr, SPAN_WARNING("[src] does not have any usable underbarrel attachments!"))
		return

/obj/item/weapon/gun/verb/toggle_stock_attachment_verb()
	set category = "Weapons"
	set name = "Toggle Stock Attachment"
	set desc = "Use the stock attachment that is mounted on your gun."
	set src = usr.contents

	var/obj/item/weapon/gun/active_firearm = get_active_firearm(usr, FALSE) // incase someone
	if(!active_firearm)
		return
	src = active_firearm

	var/obj/item/attachable/attachment = attachments[ATTACHMENT_SLOT_STOCK]
	if(attachment)
		attachment.activate_attachment(src, usr)
	else
		to_chat(usr, SPAN_WARNING("[src] does not have any usable stock attachments!"))
		return
