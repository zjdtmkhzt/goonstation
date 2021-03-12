/obj/machinery/artifact/robot_controller
	name = "artifact power generator"
	associated_datum = /datum/artifact/robot_controller

/datum/artifact/robot_controller
	associated_object = /obj/machinery/artifact/robot_controller
	type_name = "Robot Controller"
	rarity_weight = 90
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/electric,/datum/artifact_trigger/silicon_touch)
	activ_text = "begins to emit an electric hum!"
	deact_text = "'s lights go dark as it shuts down!"
	deact_sound = 'sound/effects/singsuck.ogg'
	react_xray = list(10,90,80,10,"NONE")
	var/turf/last_turf = null

	New()
		..()

	effect_process(var/obj/O)
		if (..())
			return

		for(var/obj/machinery/bot/B as() in by_type[/obj/machinery/bot])
			if(last_turf != get_turf(O))
				last_turf = get_turf(O)
				B.navigate_to(O, adjacent = TRUE)
			if(istype(B, /obj/machinery/bot/guardbot))
				var/obj/machinery/bot/GB = B
				GB.task
