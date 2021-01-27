/proc/shakespearify(var/string)
	string = replacetext(string, "your ", "[pick("thy", "thine")] ")
	string = replacetext(string, " your", " [pick("thy", "thine")]")
	string = replacetext(string, " is ", " be ")
	string = replacetext(string, "you ", "thou ")
	string = replacetext(string, " you", " thou")
	string = replacetext(string, "are ", "art ")
	string = replacetext(string, " are", " art")
	string = replacetext(string, "do ", "doth ")
	string = replacetext(string, " do", " doth")
	string = replacetext(string, "does ", "doth ")
	string = replacetext(string, " does", " doth")
	string = replacetext(string, "she ", "the lady ")
	string = replacetext(string, " she", " the lady")
	string = replacetext(string, "i think", "methinks")
	return string

/mob/proc/become_statue(var/datum/material/M, var/newDesc = null)
	var/obj/overlay/statueperson = new /obj/overlay(get_turf(src))
	src.pixel_x = 0
	src.pixel_y = 0
	src.set_loc(statueperson)
	statueperson.appearance = src.appearance
	statueperson.name = "[M.name] statue of [src.name]"
	if(desc)
		statueperson.desc = newDesc
	else
		statueperson.desc = src.desc
	statueperson.setMaterial(M)
	statueperson.anchored = 0
	statueperson.set_density(1)
	statueperson.layer = MOB_LAYER
	statueperson.set_dir(src.dir)
	src.remove()

/mob/proc/become_ice_statue()
	become_statue(getMaterial("ice"), "We here at Space Station 13 believe in the transparency of our employees. It doesn't look like a functioning human can be retrieved from this.")

/mob/proc/become_rock_statue()
	become_statue(getMaterial("rock"), "Its not too uncommon for our employees to be stoned at work but this is just ridiculous!")

/proc/generate_random_pathogen()
	var/datum/pathogen/P = unpool(/datum/pathogen)
	P.setup(1, null, 0)
	return P

/proc/wrap_pathogen(var/datum/reagents/reagents, var/datum/pathogen/P, var/units = 5)
	reagents.add_reagent("pathogen", units)
	var/datum/reagent/blood/pathogen/R = reagents.get_reagent("pathogen")
	if (R)
		R.pathogens[P.pathogen_uid] = P

/proc/ez_pathogen(var/stype)
	var/datum/pathogen/P = unpool(/datum/pathogen)
	var/datum/pathogen_cdc/cdc = P.generate_name()
	cdc.mutations += P.name
	cdc.mutations[P.name] = P
	P.generate_components(cdc, 0)
	P.generate_attributes(0)
	P.advance_speed = 25
	P.spread = 25
	P.suppression_threshold = max(1, P.suppression_threshold)
	P.add_symptom(pathogen_controller.path_to_symptom[stype])
	logTheThing("pathology", null, null, "Pathogen [P.name] created by quick-pathogen-proc with symptom [stype].")
	return P
