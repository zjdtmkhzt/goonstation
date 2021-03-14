/obj/machinery/artifact/robot_controller
	name = "artifact power generator"
	associated_datum = /datum/artifact/robot_controller

	pull()
		. = ..()
		add_enemy(usr)

	attackby(obj/item/W, mob/user)
		. = ..()
		add_enemy(user)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		. = ..()
		add_enemy(thr.user)

	bullet_act(obj/projectile/P)
		. = ..()
		add_enemy(P.mob_shooter)

	Bumped(AM)
		. = ..()
		add_enemy(AM)

	// you've just made an enemy for life
	proc/add_enemy(var/mob/living/bad_person)
		if(!isliving(bad_person)) // a nonorganic can't possibly be a bad person!
			return
		if(istype(src.artifact, /datum/artifact/robot_controller))
			var/datum/artifact/robot_controller/art_dat = src.artifact
			art_dat.add_enemy(bad_person)

/datum/artifact/robot_controller
	associated_object = /obj/machinery/artifact/robot_controller
	type_name = "Robot Controller"
	rarity_weight = 90
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/electric,/datum/artifact_trigger/silicon_touch)
	activ_text = "begins to emit an electric hum!"
	deact_text = "goes quiet."
	deact_sound = 'sound/effects/singsuck.ogg'
	react_xray = list(10,90,80,10,"NONE")
	var/list/mob/living/enemies = list()
	var/lethal = FALSE
	var/hateful = FALSE // emag aoe
	var/worship_radius = 3
	var/list/obj/machinery/bot/emagged_bots = list()

	New()
		..()
		worship_radius = rand(1,5)
		if(prob(35))
			src.lethal = TRUE
			if(prob(40))
				src.hateful = TRUE

	effect_activate(obj/O)
		if(..())
			return
		enemies = list()

	effect_deactivate(obj/O)
		if(..())
			return
		for(var/obj/machinery/bot/B as() in emagged_bots)
			B.demag()

	proc/add_enemy(var/mob/living/bad_person)
		if(!enemies.Find(bad_person))
			enemies += bad_person

	effect_process(var/obj/O)
		if (..())
			return

		for(var/obj/machinery/bot/B as() in by_type[/obj/machinery/bot])
			if(B.z != O.z || get_dist(B, O) <= src.worship_radius)
				continue
			if(istype(B, /obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/GB = B
				if(istype(GB.task, /datum/computer/file/guardbot_task/artifact))
					continue
				if(GB.charge_dock)
					GB.charge_dock.eject_robot()
				else
					GB.wakeup()
				GB.speak(pick("I can hear it calling me!", "The [src.internal_name] has need of me.", "I need to go.", "Time to go on a journey!"))
				var/datum/computer/file/guardbot_task/artifact/task = new /datum/computer/file/guardbot_task/artifact(O)
				GB.add_task(task, TRUE, TRUE)
			else
				B.navigate_to(O, adjacent = TRUE)

		if(src.hateful && prob(20))
			O.visible_message("The [O] emits a terrifying crackling noise.")
			playsound(O, "sound/effects/screech.ogg", 80, 1, 0)
			particleMaster.SpawnSystem(new /datum/particleSystem/sonic_burst(O))
			for(var/obj/machinery/bot/B in range(O, worship_radius))
				if(!emagged_bots.Find(B))
					emagged_bots += B
					B.emag_act()
