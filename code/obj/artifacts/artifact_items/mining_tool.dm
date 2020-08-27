/obj/item/artifact/mining_tool
	name = "artifact mining tool"
	artifact = 1
	associated_datum = /datum/artifact/mining
	module_research_no_diminish = 1
	var/datum/artifact/mining/artifact_mining = null

	New(var/loc, var/forceartitype)
		..()
		if(src.artifact && istype(src.artifact, /datum/artifact/mining))
			artifact_mining = artifact

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, var/reach)
		if(user == target || (!isturf(target.loc) && !isturf(target))) // we only hit turf
			return
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST) // diagonals chose one of the two dirs randomly
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))

		playsound(src.loc, src.artifact_mining.dig_sound, 20, 1)
		src.artifact_mining.dig(target, attackDir)

/datum/artifact/mining
	associated_object = /obj/item/artifact/mining_tool
	rarity_class = 1
	automatic_activation = 1
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	react_xray = list(12,80,95,5,"DENSE")
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	module_research = list("mining" = 10, "engineering" = 5, "miniaturization" = 10)
	module_research_insight = 3
	var/dig_power = 1
	var/dig_sound = "sound/effects/exlow.ogg"
	var/digType = 1
	var/tile_count = 10  // this is for non ancient artifacts
	var/width = 1  // these two are for ancient artifacts
	var/length = 1

	post_setup()
		..()
		src.dig_power = rand(50,250) // this be attacking the HP of the asteroid directly, default asteroids have, like, 120 HP
		src.tile_count = rand(10,30)
		src.width = rand(1,3) // this is like, 1 3 5 width
		src.length = rand(1,4)
		switch(artitype.name)
			if ("ancient")
				// robot stuff gets, uh, blocky dig
				src.dig_sound = pick("sound/machines/engine_grump1.ogg","sound/machines/chainsaw_green.ogg") // this is a drill
				src.digType = 1
			if ("martian")
				// weird squishy dig
				src.dig_sound = pick("sound/effects/splort.ogg")
				src.digType = 2
			if ("eldritch")
				// EVIL dig
				src.dig_sound = pick("sound/effects/mag_magmisimpact.ogg")
				src.digType = 3
			if ("wizard")
				// the lightning thing
				src.dig_sound = pick("sound/effects/elec_bigzap.ogg")
				src.digType = 4
			else
				// absolutely everything
				src.dig_sound = pick("sound/effects/exlow.ogg")
				src.digType = rand(1,4)

	proc/dig(var/turf/first, var/forward)
		var/left = turn(forward, 90)
		var/right = turn(forward, -90)
		switch(src.digType)
			if(1) // just a square with length and width
				var/currentTurf = first
				for(var/hit in 1 to length)
					if(!damage_asteroid(currentTurf))
						break
					var/leftTurf = currentTurf
					var/rightTurf = currentTurf
					for(var/i = 1; i < width; i++)
						leftTurf = get_step(leftTurf, left)
						rightTurf = get_step(rightTurf, right)
						damage_asteroid(leftTurf)
						damage_asteroid(rightTurf)
					currentTurf = get_step(currentTurf, forward)
			if(2)
				var/currentTurf = first
				var/side = 1
				if(prob(50))
					side = -1
				var/dir = turn(forward, side*45)
				for(var/hit in 1 to length)
					if(!damage_asteroid(currentTurf))
						break
					currentTurf = get_step(currentTurf, dir)
				dir = turn(forward, -side*45)
				for(var/hit in 1 to length)
					if(!damage_asteroid(currentTurf))
						break
					currentTurf = get_step(currentTurf, dir)
				dir = turn(forward, -side*45)
				for(var/hit in 1 to length)
					if(!damage_asteroid(currentTurf))
						break
					currentTurf = get_step(currentTurf, dir)

	proc/damage_asteroid(var/turf/cur)
		if(istype(cur,/turf/simulated/wall/asteroid))
			var/turf/simulated/wall/asteroid/A = cur
			A.change_health(-dig_power)
			return 1
		else
			return 0
