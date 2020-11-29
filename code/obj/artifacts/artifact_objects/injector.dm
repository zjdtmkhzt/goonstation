/obj/artifact/injector
	name = "artifact injector"
	associated_datum = /datum/artifact/injector

/datum/artifact/injector
	associated_object = /obj/artifact/injector
	rarity_class = 2
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold)
	activ_text = "opens up, revealing an array of strange needles!"
	deact_text = "closes itself up."
	react_xray = list(8,60,75,11,"SEGMENTED")
	var/list/injection_reagents = list()
	var/injection_amount = 10
	var/static/potential_reagents_ancient = list("nanites","liquid plasma","mercury","lithium","plasma","radium","uranium","cryostylane")
	var/static/potential_reagents_martian = list("charcoal","salbutamol","anti_rad","synaptizine","omnizine","synthflesh",
				"cyanide","ketamine","toxin","neurotoxin","mutagen","fake_initropidril",
				"toxic_slurry","space_fungus","blood","urine","meat_slurry")
	var/static/potential_reagents_eldritch = list("chlorine","fluorine","lithium","mercury","plasma","radium","uranium","strange_reagent",
				"amanitin","coniine","cyanide","curare",
				"formaldehyde","lipolicide","initropidril","cholesterol","itching","pancuronium","polonium",
				"sodium_thiopental","ketamine","sulfonal","toxin","venom","neurotoxin","mutagen","wolfsbane",
				"toxic_slurry","histamine","sarin")
	var/potential_reagents = list()

	post_setup()
		switch(artitype.name)
			if ("ancient")
				// industrial heavy machinery kinda stuff
				potential_reagents = potential_reagents_ancient
			if ("martian")
				// medicine, some poisons, some gross stuff
				potential_reagents = potential_reagents_martian
			if ("eldritch")
				// all the worst stuff. all of it
				potential_reagents = potential_reagents_eldritch
			else
				// absolutely everything
				potential_reagents = all_functional_reagent_ids

		if (length(potential_reagents) > 0)
			var/looper = rand(1,3)
			while (looper > 0)
				looper--
				injection_reagents += pick(potential_reagents)

		injection_amount = rand(3,25)

	effect_reconfigure(obj/O)
		if (..())
			return

		var/remove_amt = rand(0, min(3, injection_reagents.len)) // remove some reagents!
		var/looper = remove_amt
		while (looper > 0)
			looper--
			injection_reagents -= pick(injection_reagents)

		var/add_amt = rand(1, 3)																 // add some!
		if (length(potential_reagents) > 0)
			looper = add_amt
			while (looper > 0)
				looper--
				injection_reagents += pick(potential_reagents)

		injection_amount += rand(-injection_amount/2, injection_amount/2) // change injection amount!

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (user.reagents && injection_reagents.len > 0)
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O]</b> jabs [user] with a needle and injects something!")
			for (var/X in injection_reagents)
				ArtifactLogs(user, null, O, "touched by [user.real_name]", "injecting [X]", 0) // Added (Convair880).
				user.reagents.add_reagent(X,injection_amount)
