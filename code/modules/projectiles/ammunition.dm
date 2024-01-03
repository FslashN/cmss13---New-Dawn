//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[----------------------------------------------------]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
//hhhhhhhhhhhhhhhhh===========[                 GENERIC AMMO MAGAZINE              ]=========hhhhhhhhhhhhhhhhhhhhhhh
//VVVVVVVVVVVVVVVVVHHHHHHHHHH=[____________________________________________________]=HHHHHHHHVVVVVVVVVVVVVVVVVVVVVVV
/*
Ammunition is stored in a basic container object. The generic object is a sequential holder of compressed information, but there are four other variations.
The ammunition these hold are paths to a specific ammo datum. All can hold mixed types of rounds (paths), but they differ in what exactly they can hold. Let's go over all five:
MAGAZINE_TYPE_DETACHABLE - This is the most generic weapon mag. It can be attached to and detached from a gun, and will only feed the weapon if it's attached. It's sequential in terms of how it feeds ammo.
These are compressed (check feeder_contents var) and can only hold a specific caliber of ammunition. These are specific to individual guns (or their types), and often seen in vis_contents.
MAGAZINE_TYPE_SPEEDLOADER - Speedloaders are circular, feeding their ammo based on an index value, and are uncompressed. They too only hold one type of caliber of ammunition and are gun-specific.
Because they are circular, they have additional handling for most procs.
MAGAZINE_TYPE_INTERNAL - This is the same as DETACHABLE, except it's always contained within a gun and cannot be removed from it. Other handling is pretty much the same.
MAGAZINE_TYPE_INTERNAL_CYLINDER - The same as an INTERNAL speedloader. For revolvers or other guns with cylindrical internal mags.
MAGAZINE_TYPE_HANDFUL - Handfuls are literally just a bunch of loose rounds held together in a hand, or a small amount, to be used with firearms that reload with individual rounds instead of magazines. Also the most complicated code wise.
Handfuls generally reload firearms that have INTERNAL mags of some kind, but can be used to transfer rounds between other types. Handfuls can have mixed calibers, and if they do,
they are added into a parent handful contents and then added to vis_contents to basically have a bunch of mixed rounds together. Instead of a max_round limit, each handful type has its own "size" that determines how many can be
mixed together in all. Handfuls can be toggled by clicking on themselves to either ADD or SUBTRACT ammo when they are used to reload.
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

	//This is what populates the magazine by default.
	var/default_ammo = /datum/ammo/bullet
	//Contents of the feeder, broken up by their position. Initialized on New(). Cylinders use uncompressed format of paths for each position. ie: list(/path/ammo1, /path/ammo2, null, null, null, /path/ammo1)
	//Other magazines use a compressed format of path, position. When a bullet is added to a normal mag, it should be inserted in position 1. ie: Insert(1, path, amount).
	//You can overwrite this list on Initialize to start with a custom arrangement of ammo paths. ie: list(/path/ammo1, 20, /path/ammo2, 15, /path/ammo1, 5). In compressed lists, amounts should add up to current_rounds.
	//It doesn't particularly matter if the paths repeat, ie: list(/path/ammo1, 20, /path/ammo1, 20), but this is unnecessary as it equals to: list(/path/ammo1, 40) when a gun is fired by the player.
	var/list/feeder_contents
	//This tracks where the firing pin is located for internal mags and speedloaders, specific to cylinders. There are other ways of doing this, but this is the fastest and easiest to visualize.
	//Elsewise we would need to shift the actual contents of the feeder_contents list, which would take extra time to process and is harder to accomodate when reloading.
	//Always 1 for compressed magazines as we want to reference the first position in the list.
	var/feeder_index = 1

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

	if(spawn_empty) current_rounds = 0
	switch(current_rounds)
		if(-1) current_rounds = max_rounds //Fill it up. Anything other than -1 and 0 will just remain so.
		if(0)
			icon_state += "_e" //In case it spawns empty instead.
			item_state += "_e"
			vis_state += "_e"
		else current_rounds = abs(min(max_rounds, current_rounds)) //Just in case the mag spawns with more ammo than it should, or negative ammo.

	if(!feeder_contents) //No list defined. If it was defined, we will use that list instead.
		feeder_contents = list() //Generate a list for the contents, if we didn't override it for a child.
		if(magazine_type in list(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER)) //Internal cylinders/speedloaders will populate their feeder_contents uncompressed.
			feeder_contents.len = max_rounds
			for(var/i = 1 to current_rounds)
				feeder_contents[i] = default_ammo
		else //For regular magazines we add the default ammo in position 1 and curent rounds in position 2.
			feeder_contents += default_ammo
			feeder_contents += current_rounds

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
		if(MG.flags_magazine & (AMMUNITION_HANDFUL|AMMUNITION_SLAP_TRANSFER)) //got a handful of bullets
			if(flags_magazine & AMMUNITION_REFILLABLE) //and a refillable magazine
				var/obj/item/ammo_magazine/handful/transfer_from = I
				if(src == user.get_inactive_hand() || bypass_hold_check) //It has to be held.
					if(transfer_bullet_number(transfer_from,user,transfer_from.current_rounds)) // This takes care of the rest.
						to_chat(user, SPAN_NOTICE("You transfer rounds to [src] from [transfer_from]."))
				else
					to_chat(user, SPAN_WARNING("Try holding [src] before you attempt to restock it."))
/*
#define MAGAZINE_CALC_HANDFUL_AVAILABLE_SPACE(magazine) ( magazine.handful_space_left = ( 1 - ((1/magazine.max_rounds) * magazine.current_rounds) ) )
#define MAGAZINE_CALC_HANDFUL_TRANSFER_SIZE(magazine, handful_space_left, unit_of_transfer) min(magazine.current_rounds, FLOOR_INTEGER((handful_space_left / unit_of_transfer)) //To account for floating point error.
#define MAGAZINE_CALC_HANDFUL_UNIT_OF_TRANSFER(magazine) (1 / magazine.max_rounds)
#define MAGAZINE_LIST_OF_INTERNAL_MAG_TYPES list(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER)
*/
//The workhorse of bullet handling. Will move bullets from one magazine to another, taking into account capacity, type, and so on. `if(transfer_bullet_mount(some_magazine,user)) do_this` is an example usage.
/obj/item/ammo_magazine/proc/transfer_bullet_number(obj/item/ammo_magazine/source, mob/user, transfer_amount = 1)
	if(current_rounds >= max_rounds) //Does the mag actually need reloading?
		to_chat(user, SPAN_WARNING("[src] is already full."))
		return FALSE

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, SPAN_WARNING("Not the same caliber, they won't fit right."))
		return FALSE

	. = 0 //Set return to 0 rounds.
	 //Whatever is lower, the rounds in source or how many rounds we can replace. If our mag is a handful, we will clamp this based on what other handfuls are contained within.
	transfer_amount = min(transfer_amount, source.current_rounds, (max_rounds - current_rounds) )

	var/ammo_path
	var/group_count
	var/group_transfer

	world << "Transfer amount set to [transfer_amount]."

	switch(magazine_type) //Here we go trying to see how the transfer should proceed.
		if(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER)
			switch(source.magazine_type)
				if(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER) //This is generally for speedloaders loading up an internal cylinder.
					var/i
					while(. < transfer_amount)
						ammo_path = source.feeder_contents[feeder_index]
						if(ammo_path)
							while(i)
								if(!feeder_contents[feeder_index]) //No ammo path in this slot.
									feeder_contents[feeder_index] = ammo_path //Replace it.
									ROTATE_CYLINDER(src, 1) //Rotate cylinder to the next available position.
									break //Get out of processing.
								ROTATE_CYLINDER(src, 1) //Rotate cylinder if not.
						source.feeder_contents[source.feeder_index] = null //Null out the original entry.
						.++
						ROTATE_CYLINDER(source, 1) //Keep rotating.
			//	if(MAGAZINE_TYPE_HANDFUL)

				else
					while(. < transfer_amount) //We know implicitly that we will do enough rotations to replace every round we can.
						if(!feeder_contents[feeder_index]) //Nothing in this slot, slot in the ammo.
							feeder_contents[feeder_index] = source.feeder_contents[1]
							if(--source.feeder_contents[2] <= 0) //Remove source ammo if needed.
								source.feeder_contents.Cut(1, 3)
							.++ //Incremenet the return value.
						ROTATE_CYLINDER(src, 1) //Rotate to the next position.

			source.current_rounds -= .
			current_rounds += .
		if(MAGAZINE_TYPE_HANDFUL)
			//Handfuls are tricky. We first need to determine how much "space" the handful has available.
			//We grab a ratio of how many rounds are contained within versus how many can be contained, and that will give us the relative measure of what we can transfer.
			var/handful_space_left = 1 - ((1/max_rounds) * current_rounds)
			for(var/i in src)
				var/obj/item/ammo_magazine/handful/H = i
				handful_space_left -= H.current_rounds / H.max_rounds
			if(current_rounds && !handful_space_left)
				to_chat(user, SPAN_WARNING("You can't carry any more rounds in this handful."))
				return
			var/full_contents[] = list(src) + contents
			var/len = length(contents)
			world << "Have [handful_space_left] space. Length is [len]"

			switch(source.magazine_type)
				if(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER) //For cylinders we want to iterate and grab whatever we can for the handful.
					var/i = source.max_rounds
					while(. < transfer_amount)
						if(i <= 0) break //We iterate the cylinder only once.
						ammo_path = source.feeder_contents[feeder_index]
						if(ammo_path)
							if(ammo_path == feeder_contents[1]) //Does it already exist in position 1?
								feeder_contents[2]++ //Add it together.
								source.feeder_contents[feeder_index] = null //Null out the original entry.
								.++
						i--
						ROTATE_CYLINDER(source, 1) //Rinse and repeat.

					source.current_rounds -= .
					current_rounds += .

				if(MAGAZINE_TYPE_HANDFUL)
					//If we're hitting two handfuls together, we transfer the first thing that we can, which is the holder object. If not it, any child object that fits.
					var/unit_of_measure
					var/L[] = list(source) + source.contents
					for(var/i in L)
						if(handful_space_left <= 0) break
						var/obj/item/ammo_magazine/handful/H = i
						unit_of_measure = 1 / H.max_rounds
						world << "Unit of measure for [H] is [unit_of_measure]"
						if(unit_of_measure <= handful_space_left) //We can transfer at least one unit.
							var/obj/item/ammo_magazine/handful/H2
							var/to_transfer
							var/unit_of_transfer
							for(var/i2 in full_contents)
								H2 = i2
								unit_of_transfer = 1 / H2.max_rounds
								if(H2.current_rounds != H2.max_rounds && unit_of_transfer <= handful_space_left && H2.default_ammo == H.default_ammo && H2.caliber == H.caliber)
									world << "Adding to current handful total."
									to_transfer = min(H.current_rounds, floor( (handful_space_left / unit_of_transfer) + 0.0001))  //How much we can transfer.
									world << "to_transfer is [to_transfer]"
									world << "handful_space_left is [handful_space_left]"
									handful_space_left -= to_transfer
									H.current_rounds -= to_transfer
									H.feeder_contents[2] -= to_transfer
									H2.current_rounds += to_transfer
									H2.feeder_contents[2] += to_transfer
									. += to_transfer
									H2.update_icon()
									break
							if(!to_transfer) //Haven't transferred anything. We will add it instead.
								world << "Adding to vis contents"
								unit_of_transfer = 1 / H.max_rounds
								world << "unit_of_transfer is [unit_of_transfer]"
								world << "current_rounds is: [H.current_rounds] and rounding is: [round(handful_space_left / unit_of_transfer)] : [handful_space_left] / [unit_of_transfer]"
								world << "Rounding 0.4 / 0.2 : [round(0.4 / 0.2)]"
								to_transfer = min(H.current_rounds, floor( (handful_space_left / unit_of_transfer) + 0.0001)) //To account for floating point error.
								world << "to_transfer is [to_transfer]"
								var/obj/item/ammo_magazine/handful/H3 = H

								if(to_transfer == H.current_rounds) //If it's the whole thing, we just move it instead of creating a new one.
									H3.loc = src
									source.vis_contents -= H
								else
									H.current_rounds -= to_transfer
									H.feeder_contents[2] -= to_transfer
									H3 = new(src)
									H3.generate_handful(H.default_ammo, H.caliber, to_transfer)

								. += to_transfer
								vis_contents += H3
								H3.flags_magazine |= AMMUNITION_IN_VIS_CONTENTS

								switch(len) //Adding top right, bottom left, top left, bottom right.
									if(0)
										H3.pixel_x = 4
										H3.pixel_y = 4
									if(1)
										H3.pixel_x = -4
										H3.pixel_y = -4
									if(2)
										H3.pixel_x = -4
										H3.pixel_y = 4
									if(3)
										H3.pixel_x = 4
										H3.pixel_y = -4

								len += 1

							if(H.current_rounds <= 0 && H.flags_magazine & AMMUNITION_IN_VIS_CONTENTS) //It's in vis contents but it's empty.
								world << "Deleting vis contents handful."
								source.vis_contents -= H
								qdel(H)
							else H.update_icon()
							to_transfer = null


				else //Here we only add whatever is actually the same ammo wise. If it's not the same, we can't add it.
					ammo_path = source.feeder_contents[1]
					group_count = source.feeder_contents[2]
					if(ammo_path == feeder_contents[1]) //Same path.
						group_transfer = min(transfer_amount, group_count) //We want to make sure we're not taking too many rounds.
						source.feeder_contents[2] -= group_transfer //Subtract the final amount.
						MAGAZINE_CLEAN_FIRST_POSITION(source)
						feeder_contents[2] += group_transfer //Let's not forget to add it to the feeder count.
						. += group_transfer
					else //They have to be the same as handfuls cannot mix ammo at this time.
						to_chat(user, SPAN_WARNING("Not the same type of ammo, better not mix them up."))
					source.current_rounds -= .
					current_rounds += .

		else //Every other case, such as detachables.
			switch(source.magazine_type)
				if(MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_SPEEDLOADER) //Cylindrical ammo, we will compress this.
					while(. < transfer_amount)
						ammo_path = source.feeder_contents[feeder_index]
						if(ammo_path)
							if(ammo_path == feeder_contents[1]) //Does it already exist in position 1?
								feeder_contents[2]++ //Add it togehter.
							else
								feeder_contents.Insert(1, ammo_path, 1) //Insert into position 1, ammo path followed by 1 round.
							source.feeder_contents[feeder_index] = null //Null out the original entry.
							.++
						ROTATE_CYLINDER(source, 1) //Rinse and repeat.
			//	if(MAGAZINE_TYPE_HANDFUL)

				else //Adding regular ammo together.
					while(transfer_amount > 0)
						ammo_path = source.feeder_contents[1]
						group_count = source.feeder_contents[2]
						group_transfer = min(transfer_amount, group_count) //We want either the lowest amount we still have to transfer, or whatever the stack has left.
						if(ammo_path == feeder_contents[1]) //Same as what we already have?
							feeder_contents[2] += group_transfer //Add the amount to our compressed stack.
						else
							feeder_contents.Insert(1, ammo_path, group_transfer) //Otherwise add the stack.
						source.feeder_contents[2] -= group_transfer //Remove it from the original source.
						MAGAZINE_CLEAN_FIRST_POSITION(source)
						. += group_transfer //Add to our return value.
						transfer_amount -= group_transfer //Remove from the iterator.
			source.current_rounds -= .
			current_rounds += .

	if(source.current_rounds <= 0 && source.magazine_type == MAGAZINE_TYPE_HANDFUL) //We don't have any more rounds in the current handful, but we have a child. Convert it to the parent.
		if(length(source.contents) > 0)
			world << "Mimicing handful because we don't have any rounds in current handful and have a child."
			var/obj/item/ammo_magazine/handful/H = contents[1]
			source.name = H.name
			source.default_ammo = H.default_ammo
			source.caliber = H.caliber
			source.max_rounds = H.max_rounds
			source.current_rounds = H.current_rounds
			source.feeder_contents = H.feeder_contents
			source.handful_state = H.handful_state
			vis_contents -= H
			qdel(H)
			source.update_icon()
		else
			world << "DELETING HANDFUL"
			if(user)
				user.temp_drop_inv_item(source)
			qdel(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.

	else source.update_icon()

	if( !( magazine_type in list(MAGAZINE_TYPE_INTERNAL,MAGAZINE_TYPE_INTERNAL_CYLINDER,MAGAZINE_TYPE_HANDFUL) )) //If we are not reloading into an internal mag.
		playsound(loc, pick('sound/weapons/handling/mag_refill_1.ogg', 'sound/weapons/handling/mag_refill_2.ogg', 'sound/weapons/handling/mag_refill_3.ogg'), 25, 1)

	update_icon(.)

	world << "Return value is [.]"

/// Proc to reload the current_ammo using the items existing inherent ammo, used for Sentry Post
/obj/item/ammo_magazine/proc/inherent_reload(mob/user)
	if(current_rounds == max_rounds) //Does the mag actually need reloading?
		to_chat(user, SPAN_WARNING("[src] is already full."))
		return 0

	var/rounds_to_reload = max_rounds - current_rounds
	current_rounds += rounds_to_reload
	max_inherent_rounds -= rounds_to_reload

	return rounds_to_reload // Returns the amount of ammo it reloaded

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
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	flags_equip_slot = null // It only fits into pockets and such.
	w_class = SIZE_SMALL
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.
	flags_atom = FPRINT|CONDUCT
	flags_magazine = AMMUNITION_HANDFUL
	attack_speed = 3 // should make reloading less painful
	magazine_type = MAGAZINE_TYPE_HANDFUL
	maptext = FALSE
	maptext_y = 1
	maptext_x = 2
	var/inserting_ammo = FALSE

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
	pixel_x = 0
	pixel_y = 0
	scatter_item()
	if(flags_magazine & AMMUNITION_IN_VIS_CONTENTS)
		var/obj/item/ammo_magazine/handful/H = loc
		H.vis_contents -= src
		flags_magazine &= ~AMMUNITION_IN_VIS_CONTENTS
	. = ..()
	dir = olddir

/obj/item/ammo_magazine/handful/equipped(mob/user, slot)
	maptext = inserting_ammo ? {"<span style= 'font-size: 6px; font-family:VCR OSD Mono; color: red'>ADD</span>"} : {"<span style= 'font-size:6px; font-family:VCR OSD Mono; color: blue'>TAKE</span>"}
	var/thisDir = dir
	..(user,slot)
	setDir(thisDir)

/obj/item/ammo_magazine/handful/dropped(mob/user)
	. = ..()
	maptext = null

/*
There aren't many ways to interact here.
If the default ammo isn't the same, then you can't do much with it.
If it is the same and the other stack isn't full, transfer an amount (default 1) to the other stack.
*/
/obj/item/ammo_magazine/handful/attackby(obj/item/ammo_magazine/handful/transfer_from, mob/user)
	if(istype(transfer_from)) // We have a handful. They don't need to hold it.
		if(flags_magazine & AMMUNITION_IN_VIS_CONTENTS) src = loc
		if(transfer_from.inserting_ammo) // This takes care of the rest.
			transfer_bullet_number(transfer_from,user,transfer_from.current_rounds)
		else
			transfer_from.transfer_bullet_number(src,user,current_rounds)

/obj/item/ammo_magazine/handful/attack_self(mob/user)
	..()
	inserting_ammo = !inserting_ammo
	maptext = inserting_ammo ? {"<span style= 'font-size: 6px; font-family:VCR OSD Mono; color: red'>ADD</span>"} : {"<span style= 'font-size:6px; font-family:VCR OSD Mono; color: blue'>TAKE</span>"}

//This will attempt to place the ammo in the user's hand if possible. High level proc from ammo_magazine parent. Every parameter is optional. Will default to a max sized handful using whatever rounds the mag has left.
/obj/item/ammo_magazine/proc/create_handful(mob/user, obj_name = src, transfer_amount = current_rounds, in_chamber_override)
	if (current_rounds > 0)
		var/obj/item/ammo_magazine/handful/new_handful = new

		if(in_chamber_override)
			new_handful.generate_handful(in_chamber_override, caliber, transfer_amount)
		else
			world << "Transferring bullets."
			new_handful.generate_handful(feeder_contents[1], caliber, -1) //Generate a handful
			new_handful.transfer_bullet_number(src, user, min(new_handful.max_rounds, transfer_amount))

		update_icon(-new_handful.current_rounds) //Update the src icon.

		if(magazine_type == MAGAZINE_TYPE_DETACHABLE) //Play a sound if this is a regular mag getting a handful dumped.
			playsound(loc, pick('sound/weapons/handling/mag_refill_1.ogg', 'sound/weapons/handling/mag_refill_2.ogg', 'sound/weapons/handling/mag_refill_3.ogg'), 25, TRUE, 3)

		if(user)
			user.put_in_hands(new_handful)
			to_chat(user, SPAN_NOTICE("You grab <b>[new_handful.current_rounds]</b> round\s from [obj_name]."))
		else new_handful.forceMove(get_turf(src))

		return new_handful.current_rounds //Give the number created. Could also return the handful itself I suppose.

//Handfuls don't care about gun type. new_rounds is optional.
/obj/item/ammo_magazine/handful/proc/generate_handful(new_ammo_path, new_caliber, new_rounds = 0)
	var/datum/ammo/A = GLOB.ammo_list[new_ammo_path]
	switch(new_rounds)
		if(0) new_rounds = A.handful_max //Default to the max rounds in case we're dumping it or something.
		if(-1) new_rounds = 0 //If we want to set them through transfer_bullet_number()
	name = "handful of [A.name + (A.multiple_handful_name ? " ":"s ") + "([new_caliber])"]"
	default_ammo = new_ammo_path
	caliber = new_caliber
	max_rounds = A.handful_max
	current_rounds = min(new_rounds, max_rounds) //If rounds exceed the max rounds possible in the handful.
	feeder_contents = list(new_ammo_path, current_rounds) //Overwrite as this is being generated from a blank state.

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
