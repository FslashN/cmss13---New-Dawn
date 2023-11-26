/*
ERROR CODES AND WHAT THEY MEAN:


ERROR CODE A1: null ammo while reloading. <------------ Only appears when initialising or reloading a weapon and switching the ammo. Somehow the argument passed a null ammo.
ERROR CODE A2: null caliber while reloading. <------------ Only appears when initialising or reloading a weapon and switching the calibre. Somehow the argument passed a null caliber.
ERROR CODE I1: projectile malfunctioned while firing. <------------ Right before the bullet is fired, the actual bullet isn't present or isn't a bullet.
ERROR CODE I2: null ammo while load_into_chamber() <------------- Somehow the ammo datum is missing or something. We need to figure out how that happened.
ERROR CODE R1: negative current_rounds on examine. <------------ Applies to ammunition only. Ammunition should never have negative rounds after spawn.

DEFINES in conflict.dm, referenced here.

//================================
//These are gun features set through flats_gun_features. Three categories, but they all fall under the same flags.
//These are basic features of a gun.
#define GUN_CAN_POINTBLANK (1<<0) ///Can gun the shoot point-blank? Add it if it can.
#define GUN_NO_SAFETY_SWITCH (1<<1) ///Some guns don't have a safety switch at all. You will not be able to set GUN_TRIGGER_SAFETY_ON via interaction, but does not safety check beyond that.
#define GUN_AMMO_COUNTER (1<<3) ///Most USCM and UPP primaries have this set. This shows an active ammo counter on the weapon when picked up.
#define GUN_AUTO_EJECTOR (1<<4) ///This will kick it out the magazine automatically once it runs dry. Most rifles and SMGs have this set.
#define GUN_RECOIL_BUILDUP (1<<5) /// Whether the gun has been fired by its current user (reset upon `dropped()`)
#define GUN_IS_SILENCED (1<<6) ///Only from an attachment, add an attachment on spawn if wanted. Temporary until attachement is removed.
#define GUN_ONE_HAND_WIELDED (1<<7) /// This removes unwielded accuracy and scatter penalties (not recoil) when set, when you're using only one hand.
#define GUN_NO_DESCRIPTION (1<<8) /// No gun description, only base desc
//These are various restrictions
#define GUN_SPECIALIST (1<<10) ///Some weapons are restricted to specialists on, this checks for it for those weapons.
#define GUN_WY_RESTRICTED (1<<11) ///Some weapons are locked to WY mercs only, this checks for it for those weapons.
#define GUN_WIELDED_FIRING_ONLY (1<<12) ///Some firarms have to be wielded to be fired, like rocket launchers.
//These are gun designs
#define GUN_SUPPORT_PLATFORM (1<<17) /// support weapon, bipod will grant autofire
#define GUN_UNUSUAL_DESIGN (1<<18) ///Guns with weird designs, energy weapons, not guns, and so on. This is important for checking for reloads and unloads. Can also be categorized as a basic feature. //TODO NIX THIS
#define GUN_ANTIQUE (1<<19) ///Some really old guns (chronologically to the world) have this set. Used to show guns that couldn't auto-eject, but has been phased out in favor of GUN_AUTO_EJECTOR being set for anything that can auto eject.

//================================
//These are temporary gun states set through flags_gun_toggles. They can change depending on various factors.
#define GUN_TRIGGER_SAFETY_ON (1<<0) ///Disable safety, so setting through flags means the gun starts with the SAFETY ON.
#define GUN_FLASHLIGHT_ON (1<<1) ///From an attachment, if the attached light source is on.
#define GUN_BURST_FIRING (1<<2) ///Added when the gun is burst firing.
#define GUN_AUTO_EJECTING_OFF (1<<3) ///If the gun has an auto ejector, it defaults to ON when spawned in. Adding this toggles it off instead. Must have GUN_AUTO_EJECTOR
///These defines are still part of flags_gun_toggles, but they primarily function with the smartgun. Can be used on other things.
#define GUN_IFF_SYSTEM_ON (1<<4) ///We want this to default to ON in most circumstances.
#define GUN_RECOIL_COMP_ON (1<<5) ///If the gun is toggled to minimize recoil.
#define GUN_ACCURACY_ASSIST_ON (1<<6) ///If the gun is set to assist with accuracy.
#define GUN_AUTOMATIC_AIM_ASSIST_ON (1<<7) ///If the gun will fire at targets by itself.
#define GUN_SECONDARY_MODE_ON (1<<8) ///If the gun has a secondary mode, like an alternative ammo to fire, this is used.
#define GUN_MOTION_DETECTOR_ON (1<<9) //If the gun comes with a motion detection module built in, this can be toggled too.
#define GUN_ID_LOCK_ON (1<<10) ///If the gun can lock itself from use, requiring a specific ID to unlock or something.

//================================
//These are receiver features set through flags_gun_receiver
#define GUN_INTERNAL_MAG (1<<0) ///The gun is fed ammunition into an internal magazine, like a shotgun or revolver.
#define GUN_CHAMBERED_CYCLE (1<<1)///The gun has to be "cocked" to fire, usually when a magazine is loaded. Most guns do this.
#define GUN_MANUAL_CYCLE (1<<2)///Intead of automatically loading the next bullet, the user must manually load it each shot.
#define GUN_CHAMBER_CAN_OPEN (1<<3)///The receiver can be opened, like a double barrel or revolver.
#define GUN_CHAMBER_IS_OPEN (1<<4)///If the above is set, this means the receiver is currently open.
#define GUN_CHAMBER_ROTATES (1<<5)///The chamber position can move around, typically with a cylinder.
#define GUN_CHAMBER_IS_STATIC (1<<6)///in_chamber is always "on" acting as the default ammo for the gun and ignores most of the fire cycle. It should never be nulled.

//Gun weapon categories, currently used for firing while dualwielding. Changed these to bitflags in case I want to mix and match. Unique from the flags above, could combine with gun designs.
#define GUN_CATEGORY_HANDGUN (1<<0)
#define GUN_CATEGORY_SMG (1<<1)
#define GUN_CATEGORY_RIFLE (1<<2)
#define GUN_CATEGORY_SHOTGUN (1<<3)
#define GUN_CATEGORY_HEAVY (1<<4)

//Defines for casing types
#define PROJECTILE_CASING_CASELESS null //No projectile casing
#define PROJECTILE_CASING_BULLET "bullet" //regular
#define PROJECTILE_CASING_SHELL "shell" //shotguns
#define PROJECTILE_CASING_CARTRIDGE "cartridge" //rifles and larger calibers
#define PROJECTILE_CASING_TWOBORE "twobore" //The twobore unique casing.

	UPDATED INFO

	////////////////////////////////////////////

	How guns actually work: I understand that not everyone is familiar with how real firearms are able to fire a projectile,
	so I'm going to run down really quick the most generic way a firearm works. I'm going to ignore actions, hammers, etc.
	A firearm has a chamber, a place where the bullet is placed in order to go through the barrel to be used as a projectile.
	Magazines are mechanical in nature and have a spring that pushes bullets into the chamber. However, when a magazine is
	loaded, the bullets don't just appear in the chamber somehow. It's a mechanical process. So instead, you have to do some
	physical action, like pulling a pistol's slide or a rifle's bolt, to manually chamber the first round. Most guns will take
	over the chamber feeding procedure automatically after that first round is loaded manually. They do this in a variety of ways
	that don't really matter. The firing process then goes like this: Some kind of mechanical force is applied to the
	propellant in the bullet, causing it to shoot out of the chamber, through the barrel, and toward its destination. The gun
	then uses the recoil, or some other way, to eject the empty casing from the last bullet and push the next bullet in the
	magazine into the chamber so it's ready to fire again.

	What the gun system attempts to do is model the most generic way that firearms work with room to override and change the process
	for more unique guns and interactions.

	////////////////////////////////////////////

	In CM, when a gun is loaded it calls for replace_magazine() to chamber the first bullet. This is for convenience only so
	guns don't need to be cocked to fire when first loading. It's the default behavior, as though your character is doing it
	manually. Think of it as if you're cocking the gun after a reload, but done automatically.

	Note: This was recently changed so that you need at least basic firearm skill to auto-cock your weapon after a reload.
	If you don't have basic fire arms skill, SMGs, semi-auto shotguns, rifles, and pistols will require cocking to fire after a
	reloading with nothing chambered.

	cycle_chamber() is the manual command to do the above. Since the gun is usually auto-cocked, this only cycles the chambered round out
	and replaces it with another round, which is more or less expected behavior.

	Let's go over the firing process in the code then. It goes something like this:
	able_to_fire() ---->  load_into_chamber() ----> ready_in_chamber() ----> fire() ----> reload_into_chamber()

	You check if the gun is even able to fire first, then you need a bullet to fire. able_to_fire() checks for a bunch of
	stuff, but most of it has nothing to do with the actual process of the gun firing a bullet.

	During load_into_chamber() It also looks for things like attachments to see if they are the ones that are being fired..
	What's in the chamber is tracked through var/in_chamber and is a reference to the ammo datum the gun will use to create
	a projectile later. This information is retrieved through the magazine of the gun, which is in itself a reference
	to some bullet datum.

	IMPORTANT: The default behavior is the gun will attempt to fire regardless if there is anything in the chamber or not. If it doesn't
	have something in the chamber, the gun will attempt to make something. You can override this behavior.

	Most CM guns used to auto-cock as a convenience, but I've tweaked that behavior. The default is still not to require it,
	You can see a little more advanced examples of how this can be changed in boltaction.dm, where the chamber must be cycled
	each individual fire and on reload.

	ready_in_chamber() prepares the actual in_chamber to be referenced. Think of this as loading the actual bullet.
	So then the gun will attempt to actually fire something with Fire(). This goes through some checks for bursting/pointblanking
	and so on. If the gun fires successfully, it will try to chamber the next round (this behavior can be changed), with
	reload_into_chamber(). And if the gun is automatic or bursting, it will continue to fire again. reload_into_chamber()
	is also where empty casings are created. This can be changed if the gun only creates casings when cocked. reload_into_chamber()
	is also where remaining ammo count should be tracked, if the gun has that feature.

	That's a surface level walkthrough, but there is more going on under the hood. There are, as mentioned, projectiles being created,
	but those are fairly distant from the rest of the gun code and do their own thing. Guns have a fairly complex system where
	they can remain in auto-fire, but you generally don't need to worry about how all that works. Understanding the basic gun
	process should account for most of your needs.

	///////////////////////////////////////////

	OLD NOTES

	if(burst_toggled && burst_firing)
		return
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	That should be on for most procs that deal with the gun doing some action. We do not want
	the gun to suddenly begin to fire when you're doing something else to it that could mess it up.
	As a general safety, make sure you remember this.

	To successfully create some unique gun
	that has a special method of firing, you need to override these procs.

	New() //You can typically leave this one alone unless you need for the gun to do something on spawn.
	Guns that use the regular system of chamber fire should load_into_chamber() on New().

	reload() //If the gun doesn't use the normal methods of reloading, like revolvers or shotguns which use
	handfuls, you will need to specify just how it reloads. User can be passed as null.

	unload() //Same deal. If it's some unique unload method, you need to put that here. User can be passed as null.

	Guns, on the front end, function off a three tier process.

	=1===========================================
	load_into_chamber() //This can get complicated, but if the gun doesn't take attachments that fire bullets from
	the Fire() process, just set them to null and leave the if(current_mag && current_mag.current_rounds > 0) check.
	The idea here is that if the gun can find a valid bullet to fire, subtract the ammo.
	This must return positive to continue the fire cycle.
	=============================================

	=2===========================================
	ready_in_chamber() //If the load_into_chamber is identical to the base outside of the actual bullet getting loaded,
	then you can use this in order to save on overrides. This primarily goes for anything that uses attachments like
	any standard firing cycle (attachables that fire through the firing cycle).
	=============================================

	=3===========================================
	reload_into_chamber() //The is the back action of the fire cycle that tells the gun to do all the stuff it needs
	to in order to prepare for the next fire cycle. This will be called if the gun fired successfully, per bullet.
	This is also where the gun will make a casing. So if your gun doesn't handle casings the regular way, modify it.
	Also where the gun will do final attachment calculations if the gun fired an attachment bullet.
	This must return positive to continue burst firing or so that you don't hear *click*.
	=============================================

	Other important procs:

	============================================
	able_to_fire() //Unless the gun has some special check to see whether or not it may fire, you don't need this.
	You can see examples of how this is modified in smartgun/sadar code, along with others. Return ..() on a success.
	============================================

	============================================
	delete_bullet() //Important for point blanking and jams, but can be called on for other reasons (that are
	not currently used). If the gun makes a bullet but doesn't fire it, this will be called on through clear_jam().
	This is also used to delete the bullet when you directly fire a bullet without going through the Fire() process,
	like with the mentioned point blanking/suicide.
	============================================

	Other procs are pretty self explanatory, and what is listed above is what you should usually change for unusual
	cases. So long as the gun can return true on able_to_fire() then move on to load_into_chamber() and finally
	reload_into_chamber(), you're in good shape. Those three procs basically make up the fire cycle, and if they
	function correctly, everything else will follow.

	This system is incredibly robust and can be used for anything from single bullet carbines to high-end energy
	weapons. So long as the steps are followed, it will work without issue. Some guns ignore active attachables,
	since they currently do not use them, but if that changes, the related procs must also change.

	Energy guns, or guns that don't really use magazines, can gut this system a bit. You can see examples in
	predator weapons or the taser.

	Ammo is loaded dynamically based on parent type through a global list. It is located in global_lists.dm under
	__HELPERS. So never create new() datums, as the datum should just be referenced through the global list instead.
	This cuts down on unnecessary overhead, and makes bullets always have an ammo type, even if the parent weapon is
	somehow deleted or some such. Null ammo in the projectile flight stage shoulder NEVER exist. If it does, something
	has gone wrong elsewhere and should be looked at. Do not simply add if(ammo) checks. If the system is working correctly,
	you will never need them.

	The guns also have bitflags for various functions, so refer to those in case you want to create something unique.
	They're all pretty straight forward; silenced comes from attachments only, so don't try to set it as the default.
	If you want a silenced gun, attach a silencer to it on New() that cannot be removed.

	~N

	TODO:

	/obj/item/attachable/proc/Attach(obj/item/weapon/gun/G)
	I commented out a line in attachments.
		//G.in_chamber.apply_bullet_trait(L)

	Bullet holds leave the wrong sprite.
	Fix lever action
	Touch up revolvers
	Check on jamming.
	Check on dual wielding
	Check on pointblaking
	add spawn on human spawn with a gun for ammo counter
	also check how it goes into containers
	Check attachments too
	Gun click after the last round is fired

	Look overlays not being removed with guns
	Casings face wrong way in hand



	Port the tg smoke thing
	Casing sprites/rework?
	See if it's possible to have gun slide animations when firing
	Finish the ammo counter. Make sure it's active on all guns that override normal procs.


	Add more muzzle flashes and gun sounds. Energy weapons, spear launcher, and taser for example.
	Add ping for energy guns like the taser and plasma caster.
	Move pred check for damage effects into the actual predator files instead of the usual.
	Move the mind checks for damage and stun to actual files, or rework it somehow.
*/