//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 GENERIC AMMO MAGAZINE              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
Boxes of ammo. Certain weapons have internal boxes of ammo that cannot be removed and function as part of the weapon.
They're all essentially identical when it comes to getting the job done.
*/
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo."
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/uscm.dmi'
	icon_state = null
	item_state = "ammo_mag" //PLACEHOLDER. This ensures the mag doesn't use the icon state instead.
	vis_flags = VIS_UNDERLAY|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_INHERIT_ID //Set these so that we can use mags as underlays for different guns.
	var/vis_state = null //Instead of the old pointer, this is used when the mag is inside vis_contents of a gun.
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	matter = list("metal" = 1000)
	//Low.
	throwforce = 2
	w_class = SIZE_SMALL
	throw_speed = SPEED_SLOW
	throw_range = 6
	ground_offset_x = 7
	ground_offset_y = 6
	var/default_ammo = /datum/ammo/bullet
	var/feeding_ammo //What is currently used to load the chamber, also a path, starts as default_ammo on New(). Change this if you have mixed ammo.
	var/list/feeder_contents //Contents of the feeder, broken up by their position. Initialized on New().
	var/caliber = null // This is used for matching handfuls to each other or whatever the mag is. Examples are" "12g" ".44" ".357" etc.
	var/current_rounds = -1 //This will fill the mag to full at initialize. Change this to a different number to have it start with less than full ammo.
	var/max_rounds = 7 //How many rounds can it hold?
	var/max_inherent_rounds = 0 //How many extra rounds the magazine has thats not in use? Used for Sentry Post, specifically for inherent reloading
	var/gun_type = null //Path of the gun that it fits. Mags will fit any of the parent guns as well, so make sure you want this.
	var/reload_delay = 1 //Set a timer for reloading mags. Higher is slower.
	var/flags_magazine = AMMUNITION_REFILLABLE //flags specifically for magazines.
	var/magazine_type = MAGAZINE_TYPE_DETACHABLE //What sort of mag is it? For easier switching.
	var/handful_state = "bullet" //used for generating handfuls from boxes and setting their sprite when loading/unloading
	var/used_casings = 0
	var/malfunction_chance_added = GUN_MALFUNCTION_CHANCE_ZERO //For guns jamming. Legacy mechanic carryover for some special guns.

	/// If this and ammo_band_icon aren't null, run update_ammo_band(). Is the color of the band, such as green on AP.
	var/ammo_band_color
	/// If this and ammo_band_color aren't null, run update_ammo_band() Is the greyscale icon used for the ammo band.
	var/ammo_band_icon
	/// Is the greyscale icon used for the ammo band when it's empty of bullets.
	var/ammo_band_icon_empty

//Children should reference this proc from the bottom of a stack, after their own processing.
/obj/item/ammo_magazine/Initialize(mapload, spawn_empty)
	. = ..()
	GLOB.ammo_magazine_list += src
	feeding_ammo = feeding_ammo ? feeding_ammo : default_ammo //If we have something set, we use that instead of default ammo.
	feeder_contents = list() //Generate a list for the contents, if we didn't override it for a child.

	if(spawn_empty) current_rounds = 0
	switch(current_rounds)
		if(-1) current_rounds = max_rounds //Fill it up. Anything other than -1 and 0 will just remain so.
		if(0)
			icon_state += "_e" //In case it spawns empty instead.
			item_state += "_e"
			vis_state += "_e"
		else current_rounds = abs(min(max_rounds, current_rounds)) //Just in case the mag spawns with more ammo than it should, or negative ammo.

	if(ammo_band_color && ammo_band_icon && !istype(loc, /obj/item/weapon/gun)) //Bandaid for until I can fix a proper bit define.
		update_ammo_band()

/obj/item/ammo_magazine/Destroy()
	GLOB.ammo_magazine_list -= src
	return ..()

/obj/item/ammo_magazine/proc/update_ammo_band()
	overlays.Cut()
	var/band_icon = ammo_band_icon
	if(!current_rounds)
		band_icon = ammo_band_icon_empty
	var/image/ammo_band_image = image(icon, src, band_icon)
	ammo_band_image.color = ammo_band_color
	ammo_band_image.appearance_flags = RESET_COLOR|KEEP_APART
	overlays += ammo_band_image

/obj/item/ammo_magazine/update_icon(round_diff = 0, obj/item/weapon/gun/G)
	if(G && icon == 'icons/obj/items/weapons/guns/ammo_by_faction/colony.dmi')
		pixel_x = 0 //It may have been scattered, we need to reset these to properly align the sprites.
		pixel_y = 0
		if(overlays.len) overlays.len = 0 //Get rid of overlays if they exist.
		icon_state = initial(icon_state) + "_vis" //Add the visual state.
		if(!current_rounds) icon_state += "_e" //Make it empty if there are no rounds remaining.
		G.vis_contents += src
	else
		if(current_rounds <= 0)
			icon_state = initial(icon_state) + "_e"
			item_state = initial(item_state) + "_e"
			vis_state = initial(vis_state) + "_e"
			add_to_garbage(src)
		else if(current_rounds - round_diff <= 0)
			icon_state = initial(icon_state)
			item_state = initial(item_state) //to-do, unique magazine inhands for majority firearms.
			vis_state = initial(vis_state)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if(C.r_hand == src)
				C.update_inv_r_hand()
			else if(C.l_hand == src)
				C.update_inv_l_hand()
		if(ammo_band_color && ammo_band_icon) //Bandaid for until I can fix a proper bit define.
			update_ammo_band()

/obj/item/ammo_magazine/get_examine_text(mob/user)
	. = ..()

	if(flags_magazine & AMMUNITION_HIDE_AMMO)
		return
	// It should never have negative ammo after spawn. If it does, we need to know about it.
	if(current_rounds < 0)
		. += "Something went horribly wrong. Ahelp the following: ERROR CODE R1: negative current_rounds on examine."
		log_debug("ERROR CODE R1: negative current_rounds on examine. User: <b>[usr]</b> Magazine: <b>[src]</b>")
	else
		. += "[src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."

/obj/item/ammo_magazine/attack_hand(mob/user)
	if(flags_magazine & AMMUNITION_REFILLABLE) //actual refillable magazine, not just a handful of bullets or a fuel tank.
		if(src == user.get_inactive_hand()) //Have to be holding it in the hand.
			if(flags_magazine & AMMUNITION_CANNOT_REMOVE_BULLETS)
				to_chat(user, SPAN_WARNING("You can't remove ammo from \the [src]!"))
				return
			if (current_rounds > 0)
				if(create_handful(user))
					return
			else to_chat(user, SPAN_WARNING("[src] is empty. Nothing to grab."))
			return
	return ..() //Do normal stuff.

//We should only attack it with handfuls. Empty hand to take out, handful to put back in. Same as normal handful.
/obj/item/ammo_magazine/attackby(obj/item/I, mob/living/user, bypass_hold_check = 0)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/MG = I
		if((MG.flags_magazine & AMMUNITION_HANDFUL) || (MG.flags_magazine & AMMUNITION_SLAP_TRANSFER)) //got a handful of bullets
			if(flags_magazine & AMMUNITION_REFILLABLE) //and a refillable magazine
				var/obj/item/ammo_magazine/handful/transfer_from = I
				if(src == user.get_inactive_hand() || bypass_hold_check) //It has to be held.
					if(transfer_bullet_number(transfer_from,user,transfer_from.current_rounds)) // This takes care of the rest.
						to_chat(user, SPAN_NOTICE("You transfer rounds to [src] from [transfer_from]."))
				else
					to_chat(user, SPAN_WARNING("Try holding [src] before you attempt to restock it."))

/*
//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
/obj/item/ammo_magazine/proc/transfer_bullet_number(obj/item/ammo_magazine/source, mob/user, transfer_amount = 1)
	if(current_rounds == max_rounds) //Does the mag actually need reloading?
		to_chat(user, "[src] is already full.")
		return

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, "The rounds don't match up. Better not mix them up.")
		return

	var/S = min(transfer_amount, max_rounds - current_rounds)
	source.current_rounds -= S
	current_rounds += S
	if(source.current_rounds <= 0 && istype(source, /obj/item/ammo_magazine/handful)) //We want to delete it if it's a handful.
		if(user)
			user.temp_drop_inv_item(source)
		qdel(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
	else source.update_icon()

	if(!istype(src, /obj/item/ammo_magazine/internal) && !istype(src, /obj/item/ammo_magazine/shotgun) && !istype(source, /obj/item/ammo_magazine/revolver)) //if we are shotgun or revolver or whatever not using normal mag system
		playsound(loc, pick('sound/weapons/handling/mag_refill_1.ogg', 'sound/weapons/handling/mag_refill_2.ogg', 'sound/weapons/handling/mag_refill_3.ogg'), 25, 1)

	update_icon(S)
	return S // We return the number transferred if it was successful.
*/



/obj/item/ammo_magazine/proc/transfer_bullet_number(obj/item/ammo_magazine/source, mob/user, transfer_amount = 1)
	if(current_rounds == max_rounds) //Does the mag actually need reloading?
		to_chat(user, SPAN_WARNING("[src] is already full."))
		return

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, SPAN_WARNING("Not the same caliber, they won't fit right."))
		return

	var/transfered_bullets = 0 //Previous checks will make sure there's at least something to transfer.
	while(transfer_amount--)
		if(current_rounds == max_rounds || !source.current_rounds) break //Either our mag is full or the source is empty.

		//Let's determine if our source has a break point or it will continue using the current ammo.
		if("[source.current_rounds]" in source.feeder_contents)
			source.feeding_ammo = source.feeder_contents["[source.current_rounds]"]
			source.feeder_contents -= "[source.current_rounds]"

		if(current_rounds) //Has some rounds, we may need to determine break points.
			if(feeding_ammo != source.feeding_ammo) //Looks like we found one.
				feeder_contents["[current_rounds]"] = feeding_ammo //Make the break point on what we currently have it set to.
				feeding_ammo = source.feeding_ammo //Set it to the source.

		else //If the magazine is completely empty, we don't set break points for our mag.
			feeding_ammo = source.feeding_ammo

		source.current_rounds--
		current_rounds++
		transfered_bullets++

	if(!source.current_rounds && source.magazine_type == MAGAZINE_TYPE_HANDFUL) //We want to delete it if it's a handful.
		if(user)
			user.temp_drop_inv_item(source)
		qdel(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
	else source.update_icon()

	if(magazine_type != MAGAZINE_TYPE_INTERNAL) //If we are not reloading into an internal mag.
		playsound(loc, pick('sound/weapons/handling/mag_refill_1.ogg', 'sound/weapons/handling/mag_refill_2.ogg', 'sound/weapons/handling/mag_refill_3.ogg'), 25, 1)

	update_icon(transfered_bullets)

	return transfered_bullets

//Returns a number of rounds until a break point, where feeder_ammo switches.
/obj/item/ammo_magazine/proc/rounds_until_switch(amount_to_check = 1)
	var/rounds_before_switch = 0
	var/round_count = current_rounds
	while(amount_to_check--)
		if(!round_count || ("[round_count--]" in feeder_contents))
			break
		else rounds_before_switch++

	return rounds_before_switch

/// Proc to reload the current_ammo using the items existing inherent ammo, used for Sentry Post
/obj/item/ammo_magazine/proc/inherent_reload(mob/user)
	if(current_rounds == max_rounds) //Does the mag actually need reloading?
		to_chat(user, SPAN_WARNING("[src] is already full."))
		return 0

	var/rounds_to_reload = max_rounds - current_rounds
	current_rounds += rounds_to_reload
	max_inherent_rounds -= rounds_to_reload

	return rounds_to_reload // Returns the amount of ammo it reloaded

//our magazine inherits ammo info from a source magazine
/obj/item/ammo_magazine/proc/match_ammo(obj/item/ammo_magazine/source)
	caliber = source.caliber
	default_ammo = source.default_ammo
	gun_type = source.gun_type

//~Art interjecting here for explosion when using flamer procs.
/obj/item/ammo_magazine/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	if(current_rounds < 1)
		return
	else
		var/severity = round(current_rounds / 50)
		//the more ammo inside, the faster and harder it cooks off
		if(severity > 0)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), loc, -1, ((severity > 4) ? 0 : -1), Clamp(severity, 0, 1), Clamp(severity, 0, 2), 1, 0, 0, flame_cause_data), max(5 - severity, 2))

	if(!QDELETED(src))
		qdel(src)

//our fueltanks are extremely fire-retardant and won't explode
/obj/item/ammo_magazine/flamer_tank/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	return

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                   INTERNAL MAGAZINE                ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV

//Magazines that actually cannot be removed from the firearm. Functionally the same as the regular thing, but they do have two extra vars.
/obj/item/ammo_magazine/internal
	name = "internal chamber"
	desc = "You should not be able to examine it."
	//For revolvers and shotguns.
	magazine_type = MAGAZINE_TYPE_INTERNAL
	vis_flags = VIS_HIDE //Hide em, if ever added.
	var/list/chamber_contents //What is actually in the chamber. Initiated on New().
	var/chamber_position = 1 //This tracks where either the firing pin is located or where a bullet was last inserted.

//Helper proc, to allow us to see a percentage of how full the magazine is.
/obj/item/ammo_magazine/proc/get_ammo_percent() // return % charge of cell
	return 100.0*current_rounds/max_rounds


//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[               GENERIC HANDFUL OF AMMO              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//Now for handfuls, which follow their own rules and have some special differences from regular boxes.

/*
Handfuls are generated dynamically and they are never actually loaded into the item.
What they do instead is refill the magazine with ammo and sometime save what sort of
ammo they are in order to use later. The internal magazine for the gun really does the
brunt of the work. This is also far, far better than generating individual items for
bullets/shells. ~N
*/

/obj/item/ammo_magazine/handful
	name = "generic handful"
	desc = "A handful of rounds to reload on the go."
	icon = 'icons/obj/items/weapons/guns/handful.dmi'
	icon_state = "bullet_1"
	vis_flags = NONE //We generally don't want these in vis_contents at all.
	flags_equip_slot = null // It only fits into pockets and such.
	w_class = SIZE_SMALL
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.
	flags_atom = FPRINT|CONDUCT
	flags_magazine = AMMUNITION_HANDFUL
	attack_speed = 3 // should make reloading less painful
	magazine_type = MAGAZINE_TYPE_HANDFUL

/obj/item/ammo_magazine/handful/Initialize(mapload, spawn_empty)
	. = ..()
	update_icon()
	matter = list("metal" = 50) //This changes based on the ammo ammount. 5k is the base of one shell/bullet.

/obj/item/ammo_magazine/handful/update_icon() //Handles the icon itself as well as some bonus things.
	if(max_rounds >= current_rounds)
		matter["metal"] = current_rounds * 50
	icon_state = handful_state + "_[current_rounds]"

/obj/item/ammo_magazine/handful/pickup(mob/user)
	var/olddir = dir
	. = ..()
	dir = olddir

/obj/item/ammo_magazine/handful/equipped(mob/user, slot)
	var/thisDir = dir
	..(user,slot)
	setDir(thisDir)
	return

/*
There aren't many ways to interact here.
If the default ammo isn't the same, then you can't do much with it.
If it is the same and the other stack isn't full, transfer an amount (default 1) to the other stack.
*/
/obj/item/ammo_magazine/handful/attackby(obj/item/ammo_magazine/handful/transfer_from, mob/user)
	if(istype(transfer_from)) // We have a handful. They don't need to hold it.
		if(default_ammo == transfer_from.default_ammo) //Has to match.
			transfer_bullet_number(transfer_from,user, transfer_from.current_rounds) // Transfer it from currently held to src
		else to_chat(user, SPAN_WARNING("Those aren't the same rounds. Better not mix them up."))

//This will attempt to place the ammo in the user's hand if possible. High level proc from ammo_magazine parent. Every parameter is optional. Will default to a max sized handful using whatever rounds the mag has left.
/obj/item/ammo_magazine/proc/create_handful(mob/user, obj_name = src, transfer_amount = current_rounds, ammo_override)
	if (current_rounds > 0)
		transfer_amount = rounds_until_switch(transfer_amount) //will try to make handful with all available rounds by default, but we check for break points, so it's first until break.

		var/obj/item/ammo_magazine/handful/new_handful = new
		current_rounds -= new_handful.generate_handful(ammo_override ? ammo_override : default_ammo, caliber, transfer_amount) //Generate a handful

		if("[current_rounds]" in feeder_contents) //Remove break point and switch ammo.
			feeding_ammo = feeder_contents["[current_rounds]"]
			feeder_contents -= "[current_rounds]"

		update_icon(-new_handful.current_rounds) //Update the src icon.

		if(magazine_type == MAGAZINE_TYPE_DETACHABLE) //Play a sound if this is a regular mag getting a handful dumped.
			playsound(loc, pick('sound/weapons/handling/mag_refill_1.ogg', 'sound/weapons/handling/mag_refill_2.ogg', 'sound/weapons/handling/mag_refill_3.ogg'), 25, 1)

		if(user)
			user.put_in_hands(new_handful)
			to_chat(user, SPAN_NOTICE("You grab <b>[new_handful.current_rounds]</b> round\s from [obj_name]."))
		else new_handful.forceMove(get_turf(src))

		return new_handful.current_rounds //Give the number created. Could also return the handful itself I suppose.

//Handfuls don't care about gun type. new_rounds is optional.
/obj/item/ammo_magazine/handful/proc/generate_handful(new_ammo_path, new_caliber, new_rounds)
	var/datum/ammo/A = GLOB.ammo_list[new_ammo_path]
	if(!new_rounds) new_rounds = A.handful_max //Default to the max rounds in case we're dumping it or something.
	name = "handful of [A.name + (A.multiple_handful_name ? " ":"s ") + "([new_caliber])"]"
	default_ammo = new_ammo_path
	feeding_ammo = new_ammo_path
	caliber = new_caliber
	max_rounds = A.handful_max
	current_rounds = min(new_rounds, max_rounds) //If rounds exceed the max rounds possible in the handful.
	handful_state = A.handful_state
	update_icon()

	return current_rounds //This is how many rounds we were actually able to create, regardless of the number provided.

//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                     USED CASINGS                   ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
Doesn't do anything or hold anything anymore.
Generated per the various mags, and then changed based on the number of
casings. .dir is the main thing that controls the icon. It modifies
the icon_state to look like more casings are hitting the ground.
There are 8 directions, 8 bullets are possible so after that it tries to grab the next
icon_state while reseting the direction. After 16 casings, it just ignores new
ones. At that point there are too many anyway. Shells and bullets leave different
items, so they do not intersect. This is far more efficient than using Blend() or
Turn() or Shift() as there is virtually no overhead other than generating a few more items.. ~N
*/
/obj/item/ammo_casing
	name = "spent casing"
	desc = "Empty and useless now."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "casing"
	throwforce = 1
	w_class = SIZE_TINY
	layer = LOWER_ITEM_LAYER //Below other objects
	dir = NORTH //Always north when it spawns.
	flags_atom = FPRINT|CONDUCT|DIRLOCK
	var/current_casings = 1 //This is manipulated in the procs that use these.
	var/max_casings = 16
	var/current_icon = 0
	var/number_of_states = 10 //How many variations of this item there are.
	garbage = TRUE
	ground_offset_x = 2 //This offsets it on spawn.
	ground_offset_y = 2

/obj/item/ammo_casing/Initialize()
	. = ..()
	matter = list("metal" = 8) //tiny amount of metal
	icon_state += "_[rand(1,number_of_states)]" //Set the icon to it.

//This does most of the heavy lifting. It updates the icon and name if needed, then changes .dir to simulate new casings.
/obj/item/ammo_casing/update_icon()
	if(max_casings >= current_casings)
		if(current_casings == 2) name += "s" //In case there is more than one.
		if(round((current_casings-1)/8) > current_icon)
			current_icon++
			icon_state += "_[current_icon]"

		matter["metal"] = current_casings * 8
		var/base_direction = current_casings - (current_icon * 8)
		setDir(base_direction + round(base_direction)/3)
		switch(current_casings)
			if(3 to 5) w_class = SIZE_SMALL //Slightly heavier.
			if(9 to 10) w_class = SIZE_MEDIUM //Can't put it in your pockets and stuff.

/obj/item/ammo_casing/pickup(mob/user)
	var/olddir = dir
	. = ..()
	dir = olddir

/obj/item/ammo_casing/equipped(mob/user, slot)
	var/thisDir = dir
	..(user,slot)
	setDir(thisDir)
	return

//Making child objects so that locate() and istype() doesn't screw up.
/obj/item/ammo_casing/bullet

/obj/item/ammo_casing/cartridge
	name = "spent cartridge"
	icon_state = "cartridge"

/obj/item/ammo_casing/shell
	name = "spent shell"
	icon_state = "shell"

/obj/item/ammo_casing/twobore
	name = "spent twobore shell"
	icon_state = "twobore"
	max_casings = 8
	number_of_states = 3 //I don't want to be making these all day.
