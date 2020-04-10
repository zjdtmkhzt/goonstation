/datum/targetable/spell/stickstosnakes
	name = "Sticks to Snakes"
	desc = "Turns an item into a snake."
	icon_state = "snakes"
	targeted = 1
	cooldown = 150 // TODO
	requires_robes = 1
	offensive = 1
	targeting_flags = TARGETS_ATOMS | TARGETS_IN_INVENTORY
	/*
	voice_grim = "sound/voice/wizard/weneed.ogg"
	voice_fem = "sound/voice/wizard/someoneto.ogg"
	voice_other = "sound/voice/wizard/recordthese.ogg"
	*/

	cast(atom/target)
		if(!holder)
			return

		var/has_spellpower = holder.owner.wizard_spellpower() // we track spellpower *before* we turn our staff into a snake

		var/atom/movable/stick = null
		if(istype(target, /obj/item))
			stick = target
		else if(istype(target, /mob))
			var/mob/living/carbon/human/M = target
			stick = M.equipped()
			if(!M.drop_item()) // if drop was unsuccessful
				stick = null
		else if(istype(target, /turf))
			var/list/items = list()
			for(var/obj/item/thing in target.contents)
				items.Add(thing)
			if(items.len)
				stick = pick(items)
		else if(istype(target, /obj/critter/domestic_bee))
			stick = target
		else if(istype(target, /obj/critter/snake))
			var/obj/critter/snake/snek = target
			if(snek.double)
				boutput(holder.owner, "<span style=\"color:red\">Your wizarding skills are not up to the legendary Triplesnake technique.</span>")
				return 1
			stick = target
		if (ismob(target.loc))
			var/mob/HH = target.loc
			HH.u_equip(target)
			var/atom/movable/AM = target
			AM.set_loc(get_turf(target))
		if (istype(target.loc, /obj/item/storage))
			var/obj/item/storage/S_temp = target.loc
			var/datum/hud/storage/H_temp = S_temp.hud
			H_temp.remove_object(target)
			var/atom/movable/AM = target
			AM.set_loc(get_turf(target))

		if(!stick)
			boutput(holder.owner, "<span style=\"color:red\">You must target an item or a person holding one.</span>")
			return 1 // No cooldown when it fails.
		if(!istype(stick.loc, /turf))
			boutput(holder.owner, "<span style=\"color:red\">It wasn't possible to remove the item from its container, oh no.</span>")
			return 1 // No cooldown when it fails.

		holder.owner.say("STYX TUSNEKS")
        //..() uncomment this when we have voice files

		var/obj/critter/snake/snake = new(stick.loc, stick)

		if (!has_spellpower)
			snake.aggressive = 0

		snake.start_expiration(2 MINUTES)

		holder.owner.visible_message("<span style=\"color:red\">[holder.owner] turns [stick] into [snake]!</span>")
		playsound(holder.owner.loc, "sound/effects/mag_golem.ogg", 25, 1, -1)
