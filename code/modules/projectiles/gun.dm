#define CODEX_ARMOR_MAX 50
#define CODEX_ARMOR_STEP 5
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                  GENERIC GUN PRESET                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = ""
	item_state = "gun"
	pickup_sound = "gunequip"
	drop_sound = "gunrustle"
	pickupvol = 7
	dropvol = 15
	matter = null //Guns generally have their own unique levels.
	w_class = SIZE_MEDIUM
	throwforce = 5
	throw_speed = SPEED_VERY_FAST
	throw_range = 5
	force = 5
	attack_verb = null
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi'
		)
	flags_atom = FPRINT|CONDUCT
	flags_item = TWOHANDED
	light_system = DIRECTIONAL_LIGHT

	//ICONS
	///the default gun icon_state. change to reskin the gun
	var/base_gun_icon
	/// whether gun has icon state of (base_gun_icon)_e
	var/has_empty_icon = TRUE
	/// whether gun has icon state of (base_gun_icon)_o
	var/has_open_icon = FALSE
	var/cycle_animation = null //Icon state for the gun cycle, such as handgun slides moving or shotgun pumps or a moving bolt, etc.
	var/pixel_width_offset = 0 //In case the gun's sprite insn't 32 pixels in actual width. Only really used for SMGs, rifles, and shotguns so they properly fit in gun racks.

	//EFFECTS
	var/muzzle_flash = "muzzle_flash"
	///muzzle flash brightness
	var/muzzle_flash_lum = 3

	//SOUNDS
	var/fire_sound = 'sound/weapons/Gunshot.ogg' ///Will default to this if it doesn't have a unique sound. You can make this into a list() if you want the game to pick a sound at random.
	var/firesound_volume = 60 //Volume of gunshot, adjust depending on volume of shot
	var/fire_rattle = null
	///Does our gun have a unique empty mag sound? If so use instead of pitch shifting.
	var/unload_sound = 'sound/weapons/flipblade.ogg'
	///This sound is so damn annoying.
	var/empty_sound = 'sound/weapons/smg_empty_alarm.ogg'
	//We don't want these for guns that don't have them.
	var/reload_sound = null
	var/cocked_sound = null

	///////////////////////FLAGS//////////////////////////////
	//Determine most common properties about a gun. The other two flag sets deal with additional properties. Check documentation for details.
	var/flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	//What various states the gun may have active at the same time, like when firing multiple rounds or toggling a flashlight.
	var/flags_gun_toggles = NO_FLAGS
	//How the gun operates internally. Defaults to the gun not requiring chambering or anything special. Will fire regardless of chambering if it has a magazine loaded with bullets left.
	var/flags_gun_receiver = NO_FLAGS
	///////////////////////END FLAGS////////////////////////////

	//BASIC INFO AND VARIABLES
	///Only guns of the same category can be fired together while dualwielding.
	var/gun_category //Technically a bitfield, but I'm not currently sure as to the benefit.
	///Determines what kind of bullet is created when the gun is unloaded - used to match rounds to magazines. Set automatically on spawn based on the default magazine. Should not change.
	///If the gun doesn't reload normally, this variable should not matter. Like with energy firearms.
	var/caliber
	//Will not produce casings unless overriden. If it's desired in the future that casings correspond to a particular magazine/ammunition, the ammo datum can provide most of the needed
	//info. Alternatively, a list of calibers can be created at world init, where each caliber has an associated ammo with an associated casing type. Ie, list("9mm"[ammo_datum]["casing_type"])
	var/projectile_casing = PROJECTILE_CASING_CASELESS
	/*The part of the gun where the projectile would be before it is fired. When not used it should be null. Do not use qdel() on this.
	This is a reference to an ammo datum, not the projectile itself. The projectile is created when the gun actually fires.*/
	var/datum/ammo/in_chamber = null
	/*Ammo mags may or may not be internal, though the difference is a few additional variables. If they are not internal, don't call
	on those unique vars. This is done for quicker pathing. Just keep in mind most mags aren't internal, though some are.
	This is also the default magazine path loaded into a projectile weapon for reverse lookups on New(). Leave this null to do your own thing.*/
	var/obj/item/ammo_magazine/internal/current_mag = null
	//Some guns have hybrid feeders that may take different mags from more than 1 *different* type of gun. It's basically an override.
	//If you have a parent and child guns, you won't need this. Most guns will not use this variable, and it's only for detachable magazines.
	var/additional_type_magazines
	//This is a vis_contents object that displays remaining ammo for the gun. It is created and assigned if the gun has that feature and is picked up by somebody.
	var/obj/effect/digital_counter/ammo_counter = null
	///world.time value, to prevent spamming cycle.
	var/cycle_chamber_cooldown = 0
	///Delay before we can cycle the chamber again, in tenths of seconds
	var/cycle_chamber_delay = 30

	//Basic stats.'
	///Guns can jam, though right now it's not set up for anything other than the PPSH and uzi. Jam chance compounds for the weapon and mag used, if non-zero. This is the base chance for the gun.
	var/malfunction_chance_base = GUN_MALFUNCTION_CHANCE_ZERO
	//This accumulates as the gun is fired. More rounds fired = higher chance to jam.
	var/malfunction_chance_mod = GUN_MALFUNCTION_CHANCE_ZERO
	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's accuracy by this number.
	var/accuracy_mult = BASE_ACCURACY_MULT
	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's damage by this number.
	var/damage_mult = BULLET_DAMAGE_MULT_BASE
	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's damage bleed (falloff) by this number.
	var/damage_falloff_mult = DAMAGE_FALLOFF_TIER_10
	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's damage bleed (buildup) by this number.
	var/damage_buildup_mult = DAMAGE_BUILDUP_TIER_1
	///Screen shake when the weapon is fired.
	var/recoil = RECOIL_OFF
	///How much the bullet scatters when fired.
	var/scatter = SCATTER_AMOUNT_TIER_6
	/// Added velocity to fired bullet.
	var/velocity_add = BASE_VELOCITY_BONUS
	///Multiplier. Increases or decreases how much bonus scatter is added with each bullet during burst fire (wielded only).
	var/burst_scatter_mult = SCATTER_AMOUNT_TIER_7

	///What minimum range the weapon deals full damage, builds up the closer you get. 0 for no minimum.
	var/effective_range_min = EFFECTIVE_RANGE_OFF
	///What maximum range the weapon deals full damage, tapers off using damage_falloff after hitting this value. 0 for no maximum.
	var/effective_range_max = EFFECTIVE_RANGE_OFF

	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's accuracy when unwielded by this number.
	var/accuracy_mult_unwielded = BASE_ACCURACY_MULT
	///Multiplier. Increased and decreased through attachments. Multiplies the gun's recoil when unwielded by this number.
	var/recoil_unwielded = RECOIL_OFF
	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's scatter when the gun is unwielded by this number.
	var/scatter_unwielded = SCATTER_AMOUNT_TIER_6

	///Multiplier. Increased and decreased through attachments. Multiplies the accuracy/scatter penalty of the projectile when firing onehanded while moving.
	var/movement_onehanded_acc_penalty_mult = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_1 //Multiplier. Increased and decreased through attachments. Multiplies the accuracy/scatter penalty of the projectile when firing onehanded while moving.

	///For regular shots, how long to wait before firing again. Use modify_fire_delay and set_fire_delay instead of modifying this on the fly
	VAR_PROTECTED/fire_delay = FIRE_DELAY_TIER_5
	///When it was last fired, related to world.time.
	var/last_fired = 0

	///Self explanatory. How much does aiming (wielding the gun) slow you
	var/aim_slowdown = 0
	///How long between wielding and firing in tenths of seconds
	var/wield_delay = WIELD_DELAY_FAST
	///Storing value for wield delay.
	var/wield_time = 0
	///Storing value for guaranteed delay
	var/guaranteed_delay_time = 0
	///Storing value for how long pulling a gun takes before you can use it
	var/pull_time = 0

	///Determines what happens when you fire a gun before its wield or pull time has finished. This one is extra scatter and an acc. malus.
	var/delay_style = WEAPON_DELAY_SCATTER_AND_ACCURACY

	//Burst fire.
	///How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst. Use modify_burst_amount and set_burst_amount instead of modifying this
	VAR_PROTECTED/burst_amount = BURST_AMOUNT_TIER_1
	///The delay in between shots. Lower = less delay = faster. Use modify_burst_delay and set_burst_delay instead of modifying this
	VAR_PROTECTED/burst_delay = FIRE_DELAY_TIER_5
	///When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.
	var/extra_delay = 0
	///When PB burst firing and handing off to /fire after a target moves out of range, this is how many bullets have been fired.
	var/PB_burst_bullets_fired = 0

	// Full auto
	///Whether or not the gun is firing full-auto
	var/fa_firing = FALSE
	///How many full-auto shots to get to max scatter?
	var/fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_BASE
	///How bad does the scatter get on full auto?
	var/fa_max_scatter = FULL_AUTO_SCATTER_MAX_BASE
	///Click parameters to use when firing full-auto
	var/fa_params = null

	///Used to fire faster at more than one person.
	var/tmp/mob/living/last_moved_mob
	var/tmp/lock_time = -100
	///Used to determine if you can target multiple people.
	var/automatic = 0
	///So that it doesn't spam them with the fact they cannot hit them.
	var/tmp/told_cant_shoot = 0

	//Attachments. Lists are handled on Initialize(), which is called after New().
	///This will link to one of the attachments, or remain null.
	var/obj/item/attachable/attached_gun/active_attachable = null
	///List of all current attachments on the gun.
	var/list/attachments
	///List of offsets for various attachmens.
	var/list/attachable_offset
	///Must be the exact path to the attachment present in the list. This is checked only when a player tries attaching something. Item-spawn procs ignore it. You do not need to add integrated attachments to it as those cannot be removed or added by the player.
	var/list/attachable_allowed
	///What attachments this gun starts with. They can be integrated or removable, so long as they are properly defined in the code.
	var/list/starting_attachment_types

	///I revised how random attachments work. I think it may be most effective to link them to attachable_allowed instead, but I didn't have the time to investigate that possibility fully.
	///Chance for random attachments to spawn in general. Change to higher than 0 if you want random attachments.
	///The two lists will get nulled after an item is spawned in, so override with an empty list if you need something to not spawn on a child. Random attachments are processed first, before starting_attachment_types.
	var/random_attachment_chance = 50
	//This is a percentage list for each attachment in sequence of the above. "slot" = "number". Ie, list(ATTACHMENT_SLOT_MUZZLE = "100")
	//Make sure to follow the proper if() setup for lists so this can properly inherit. Check out rifles.dm for examples.
	var/list/random_attachment_spawn_chance
	//This is a referenced list of lists for attachments that can spawn under each category: ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_MUZZLE, ATTACHMENT_SLOT_UNDER, and ATTACHMENT_SLOT_STOCK
	//Link each you want to a list of paths for that attachment to pick one to spawn. Ie, list(ATTACHMENT_SLOT_MUZZLE = list(/obj/item/attachable/suppressor)) Check how to properly do this in rifles.dm.
	var/list/random_attachments_possible

	/// How much recoil_buildup is lost per second. Builds up as time passes, and is set to 0 when a single shot is fired
	var/recoil_loss_per_second = 10
	/// The recoil on a dynamic recoil gun
	var/recoil_buildup = 0

	///The limit at which the recoil on a gun can reach. Usually the maximum value
	var/recoil_buildup_limit = RECOIL_AMOUNT_TIER_1 / RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER
	var/last_recoil_update = 0
	var/auto_retrieval_slot

	/** An assoc list in the format list(/datum/element/bullet_trait_to_give = list(...args))
	that will be given to a projectile with the current ammo datum**/
	var/list/list/traits_to_give

	/**
	* The group or groups of the gun where a fire delay is applied and the delays applied to each group when the gun is dropped
	* after being fired
	*
	* Guns with this var set will apply the gun's remaining fire delay to any other guns in the same group
	*
	* Set as null (does not apply any fire delays to any other gun group) or a list of fire delay groups (string defines)
	* matched with the corresponding fire delays applied
	*/
	var/list/fire_delay_group
	var/additional_fire_group_delay = 0 // adds onto the fire delay of the above

	// Set to TRUE or FALSE, it overrides the is_civilian_usable check with its value. Does nothing if null.
	var/civilian_usable_override = null
	///Current selected firemode of the gun.
	var/gun_firemode = GUN_FIREMODE_SEMIAUTO
	///List of allowed firemodes.
	var/list/gun_firemode_list
	///How many bullets the gun fired while bursting/auto firing
	var/shots_fired = 0


	/// Currently selected target to fire at. Set with set_target()
	VAR_PRIVATE/atom/target
	/// Current user (holding) of the gun. Set with set_gun_user()
	VAR_PRIVATE/mob/gun_user
	/// If this gun should spawn with semi-automatic fire. Protected due to it never needing to be edited.
	VAR_PROTECTED/start_semiauto = TRUE
	/// If this gun should spawn with automatic fire. Protected due to it never needing to be edited.
	VAR_PROTECTED/start_automatic = FALSE
	/// The type of projectile that this gun should shoot
	var/projectile_type = /obj/projectile
	/// The multiplier for how much slower this should fire in automatic mode. 1 is normal, 1.2 is 20% slower, 2 is 100% slower, etc. Protected due to it never needing to be edited.
	VAR_PROTECTED/autofire_slow_mult = 1

/**
 * An assoc list where the keys are fire delay group string defines
 * and the keys are when the guns of the group can be fired again
 */
/mob/var/list/fire_delay_next_fire

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      NECESSARY PROCS       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/Initialize(mapload, spawn_empty) //You can pass on spawn_empty to make the sure the gun has no bullets or mag or anything when created.
	 //This only affects guns you can get from vendors for now. Special guns spawn with their own things regardless.
	base_gun_icon = icon_state

	LAZYSET(item_state_slots, WEAR_BACK, item_state)
	LAZYSET(item_state_slots, WEAR_JACKET, item_state)

	if(current_mag)
		//We abuse an undocumented behavior to look up and set the caliber.
		var/obj/item/ammo_magazine/A = current_mag //Punch in the type path and make a variable.
		caliber = initial(A.caliber) //This gets us the default caliber name. This should be set if current_mag is a valid path.

		if(!caliber) //If it's still not set somehow. Sanity check, good have in general for error checking.
			log_debug("ERROR CODE A2: null calibre while initializing User: Weapon: <b>[src]</b> Magazine path: <b>[current_mag]</b>")
			caliber = "bugged calibre"

		if(spawn_empty && !(flags_gun_receiver & GUN_INTERNAL_MAG)) //Internal mags will still spawn, but they won't be filled.
			current_mag = null //Reset the mag since we're not spawning with it.
			update_icon()
		else
			current_mag = new current_mag(src, spawn_empty? TRUE : FALSE)

	//Essentially sets in_chamber to the ammo the gun uses, permanently. Don't need the old ammo variable.
	if(flags_gun_receiver & GUN_CHAMBER_IS_STATIC)
		in_chamber = GLOB.ammo_list[in_chamber]

	initialize_gun_lists()

	//set_fire_delay(fire_delay)
	//set_burst_amount(burst_amount)
	//set_burst_delay(burst_delay)

	set_bullet_traits()
	update_force_list() //This gives the gun some unique attack verbs for attacking.

	handle_random_attachments() //This should be first.
	handle_starting_attachment() //This should run after randoms. Anything not set by random, and present in the starting attachment list, will be attached. So you can have a fallback default attachment in case randoms don't spawn.

	GLOB.gun_list += src
	if(auto_retrieval_slot)
		AddElement(/datum/element/drop_retrieval/gun, auto_retrieval_slot)
	update_icon() //for things like magazine overlays
	gun_firemode = gun_firemode_list[1] || GUN_FIREMODE_SEMIAUTO
	AddComponent(/datum/component/automatedfire/autofire, fire_delay, burst_delay, burst_amount, gun_firemode, autofire_slow_mult, CALLBACK(src, PROC_REF(set_bursting)), CALLBACK(src, PROC_REF(reset_fire)), CALLBACK(src, PROC_REF(fire_wrapper)), CALLBACK(src, PROC_REF(set_auto_firing))) //This should go after handle_starting_attachment() and setup_firemodes() to get the proper values set.

	. = ..() //We call the parent here to make sure actions and other misc parameters are set correctly.
/*
Called on during Initialize so we are not inline defining lists. Inline proc calls mean that they run at runtime whether or not the item exists in the world,
and the list is perpetually stuck in memory because it's a non-default value. It's better to create lists on New(), which is what this proc does.
The way this proc should work is that the child object calls this after creating the necessary lists. Every time a list is being created, it should
be prefaced with an if() to make sure that list doesn't already exist from a previous proc. This means that we get to keep our inherit structure of data without
running a bunch of list creation procs to then overwrite them, possibly twice or more. The downside is that we still need to iterate parent-child calls,
though this is about as good as it gets outside of overriding proc behavior manually.
*/
/obj/item/weapon/gun/proc/initialize_gun_lists()
	//This proc is called last in the parent-child chain, so all of these trigger after all the other lists are established.
	attachments = list() //We want this to be an empty list as a lot of procs don't check whether or not it exists.
	gun_firemode_list = list() //Firemodes need this to exist.
	setup_firemodes() //Then we actually set this up. If the gun has attachments, another proc will call this again.

	if(random_attachments_possible) //If this list exists, we have random attachments.
		if(!random_attachment_spawn_chance) //This will generate a default list if one should exist but doesn't.
			random_attachment_spawn_chance = list(ATTACHMENT_SLOT_RAIL = 100, ATTACHMENT_SLOT_MUZZLE = 100, ATTACHMENT_SLOT_UNDER = 100, ATTACHMENT_SLOT_STOCK = 100)

		else //If the list already exists, we default whatever is not set. Hence, these should only be defined per child if the slot is not guaranteed to spawn.
			if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL])
				random_attachment_spawn_chance[ATTACHMENT_SLOT_RAIL] = 100

			if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE])
				random_attachment_spawn_chance[ATTACHMENT_SLOT_MUZZLE] = 100

			if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER])
				random_attachment_spawn_chance[ATTACHMENT_SLOT_UNDER] = 100

			if(!random_attachment_spawn_chance[ATTACHMENT_SLOT_STOCK])
				random_attachment_spawn_chance[ATTACHMENT_SLOT_STOCK] = 100

//Internal magazines use this to generate and track their bullets/shells.
/obj/item/weapon/gun/proc/populate_internal_magazine(number_to_replace)
	if(current_mag) //Just in case it didn't spawn in for whatever reason.
		current_mag.chamber_contents = list()
		for(var/i = 1 to current_mag.max_rounds) //We want to make sure to populate the cylinder.
			current_mag.chamber_contents += i > number_to_replace ? null : current_mag.default_ammo //Defaults to whatever the gun uses for default.
		current_mag.chamber_position = min(number_to_replace, current_mag.max_rounds)
		return TRUE

/obj/item/weapon/gun/Destroy()
	in_chamber = null
	QDEL_NULL(current_mag)
	target = null
	last_moved_mob = null
	if(flags_gun_toggles & GUN_FLASHLIGHT_ON)//Handle flashlight.
		flags_gun_toggles &= ~GUN_FLASHLIGHT_ON
	remove_ammo_counter() //Gets rid of of a counter if it has one.
	for(var/i in contents) //Unlink any other contents and empty everything out, mostly attachments.
		contents -= i
		vis_contents -= i
	attachments = null
	QDEL_NULL(active_attachable)
	GLOB.gun_list -= src
	set_gun_user(null)
	. = ..()

//This resets gun values to their initial on-compile state, so this proc is not computing multiple times for children.
//Originally called set_gun_config_values and ran at runtime to set up values based on a config file. I've reset all gun stats back to static variables since config is not used anymore.
/obj/item/weapon/gun/proc/reset_gun_stat_values()
	set_fire_delay(initial(fire_delay))
	set_burst_amount(initial(burst_amount))
	set_burst_delay(initial(burst_delay))

	accuracy_mult = initial(accuracy_mult)
	accuracy_mult_unwielded = initial(accuracy_mult_unwielded)
	scatter = initial(scatter)
	burst_scatter_mult = initial(burst_scatter_mult)

	scatter_unwielded = initial(scatter_unwielded)
	damage_mult = initial(damage_mult)
	damage_falloff_mult = initial(damage_falloff_mult)
	damage_buildup_mult = initial(damage_buildup_mult)
	velocity_add = initial(velocity_add)
	recoil = initial(recoil)
	recoil_unwielded = initial(recoil_unwielded)
	movement_onehanded_acc_penalty_mult = initial(movement_onehanded_acc_penalty_mult)

	effective_range_min = initial(effective_range_min)
	effective_range_max = initial(effective_range_max)

	//I don't believe anything modifies this directly, future proofing.
	fa_scatter_peak = initial(fa_scatter_peak)
	fa_max_scatter = initial(fa_max_scatter)

	recoil_buildup_limit = initial(recoil_buildup_limit)

/// Populate traits_to_give in this proc
/obj/item/weapon/gun/proc/set_bullet_traits()
	return

/// @bullet_trait_entries: A list of bullet trait entries
/obj/item/weapon/gun/proc/add_bullet_traits(list/list/bullet_trait_entries)
	LAZYADD(traits_to_give, bullet_trait_entries)

/// @bullet_traits: A list of bullet trait typepaths or ids
/obj/item/weapon/gun/proc/remove_bullet_traits(list/bullet_traits)
	for(var/entry in bullet_traits)
		LAZYREMOVE(traits_to_give, entry)

/obj/item/weapon/gun/emp_act(severity)
	. = ..()
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/update_icon()
	..()

	var/new_icon_state = base_gun_icon

	if(has_empty_icon && !current_mag)
		new_icon_state += "_e"

	if(has_open_icon && (!current_mag || flags_gun_receiver & GUN_CHAMBER_IS_OPEN))
		new_icon_state += "_o"

	icon_state = new_icon_state

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      EXAMINING THE GUN       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/get_examine_text(mob/user)
	. = ..()
	if(flags_gun_features & GUN_NO_DESCRIPTION) return
	if(caliber && !(flags_gun_features & GUN_UNUSUAL_DESIGN))
		. += "Chambered in [caliber]." //I thought about adding some checks for firerams to see if the user actually knows this, but probably not a good idea right now.
		//Need a better examine system. user.mind.knowledge perhaps?
		//If the user doesn't have knowledge related to the subject, they won't get the info.
		//Coould maybe be tied into skills?

	//Quick note, the parser apparently adds the line breaks automatically to the end of each list entry, so if you have them at the end of the entry already, it will make an extra empty line.

	//You have to be close to the gun to examine all of its features. Need a better solution for this.
	if( isobserver(user) || (ishuman(user) && get_dist(src, user) <= 1) )
		if(!(flags_gun_features & GUN_NO_SAFETY_SWITCH))
			. += flags_gun_toggles & GUN_TRIGGER_SAFETY_ON ? SPAN_NOTICE("The safety's on!") : SPAN_NOTICE("The safety's off!")
		if(flags_gun_features & GUN_AUTO_EJECTOR)
			. += flags_gun_toggles & GUN_AUTO_EJECTING_OFF ? "The auto-ejector is off." : "The auto-ejector is on."

		for(var/slot in attachments)
			var/obj/item/attachable/R = attachments[slot]
			if(R) . += R.handle_attachment_description(user.client)

		var/t
		if( !(flags_gun_features & GUN_UNUSUAL_DESIGN) ) //Unusual designs have their own thing set via get_additional_gun_examine_text. Same for internal mags.
			if( !(flags_gun_receiver & GUN_INTERNAL_MAG) )
				t += "It's [current_mag ? "loaded" : "unloaded"]"

		if(flags_gun_features & GUN_AMMO_COUNTER) //We want the ammo counter to be viewable if possible.
			t += "[t? " and t" : "T"]he ammo counter readout shows [current_mag? (current_mag.current_rounds + (in_chamber? 1 : 0) ) : (in_chamber? 1 : 0) ] round\s remaining"

		if(t) //If it's a string, punctuate it.
			t += "."

			. += t

		//Since we're not using the parent proc, we need to account for line breaks.
		//Can be done manually, but we can do it dynamically instead.
		var/list/L = get_additional_gun_examine_text(user)
		var/t2
		if(L.len) //If we have some text.
			for(var/i = 1 to L.len)
				t2 += L[i] //Add i's value to the text string.
				if(i != L.len) t2 += "<br>" //Append break if it's not the final line.
			. += t2//So we're not checking distance and whatnot every child, and can append something to the end of the description.

		//Switch doesn't run time error if one condition is possible in two or more if() states. It's best not to double up possibilities since
		//technically it's not a defined behavior.
		if(malfunction_chance_base > GUN_MALFUNCTION_CHANCE_ZERO)//If it has a chance to malfunction, it can get dirty.
			switch(malfunction_chance_mod)
				if(GUN_MALFUNCTION_CHANCE_ZERO to (GUN_MALFUNCTION_CHANCE_LOW - 0.01))
					. += "[src] looks really clean and well-taken care of."
				if(GUN_MALFUNCTION_CHANCE_LOW to (GUN_MALFUNCTION_CHANCE_MED_LOW - 0.01))
					. += "[src] has seen some use, but is still relatively clean."
				if(GUN_MALFUNCTION_CHANCE_MED_LOW to (GUN_MALFUNCTION_CHANCE_MEDIUM - 0.01))
					. += "It may be a good time to give [src] a cleaning."
				if(GUN_MALFUNCTION_CHANCE_MEDIUM to (GUN_MALFUNCTION_CHANCE_VERY_HIGH - 0.01))
					. += "[src] must have been fired a lot because it's starting to get really dirty."
				if(GUN_MALFUNCTION_CHANCE_VERY_HIGH to INFINITY)
					. += "[src] looks absolutely filthy and will probably fail to function properly."
		//. += "<a href='?src=\ref[src];list_stats=1'>\[See combat statistics]</a>" //Testing commenting this out.

 /*
 Overrides as necessary per child object. Use this instead of get_examine_text()
 So we're not checking for distance for every override.
 */
/obj/item/weapon/gun/proc/get_additional_gun_examine_text(mob/user)
	. = list() //Creates an empty list that can be added to by child procs. Normal return procedure is . = ..() + "Some string." per single line or . += "Something." per multiple lines.. No "<br>" needed.

//======================================================================================\\

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	           TG GUI       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr) && !isobserver(usr))
		return

	if(href_list["list_stats"]&& !(flags_gun_features & GUN_UNUSUAL_DESIGN))
		tgui_interact(usr)

// TGUI GOES HERE \\

/obj/item/weapon/gun/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "WeaponStats", name)
		ui.open()

/obj/item/weapon/gun/ui_state(mob/user)
	return GLOB.always_state // can't interact why should I care

/obj/item/weapon/gun/ui_data(mob/user)
	var/list/data = list()

	var/ammo_name = "bullet"
	var/damage = 0
	var/bonus_projectile_amount = 0
	var/falloff = 0
	var/gun_recoil = recoil

	if(flags_gun_features & GUN_RECOIL_BUILDUP)
		update_recoil_buildup() // Need to update recoil values
		gun_recoil = recoil_buildup

	var/penetration = 0
	var/armor_punch = 0
	var/accuracy = 0
	var/min_accuracy = 0
	var/max_range = 0
	var/scatter = 0
	var/list/damage_armor_profile_xeno = list()
	var/list/damage_armor_profile_marine = list()
	var/list/damage_armor_profile_armorbreak = list()
	var/list/damage_armor_profile_headers = list()

	var/datum/ammo/in_ammo
	if(in_chamber)
		in_ammo = in_chamber
	else if(current_mag && current_mag.current_rounds > 0)
		if(istype(current_mag) && length(current_mag.chamber_contents) && current_mag.chamber_contents[current_mag.chamber_position])
			in_ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
			if(!istype(in_ammo))
				in_ammo = GLOB.ammo_list[current_mag.default_ammo]

	var/has_ammo = istype(in_ammo)
	if(has_ammo)
		ammo_name = in_ammo.name

		damage = in_ammo.damage * damage_mult
		bonus_projectile_amount = in_ammo.bonus_projectiles_amount
		falloff = in_ammo.damage_falloff * damage_falloff_mult

		penetration = in_ammo.penetration
		armor_punch = in_ammo.damage_armor_punch

		accuracy = in_ammo.accurate_range

		min_accuracy = in_ammo.accurate_range_min

		max_range = in_ammo.max_range
		scatter = in_ammo.scatter

		for(var/i = 0; i<=CODEX_ARMOR_MAX; i+=CODEX_ARMOR_STEP)
			damage_armor_profile_headers.Add(i)
			damage_armor_profile_marine.Add(round(armor_damage_reduction(GLOB.marine_ranged_stats, damage, i, penetration)))
			damage_armor_profile_xeno.Add(round(armor_damage_reduction(GLOB.xeno_ranged_stats, damage, i, penetration)))
			if(!GLOB.xeno_general.armor_ignore_integrity)
				if(i != 0)
					damage_armor_profile_armorbreak.Add("[round(armor_break_calculation(GLOB.xeno_ranged_stats, damage, i, penetration, in_ammo.pen_armor_punch, armor_punch)/i)]%")
				else
					damage_armor_profile_armorbreak.Add("N/A")

	var/rpm = max(fire_delay, 1)
	var/burst_rpm = max((fire_delay * 1.5 + (burst_amount - 1) * burst_delay)/max(burst_amount, 1), 0.0001)

	// weapon info

	data["icon"] = SSassets.transport.get_asset_url("no_name.png")

	if(SSassets.cache["[base_gun_icon].png"])
		data["icon"] = SSassets.transport.get_asset_url("[base_gun_icon].png")

	data["name"] = name
	data["desc"] = desc
	data["two_handed_only"] = (flags_gun_features & GUN_WIELDED_FIRING_ONLY)
	data["recoil"] = max(gun_recoil, 0.1)
	data["unwielded_recoil"] = max(recoil_unwielded, 0.1)
	data["firerate"] = round(1 MINUTES / rpm) // 3 minutes so that the values look greater than they actually are
	data["burst_firerate"] = round(1 MINUTES / burst_rpm)
	data["firerate_second"] = round(1 SECONDS / rpm, 0.01)
	data["burst_firerate_second"] = round(1 SECONDS / burst_rpm, 0.01)
	data["scatter"] = max(0.1, scatter + src.scatter)
	data["unwielded_scatter"] = max(0.1, scatter + scatter_unwielded)
	data["burst_scatter"] = src.burst_scatter_mult
	data["burst_amount"] = burst_amount

	// ammo info

	data["has_ammo"] = has_ammo
	data["ammo_name"] = ammo_name
	data["damage"] = damage
	data["falloff"] = falloff
	data["total_projectile_amount"] = bonus_projectile_amount+1
	data["armor_punch"] = armor_punch
	data["penetration"] = penetration
	data["accuracy"] = accuracy * accuracy_mult
	data["unwielded_accuracy"] = accuracy * accuracy_mult_unwielded
	data["min_accuracy"] = min_accuracy
	data["max_range"] = max_range

	// damage table data

	data["damage_armor_profile_headers"] = damage_armor_profile_headers
	data["damage_armor_profile_marine"] = damage_armor_profile_marine
	data["damage_armor_profile_xeno"] = damage_armor_profile_xeno
	data["damage_armor_profile_armorbreak"] = damage_armor_profile_armorbreak

	return data

/obj/item/weapon/gun/ui_static_data(mob/user)
	var/list/data = list()

	// consts (maxes)

	data["recoil_max"] = RECOIL_AMOUNT_TIER_1
	data["scatter_max"] = SCATTER_AMOUNT_TIER_1
	data["firerate_max"] = 1 MINUTES / FIRE_DELAY_TIER_12
	data["damage_max"] = 100
	data["accuracy_max"] = 32
	data["range_max"] = 32
	data["falloff_max"] = DAMAGE_FALLOFF_TIER_1
	data["penetration_max"] = ARMOR_PENETRATION_TIER_10
	data["punch_max"] = 5
	data["glob_armourbreak"] = GLOB.xeno_general.armor_ignore_integrity
	data["automatic"] = (GUN_FIREMODE_AUTOMATIC in gun_firemode_list)
	data["auto_only"] = ((length(gun_firemode_list) == 1) && (GUN_FIREMODE_AUTOMATIC in gun_firemode_list))

	return data

/obj/item/weapon/gun/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/firemodes)
	//. += get_asset_datum(/datum/asset/spritesheet/gun_lineart)

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//					          >>>>>>>>>>  RELOADING AND UNLOADING   <<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------
/*
User can be passed as null. Tries to account for most reloading methods now.
*/

/obj/item/weapon/gun/proc/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	if(!istype(magazine))
		to_chat(user, SPAN_WARNING("You can't use that to reload!"))
		return

	if(magazine.current_rounds <= 0)
		to_chat(user, SPAN_WARNING("\The [magazine] is empty!"))
		return

	//If the gun can be opened but it's closed.
	if(flags_gun_receiver & GUN_CHAMBER_CAN_OPEN && !(flags_gun_receiver & GUN_CHAMBER_IS_OPEN)) //TODO: Put an exception for the revolver?
		to_chat(user, SPAN_WARNING("You can't reload [src] with the chamber closed!"))
		return

	switch(magazine.magazine_type) //Easy, we switch based on what the magazine actually is.
		if(MAGAZINE_TYPE_DETACHABLE)
			if(flags_gun_receiver & (GUN_ACCEPTS_SPEEDLOADER|GUN_ACCEPTS_HANDFUL)) //It won't take regular mags if it reloads with something special.
				to_chat(user, SPAN_WARNING("[src] can't reload with detachable magazines!"))
				return

			if(current_mag)
				to_chat(user, SPAN_WARNING("[src] still got something loaded."))
				return

			if(!istype(src, magazine.gun_type) && (!additional_type_magazines || !(magazine.type in additional_type_magazines)) )
				to_chat(user, SPAN_WARNING("That magazine doesn't fit in there!"))
				return

			if(user)
				if(magazine.reload_delay > 1)
					to_chat(user, SPAN_NOTICE("You begin reloading [src]. Hold still..."))
					if(!do_after(user, magazine.reload_delay, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
						to_chat(user, SPAN_WARNING("Your reload was interrupted!"))
						return
				replace_magazine(user, magazine)
			else
				current_mag = magazine
				magazine.forceMove(src)
				if(!in_chamber) load_into_chamber()

		if(MAGAZINE_TYPE_HANDFUL) //Handfuls ignore gun_type
			if( !(flags_gun_receiver & GUN_ACCEPTS_HANDFUL) )
				to_chat(user, SPAN_WARNING("[src] can't reload with handfuls of ammo!"))
				return

			//Handfuls can get deleted, so we need to keep this on hand
			var/ammunition_reference = magazine.default_ammo //Handfuls can get deleted, so we remember what it had.
			if(current_mag.transfer_bullet_number(magazine,user,1))
				replace_magazine(user, ammunition_reference) //Pop a round in.

		if(MAGAZINE_TYPE_SPEEDLOADER)
			if( !(flags_gun_receiver & GUN_ACCEPTS_SPEEDLOADER) ) //Should be a revolver of some kind.
				to_chat(user, SPAN_WARNING("[src] can't reload with speedloaders!"))
				return

			if(current_mag.gun_type == magazine.gun_type) //Has to be the same gun type.
				if( !(flags_gun_receiver &  GUN_CHAMBER_IS_OPEN) ) //it's closed
					if(user?.skills?.get_skill_level(SKILL_FIREARMS) > SKILL_FIREARMS_CIVILIAN) //Basic firearms skills gets you the reload anyway.
						unload(user, TRUE) //Pop open the chamber first.
					else
						to_chat(user, SPAN_WARNING("You can't load anything when the cylinder is closed!"))
						return

				if(current_mag.transfer_bullet_number(magazine,user,magazine.current_rounds))//Make sure we're successful.
					for(var/i = 1 to current_mag.current_rounds) replace_magazine(user, magazine.default_ammo) //Re-populates the cylinder with the speedloader rounds.
					playsound(user, reload_sound, 25, 1) // Reloading via speedloader.
					flags_gun_receiver &= ~GUN_CHAMBER_IS_OPEN //Close it
			else
				to_chat(user, SPAN_WARNING("\The [magazine] doesn't fit right!"))
				return

		else
			to_chat(user, SPAN_WARNING("\The [magazine] doesn't go here!"))
			return

	update_icon()
	display_ammo(user, TRUE, parent_proc = "reload()")
	return TRUE

//Override this proc based on what the gun needs to load for its specific needs. This just deals with generic detachable magazines.
/obj/item/weapon/gun/proc/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	to_chat(user, SPAN_WARNING("Got to the start of the proc call."))
	user.drop_inv_item_to_loc(magazine, src) //Click!
	current_mag = magazine
	if(!in_chamber) //Nothing chambered.
		if(!(flags_gun_receiver & GUN_MANUAL_CYCLE) && ( !(flags_gun_receiver & GUN_CHAMBERED_CYCLE) || user?.skills?.get_skill_level(SKILL_FIREARMS) > SKILL_FIREARMS_CIVILIAN ) )
			ready_in_chamber(user)
			play_chamber_cycle_sound(user, null, null, 0.5 SECONDS) //Delayed sound to account for loading.

	user.visible_message(SPAN_NOTICE("[user] loads [magazine] into [src]!"),
		SPAN_NOTICE("You load [magazine] into [src]!"), null, 3, CHAT_TYPE_COMBAT_ACTION)

	update_icon()

	if(magazine.icon == 'icons/obj/items/weapons/guns/ammo_by_faction/colony.dmi')
		//It may have been scattered, we need to reset these.
		magazine.pixel_x = 0
		magazine.pixel_y = 0
		magazine.icon_state = initial(magazine.icon_state) + "_vis"
		vis_contents += magazine
		to_chat(user, SPAN_WARNING("You should be seeing the magazine in vis_contents."))


	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)

//Ammo datum is now stored in_chamber, so if the magazine is ejected, the current in_chamber "bullet" is still loaded with the datum.
/obj/item/weapon/gun/proc/unload(mob/user, reload_override = 0, drop_override = 0, loc_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if( !reload_override && ( (flags_gun_toggles & GUN_BURST_FIRING) || (flags_gun_features & GUN_UNUSUAL_DESIGN) ) || (flags_gun_receiver & GUN_INTERNAL_MAG) )
		return

	if(!current_mag || QDELETED(current_mag) || (current_mag.loc != src && !loc_override))
		cycle_chamber(user)
		return

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.forceMove(get_turf(src))//Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message(SPAN_NOTICE("[user] unloads [current_mag] from [src]."),
	SPAN_NOTICE("You unload [current_mag] from [src]."), null, 4, CHAT_TYPE_COMBAT_ACTION)

	if(current_mag in vis_contents)
		vis_contents -= current_mag
		current_mag.scatter_item()
	current_mag = null
	current_mag.update_icon()


	display_ammo(user, TRUE, parent_proc = "unload()")
	update_icon()

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      CYCLING CHAMBER      	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------
//Renamed this proc. Previously was cock()
//This is for manually cycling the chamber through racking the slide, pulling the bolt, pumping a shotgun, etc.
//You can override this for unique behavior. You want to generally assign this to unique_action() if the gun category uses this proc.

/obj/item/weapon/gun/proc/cycle_chamber(mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return

	if(cycle_chamber_cooldown > world.time)
		return

	cycle_chamber_cooldown = world.time + cycle_chamber_delay

	var/sound_to_play = cocked_sound //In case jammed sound will replace it.

	if(flags_gun_receiver & GUN_CHAMBER_IS_JAMMED)
		var/skill_level = user?.skills?.get_skill_level(SKILL_FIREARMS) ? user.skills.get_skill_level(SKILL_FIREARMS) +1 : 1 //We do NOT want to divide by zero.
		to_chat(user, SPAN_NOTICE("You begin unjamming [src]. This takes a moment, hold still!")) //I don't want this to be chance based success. Skill means you take less time.
		if(!do_after(user, 2.5 SECONDS / skill_level, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
			to_chat(user, SPAN_WARNING("You were interrupted!"))
			playsound(src, "gun_jam_rack", 25, FALSE)
			return

		to_chat(user, SPAN_GREEN("You succesfully unjam \the [src]!"))
		sound_to_play = 'sound/weapons/handling/gun_jam_rack_success.ogg'
		balloon_alert(user, "*unjammed!*")

		flags_gun_receiver &= ~GUN_CHAMBER_IS_JAMMED //Not jammed anymore.

	if(in_chamber) //I could add a check for static ammo, but it wouldn't get this proc to begin with.
		user.visible_message(SPAN_NOTICE("[user] cocks [src], clearing a [in_chamber.name] from its chamber."),
		SPAN_NOTICE("You cock [src], clearing a [in_chamber.name] from its chamber."), null, 4, CHAT_TYPE_COMBAT_ACTION)
		eject_handful_to_turf(user)
		in_chamber = null
	else
		user.visible_message(SPAN_NOTICE("[user] cocks [src]."),
		SPAN_NOTICE("You cock [src]."), null, 4, CHAT_TYPE_COMBAT_ACTION)
		if(flags_gun_receiver & GUN_CHAMBER_EMPTY_CASING) make_casing(projectile_casing) //In case it was jammed with an empty shell.

	play_chamber_cycle_sound(user, sound_to_play)
	ready_in_chamber(user) //This will already check for everything else, loading the next bullet. Ironically, it can also jam the gun again, which is realistic behavior.
	display_ammo(user, TRUE, parent_proc = "cycle_chamber()")

//Specifically unloads either a chambered round or a number of rounds to the current turf, combining anything already there that can be combined.
//User can be passed as null, and defaults to the in_chamber and 1 round, for generic cycling action.
/obj/item/weapon/gun/proc/eject_handful_to_turf(mob/user, number_to_eject = 1, ammo_type = in_chamber.type)
	var/destination = user ? user.loc : get_turf(src)
	var/obj/item/ammo_magazine/handful/H

	for(H in destination)
		if(H.default_ammo == ammo_type && H.caliber == caliber && H.current_rounds < H.max_rounds) //Finds the first one and stops.
			var/rounds_transferred = min(number_to_eject, H.max_rounds - H.current_rounds) //We could have more rounds to transfer than it can support.
			H.current_rounds += rounds_transferred //Add the amount transferred.
			number_to_eject -= rounds_transferred //Subtract it.
			H.update_icon()
			break

	if(number_to_eject) //If we still have some rounds to eject.
		while(number_to_eject) //We keep making these until we have none to make.
			H = new(destination)
			number_to_eject -= H.generate_handful(ammo_type, caliber, number_to_eject)

//More gooder now.
//Plays the specified racking/cocking/cycling sound.
/obj/item/weapon/gun/proc/play_chamber_cycle_sound(mob/user, sound_to_play, volume = 25, sound_delay)
	set waitfor = 0

	sound_to_play = sound_to_play ? sound_to_play : cocked_sound // If we had an override, use it. Otherwise default to the regular cycle sound.
	if(sound_to_play) //Only play if we have a sound.
		if(sound_delay) //If the sound should be delayed. Default is no. Delayed behavior is for when something is loaded through a magazine and the gun is then auto-cocked.
			addtimer(CALLBACK(src, PROC_REF(chamber_cycle_sound), user, sound_to_play, volume), sound_delay)
		else
			chamber_cycle_sound(user, sound_to_play, volume)

/obj/item/weapon/gun/proc/chamber_cycle_sound(mob/user, sound_to_play, volume)
	playsound(user ? user : loc, sound_to_play, volume, TRUE)

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>    ABLE TO FIRE AND CHAMBERING   	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

//Do not call this through a child proc with ..(). Use check_additional_able_to_fire() for extra sanity checking. It fires in the middle of the main proc.
//This proc should return TRUE or FALSE. returning null is fine, but for clarity FALSE is preferred.
/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	if(flags_gun_toggles & GUN_BURST_FIRING)
		return TRUE
	if(user.is_mob_incapacitated())
		return FALSE
	if(world.time < guaranteed_delay_time)
		return FALSE
	if((world.time < wield_time || world.time < pull_time) && (delay_style & WEAPON_DELAY_NO_FIRE > 0))
		return FALSE//We just put the gun up. Can't do it that fast

	if(ismob(user)) //Could be an object firing the gun. They default to TRUE.
		if(!user.IsAdvancedToolUser())
			to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
			return FALSE

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(!H.allow_gun_usage)
				if(issynth(user))
					to_chat(user, SPAN_WARNING("Your programming does not allow you to use firearms."))
				else
					to_chat(user, SPAN_WARNING("You are unable to use firearms."))
				return FALSE

		if(flags_gun_toggles & GUN_TRIGGER_SAFETY_ON)
			to_chat(user, SPAN_WARNING("The safety is on!"))
			return FALSE

		if(active_attachable)
			if(active_attachable.flags_attach_features & ATTACH_PROJECTILE)
				if(!(active_attachable.flags_attach_features & ATTACH_WIELD_OVERRIDE) && !(flags_item & WIELDED))
					to_chat(user, SPAN_WARNING("You must wield [src] to fire [active_attachable]!"))
					return FALSE

		if((flags_gun_features & GUN_WIELDED_FIRING_ONLY) && !(flags_item & WIELDED) && !active_attachable) //If we're not holding the weapon with both hands when we should.
			to_chat(user, SPAN_WARNING("You need a more secure grip to fire this weapon!"))
			return FALSE

		if((flags_gun_features & GUN_WY_RESTRICTED) && !wy_allowed_check(user))
			return FALSE

		//Anything else extra the gun should check goes here.
		if(!check_additional_able_to_fire(user))
			return FALSE

		//Has to be on the bottom of the stack to prevent delay when failing to fire the weapon for the first time.
		//Can also set last_fired through New(), but honestly there's not much point to it.

		// The rest is delay-related. If we're firing full-auto it doesn't matter
		if(fa_firing)
			return TRUE

		var/next_shot = active_attachable ? active_attachable.last_fired + active_attachable.attachment_firing_delay : last_fired + fire_delay //Normal fire if not attachaed fire.

		if(world.time >= next_shot + extra_delay) //check the last time it was fired.
			extra_delay = 0
		else if(!PB_burst_bullets_fired) //Special delay exemption for handed-off PB bursts. It's the same burst, after all.
			return FALSE

		if(fire_delay_group)
			for(var/group in fire_delay_group)
				for(var/obj/item/weapon/gun/cycled_gun in user.fire_delay_next_fire)
					if(cycled_gun == src)
						continue

					for(var/cycled_gun_group in cycled_gun.fire_delay_group)
						if(group != cycled_gun_group)
							continue

						if(user.fire_delay_next_fire[cycled_gun] < world.time)
							user.fire_delay_next_fire -= cycled_gun
							continue

						return FALSE

	return TRUE

//Append this for a child object for additional, specific checking. Start with . = ..() and then return FALSE if the check fails. Can also just override if no other children call on it.
/obj/item/weapon/gun/proc/check_additional_able_to_fire(mob/user)
	return TRUE

//Return null if doesn't find anything.
/obj/item/weapon/gun/proc/load_into_chamber(mob/user)
	//If we have a round chambered and no active attachable, we're good to go.
	if(in_chamber && !active_attachable && !(flags_gun_receiver & GUN_CHAMBER_IS_STATIC)) //Static in_chamber will still process.
		return in_chamber //Already set!

	//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable)
		if(shots_fired >= 1) // This is what you'll want to remove if you want automatic underbarrel guns in the future
			SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE)
			return

		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			var/obj/projectile/bullet = create_bullet(active_attachable.ammo, initial(name))
			// For now, only bullet traits from the attachment itself will apply to its projectiles
			for(var/entry in active_attachable.traits_to_give_attached)
				var/list/L
				// Check if this is an ID'd bullet trait
				if(istext(entry))
					L = active_attachable.traits_to_give_attached[entry].Copy()
				else
					// Prepend the bullet trait to the list
					L = list(entry) + active_attachable.traits_to_give_attached[entry]
				bullet.apply_bullet_trait(L)
			return bullet
		else
			to_chat(user, SPAN_WARNING("[active_attachable] is empty!"))
			to_chat(user, SPAN_NOTICE("You disable [active_attachable]."))
			playsound(user, active_attachable.activation_sound, 15, 1)
			active_attachable.activate_attachment(src, null, TRUE)
	else if( !(flags_gun_receiver & GUN_CHAMBERED_CYCLE) ) //If we want the gun to only use in_chamber to fire, we can't allow it to load here.
		return ready_in_chamber(user)//Otherwise we try to load it as normal and return the result.

//This actually places the ammo in the chamber, through in_chamber.
//Override this for specific behavior instead of adding to it. That should make sure guns have the most compatability and run a little faster.
/obj/item/weapon/gun/proc/ready_in_chamber(mob/user)
	if(current_mag?.current_rounds) //Check for mag since it may not be present.
		current_mag.current_rounds-- //Subtract a round from the mag.
		in_chamber = GLOB.ammo_list[current_mag.default_ammo]
		return in_chamber

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>> FIRE PROJECTILE AND HANDLE FIRE <<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/proc/Fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield)
	set waitfor = FALSE

	if(!able_to_fire(user) || !target || !get_turf(user) || !get_turf(target))
		return NONE

	/*
	This is where the grenade launcher and flame thrower function as attachments.
	This is also a general check to see if the attachment can fire in the first place.
	*/
	var/check_for_attachment_fire = FALSE

	if(active_attachable?.flags_attach_features & ATTACH_WEAPON) //Attachment activated and is a weapon.
		check_for_attachment_fire = TRUE
		if(!(active_attachable.flags_attach_features & ATTACH_PROJECTILE)) //If it's unique projectile, this is where we fire it.
			if((active_attachable.current_rounds <= 0) && !(active_attachable.flags_attach_features & ATTACH_IGNORE_EMPTY))
				click_empty(user) //If it's empty, let them know.
				to_chat(user, SPAN_WARNING("[active_attachable] is empty!"))
				to_chat(user, SPAN_NOTICE("You disable [active_attachable]."))
				active_attachable.activate_attachment(src, null, TRUE)
			else
				active_attachable.fire_attachment(target, src, user) //Fire it.
				active_attachable.last_fired = world.time
			return NONE
			//If there's more to the attachment, it will be processed farther down, through in_chamber and regular bullet act.
	/*
	This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	If burst = 1, you must null it if you ever RETURN during the for() cycle. If for whatever reason burst is left on while
	the gun is not firing, it will break a lot of stuff. BREAK is fine, as it will null it.
	*/
	else if((gun_firemode == GUN_FIREMODE_BURSTFIRE) && burst_amount > BURST_AMOUNT_TIER_1)
		flags_gun_toggles |= GUN_BURST_FIRING
		if(PB_burst_bullets_fired) //Has a burst been carried over from a PB?
			PB_burst_bullets_fired = 0 //Don't need this anymore. The torch is passed.

	var/fired_by_akimbo = dual_wield ? TRUE : FALSE

	//Dual wielding. Do we have a gun in the other hand and is it the same category?
	var/obj/item/weapon/gun/akimbo = user.get_inactive_hand()
	if(!reflex && !dual_wield && user)
		if(istype(akimbo) && akimbo.gun_category == gun_category && !(akimbo.flags_gun_features & GUN_WIELDED_FIRING_ONLY))
			dual_wield = TRUE //increases recoil, increases scatter, and reduces accuracy.

	var/fire_return = handle_fire(target, user, params, reflex, dual_wield, check_for_attachment_fire, akimbo, fired_by_akimbo)
	if(!fire_return)
		return fire_return

	flags_gun_toggles &= ~GUN_BURST_FIRING // We always want to turn off bursting when we're done, mainly for when we break early mid-burstfire.

	return AUTOFIRE_CONTINUE

/obj/item/weapon/gun/proc/handle_fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield, check_for_attachment_fire, akimbo, fired_by_akimbo)
	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)

	var/atom/original_target = target //This is for burst mode, in case the target changes per scatter chance in between fired bullets.

	if(loc != user || (flags_gun_features & GUN_WIELDED_FIRING_ONLY && !(flags_item & WIELDED)))
		return TRUE

	if(!load_into_chamber(user)) //Load an ammo datum or check for existing one.
		click_empty(user)
		flags_gun_toggles &= ~GUN_BURST_FIRING
		return NONE

	//Unlike the previous iteration of the system, here we make a projectile when the gun actually fires.
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	var/obj/projectile/projectile_to_fire = create_bullet(in_chamber, initial(name))
	apply_traits(projectile_to_fire)
	apply_bullet_effects(projectile_to_fire, user, reflex, dual_wield) //User can be passed as null.
	SEND_SIGNAL(projectile_to_fire, COMSIG_BULLET_USER_EFFECTS, user)
	//===================================================================================================

	curloc = get_turf(user)
	if(QDELETED(original_target)) //If the target's destroyed, shoot at where it was last.
		target = targloc
	else
		target = original_target
		targloc = get_turf(target)

	projectile_to_fire.original = target

	// turf-targeted projectiles are fired without scatter, because proc would raytrace them further away
	var/ammo_flags = projectile_to_fire.ammo.flags_ammo_behavior | projectile_to_fire.projectile_override_flags
	if(!(ammo_flags & AMMO_HITS_TARGET_TURF))
		target = simulate_scatter(projectile_to_fire, target, curloc, targloc, user)

	var/bullet_velocity = projectile_to_fire?.ammo?.shell_speed + velocity_add

	if(params) // Apply relative clicked position from the mouse info to offset projectile
		if(!params["click_catcher"])
			if(params["vis-x"])
				projectile_to_fire.p_x = text2num(params["vis-x"])
			else if(params["icon-x"])
				projectile_to_fire.p_x = text2num(params["icon-x"])
			if(params["vis-y"])
				projectile_to_fire.p_y = text2num(params["vis-y"])
			else if(params["icon-y"])
				projectile_to_fire.p_y = text2num(params["icon-y"])
			var/atom/movable/clicked_target = original_target
			if(istype(clicked_target))
				projectile_to_fire.p_x -= clicked_target.bound_width / 2
				projectile_to_fire.p_y -= clicked_target.bound_height / 2
			else
				projectile_to_fire.p_x -= world.icon_size / 2
				projectile_to_fire.p_y -= world.icon_size / 2
		else
			projectile_to_fire.p_x -= world.icon_size / 2
			projectile_to_fire.p_y -= world.icon_size / 2

	if(targloc != curloc)
		simulate_recoil(dual_wield, user, target)

		//This is where the projectile leaves the barrel and deals with projectile code only.
		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		INVOKE_ASYNC(projectile_to_fire, TYPE_PROC_REF(/obj/projectile, fire_at), target, user, src, projectile_to_fire?.ammo?.max_range, bullet_velocity, original_target)
		//IMPORTANT NOTE: we want to null this variable only if in_chamber is not static, and only here. If the system is working correctly, we won't have to reset it again.
		if( !(flags_gun_receiver & GUN_CHAMBER_IS_STATIC) ) in_chamber = null
		// IMPORTANT NOTE: firing might have made projectile collide early and ALREADY have deleted it. We clear it too.
		projectile_to_fire = null
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		if(check_for_attachment_fire)
			active_attachable.last_fired = world.time
		else
			last_fired = world.time
			var/delay_left = (last_fired + fire_delay + additional_fire_group_delay) - world.time
			if(fire_delay_group && delay_left > 0)
				LAZYSET(user.fire_delay_next_fire, src, world.time + delay_left)
		SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src)
		. = TRUE

		shots_fired++

		if(dual_wield && !fired_by_akimbo)
			switch(user?.client?.prefs?.dual_wield_pref)
				if(DUAL_WIELD_FIRE)
					INVOKE_ASYNC(akimbo, PROC_REF(Fire), target, user, params, 0, TRUE)
				if(DUAL_WIELD_SWAP)
					user.swap_hand()

	else //If ended up not firing anything, we need to clean up the created projectile.
		qdel(projectile_to_fire)
		to_chat(user, "Fired at yourself. Dummy.")
		log_debug("Projectile malfunctioned while firing. User: <b>[user]</b> Weapon: <b>[src]</b> Magazine: <b>[current_mag]</b>")
		return TRUE

	//>>POST PROCESSING AND CLEANUP BEGIN HERE.<<
	var/angle = round(Get_Angle(user,target)) //Let's do a muzzle flash.
	muzzle_flash(angle,user)

	//This is where we load the next bullet in the chamber. We check for attachments too, since we don't want to load anything if an attachment is active.
	if(!check_for_attachment_fire && !reload_into_chamber(user)) // It has to return a bullet, otherwise it's empty. Unless it's an undershotgun.
		click_empty(user)
		return TRUE //Nothing else to do here, time to cancel out.
	return TRUE

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>   POINTBLANKING AND ATTACK   	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

#define EXECUTION_CHECK (attacked_mob.stat == UNCONSCIOUS || attacked_mob.is_mob_restrained()) && ((user.a_intent == INTENT_GRAB)||(user.a_intent == INTENT_DISARM))

/obj/item/weapon/gun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FALSE

	if(active_attachable && (active_attachable.flags_attach_features & ATTACH_MELEE))
		active_attachable.last_fired = world.time
		active_attachable.fire_attachment(target, src, user)
		return TRUE

//This is a maze of code.
/obj/item/weapon/gun/attack(mob/living/attacked_mob, mob/living/user, dual_wield)
	if(active_attachable && (active_attachable.flags_attach_features & ATTACH_MELEE)) //this is expected to do something in melee.
		active_attachable.last_fired = world.time
		active_attachable.fire_attachment(attacked_mob, src, user)
		return TRUE

	if(!(flags_gun_features & GUN_CAN_POINTBLANK)) // If it can't point blank, you can't suicide and such.
		return ..()

	if(attacked_mob == user && user.zone_selected == "mouth" && ishuman(user))
		var/mob/living/carbon/human/HM = user
		if(!able_to_fire(user))
			return TRUE

		var/ffl = " [ADMIN_JMP(user)] [ADMIN_PM(user)]"

		var/obj/item/weapon/gun/revolver/current_revolver = src
		if(istype(current_revolver) && current_revolver.russian_roulette)
			attacked_mob.visible_message(SPAN_WARNING("[user] puts their revolver to their head, ready to pull the trigger."))
		else
			attacked_mob.visible_message(SPAN_WARNING("[user] sticks their gun in their mouth, ready to pull the trigger."))

		flags_gun_features ^= GUN_CAN_POINTBLANK //If they try to click again, they're going to hit themselves.
		if(!do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE) || !able_to_fire(user))
			attacked_mob.visible_message(SPAN_NOTICE("[user] decided life was worth living."))
			flags_gun_features ^= GUN_CAN_POINTBLANK //Reset this.
			return TRUE

		if(active_attachable && !(active_attachable.flags_attach_features & ATTACH_PROJECTILE))
			active_attachable.activate_attachment(src, null, TRUE)//We're not firing off a nade into our mouth.

		if(load_into_chamber(user)) //We actually have an ammo datum to fire. Make a projectile.
			//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
			var/obj/projectile/projectile_to_fire = create_bullet(in_chamber, initial(name))
			apply_traits(projectile_to_fire)
			if( !(flags_gun_receiver & GUN_CHAMBER_IS_STATIC) ) in_chamber = null
			//No bullet effects.
			//===================================================================================================

			user.visible_message(SPAN_WARNING("[user] pulls the trigger!"))

			play_fire_sound(projectile_to_fire, user)

			simulate_recoil(2, user)
			var/t
			var/datum/cause_data/cause_data
			if(projectile_to_fire.ammo.damage == 0)
				t += "\[[time_stamp()]\] <b>[key_name(user)]</b> tried to commit suicide with a [name]"
				cause_data = create_cause_data("failed suicide by [initial(name)]")
				to_chat(user, SPAN_DANGER("Ow..."))
				msg_admin_ff("[key_name(user)] tried to commit suicide with a [name] in [get_area(user)] [ffl]")
				user.apply_damage(200, HALLOSS)
			else
				t += "\[[time_stamp()]\] <b>[key_name(user)]</b> committed suicide with <b>[src]</b>" //Log it.
				cause_data = create_cause_data("suicide by [initial(name)]")
				if(istype(current_revolver) && current_revolver.russian_roulette) //If it's a revolver set to Russian Roulette.
					t += " after playing Russian Roulette"
					HM.apply_damage(projectile_to_fire.damage * 3, projectile_to_fire.ammo.damage_type, "head", used_weapon = "An unlucky pull of the trigger during Russian Roulette!", no_limb_loss = TRUE, permanent_kill = TRUE)
					HM.apply_damage(200, OXY) //Fill out the rest of their healthbar.
					HM.death(create_cause_data("russian roulette with \a [name]", user)) //Make sure they're dead. permanent_kill above will make them unrevivable.
					HM.update_headshot_overlay(projectile_to_fire.ammo.headshot_state) //Add headshot overlay.
					msg_admin_ff("[key_name(user)] lost at Russian Roulette with \a [name] in [get_area(user)] [ffl]")
					to_chat(user, SPAN_HIGHDANGER("Your life flashes before you as your spirit is torn from your body!"))
					user.ghostize(0) //No return.
				else
					HM.apply_damage(projectile_to_fire.damage * 2.5, projectile_to_fire.ammo.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [projectile_to_fire]", no_limb_loss = TRUE, permanent_kill = TRUE)
					HM.apply_damage(200, OXY) //Fill out the rest of their healthbar.
					HM.death(cause_data) //Make sure they're dead. permanent_kill above will make them unrevivable.
					HM.update_headshot_overlay(projectile_to_fire.ammo.headshot_state) //Add headshot overlay.
					msg_admin_ff("[key_name(user)] committed suicide with \a [name] in [get_area(user)] [ffl]")
			attacked_mob.last_damage_data = cause_data
			user.attack_log += t //Apply the attack log.
			last_fired = world.time //This is incorrect if firing an attached undershotgun, but the user is too dead to care.
			SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src)

			projectile_to_fire.play_hit_effect(user)
			// No projectile code to handhold us, we do the cleaning ourselves:
			QDEL_NULL(projectile_to_fire)

			reload_into_chamber(user) //Reload the sucker.
		else
			click_empty(user)//If there's no projectile, we can't do much.
			if(istype(current_revolver) && current_revolver.russian_roulette && current_revolver.current_mag && current_revolver.current_mag.current_rounds)
				msg_admin_niche("[key_name(user)] played live Russian Roulette with \a [name] in [get_area(user)] [ffl]") //someone might want to know anyway...

		flags_gun_features ^= GUN_CAN_POINTBLANK //Reset this.
		return TRUE

	if(EXECUTION_CHECK) //Execution
		if(!able_to_fire(user)) //Can they actually use guns in the first place?
			return ..()
		user.visible_message(SPAN_DANGER("[user] puts [src] up to [attacked_mob], steadying their aim."), SPAN_WARNING("You put [src] up to [attacked_mob], steadying your aim."),null, null, CHAT_TYPE_COMBAT_ACTION)
		if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|INTERRUPT_DIFF_INTENT, BUSY_ICON_HOSTILE))
			return TRUE
	else if(user.a_intent != INTENT_HARM) //Thwack them
		return ..()

	if(MODE_HAS_TOGGLEABLE_FLAG(MODE_NO_ATTACK_DEAD) && attacked_mob.stat == DEAD) // don't shoot dead people
		return afterattack(attacked_mob, user, TRUE)

	user.next_move = world.time //No click delay on PBs.

	//Point blanking doesn't actually fire the projectile. Instead, it simulates firing the bullet proper.
	if(!able_to_fire(user)) //If it's a valid PB aside from that you can't fire the gun, do nothing.
		return TRUE

	//The following relating to bursts was borrowed from Fire code.
	var/check_for_attachment_fire = FALSE
	if(active_attachable)
		if(active_attachable.flags_attach_features & ATTACH_PROJECTILE)
			check_for_attachment_fire = TRUE
		else
			active_attachable.activate_attachment(src, null, TRUE)//No way.

	var/fired_by_akimbo = FALSE
	if(dual_wield)
		fired_by_akimbo = TRUE

	//Dual wielding. Do we have a gun in the other hand and is it the same category?
	var/obj/item/weapon/gun/akimbo = user.get_inactive_hand()
	if(!dual_wield && user)
		if(istype(akimbo) && akimbo.gun_category == gun_category && !(akimbo.flags_gun_features & GUN_WIELDED_FIRING_ONLY))
			dual_wield = TRUE //increases recoil, increases scatter, and reduces accuracy.

	var/bullets_to_fire = 1

	if(!check_for_attachment_fire && (gun_firemode == GUN_FIREMODE_BURSTFIRE) && burst_amount > BURST_AMOUNT_TIER_1)
		bullets_to_fire = burst_amount
		flags_gun_toggles |= GUN_BURST_FIRING

	var/bullets_fired
	for(bullets_fired = 1 to bullets_to_fire)
		if(loc != user || (flags_gun_features & GUN_WIELDED_FIRING_ONLY && !(flags_item & WIELDED)))
			break //If you drop it while bursting, for example.

		if (bullets_fired > 1 && !(flags_gun_toggles & GUN_BURST_FIRING)) // No longer burst firing somehow
			break

		if(QDELETED(attacked_mob)) //Target deceased.
			break

		var/obj/projectile/projectile_to_fire
		if(load_into_chamber(user)) //We actually have an ammo datum to fire. Make a projectile.
			//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
			projectile_to_fire = create_bullet(in_chamber, initial(name))
			apply_traits(projectile_to_fire)
			if( !(flags_gun_receiver & GUN_CHAMBER_IS_STATIC) ) in_chamber = null
			//No bullet effects.
			//===================================================================================================
		else
			click_empty(user)
			break

		if(SEND_SIGNAL(projectile_to_fire.ammo, COMSIG_AMMO_POINT_BLANK, attacked_mob, projectile_to_fire, user, src) & COMPONENT_CANCEL_AMMO_POINT_BLANK)
			flags_gun_toggles &= ~GUN_BURST_FIRING
			return TRUE

		//We actually have a projectile, let's move on. We're going to simulate the fire cycle.
		if(projectile_to_fire.ammo.on_pointblank(attacked_mob, projectile_to_fire, user, src))
			flags_gun_toggles &= ~GUN_BURST_FIRING
			return TRUE

		var/damage_buff = BULLET_DAMAGE_MULT_BASE
		//if target is lying or unconscious - add damage bonus
		if(!(attacked_mob.mobility_flags & MOBILITY_STAND) || attacked_mob.stat == UNCONSCIOUS)
			damage_buff += BULLET_DAMAGE_MULT_TIER_4
		projectile_to_fire.damage *= damage_buff //Multiply the damage for point blank.
		if(bullets_fired == 1) //First shot gives the PB message.
			user.visible_message(SPAN_DANGER("[user] fires [src] point blank at [attacked_mob]!"),
				SPAN_WARNING("You fire [src] point blank at [attacked_mob]!"), null, null, CHAT_TYPE_WEAPON_USE)

		user.track_shot(initial(name))
		apply_bullet_effects(projectile_to_fire, user, bullets_fired, dual_wield) //We add any damage effects that we need.

		SEND_SIGNAL(projectile_to_fire, COMSIG_BULLET_USER_EFFECTS, user)
		SEND_SIGNAL(user, COMSIG_BULLET_DIRECT_HIT, attacked_mob)
		simulate_recoil(1, user)

		if(projectile_to_fire.ammo.bonus_projectiles_amount)
			var/obj/projectile/BP
			for(var/i in 1 to projectile_to_fire.ammo.bonus_projectiles_amount)
				BP = new /obj/projectile(attacked_mob.loc, create_cause_data(initial(name), user))
				BP.generate_bullet(GLOB.ammo_list[projectile_to_fire.ammo.bonus_projectiles_type], 0, NO_FLAGS)
				BP.accuracy = round(BP.accuracy * projectile_to_fire.accuracy/initial(projectile_to_fire.accuracy)) //Modifies accuracy of pellets per fire_bonus_projectiles.
				BP.damage *= damage_buff
				projectile_to_fire.give_bullet_traits(BP)
				if(bullets_fired > 1)
					BP.original = attacked_mob //original == the original target of the projectile. If the target is downed and this isn't set, the projectile will try to fly over it. Of course, it isn't going anywhere, but it's the principle of the thing. Very embarrassing.
					if(!BP.handle_mob(attacked_mob) && attacked_mob.body_position == LYING_DOWN) //This is the 'handle impact' proc for a flying projectile, including hit RNG, on_hit_mob and bullet_act. If it misses, it doesn't go anywhere. We'll pretend it slams into the ground or punches a hole in the ceiling, because trying to make it bypass the xeno or shoot from the tile beyond it is probably more spaghet than my life is worth.
						if(BP.ammo.sound_bounce)
							playsound(attacked_mob.loc, BP.ammo.sound_bounce, 35, 1)
						attacked_mob.visible_message(SPAN_AVOIDHARM("[BP] slams into [get_turf(attacked_mob)]!"), //Managing to miss an immobile target flat on the ground deserves some recognition, don't you think?
							SPAN_AVOIDHARM("[BP] narrowly misses you!"), null, 4, CHAT_TYPE_TAKING_HIT)
				else
					BP.ammo.on_hit_mob(attacked_mob, BP, user)
					BP.def_zone = user.zone_selected
					attacked_mob.bullet_act(BP)
				qdel(BP)

		if(bullets_fired > 1)
			projectile_to_fire.original = attacked_mob
			if(!projectile_to_fire.handle_mob(attacked_mob) && attacked_mob.body_position == LYING_DOWN)
				if(projectile_to_fire.ammo.sound_bounce)
					playsound(attacked_mob.loc, projectile_to_fire.ammo.sound_bounce, 35, 1)
				attacked_mob.visible_message(SPAN_AVOIDHARM("[projectile_to_fire] slams into [get_turf(attacked_mob)]!"),
					SPAN_AVOIDHARM("[projectile_to_fire] narrowly misses you!"), null, 4, CHAT_TYPE_TAKING_HIT)
		else
			projectile_to_fire.ammo.on_hit_mob(attacked_mob, projectile_to_fire, user)
			attacked_mob.bullet_act(projectile_to_fire)

		if(check_for_attachment_fire)
			active_attachable.last_fired = world.time
		else
			last_fired = world.time
			var/delay_left = (last_fired + fire_delay + additional_fire_group_delay) - world.time
			if(fire_delay_group && delay_left > 0)
				LAZYSET(user.fire_delay_next_fire, src, world.time + delay_left)

		SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src)

		if(dual_wield && !fired_by_akimbo)
			switch(user?.client?.prefs?.dual_wield_pref)
				if(DUAL_WIELD_FIRE)
					INVOKE_ASYNC(akimbo, PROC_REF(attack), attacked_mob, user, TRUE)
				if(DUAL_WIELD_SWAP)
					user.swap_hand()

		if(EXECUTION_CHECK) //Continue execution if on the correct intent. Accounts for change via the earlier do_after
			user.visible_message(SPAN_DANGER("[user] has executed [attacked_mob] with [src]!"), SPAN_DANGER("You have executed [attacked_mob] with [src]!"), message_flags = CHAT_TYPE_WEAPON_USE)
			attacked_mob.death()
			bullets_to_fire = bullets_fired //Giant bursts are not compatible with precision killshots.
		// No projectile code to handhold us, we do the cleaning ourselves:
		QDEL_NULL(projectile_to_fire)

		//This is where we load the next bullet in the chamber. We check for attachments too, since we don't want to load anything if an attachment is active.
		if(!check_for_attachment_fire && !reload_into_chamber(user)) // It has to return a bullet, otherwise it's empty. Unless it's an undershotgun.
			click_empty(user)
			break //Nothing else to do here, time to cancel out.

		if(bullets_fired < bullets_to_fire) // We still have some bullets to fire.
			extra_delay = fire_delay * 0.5
			sleep(burst_delay)
			if(get_dist(user, attacked_mob) > 1) //We can each move around while burst-PBing, but if we get too far from the target, we'll have to shoot at them normally.
				PB_burst_bullets_fired = bullets_fired
				break

	flags_gun_toggles &= ~GUN_BURST_FIRING

	if(PB_burst_bullets_fired)
		Fire(get_turf(attacked_mob), user, reflex = TRUE) //Reflex prevents dual-wielding.

	return TRUE

#undef EXECUTION_CHECK

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	    RELOADING INTO CHAMBER     	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

#define MALFUNCTION_BULLET 1
#define MALFUNCTION_CASING 2

//What happens after the gun is fired.
/obj/item/weapon/gun/proc/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable) //We don't need to check for the mag if an attachment was used to shoot.
		make_casing(active_attachable.projectile_casing) // Attachables can drop their own casings.

	else

		if(flags_gun_receiver & GUN_INTERNAL_MAG) current_mag.used_casings++ //Internal mags will accumulate casings if the next check doesn't dump them all out. We'll get this out of the way before checking jams.

		//If the gun fired, we will need to add a bit of jam chance. The more rounds, the higher it gets. Disabled for now.
		//malfunction_chance_mod += prob(35) ? GUN_MALFUNCTION_CHANCE_VERY_LOW : 0

		//Let's find out if the gun jams before we proceed. We need to simulate whether it's a jammed bullet from a new cycle or jammed casing from the last cycle.
		if(user && prob((malfunction_chance_base + malfunction_chance_mod + (current_mag ? current_mag.malfunction_chance_added : 0) )) )  //Requires a user present to jam. Objects firing guns won't jam.
			var/simulate_gun_jam = NONE

			switch(pick(35; MALFUNCTION_BULLET,65; MALFUNCTION_CASING)) //This just checks what we try first. Casing jams are more common.
				if(MALFUNCTION_BULLET)
					if(ready_in_chamber(user)) //If we don't find a bullet we'll try the casing method.
						simulate_gun_jam = MALFUNCTION_CASING
					else if(projectile_casing)
						flags_gun_receiver |= GUN_CHAMBER_EMPTY_CASING
						simulate_gun_jam = MALFUNCTION_CASING

				if(MALFUNCTION_CASING)
					if(projectile_casing) //Casings are easy to deal with.
						flags_gun_receiver |= GUN_CHAMBER_EMPTY_CASING
						simulate_gun_jam = MALFUNCTION_CASING
					else if(ready_in_chamber(user))
						simulate_gun_jam = MALFUNCTION_CASING

			if(simulate_gun_jam)//Still jammed? If all checks fail, the gun won't malfunction.
				SEND_SIGNAL(src, COMSIG_GUN_INTERRUPT_FIRE) //Interrupt any sort of burst or whatever.
				if(simulate_gun_jam != MALFUNCTION_CASING && !(flags_gun_receiver & GUN_MANUAL_CYCLE)) //If the casings didn't jam, we'll try to eject it as normal.
					make_casing(projectile_casing)
				flags_gun_toggles &= ~GUN_BURST_FIRING
				flags_gun_receiver |= GUN_CHAMBER_IS_JAMMED
				playsound(src, 'sound/weapons/handling/gun_jam_initial_click.ogg', 25, FALSE)
				user.visible_message(SPAN_DANGER("[src] makes a noticeable clicking noise!"), SPAN_HIGHDANGER("\The [src] suddenly jams and refuses to fire! Use Unique-Action to unjam it!"))
				balloon_alert(user, "*jammed*")

				display_ammo(user, parent_proc = "reload_into_chamber()")
				return FALSE //End the proc early. If there's an auto ejector or whatever, it won't work with a malfunction.

		if(!(flags_gun_receiver & GUN_MANUAL_CYCLE)) make_casing(projectile_casing) //If you manually cycle, you will drop the casing next cock/whatever it uses instead.
		else return TRUE //If the gun cycles manually, we end early.

		if(current_mag) //If there is no mag, we can't reload.
			if(!(flags_gun_receiver & GUN_MANUAL_CYCLE)) ready_in_chamber(user) //If the weapon requires manual cocking each fire cycle, we don't prepare the next bullet to fire.

			// This is where the magazine is auto-ejected
			if(current_mag.current_rounds <= 0 && flags_gun_features & GUN_AUTO_EJECTOR && !(flags_gun_toggles & GUN_AUTO_EJECTING_OFF))
				if (user.client?.prefs && (user.client?.prefs?.toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_OFF))
					update_icon()
				else if (!(flags_gun_toggles & GUN_BURST_FIRING) || !in_chamber) // Magazine will only unload once burstfire is over
					var/drop_to_ground = TRUE
					if (user.client?.prefs && (user.client?.prefs?.toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND))
						drop_to_ground = FALSE
						unwield(user)
						user.swap_hand()
					unload(user, TRUE, drop_to_ground) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
					playsound(src, empty_sound, 25, 1)
		else // Just fired a chambered bullet with no magazine in the gun
			update_icon()

		display_ammo(user, parent_proc = "reload_into_chamber()")

	return in_chamber //Returns an ammo datum if it's actually successful.

#undef MALFUNCTION_BULLET
#undef MALFUNCTION_CASING

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	       AMMO COUNTER       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

//This is only a visual effect, it does nothing by itself.
/obj/effect/digital_counter
	icon = 'icons/obj/items/weapons/guns/attachments/ammo_counter.dmi'
	icon_state = "counter"
	mouse_opacity = 0 //Can still click on the hud.
	pixel_y = 3
	layer = ABOVE_HUD_LAYER + 0.01 //Wonky. Certain hud elements are drawn on ABOVE_HUD_LAYER instead of HUD_LAYER, leading to some layering issues. Properly reworking hud is preferred.
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART //We don't want these to be changed by the parent.

	maptext_x = 10 //These offsets work to center the text on the counter. It will be pixel perfect if everything is set up correctly.
	maptext_y = 24

//The ammo counter is not held in contents. Doesn't really need to be, it's referenced twice already.
/obj/item/weapon/gun/proc/create_ammo_counter()
	if(!ammo_counter)//We could already have one.
		if(GLOB.ammo_counters_pool.len) //Let's see if the global list has some stored.
			ammo_counter = GLOB.ammo_counters_pool[1] //Take the first one.
			GLOB.ammo_counters_pool -= ammo_counter //Remove the one taken.
		else
			ammo_counter = new //If the list contains nothing, generate a new one.
	return ammo_counter

/obj/item/weapon/gun/proc/remove_ammo_counter()
	if(ammo_counter) //Only if it has an active ammo_counter. Doesn't matter if it's got the flag set or not.
		vis_contents -= ammo_counter //This counts as a reference.
		if(GLOB.ammo_counters_pool.len < AMMO_COUNTER_OBJ_POOL_MAX) GLOB.ammo_counters_pool += ammo_counter
		ammo_counter = null //Another reference. Native garbage collection should take care of the object since it has no more references.

//Displays ammo dynamically. This is found in reloading, unloading, and similar procs. During the fire cycle you want it to run in reload_into_chamber().
//Otherwise the check should be present when loading, unloading, and cycling the chamber.
//The ammo counter is attached to the gun itself, it's a visual effect only.
/obj/item/weapon/gun/proc/display_ammo(mob/user, override = FALSE, parent_proc = "NOTHING", ammo_remaining_override)
	//Removed the chat message as it was superfluous with functional counters and also crammed the chat.

	// Do not display ammo if you have an attachment currently activated unless override is active.
	if(active_attachable && !override) //The override is when we either eject the mag or reload it or manually cock the gun.
		return //Potentially not care about this at all since guns won't get to this proc in the cycle. Comment out and test later.
		//Currently override is set to everything but the fire cycle itself.

	user.visible_message(SPAN_NOTICE("DEBUG: TRIGGERED AMMO COUNTER CALL! Parent proc is: [parent_proc]"))

	//Very light weight.
	if(flags_gun_features & GUN_AMMO_COUNTER)
		var/total_ammo_remaining = min( ammo_remaining_override ? ammo_remaining_override  :  (current_mag ? current_mag.current_rounds : 0) + (in_chamber ? 1 : 0) , 999)
		ammo_counter.maptext = {"<span style= 'font-size:6px;font-family:DigitalCounter;color: red'>[total_ammo_remaining < 10 ? "00" : (total_ammo_remaining < 100 ? "0" : null)][total_ammo_remaining]</span>"}
		user.visible_message(SPAN_NOTICE("DEBUG: Pool is now:: [GLOB.ammo_counters_pool.len] item\s"))

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      MAKING CASINGS       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

//Since reloading and casings are closely related, placing this here, the sequel. ~N
/obj/item/weapon/gun/proc/make_casing(casing_type) //Handle casings is set to discard them.
	var/num_of_casings = 1 //Defaults to 1.
	if(flags_gun_receiver & GUN_INTERNAL_MAG)
		num_of_casings = current_mag.used_casings //Set it to whatever the internal mag is showing, could be zero.
		current_mag.used_casings = 0 //Reset it.

	if(num_of_casings && casing_type) //If we have casings to make and we have a casing type.
		var/sound_to_play
		switch(casing_type)
			if(PROJECTILE_CASING_SHELL, PROJECTILE_CASING_TWOBORE) sound_to_play = 'sound/weapons/bulletcasing_shotgun_fall.ogg'
			else sound_to_play = pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')
		var/turf/current_turf = get_turf(src)
		var/new_casing = text2path("/obj/item/ammo_casing/[casing_type]")
		var/obj/item/ammo_casing/casing = locate(new_casing) in current_turf
		if(!casing) //No casing on the ground?
			casing = new new_casing(current_turf)
			num_of_casings--
			playsound(current_turf, sound_to_play, rand(15,20), TRUE, 5)
		if(num_of_casings) //Still have some.
			casing.current_casings += num_of_casings
			casing.update_icon()
			playsound(current_turf, sound_to_play, rand(15,20), TRUE, 5) //Played again if necessary.

		flags_gun_receiver &= ~GUN_CHAMBER_EMPTY_CASING //In case it was jammed with a casing, or has this casing set manually, we empty it out.

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	  CREATING BULLET AND EFFECTS  	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/proc/create_bullet(datum/ammo/chambered, bullet_source)
	if(!istype(chambered))
		to_chat(usr, "Something has gone horribly wrong. Ahelp the following: ERROR CODE I2: null ammo or wrong type while create_bullet()")
		log_debug("ERROR CODE I2: null ammo while create_bullet(). User: <b>[usr]</b> Weapon: <b>[src]</b> Magazine: <b>[current_mag]</b>")
		chambered = GLOB.ammo_list[/datum/ammo/bullet] //Slap on a default bullet if somehow ammo wasn't passed.

	var/weapon_source_mob = isliving(loc) ? loc : null

	var/obj/projectile/P = new projectile_type(src, create_cause_data(bullet_source, weapon_source_mob))
	P.generate_bullet(chambered, 0, NO_FLAGS)

	return P

/obj/item/weapon/gun/proc/apply_traits(obj/projectile/P)
	// Apply bullet traits from gun
	var/list/L
	for(var/entry in traits_to_give)
		// Check if this is an ID'd bullet trait
		if(istext(entry))
			L = traits_to_give[entry].Copy()
		else
			// Prepend the bullet trait to the list
			L = list(entry) + traits_to_give[entry]
		P.apply_bullet_trait(L)

	// Apply bullet traits from attachments
	var/obj/item/attachable/AT
	for(var/slot in attachments)
		if(!attachments[slot])
			continue

		AT = attachments[slot]
		for(var/entry in AT.traits_to_give)
			// Check if this is an ID'd bullet trait
			if(istext(entry))
				L = AT.traits_to_give[entry].Copy()
			else
				// Prepend the bullet trait to the list
				L = list(entry) + AT.traits_to_give[entry]
			P.apply_bullet_trait(L)

//This proc applies some bonus effects to the shot/makes the message when a bullet is actually fired.
/obj/item/weapon/gun/proc/apply_bullet_effects(obj/projectile/projectile_to_fire, mob/user, reflex = 0, dual_wield = 0)

	var/gun_accuracy_mult = accuracy_mult_unwielded
	var/gun_scatter = scatter_unwielded

	if(flags_item & WIELDED || flags_gun_features & GUN_ONE_HAND_WIELDED)
		gun_accuracy_mult = accuracy_mult
		gun_scatter = scatter
	else if(user && world.time - user.l_move_time < 5) //moved during the last half second
		//accuracy and scatter penalty if the user fires unwielded right after moving
		gun_accuracy_mult = max(0.1, gun_accuracy_mult - max(0,movement_onehanded_acc_penalty_mult * HIT_ACCURACY_MULT_TIER_3))
		gun_scatter += max(0, movement_onehanded_acc_penalty_mult * SCATTER_AMOUNT_TIER_10)

	if(dual_wield) //akimbo firing gives terrible accuracy
		gun_accuracy_mult = max(0.1, gun_accuracy_mult - 0.1*rand(5,7))
		gun_scatter += SCATTER_AMOUNT_TIER_3

	if(user)
		//Putting this here for fewer checks. Very ugly.
		projectile_to_fire.firer = user
		if(isliving(user)) projectile_to_fire.def_zone = user.zone_selected
		play_fire_sound(projectile_to_fire, user)

		// Apply any skill-based bonuses to accuracy
		if(user.mind && user.skills)
			var/skill_accuracy = user.skills.get_skill_level(SKILL_FIREARMS)
			skill_accuracy = ( skill_accuracy == SKILL_FIREARMS_CIVILIAN && !is_civilian_usable(user) ) ? -1 : skill_accuracy //Default to either -1 if they are unskilled or skill level.
			if(skill_accuracy) //If it's non-zero. Firearms 1 is still 1 * HIT_ACCURACY_MULT_TIER_3
				gun_accuracy_mult += skill_accuracy * HIT_ACCURACY_MULT_TIER_3 // Accuracy mult increase/decrease per level is equal to attaching/removing a red dot sight

	projectile_to_fire.accuracy = round(projectile_to_fire.accuracy * gun_accuracy_mult) // Apply gun accuracy multiplier to projectile accuracy
	projectile_to_fire.scatter += gun_scatter

	if(wield_delay > 0 && (world.time < wield_time || world.time < pull_time))
		var/old_time = max(wield_time, pull_time) - wield_delay
		var/new_time = world.time
		var/pct_settled = 1 - (new_time-old_time + 1)/wield_delay
		if(delay_style & WEAPON_DELAY_ACCURACY)
			var/accuracy_debuff = 1 + (SETTLE_ACCURACY_MULTIPLIER - 1) * pct_settled
			projectile_to_fire.accuracy /=accuracy_debuff
		if(delay_style & WEAPON_DELAY_SCATTER)
			var/scatter_debuff = 1 + (SETTLE_SCATTER_MULTIPLIER - 1) * pct_settled
			projectile_to_fire.scatter *= scatter_debuff

	projectile_to_fire.damage = round(projectile_to_fire.damage * damage_mult) // Apply gun damage multiplier to projectile damage

	// Apply effective range and falloffs/buildups
	projectile_to_fire.damage_falloff = damage_falloff_mult * projectile_to_fire.ammo.damage_falloff
	projectile_to_fire.damage_buildup = damage_buildup_mult * projectile_to_fire.ammo.damage_buildup

	projectile_to_fire.effective_range_min = effective_range_min + projectile_to_fire.ammo.effective_range_min //Add on ammo-level value, if specified.
	projectile_to_fire.effective_range_max = effective_range_max + projectile_to_fire.ammo.effective_range_max //Add on ammo-level value, if specified.

	projectile_to_fire.shot_from = src

	return TRUE

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	      SCATTER AND RECOIL       	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/proc/simulate_scatter(obj/projectile/projectile_to_fire, atom/target, turf/curloc, turf/targloc, mob/user, bullets_fired = 1)
	var/fire_angle = Get_Angle(curloc, targloc)
	var/total_scatter_angle = projectile_to_fire.scatter

	switch(gun_firemode) //Cannot have burst and auto active at the same time.
		if((GUN_FIREMODE_BURSTFIRE))//Much higher scatter on burst. Each additional bullet adds scatter
			var/bullet_amt_scat = min(burst_amount - 1, SCATTER_AMOUNT_TIER_6)//capped so we don't penalize large bursts too much.
			total_scatter_angle += max(0, (flags_item & WIELDED ? bullet_amt_scat : 2 * bullet_amt_scat)  * burst_scatter_mult)

		// Full auto fucks your scatter up big time
		// Note that full auto uses burst scatter multipliers
		if(GUN_FIREMODE_AUTOMATIC)
			// The longer you fire full-auto, the worse the scatter gets
			var/bullet_amt_scat = min((shots_fired / fa_scatter_peak) * fa_max_scatter, fa_max_scatter)
			total_scatter_angle += max(0, (flags_item & WIELDED ? bullet_amt_scat : 2 * bullet_amt_scat)  * burst_scatter_mult)

	if(user && user.mind && user.skills)
		if(user?.skills?.get_skill_level(SKILL_FIREARMS) == SKILL_FIREARMS_CIVILIAN && !is_civilian_usable(user))
			total_scatter_angle += SCATTER_AMOUNT_TIER_7
		else
			total_scatter_angle -= user.skills.get_skill_level(SKILL_FIREARMS)*SCATTER_AMOUNT_TIER_8

	//Not if the gun doesn't scatter at all, or negative scatter.
	if(total_scatter_angle > 0)
		fire_angle += rand(-total_scatter_angle, total_scatter_angle)
		target = get_angle_target_turf(curloc, fire_angle, 30)

	return target

/obj/item/weapon/gun/proc/update_recoil_buildup()
	var/seconds_since_fired = max(world.timeofday - last_recoil_update, 0) * 0.1

	seconds_since_fired = max(seconds_since_fired - (fire_delay * 0.3), 0) // Takes into account firerate, so that recoil cannot fall whilst firing.
	// You have to be shooting at a third of the firerate of a gun to not build up any recoil if the recoil_loss_per_second is greater than the recoil_gain_per_second

	recoil_buildup = max(recoil_buildup - recoil_loss_per_second*seconds_since_fired, 0)

	last_recoil_update = world.timeofday

/obj/item/weapon/gun/proc/simulate_recoil(total_recoil = 0, mob/user, atom/target)
	if(flags_gun_features & GUN_RECOIL_BUILDUP)
		update_recoil_buildup()

		recoil_buildup = min(recoil + recoil_buildup, recoil_buildup_limit)
		total_recoil += (recoil_buildup*RECOIL_BUILDUP_VIEWPUNCH_MULTIPLIER)

	if(flags_item & WIELDED)
		if(!(flags_gun_features & GUN_RECOIL_BUILDUP)) // We're nesting this if loop, because we don't want the "else" to run if we are wielding
			total_recoil += recoil
	else
		total_recoil += recoil_unwielded
		if(flags_gun_toggles & GUN_BURST_FIRING)
			total_recoil++

	if(user && user.mind && user.skills)
		if(user?.skills?.get_skill_level(SKILL_FIREARMS) == SKILL_FIREARMS_CIVILIAN && !is_civilian_usable(user))
			total_recoil += RECOIL_AMOUNT_TIER_5
		else
			total_recoil -= user.skills.get_skill_level(SKILL_FIREARMS)*RECOIL_AMOUNT_TIER_5

	if(total_recoil > 0 && ishuman(user))
		if(total_recoil >= 4)
			shake_camera(user, total_recoil * 0.5, total_recoil)
		else
			shake_camera(user, 1, total_recoil)
		return TRUE

	return FALSE

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	   FIRE CYCLE RELATED PROCS    	<<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/obj/item/weapon/gun/proc/click_empty(mob/user)
	if(user)
		to_chat(user, SPAN_WARNING("<b>*click*</b>"))
		playsound(user, 'sound/weapons/gun_empty.ogg', 25, 1, 5) //5 tile range
	else
		playsound(src, 'sound/weapons/gun_empty.ogg', 25, 1, 5)

/obj/item/weapon/gun/proc/muzzle_flash(angle,mob/user)
	if(!muzzle_flash || flags_gun_features & GUN_IS_SILENCED || isnull(angle))
		return //We have to check for null angle here, as 0 can also be an angle.
	if(!istype(user) || !istype(user.loc,/turf))
		return

	var/prev_light = light_range
	if(!light_on && (light_range <= muzzle_flash_lum))
		set_light_range(muzzle_flash_lum)
		set_light_on(TRUE)
		addtimer(CALLBACK(src, PROC_REF(reset_light_range), prev_light), 0.5 SECONDS)

	var/image_layer = (user && user.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
	var/offset = 5

	var/image/I = image('icons/obj/items/weapons/projectiles.dmi',user,muzzle_flash,image_layer)
	var/matrix/rotate = matrix() //Change the flash angle.
	rotate.Translate(0, offset)
	rotate.Turn(angle)
	I.transform = rotate
	I.flick_overlay(user, 3)

/// called by a timer to remove the light range from muzzle flash
/obj/item/weapon/gun/proc/reset_light_range(lightrange)
	set_light_range(lightrange)
	if(lightrange <= 0)
		set_light_on(FALSE)

/obj/item/weapon/gun/proc/play_fire_sound(obj/projectile/projectile_to_fire, mob/user)
	var/actual_sound = projectile_to_fire.ammo.sound_override ? projectile_to_fire.ammo.sound_override :  ( active_attachable?.fire_sound ? active_attachable.fire_sound : pick(fire_sound) ) //pick() works fine with lists and single variables.
	var/sound_volume = active_attachable ? 60 : ( flags_gun_features & GUN_IS_SILENCED ? 25 : firesound_volume )
	var/firing_sndfreq = (current_mag && (current_mag.current_rounds / current_mag.max_rounds) > GUN_LOW_AMMO_PERCENTAGE) ? FALSE : SOUND_FREQ_HIGH

	if(firing_sndfreq && fire_rattle) //Not all guns will have these set.
		playsound(user, fire_rattle, sound_volume, FALSE)
	else
		playsound(user, actual_sound, sound_volume, firing_sndfreq)

//|********************\============================================================/********************|
//\____________________/                                           	                \____________________/
//							>>>>>>>>>>	  AUTOFIRE AND BURST PROCS 	  <<<<<<<<<
//
//|********************|____________________________________________________________|********************|
//\____________________/012345678901234567890123456789012345678901234567890123456789\____________________/
//--------------------------------------------------------------------------------------------------------

/// Setter proc to toggle burst firing
/obj/item/weapon/gun/proc/set_bursting(bursting = FALSE)
	if(bursting)
		flags_gun_toggles |= GUN_BURST_FIRING
	else
		flags_gun_toggles &= ~GUN_BURST_FIRING

///Clean all references
/obj/item/weapon/gun/proc/reset_fire()
	shots_fired = 0//Let's clean everything
	set_target(null)
	set_auto_firing(FALSE)

/// adder for fire_delay
/obj/item/weapon/gun/proc/modify_fire_delay(value)
	fire_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)

/// setter for fire_delay
/obj/item/weapon/gun/proc/set_fire_delay(value)
	fire_delay = value
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)

/// getter for fire_delay
/obj/item/weapon/gun/proc/get_fire_delay(value)
	return fire_delay

/// setter for burst_amount
/obj/item/weapon/gun/proc/set_burst_amount(value, mob/user)
	burst_amount = value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)

/// adder for burst_amount
/obj/item/weapon/gun/proc/modify_burst_amount(value, mob/user)
	burst_amount += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)

/// Adder for burst_delay
/obj/item/weapon/gun/proc/modify_burst_delay(value, mob/user)
	burst_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, burst_delay)

/// Setter for burst_delay
/obj/item/weapon/gun/proc/set_burst_delay(value, mob/user)
	burst_delay = value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, burst_delay)

///Set the target and take care of hard delete
/obj/item/weapon/gun/proc/set_target(atom/object)
	active_attachable?.set_target(object)
	if(object == target || object == loc)
		return
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = object
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clean_target))

///Set the target to its turf, so we keep shooting even when it was qdeled
/obj/item/weapon/gun/proc/clean_target()
	SIGNAL_HANDLER
	active_attachable?.clean_target()
	target = get_turf(target)

/obj/item/weapon/gun/proc/stop_fire()
	SIGNAL_HANDLER
	if(!target || (gun_user.get_active_hand() != src))
		return

	if(gun_firemode == GUN_FIREMODE_AUTOMATIC)
		reset_fire()
	SEND_SIGNAL(src, COMSIG_GUN_STOP_FIRE)

/obj/item/weapon/gun/proc/set_gun_user(mob/to_set)
	if(to_set == gun_user)
		return
	if(gun_user)
		UnregisterSignal(gun_user, list(COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG))

	gun_user = to_set
	if(gun_user)
		RegisterSignal(gun_user, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_fire))
		RegisterSignal(gun_user, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
		RegisterSignal(gun_user, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))

/obj/item/weapon/gun/hands_swapped(mob/living/carbon/swapper_of_hands)
	if(src == swapper_of_hands.get_active_hand())
		set_gun_user(swapper_of_hands)
		return

	set_gun_user(null)

///Update the target if you draged your mouse
/obj/item/weapon/gun/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, gun_user, params))
	gun_user?.face_atom(target)

///Check if the gun can fire and add it to bucket auto_fire system if needed, or just fire the gun if not
/obj/item/weapon/gun/proc/start_fire(datum/source, atom/object, turf/location, control, params, bypass_checks = FALSE)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["middle"] || modifiers["right"])
		return

	// Don't allow doing anything else if inside a container of some sort, like a locker.
	if(!isturf(gun_user.loc))
		return

	if(istype(object, /atom/movable/screen))
		return

	if(!bypass_checks)
		if(gun_user.hand && !isgun(gun_user.l_hand) || !gun_user.hand && !isgun(gun_user.r_hand)) // If the object in our active hand is not a gun, abort
			return

		if(gun_user.throw_mode)
			return

		if(gun_user.Adjacent(object)) //Dealt with by attack code
			return

	if(QDELETED(object))
		return

	if(gun_user.client?.prefs?.toggle_prefs & TOGGLE_HELP_INTENT_SAFETY && (gun_user.a_intent == INTENT_HELP))
		if(world.time % 3) // Limits how often this message pops up, saw this somewhere else and thought it was clever
			//Absolutely SCREAM this at people so they don't get killed by it
			to_chat(gun_user, SPAN_HIGHDANGER("Help intent safety is on! Switch to another intent to fire your weapon."))
			click_empty(gun_user)
		return FALSE

	if(flags_gun_receiver & GUN_CHAMBER_IS_JAMMED)//Oh no, the gun is jammed! Cannot fire while it is jammed.
		if(world.time % 3)
			playsound(src, 'sound/weapons/handling/gun_jam_click.ogg', 35, TRUE)
			to_chat(gun_user, SPAN_WARNING("Your gun is jammed! Use Unique-Action to unjam it!"))
			balloon_alert(gun_user, "*jammed*")
		return FALSE

	set_target(get_turf_on_clickcatcher(object, gun_user, params))
	if((gun_firemode == GUN_FIREMODE_SEMIAUTO) || active_attachable)
		Fire(object, gun_user, modifiers)
		reset_fire()
		return
	SEND_SIGNAL(src, COMSIG_GUN_FIRE)

/// Wrapper proc for the autofire subsystem to ensure the important args aren't null
/obj/item/weapon/gun/proc/fire_wrapper(atom/target, mob/living/user, params, reflex = FALSE, dual_wield)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!target)
		target = src.target
	if(!user)
		user = gun_user
	if(!target || !user)
		return NONE
	return Fire(target, user, params, reflex, dual_wield)

/// Setter proc for fa_firing
/obj/item/weapon/gun/proc/set_auto_firing(auto = FALSE)
	SIGNAL_HANDLER
	fa_firing = auto

/// Getter for gun_user
/obj/item/weapon/gun/proc/get_gun_user()
	return gun_user
