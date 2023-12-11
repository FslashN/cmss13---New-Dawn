#define FIRE_DELAY_GROUP_SHOTGUN "fdg_shtgn"

#define TASER_MODE_P "precision"
#define TASER_MODE_F "free"

// Common
#define AMMO_BAND_COLOR_AP "#1F951F"
#define AMMO_BAND_COLOR_HIGH_VELOCITY "#8998A3"
#define AMMO_BAND_COLOR_TRAINING "#FFFFFF"
// Uncommon
#define AMMO_BAND_COLOR_HOLOTARGETING "#276A74"
#define AMMO_BAND_COLOR_RUBBER "#556696"
#define AMMO_BAND_COLOR_HOLLOWPOINT "#BA5D00"
#define AMMO_BAND_COLOR_INCENDIARY "#9C2219"
#define AMMO_BAND_COLOR_IMPACT "#7866FF"
// Techwebs
#define AMMO_BAND_COLOR_PENETRATING "#67819C"
#define AMMO_BAND_COLOR_TOXIN "#98104d"
// CO
#define AMMO_BAND_COLOR_SUPER "#C1811C"
#define AMMO_BAND_COLOR_HIGH_IMPACT "#00CDEA"
// Rare
#define AMMO_BAND_COLOR_HEAP "#9C9A19"
#define AMMO_BAND_COLOR_EXPLOSIVE "#19499C"
#define AMMO_BAND_COLOR_LIGHT_EXPLOSIVE "#7D199C"

// Ammo bands, but for revolvers. Or handfuls?

// M44
#define REVOLVER_TIP_COLOR_MARKSMAN "#FF744F"
#define REVOLVER_TIP_COLOR_HEAVY AMMO_BAND_COLOR_IMPACT
// Mateba
#define REVOLVER_TIP_COLOR_HIGH_IMPACT AMMO_BAND_COLOR_HIGH_IMPACT
#define REVOLVER_TIP_COLOR_AP AMMO_BAND_COLOR_AP
#define REVOLVER_TIP_COLOR_EXPLOSIVE AMMO_BAND_COLOR_EXPLOSIVE
// Techwebs
#define REVOLVER_TIP_COLOR_INCENDIARY AMMO_BAND_COLOR_INCENDIARY
#define REVOLVER_TIP_COLOR_PENETRATING AMMO_BAND_COLOR_PENETRATING
#define REVOLVER_TIP_COLOR_TOXIN AMMO_BAND_COLOR_TOXIN

#define GUN_FIREMODE_SEMIAUTO "semi-auto fire mode"
#define GUN_FIREMODE_BURSTFIRE "burst-fire mode"
#define GUN_FIREMODE_AUTOMATIC "automatic fire mode"

//autofire component fire callback return flags
#define AUTOFIRE_CONTINUE (1<<0)
#define AUTOFIRE_SUCCESS (1<<1)

///Base CO special weapons options
#define CO_GUNS list(CO_GUN_MATEBA, CO_GUN_MATEBA_SPECIAL, CO_GUN_DEAGLE)

///Council CO special weapons options
#define COUNCIL_CO_GUNS list(CO_GUN_MATEBA_COUNCIL, CO_GUN_DEAGLE_COUNCIL)

#define CO_GUN_MATEBA "Mateba"
#define CO_GUN_MATEBA_SPECIAL "Mateba Special"
#define CO_GUN_DEAGLE "Desert Eagle"
#define CO_GUN_MATEBA_COUNCIL "Colonel's Mateba"
#define CO_GUN_DEAGLE_COUNCIL "Golden Desert Eagle"

//Defines for various attachment slots.
//Keep in mind that attachable slots have to match the offset defines.
#define ATTACHMENT_SLOT_MUZZLE "muzzle" //Silencers/etc.
#define ATTACHMENT_SLOT_STOCK "stock" //What you brace the firearm with.
#define	ATTACHMENT_SLOT_RAIL "rail" //On top of the gun, like a scope.
#define	ATTACHMENT_SLOT_UNDER "under" //Under the barrel, like a flashlight.
#define ATTACHMENT_SLOT_BARREL "barrel" //Integrated barrels mostly. A lot of the old itengrated barrels need to be converted to this, including the gun _x and _y offsets.
#define ATTACHMENT_SLOT_SPECIAL "special" //Anything that doesn't fit into another general category. Unused right now.
//Other attachments hardpoints can be entered here.

//This determines how many max objects are allowed for the ammo counter pool.
//So they are not constantly generated when marines drop their guns.
#define AMMO_COUNTER_OBJ_POOL_MAX 5

//Easy switching between magazines instead of type casting.
#define MAGAZINE_TYPE_INTERNAL 0
#define MAGAZINE_TYPE_DETACHABLE 1
#define MAGAZINE_TYPE_HANDFUL 2
#define MAGAZINE_TYPE_SPEEDLOADER 3

//Jam chance compounds with the weapon fired. They use the same defines right now, but the vast majority are set to 0.
#define GUN_MALFUNCTION_CHANCE_ZERO 0 //Default at the time of this comment.
#define GUN_MALFUNCTION_CHANCE_VERY_LOW 0.01 //Very unlikely to jam, probably elite weapons.
#define GUN_MALFUNCTION_CHANCE_LOW 0.1 //Base jam chance of the PPSH stick mag. Very reliable. This is a good baseline in the future.
#define GUN_MALFUNCTION_CHANCE_MED_LOW 0.5
#define GUN_MALFUNCTION_CHANCE_MEDIUM 1 //Jam chance of the PPSH drum mag. 1/100 bullets will jam.
#define GUN_MALFUNCTION_CHANCE_HIGH 5 //Getting into unreliable teritory. 5/100 bullets will jam.
#define GUN_MALFUNCTION_CHANCE_MED_HIGH 7.5 //Poor, very poor.
#define GUN_MALFUNCTION_CHANCE_VERY_HIGH 10 //Unacceptable. The firearm could be damaged or something.