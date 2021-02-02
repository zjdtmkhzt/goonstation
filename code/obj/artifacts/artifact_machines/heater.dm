/obj/machinery/artifact/heater
	name = "artifact heater"
	associated_datum = /datum/artifact/heater

/datum/artifact/heater
	associated_object = /obj/machinery/artifact/heater
	rarity_class = 1 // modified from 2 as part of art tweak
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/cold)
	activ_text = "begins to emit gas!"
	deact_text = "stops emitting gas."
	react_xray = list(10,85,80,5,"COMPLEX")
	var/gas_type = "oxygen"
	var/gas_temp = 310
	var/gas_amount = 100
	examine_hint = "It is covered in very conspicuous markings."

	post_setup()
		. = ..()
		// gas type
		// oxygen is really the only thing here that's not dangerous, so I am having it be pretty common
		switch(artitype.name)
			if("eldritch") // bad things
				gas_type = pick(
					100;"nitrogen",
					100;"plasma",
					100;"carbon dioxide",
					75;"sleeping agent")
			if("martian") // organic stuff
				gas_type = pick(
					200;"oxygen",
					100;"nitrogen",
					50;"carbon dioxide",
					50;"farts")
			if("ancient") // industrial type stuff
				gas_type = pick(
					200;"oxygen",
					100;"nitrogen",
					50;"carbon dioxide",
					50;"agent b")
			if("precursor") // the rest
				gas_type = pick(
					125;"oxygen",
					100;"nitrogen",
					75;"plasma",
					50;"carbon dioxide",
					30;"farts",
					30;"agent b",
					30;"sleeping agent")

		// temperature
		gas_temp = rand(0,620)
		if (artitype.name == "eldritch" && prob(66))
			if (gas_temp > 310)
				gas_temp *= 2
			if (gas_temp < 310)
				gas_temp /= 2

		// amount
		gas_amount = rand(50,200)

		// text
		var/tempText = ""
		if (gas_temp > 310)
			tempText = "hot "
		else if (gas_temp < 310)
			tempText = "cold "

		src.activ_text = "begins to emit [tempText] gas!"
		src.deact_text = "stops emitting [tempText] gas."

	effect_process(var/obj/O)
		if (..())
			return
		var/turf/simulated/L = get_turf(O)
		if(istype(L))
			var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
			gas.zero()
			switch(src.gas_type)
				if("oxygen")
					gas.oxygen = src.gas_amount
				if("nitrogen")
					gas.nitrogen = src.gas_amount
				if("plasma")
					gas.toxins = src.gas_amount
				if("carbon dioxide")
					gas.carbon_dioxide = src.gas_amount
				if("farts")
					gas.farts = src.gas_amount
				if("agent b")
					var/datum/gas/oxygen_agent_b/trace = gas.get_or_add_trace_gas_by_type(var/datum/gas/oxygen_agent_b)
					trace.moles = src.gas_amount
				if("sleeping agent")
					var/datum/gas/sleeping_agent/trace = gas.get_or_add_trace_gas_by_type(var/datum/gas/sleeping_agent)
					trace.moles = src.gas_amount
			gas.temperature = src.gas_temp
			gas.volume = R_IDEAL_GAS_EQUATION * src.gas_temp / 1000
			if (L)
				L.assume_air(gas)
