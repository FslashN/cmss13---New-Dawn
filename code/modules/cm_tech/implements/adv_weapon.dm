
/obj/item/techtree_advanced_weapon_kit
	name = "advanced weapon kit"
	desc = "It seems to be a kit to choose an advanced weapon"

	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrench"

	var/gun_type = /obj/item/weapon/gun/shotgun/pump
	var/ammo_type = /obj/item/ammo_magazine/shotgun/buckshot
	var/ammo_type_count = 3


/obj/item/techtree_advanced_weapon_kit/attack_self(mob/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user

	new gun_type(get_turf(H))
	for (var/i in 1 to ammo_type_count)
		new ammo_type(get_turf(H))

	qdel(src)

/obj/item/techtree_advanced_weapon_kit/railgun
	name = "advanced weapon kit"
	desc = "It seems to be a kit to choose an advanced weapon"

	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrench"

	gun_type = /obj/item/weapon/gun/rifle/techweb_railgun
	ammo_type = /obj/item/ammo_magazine/techweb_railgun
	ammo_type_count = 5
