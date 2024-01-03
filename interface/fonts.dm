/// A font datum, it exists to define a custom font to use in a span style later.
/datum/font
	/// Font name, just so people know what to put in their span style.
	var/name
	/// The font file we link to.
	var/font_family

/datum/font/vcr_osd_mono
	name = "VCR OSD Mono"
	font_family = 'interface/VCR_OSD_Mono.ttf'

//Font for the ammo counter. Size should be 6 to display correctly. Numbers only.
/datum/font/digital_counter
	name = "DigitalCounter"
	font_family = 'interface/Digital_Counter.ttf'

//Font for the motion detector, same size as the original counter. Slightly fancier, pixely and less dial looking.
/datum/font/digital_counter
	name = "DigitalCounter2"
	font_family = 'interface/Digital_Counter2.ttf'