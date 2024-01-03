/*
found in __game.dm, actually for real this time. Funny enough, the flags weren't being utilized at all. I converted the variables into flags and added some functionality. /N
#define UI_ACTIONS_HIDDEN (1<<0) //Primary to show and hide xeno buttons.
#define UI_ACTIONS_UNIQUE (1<<1) //Unique actions are one per, so if another is added, it's ignored. If it was previously hidden, it gets unhidden.
#define UI_ACTIONS_ITEM_CUSTOM (1<<2) //If the action is an item action, this will prevent the item's icon from appearing on the button as well as retaining the name you set rather than "Use [something]"
#define UI_ACTIONS_ITEM_GROUP (1<<3) //If there is more than one instance of the item, the others will not be shown. For behavior of groups rather than individual items. ie revolver tricks.
*/

/datum/action
	var/name = "Generic Action"
	var/icon_file = 'icons/mob/hud/actions.dmi'
	var/action_icon_state
	var/button_icon_state
	var/obj/target = null
	var/atom/movable/screen/action_button/button = null
	var/mob/owner
	var/cooldown = 0 // By default an action has no cooldown
	var/cost = 0 // By default an action has no cost -> will be utilized by skill actions/xeno actions
	var/flags_ui_actions = UI_ACTIONS_UNIQUE
	/// Whether the action is hidden from its owner
	/// Useful for when you want to preserve action state while preventing
	/// a mob from using said action
	/// A signal on the mob that will cause the action to activate
	var/listen_signal

/datum/action/New(Target, override_icon_state)
	target = Target
	button = new
	button.source_action = src
	button.name = name
	if(button_icon_state) button.icon_state = button_icon_state
	if(!(flags_ui_actions & UI_ACTIONS_ITEM_CUSTOM)) //We do not want overlays if we're doing our own thing. This will be added on top of the button for items otherwise.
		if(target && isatom(target))
			var/image/IMG = image(target.icon, button, target.icon_state)
			IMG.pixel_x = 0
			IMG.pixel_y = 0
			button.overlays += IMG
		button.overlays += image(icon_file, button, override_icon_state || action_icon_state)

/datum/action/Destroy()
	if(owner)
		remove_from(owner)
	QDEL_NULL(button)
	target = null
	return ..()

/datum/action/proc/update_button_icon()
	return

/datum/action/proc/action_activate()
	return

/// handler for when a keybind signal is received by the action, calls the action_activate proc asynchronous
/datum/action/proc/keybind_activation()
	SIGNAL_HANDLER
	if(can_use_action())
		INVOKE_ASYNC(src, PROC_REF(action_activate))

/datum/action/proc/can_use_action()
	if(flags_ui_actions & UI_ACTIONS_HIDDEN)
		return FALSE

	if(owner)
		return TRUE

/datum/action/proc/set_name(new_name)
	name = new_name
	button.name = new_name

/**
 * Gives an action to a mob and returns it
 *
 * If mob already has the action, unhide it if it's hidden
 *
 * Can pass additional initialization args
 */
/proc/give_action(mob/L, action_path, ...)
	var/datum/action/A
	for(var/a in L.actions)
		A = a
		if(A.flags_ui_actions & UI_ACTIONS_UNIQUE && A.type == action_path)
			if(A.flags_ui_actions & UI_ACTIONS_HIDDEN)
				A.flags_ui_actions &= ~UI_ACTIONS_HIDDEN
				L.update_action_buttons()
			return A

	var/datum/action/action
	/// Cannot use arglist for both cases because of
	/// unique BYOND handling of args in New
	if(length(args) > 2)
		action = new action_path(arglist(args.Copy(3)))
	else
		action = new action_path()
	action.give_to(L)
	return action

/datum/action/proc/give_to(mob/L)
	SHOULD_CALL_PARENT(TRUE)
	if(owner)
		if(owner == L)
			return
		remove_from(owner)
	SEND_SIGNAL(src, COMSIG_ACTION_GIVEN, L)
	L.handle_add_action(src)
	if(listen_signal)
		RegisterSignal(L, listen_signal, PROC_REF(keybind_activation))
	owner = L

/mob/proc/handle_add_action(datum/action/action)
	LAZYADD(actions, action)
	if(client)
		client.add_to_screen(action.button)
	update_action_buttons()

/proc/remove_action(mob/L, action_path)
	var/datum/action/A
	for(var/a in L.actions)
		A = a
		if(A.type == action_path)
			A.remove_from(L)
			return A

/datum/action/proc/remove_from(mob/L)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, L)
	L.handle_remove_action(src)
	owner = null

/mob/proc/handle_remove_action(datum/action/action)
	actions?.Remove(action)
	if(client)
		client.remove_from_screen(action.button)
	update_action_buttons()

/mob/living/carbon/human/handle_remove_action(datum/action/action)
	if(selected_ability == action)
		action.action_activate()
	return ..()

/proc/hide_action(mob/L, action_path)
	for(var/a in L.actions)
		var/datum/action/A = a
		if(A.type == action_path)
			A.flags_ui_actions |= UI_ACTIONS_HIDDEN
			L.update_action_buttons()
			return A

/datum/action/proc/hide_from(mob/L)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ACTION_HIDDEN, L)
	flags_ui_actions |= UI_ACTIONS_HIDDEN
	L.update_action_buttons()

/proc/unhide_action(mob/L, action_path)
	for(var/a in L.actions)
		var/datum/action/A = a
		if(A.type == action_path)
			A.flags_ui_actions &= ~UI_ACTIONS_HIDDEN
			L.update_action_buttons()
			return A

/datum/action/proc/unhide_from(mob/L)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ACTION_UNHIDDEN, L)
	flags_ui_actions &= ~UI_ACTIONS_HIDDEN
	L.update_action_buttons()


/datum/action/item_action
	name = "Use item"
	var/obj/item/holder_item //the item that has this action in its list of actions. Is not necessarily the target
								//e.g. gun attachment action: target = attachment, holder = gun.
	flags_ui_actions = NO_FLAGS

/datum/action/item_action/New(Target, obj/item/holder)
	..()
	if(!holder)
		holder = target
	holder_item = holder
	LAZYADD(holder_item.actions, src)
	if(!(flags_ui_actions & UI_ACTIONS_ITEM_CUSTOM)) //If we're not setting the item overlay, we don't want this behavior.
		name = "Use [target]"
		button.name = name

	update_button_icon()

/datum/action/item_action/Destroy()
	LAZYREMOVE(holder_item.actions, src)
	holder_item = null
	return ..()

/datum/action/item_action/action_activate()
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, holder_item)

/datum/action/item_action/can_use_action()
	if(ishuman(owner) && !owner.is_mob_incapacitated())
		var/mob/living/carbon/human/human = owner
		if(human.body_position == STANDING_UP)
			return TRUE

/datum/action/item_action/update_button_icon()
	if(flags_ui_actions & UI_ACTIONS_ITEM_CUSTOM) return //We don't want to update this if we have a custom icon.
	button.overlays.Cut()
	var/mutable_appearance/item_appearance = mutable_appearance(target.icon, target.icon_state, plane = ABOVE_HUD_PLANE)
	for(var/overlay in target.overlays)
		item_appearance.overlays += overlay
	button.overlays += item_appearance

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target]"
	button.name = name

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!client)
		return

	if(!hud_used)
		create_hud()

	if(hud_used.hud_version == HUD_STYLE_NOHUD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A in actions)
			A.button.screen_loc = null
			if(reload_screen)
				client.add_to_screen(A.button)
	else
		var/L[0] //We will use this to make sure our group buttons aren't repeated.
		for(var/datum/action/A in actions)
			if(A.flags_ui_actions & UI_ACTIONS_ITEM_GROUP)
				if(A.type in L) continue//We have this type already, continue processing.
				else L += A.type //Add it and do the other stuff.

			var/atom/movable/screen/action_button/B = A.button
			if(reload_screen)
				client.add_to_screen(B)
			if(A.flags_ui_actions & UI_ACTIONS_HIDDEN)
				B.screen_loc = null
				continue
			button_number++
			B.screen_loc = B.get_button_screen_loc(button_number)

		if(!button_number)
			hud_used.hide_actions_toggle.screen_loc = null
			if(reload_screen)
				client.add_to_screen(hud_used.hide_actions_toggle)
			return

	hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.get_button_screen_loc(button_number+1)

	if(reload_screen)
		client.add_to_screen(hud_used.hide_actions_toggle)

