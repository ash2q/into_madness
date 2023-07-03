--specs,defs,spawns

entities={}

e_state={
	--deciding, walking
	idle=1,
	--targeting, usage delays
	wind_up=2,
	--using move/action
	using=3,
	--todo?
	stumble=4
}
	
--😐 react mode
--🐱 fight mode
--☉ break mode
p1_aspect={
	fight=1,
	react=2,
	broken=3
}
p1={
	name="p1",
	faction=0,
	tb_anim={128,128,134,134},
	tb_spr_size=2,
	--tb_mv_anim={64,66,68,70},
	tb_x=2,
	tb_y=1,
	
	c_move_anim={64,64,72,72},
	c_anim={64,64,72,72},
	c_sz=2,
	health=50,
	max_health=100,
	--energy and clarity
	eng=0,
	eng_rate=0.1,
	max_eng=50,
	clr=0,
	clr_rate=0.1,
	max_clr=50,
	sanity=100,
	--invincibility
	inv_max=60,
	inv_count=0,
	gear={},
	idle=20,
	--efforts is either acts or moves
	--depending on p_type
	efforts={},
	moves={},
	acts={},
	equips={},
	fight_aspect={},
	p_type=p1_aspect.fight, 
	c_move_anim={128,130,132,134},
	c_anim={128,128,134,134},
	
	to_fight=function(self)
		self.efforts=self.moves
		self.p_type=p1_aspect.fight
	end,
	to_react=function(self)
		self.efforts=self.acts
		self.p_type=p1_aspect.react
	end
}


int_warrior={
	name="warrior int.",
	slot=slot_num.intrinsic,
	patk=10,
	pspd=1,
	pdef=1,
	ablt=1,
	wspd=5,
	luck=1,
}

empty_gear={
	name="empty gear",
	slot=nil, --on purpose
	patk=0,
	pspd=0,
	pdef=0,
	ablt=0,
	wspd=0,
	luck=0,
	moves={},
}

e_slime={}
e_splicer={}
tb_portal={}
tb_anim_chest={38,38}
function init_tb()
	e_slime={
		name="slime",
		intrinsic=int_slime,
		etype=1, --todo
		faction=1,
		tb_anim={6,6,7,7},
		tb_spr_size=0.75,
		c_anim={74,76},
		health=10,
		moves={bash_move},
		tb_move=tb_move_still,
		--energy(moves)
		eng=0,
		max_eng=50,
		eng_rate=0.5,
		--clarity(actions)
		clr=0,
		max_clr=50,
		clr_rate=0.5,
		ai=slime_ai,
		--populated by equips
		moves={},
		gear={},
	}
	e_splicer={
		name="splicer",
		intrinsic=int_splicer,
		etype=1, --todo
		faction=1,
		tb_anim={43,43,44,44},
		tb_spr_size=1,
		c_anim={164,166},
		health=10,
		moves={bash_move},
		tb_move=tb_move_still,
		--energy(moves)
		eng=0,
		max_eng=50,
		eng_rate=0.5,
		--clarity(actions)
		clr=0,
		max_clr=50,
		clr_rate=0.5,
		ai=slime_ai,
		--populated by equips
		moves={},
		gear={},
	}
	tb_portal={
		name="portal",
		etype=2, --todo
		faction=0,
		tb_anim={136,136,136,138,138,138},
		tb_spr_size=2
	}

end


bounce_act={}

function init_actions()
	bounce_act={
		name="bounce",
		activate=do_bounce_act,
		--how many points needed
		--to use once.
		act_points=120,
		range=80
	}
end

int_slime=nil
int_splicer=nil
pri_sword=nil
pri_spear=nil
loot_pool={}

function add_loot(l)
	add(loot_pool,l)
end
function init_gear()
	init_moves()
	int_slime={
		name="slime int.",
		slot=slot_num.intrinsic,
		tb_t=tb_type.gear,
		patk=10,
		pspd=5,
		pdef=1,
		ablt=5,
		wspd=1,
		luck=1,
		moves={slash_move},
	}
	int_splicer={
		name="splicer int.",
		slot=slot_num.intrinsic,
		tb_t=tb_type.gear,
		patk=10,
		pspd=5,
		pdef=5,
		ablt=5,
		wspd=5,
		luck=1,
		moves={slash_move},
	}
	pri_sword={
		icon=13,
		slot=slot_num.primary,
		tb_t=tb_type.gear,
		tb_anim=tb_anim_chest,
		tb_spr_size=1,
		name="sword",
		desc=
"a modern sword. nothing\n"..
"special honestly, but feels good\n"..
"in your hand",
		moves={slash_move,bash_move},
	}
	--roll_stats(pri_sword,40)
		add_loot(pri_sword)
	pri_spear={
		icon=37,
		slot=slot_num.primary,
		tb_t=tb_type.gear,
		tb_anim=tb_anim_chest,
		tb_spr_size=1,
		name="spear",
		desc=
"a primitive spear. seems pretty\n"..
"basic. faster than expected.",
		moves={bash_move},
	}
	--roll_stats(pri_spear,40)
	add_loot(pri_spear)
	
end

function spawn_enemy(spec,x,y)
	local e={
		tb_t=tb_type.enemy,
		tb_x=x,
		tb_y=y,
	}
	copy_into(e,spec)
	init_gear_slots(e)
	if e.intrinsic!=nil then
		equip(e,e.intrinsic)
	else
		assert(false)
	end
	rebuild_entity(e)
	tb_add_entity(e)
end
	

function spawn_slime(x,y)
	spawn_enemy(e_slime,x,y)
end

function spawn_splicer(x,y)
	spawn_enemy(e_splicer,x,y)
end
function spawn_gear(g,x,y)
	local e={
		tb_t=tb_type.enemy,
		tb_x=x,
		tb_y=y
		--tb_anim={38,38}
	}
	copy_into(e,g)
	tb_add_entity(e)
end


roll_num=0
function roll_stats(s,total)
	roll_num+=1
	s.aim_total=total
	local secs=stat(95)
	local mins=stat(94)
	local hours=stat(93)
	local tseed=secs+(mins*60)+(hours*60*60)
	s.seed=flr(tseed+(time()*10)
		+(roll_num*100)+(s.slot*10))
	srand(s.seed)
	aim=total/2
	--note, no magic yet
	s.patk=abs(flr(rnd(aim)))
	--s.matk=flr(rng(aim))
	s.pspd=abs(flr(rnd(aim)))
	--s.mspd=flr(rng(aim))
	--s.mdef=flr(rng(aim))
	s.pdef=abs(flr(rnd(aim)))
	s.ablt=abs(flr(rnd(aim)))
	s.wspd=abs(flr(rnd(aim)))
	s.luck=abs(flr(rnd(aim)))
	s.total=
		s.patk+s.pspd+s.pdef+
		s.ablt+s.wspd
end

function gen_sword(total)
	s={}
	copy_into(s,pri_sword)
	roll_stats(s,total)
	return s
end


slash_move=nil
bash_move=nil
function init_moves()
	--defaults
	local r_anim={33,33,34,34,35,35,36,36}
 --local t_anim={16,16,17,17,18}

slash_move={
	icon=23,
	icon_disabled=24,
	t_anim={16,16,17,17,18},
	r_anim=r_anim,
	s_anim=nil, --optional
	sound=0,
	name="❎slash",
	eng_cost=40,
	clr_cost=10,
	range=10,
	dmg=2,
	splash=false,
	spin=false,
	lock=20,
	cooldown=20,
	targets=4,
	ttl=20,
	delay=2
}
bash_move={
	icon=42,
	icon_disabled=31,
	t_anim={26,27,28,29},
	r_anim={33,33,34,34,35,35,36,36},
	s_anim=nil, --optional
	sound=0,
	name="❎bash",
	eng_cost=20,
	clr_cost=0,
	range=20,
	dmg=1,
	splash=false,
	spin=false,
	cooldown=10,
	lock=0,
	targets=1,
	ttl=20,
	delay=5
}
end


function apply_dmg(src,e,dmg,rdmg)
	if src==p1 then
		add_log("attacking!"..anim_c)
	end
	if rdmg>0 then
		play_float_text("-"..flr(rdmg),
			src.x-4,src.y-8,8)
		src.health-=rdmg
	end
	play_float_text("-"..flr(dmg),e.x-4,
		e.y-8,8)
	e.health-=dmg
end

function calc_attributes(e)
	e.eng_rate=0.5+(e.pspd*0.05)
	e.clr_rate=0.5+(e.pdef*0.05)
	e.max_eng=50+(e.wspd*2)
	e.clr_max=50+(e.ablt*2)
	e.speed=0.5+(e.wspd/10)
end

