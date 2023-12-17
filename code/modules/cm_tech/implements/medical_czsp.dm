
/obj/item/storage/box/czsp/first_aid
	name = "first-aid combat support kit"
	desc = "Contains upgraded medical kits, nanosplints and an upgraded defibrillator."
	icon_state = "medicbox"
	storage_slots = 3

/obj/item/storage/box/czsp/first_aid/Initialize()
	. = ..()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	if(prob(5))
		new /obj/item/device/healthanalyzer(src)

/obj/item/storage/box/czsp/medical
	name = "medical combat support kit"
	desc = "Contains upgraded medical kits, nanosplints and an upgraded defibrillator."
	icon_state = "medicbox"
	storage_slots = 4

/obj/item/storage/box/czsp/medical/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)
	new /obj/item/stack/medical/splint/nano(src)
	new /obj/item/device/defibrillator/upgraded(src)

/obj/item/storage/box/czsp/medic_upgraded_kits
	name = "medical upgrade kit"
	icon_state = "upgradedkitbox"
	desc = "This kit holds upgraded trauma and burn kits, for critical injuries."
	max_w_class = SIZE_MEDIUM
	storage_slots = 2

/obj/item/storage/box/czsp/medic_upgraded_kits/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack/upgraded(src)
	new /obj/item/stack/medical/advanced/ointment/upgraded(src)

/obj/item/stack/medical/advanced/ointment/upgraded
	name = "upgraded burn kit"
	singular_name = "upgraded burn kit"
	stack_id = "upgraded burn kit"

	icon_state = "burnkit_upgraded"
	desc = "An upgraded burn treatment kit. Three times as effective as standard-issue, and non-replenishable. Use sparingly on only the most critical burns."

	max_amount = 10
	amount = 10

/obj/item/stack/medical/advanced/ointment/upgraded/Initialize(mapload, ...)
	. = ..()
	heal_burn = initial(heal_burn) * 3 // 3x stronger

/obj/item/stack/medical/advanced/bruise_pack/upgraded
	name = "upgraded trauma kit"
	singular_name = "upgraded trauma kit"
	stack_id = "upgraded trauma kit"

	icon_state = "traumakit_upgraded"
	desc = "An upgraded trauma treatment kit. Three times as effective as standard-issue, and non-replenishable. Use sparingly on only the most critical wounds."

	max_amount = 10
	amount = 10

/obj/item/stack/medical/advanced/bruise_pack/upgraded/Initialize(mapload, ...)
	. = ..()
	heal_brute = initial(heal_brute) * 3 // 3x stronger

/obj/item/stack/medical/splint/nano
	name = "nano splints"
	singular_name = "nano splint"

	icon_state = "nanosplint"
	desc = "Advanced technology allows these splints to hold bones in place while being flexible and damage-resistant. These aren't plentiful, so use them sparingly on critical areas."

	indestructible_splints = TRUE
	amount = 5
	max_amount = 5

	stack_id = "nano splint"

/obj/item/device/defibrillator/upgraded
	name = "upgraded emergency defibrillator"
	icon_state = "adv_defib"
	desc = "An advanced rechargeable defibrillator using induction to deliver shocks through metallic objects, such as armor, and does so with much greater efficiency than the standard variant, not damaging the heart."

	blocked_by_suit = FALSE
	min_heart_damage_dealt = 0
	max_heart_damage_dealt = 0
	damage_heal_threshold = 35