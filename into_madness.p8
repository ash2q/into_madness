pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--into madness
--by alek(ash2q)

--turn based functions
--into madness
--a turn based rogue like with
--a sanity mechanic

--the "dungeon" state is turn
--based, while the "combat"
--state is real time

game_state={
	dungeon=1,
	combat=2,
	inventory=3,
	swap=4,
	wait=5,
	equip=6
}
anim_c=0
state=game_state.dungeon

sanity=100.0

tb_type={
	player=0,
	enemy=1,
	gear=2,
	portal=3
}
tb_depth=0

--animation helpers
shorts={}
atexts={}

function copy_into(dest,source)
	for k, v in pairs(source) do
		dest[k]=v
	end
end
function contains(t,v)
	for tmp in all(t) do
		if tmp==v then
			return true
		end
	end
	return false
end

function _init()
	printh("--init--")
	init_gear()
	init_tb()
	init_gear_slots(p1)
	init_map_pool()
	--tb_spawn_slime(4,5)
	--local sword=gen_sword(20)
	--equip(p1,sword)
	rebuild_player(p1)
	--sword=gen_sword(20)
	--r=gen_sword(40)
	--tb_spawn_gear(r,4,5)
	--trigger_swap(sword)
	p1:to_fight()
	gen_room()
end


function _update()
	anim_c+=1
	if state==game_state.dungeon
		then
		dungeon_mode()
	elseif state==game_state.combat
		then
		combat_mode()
	elseif state==game_state.equip
		then
		equip_mode()
	elseif state==game_state.swap
		then
		swap_mode()
	elseif state==game_state.wait
		then
		wait_mode()
	end
	
	--play shorts
	for s in all(shorts) do
		play_short_frame(s)
		if s.cnt>=#s.anim then
			del(shorts,s)
		end
	end
	for t in all(atexts) do
		play_atext_frame(t)
		if t.l<=0 then
			del(atexts,t)
		end
	end
end

apply_fns={}
turn_over=false
function dungeon_mode()
	cls(0)
	palt(0,false)
	palt(7,true)

	
	tb_controls()
	if turn_over then
		move_entities()
		turn_over=false
	end
	for e in all(entities) do
		if tb_same_pos(p1,e)
		then
			if e.tb_t==tb_type.enemy
				then
				trigger_combat()
				return
			elseif e.tb_t==tb_type.gear
				then
				trigger_swap(e)
			elseif e.tb_t==tb_type.portal
				then
				trigger_portal()
			else
--				assert(false)
			end
		end
	end
	
	draw_grid()
	tb_draw_player()
	tb_draw_entities()
	tb_draw_walls()
	tb_draw_status()
	if draw_room_text then
		tb_draw_tutorial()
	end
	turn_over=false
end

text_state=0
function tb_draw_tutorial()
	if text_state==0 then
		local x=24
		local y=80
		rectfill(x-3,y-3,x+29,y+13,0)
		print(
			"accept\n"..
			"warrior", x,y,15)
		x=76
		y=80
		rectfill(x-3,y-3,x+29,y+13,0)
		print(
		"accept\n"..
		"rogue", x,y,15)
		if #p1.moves>0 then
			text_state=1
		end
	elseif text_state==1 then
		local x=20
		local y= 24
		rectfill(x-3,y-3,x+80,y+32,0)
		print(
			"push 🅾️ to equip your\n".. 
			"lethal punch.\n\n"..
			"your journey begins\n"..
			"through the portal",
			x,y,15)
		if tb_depth>0 then
			text_state=2
		end
	end
end

function tb_draw_status()
	print("health: "..p1.health.."/"..p1.max_health,
		8,8,7)
	print("depth: "..tb_depth,
		96,8,7)
end

function tb_draw_walls()
	local c=0
	rectfill(0,0,128,15,c)
	rectfill(0,0,15,128,c)
	rectfill(0,128,128,128-15,c)
	rectfill(128,128,128-15,0,c)
end

function tb_add_entity(e)
	add(entities, e)
end

function tb_draw_entities()
	local c=0
	for e in all(entities) do
		c+=1
		tb_draw_entity(e,c)
	end
end

function tb_trace_still(e)
	--do nothing
	turn_over=true
end

function move_entities()
	for e in all(entities) do
		if e.tb_move!=nil then
			e.tb_move(e)
			assert(turn_over==true)
		else
			turn_over=true
		end
	end
end

function tb_draw_player()
	tb_draw_entity(p1)
end

function tb_draw_entity(e,c)
	local ac=flr(anim_c/4)
	--if e.tb_moving
	--then
		--anim=e.tb_mv_anim
	--else
	--anim=e.tb_anim
	--end
	occupants=0
	e.tb_drawn=false
	for a in all(entities) do
		if e.tb_y==a.tb_y and
				e.tb_x==a.tb_x
			then
			if not a.tb_drawn then
				break
			end
			if (a.tb_drawn!=nil and
				a.tb_drawn==true) and
				a!=e then
				occupants+=1
			end
		end
	end
	e.tb_drawn=true
	local x=0
	local y=0
	occupants%=4
	tx=e.tb_x
	ty=e.tb_y
	if occupants==0
		then
		x=tx*16
		y=ty*16
	end
	if occupants==1
		then
		x=tx*16+8
		y=ty*16
	end
	if occupants==2 
		then
		x=tx*16
		y=ty*16+8
	end
	if occupants==3 
		then
		x=tx*16+8
		y=ty*16+8
	end
	
	local sz=e.tb_spr_size
	if sz==nil then
		sz=1
	end
	local anim=e.tb_anim
	if anim==nil then
		anim=tb_anim_chest
	end
 local i=(ac%#anim)+1
	spr(anim[i],
		x+16,y+16,
		sz,
		sz)
end

function draw_grid()
	circfill(64,64,64,5)
	circfill(64,64,48,6)
	circfill(64,64,16,7)
	circ(64,64,4,0)
	--draw grid lines
	--horizontal
	for i=0,(128/16) do
		line(0,i*16,128,
			i*16,1)
	end
	--vertical
	i=0
	for i=0,(128/4) do
		line(i*16,0,i*16,128,1)
	end
end



function tb_controls()
	if btnp()==0 then

	elseif btnp(0) then
		tb_mv_left(p1)
	elseif btnp(1) then
		tb_mv_right(p1)
	elseif btnp(2) then
		tb_mv_up(p1)
	elseif btnp(3) then
		tb_mv_down(p1)
	elseif btnp(4) then
		trigger_equip_mode()
		
	elseif btnp(5) then
		--use item?
	end
		
end

function tb_mv_left(e)
	e.moved=true
	if e.tb_x>0 then
		e.tb_x-=1
	end
	turn_over=true
end
function tb_mv_right(e)
	e.moved=true
	if e.tb_x<5 then
		e.tb_x+=1
	end
	turn_over=true
end
function tb_mv_up(e)
	e.moved=true
	if e.tb_y>0 then
		e.tb_y-=1
	end
	turn_over=true
end
function tb_mv_down(e)
	e.moved=true
	if e.tb_y<5 then
		e.tb_y+=1
	end
	turn_over=true
end

function tb_same_pos(e1,e2)
	--printh("ex1: "..e1.tb_x..", ex2: "..e2.tb_x)
	if e1.tb_x==e2.tb_x and
			e1.tb_y==e2.tb_y
		then
		return true
	else
		return false
	end
end

function tb_move_square(e)

	if e.t_cnt==nil then
		e.t_cnt=4
	end
	if e.t_cnt==4 then
		tb_mv_up(e)
	elseif e.t_cnt==3 then
		tb_mv_left(e)
	elseif e.t_cnt==2 then
		tb_mv_down(e)
	elseif e.t_cnt==1 then
		tb_mv_right(e)
		e.t_cnt=nil
	end
	if e.t_cnt!=nil then
		e.t_cnt-=1
	end
end

shorts={}
function play_anim(anim,x,y,w,h)
	if w==nil then w=1 end
	if h==nil then h=1 end
	short={
		anim=anim,
		x=x,
		y=y,
		w=w,
		h=h,
		cnt=1,
		div=1
	}
	add(shorts,short)
end
function play_text(t,l,x,y,col)
	text={
		t=t,
		l=l, --length
		x=x,
		y=y,
		col=col,
		float=false
	}
	add(atexts,text)
end
function play_float_text(t,x,y,col)
	text={
		t=t,
		l=20, --length
		x=x,
		y=y,
		col=col,
		float=true
	}
	add(atexts,text)
end
function entity_text(e,txt,col)
	play_float_text(txt,10,
			e.x-4,e.y-6,col)
end


function play_short_frame(s)
	c=flr(anim_c/s.div)
	if c%s.div==0 then
		--divide time
		s.cnt+=1
	else
		--redraw last frame
	end
	spr(s.anim[s.cnt-1],s.x-4,s.y-4,s.w,s.h)
end

function play_atext_frame(s)
	if s.float then
		s.y-=0.75
	end
	print(s.t,s.x,s.y,s.col)
	s.l-=1
	spr(s.anim,s.x,s.y,s.w,s.h)
end

function trigger_dungeon()
	state=game_state.dungeon
end


function equip(ent,g)
	--unequip(ent,s)
	assert(g!=nil)
	add(ent.gear,g)
	rebuild_entity(ent)
end

function unequip(ent,slot)
	if ent.gear==nil then
		return
	end
	ent.gear[slot]=nil
end

function calc_stats(ent)
	ent.patk=0
	ent.pspd=0
	ent.pdef=0
	ent.ablt=0
	ent.wspd=0
	ent.luck=0
	printh("y")
	for g in all(ent.gear) do
		printh("x")
		ent.patk+=1--g.patk
		ent.pspd+=g.pspd
		ent.pdef+=g.pdef
		ent.ablt+=g.ablt
		ent.wspd+=g.wspd
		ent.luck+=g.luck
	end
end

function has_move(ent,name)
	for i in all(ent.moves) do
		if i==name then
			return true
		end
	end
end

function move_lvl(ent,name)
	local c=0
	for g in all(ent.gear) do
		for i in all(g.moves) do
			if i==name then
				c+=1
			end
		end
	end
	return c
end

function rebuild_lists(ent)
	ent.moves={}
	ent.mcount={}
	for g in all(ent.gear) do
		--assert(g.moves!=nil)
		for m in all(g.moves) do
			if not contains(
					ent.moves,m)
				then
				add(ent.moves,m)
				tmp=ent.move_lvls[m]
				if tmp==nil
					then
					local t={}
					copy_into(t,all_moves[m])
					ent.move_lvls[m]=t
				end
			else
				--does contain
			end
		end --for m
	end
		
end

function rebuild_entity(e)
	e.eng=0
	e.clr=0
	calc_stats(e)
	calc_attributes(e)
	rebuild_lists(e)
end

function rebuild_player(e)
	rebuild_entity(e)
	if e.selected_move!=nil and
			not contains(
				e.moves,e.selected_move) 
		then
		--if #e.moves==0
		e.selected_move=nil --e.m0ves[0]
	end
end

function init_gear_slots(e)
	--while #e.gear<#slot_names do
		--add(e.gear,empty_gear)
	--end
end

log_msgs={"","",""}
function add_log(msg)
	add(log_msgs,msg)
end

function print_logs()
	--for i=#log_msgs,i=#log_msgs-3,-1 do
	for i=0,2 do
		local l=#log_msgs
		print(log_msgs[l-i],1,120-(i*8),7)
	end
end

--specs,defs,spawns

entities={}

	
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
	c_move_anim={128,130,132,134},
	c_anim={128,128,134,134},
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
	--this is all the move names available
	moves={},
	--this is a copied version
	--of the base all_moves copy.
	--This has levels etc applied.
	--key-value pair
	move_lvls={},

	acts={},
	--equips are mapped for use in
	--combat! Only 3 at a time
	equips={},
	fight_aspect={},
	p_type=p1_aspect.fight, 
	to_fight=function(self)
		self.efforts=self.moves
		self.p_type=p1_aspect.fight
	end,
	to_react=function(self)
		self.efforts=self.acts
		self.p_type=p1_aspect.react
	end,
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
		moves={},
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
		move_lvls={},
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
		moves={"bash"},
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
		move_lvls={},
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
int_warrior=nil
loot_pool={}
all_moves={}

function add_loot(l)
	add(loot_pool,l)
end
function init_gear()
	init_moves()
	int_slime={
		name="slime int.",
		tb_t=tb_type.gear,
		patk=10,
		pspd=5,
		pdef=1,
		ablt=5,
		wspd=1,
		luck=1,
		moves={"slash"},
		seed=0
	}
	int_splicer={
		name="splicer int.",
		tb_t=tb_type.gear,
		patk=10,
		pspd=5,
		pdef=5,
		ablt=5,
		wspd=5,
		luck=1,
		moves={"slash"},
		seed=0
	}
	start_module={
		icon=13,
		tb_t=tb_type.gear,
		tb_anim=tb_anim_chest,
		tb_spr_size=1,
		moves={"bash"},
		patk=1,
		pspd=1,
		pdef=1,
		ablt=1,
		wspd=1,
		luck=1,
		seed=0,
		slot=1,
	}
	int_warrior={
		name="warrior int.",
		patk=10,
		pspd=1,
		pdef=1,
		ablt=1,
		wspd=5,
		luck=1,
		moves={"punch"},
		slot=1
	}

	int_rogue={
		name="rogue int.",
		patk=1,
		pspd=20,
		pdef=10,
		ablt=1,
		wspd=5,
		luck=2,
		moves={"punch"},
		slot=1
	}

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
		tb_t=tb_type.gear,
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
		+(roll_num*100))
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
punch_move=nil
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
	name="slash",
	desc=
"a broad focused slash.\n"..
"damages several.\n\n"..
"cut them cut them cut them",
	eng_cost=40,
	clr_cost=10,
	range=10,
	dmg=2,
	splash=false,
	spin=false,
	lock=20,
	cooldown=5,
	targets=4,
	ttl=20,
	delay=2
}
all_moves.slash=slash_move
bash_move={
	icon=42,
	icon_disabled=31,
	t_anim={26,27,28,29},
	r_anim={33,33,34,34,35,35,36,36},
	s_anim=nil, --optional
	sound=0,
	name="bash",
	desc=
"a brutal yet simple bash\n"..
"simple yet subpar.\n\n"..
"they told me to do it",
	eng_cost=20,
	clr_cost=0,
	range=20,
	dmg=1,
	splash=false,
	spin=false,
	cooldown=5,
	lock=0,
	targets=1,
	ttl=20,
	delay=5
}
all_moves.bash=bash_move

punch_move={
	icon=56,
	icon_disabled=31,
	t_anim={26,27,28,29},
	r_anim={33,33,34,34,35,35,36,36},
	s_anim=nil, --optional
	sound=0,
	name="punch",
	desc=
"Inspired by a visit to\n"..
"a land of punches\n\n"..
"harder, please, more, please",
	eng_cost=10,
	clr_cost=0,
	range=20,
	dmg=0.5,
	splash=false,
	spin=false,
	cooldown=2,
	lock=0,
	targets=1,
	ttl=20,
	delay=5
}
all_moves.punch=punch_move

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

--combat

--all enemies within the same
--grid position
c_entities={}

function trigger_combat()
	setup_combat()
	state=game_state.combat
end

function setup_combat()
	p1.x=8
	p1.y=70
	p1.moved=false
	--p1.moves={slash_move}
	p1.selected_move=nil --p1.moves[1]
	
	--print_table("-----player 1-----"
	--	,p1)
	c_entities={}
	add(c_entities,p1)
	
	for e in all(entities) do
		if tb_same_pos(p1,e)
			and e.tb_t==tb_type.enemy
		then
			add(c_entities,e)
		end
	end
	y=80
	for e in all(c_entities) do
		if e.faction==1 then
			e.x=70
			e.y=y
			e.moved=false
			y+=20
		end
	end
	assert(#c_entities>1)
end

function combat_mode()
	cls(6)
	palt(0,false)
	palt(7,true)
	draw_backdrop()
	draw_hud()
	--c_draw_player()
	c_draw_entities()
	print_logs()
	if parry_state!=parry.done then
		c_parry()
		return
	end
	
	parry_dmg_mul=1
	parry_rdmg_mul=0
	process_swings_2()
	track_inputs()
	c_player_control()
	for e in all(entities) do
		c_enemy_control(e)
	end
	draw_swings()
	sanity_distortion()
	if dial_display then
		draw_dial()
	end
	
	c_clean_enemies()
	if #c_entities==1 then
		--battle done!
		trigger_dungeon()
	end
	track_charging(p1)
	for e in all(c_entities) do
		track_charging(e)
	end
end

function track_charging(e)
	if e.eng < e.max_eng then
		e.eng+=e.eng_rate
	else
		e.eng=e.max_eng
	end
	if e.clr < e.max_clr then
		e.clr+=e.clr_rate
	else
		e.clr=e.max_clr
	end
end

function c_clean_enemies()
	for e in all(c_entities) do
		if e.faction>0 then
			if e.health<=0 then
				del(c_entities,e)
				del(entities,e)
			end
		end
	end
end

function c_enemy_control(e)
	if p1!=e and 
			e.tb_t==tb_type.enemy then
		if e.ai!=nil then
			e.ai(e)
		end
	end
end

double_press=0
z_hold=false
function c_player_control()
	x_used=false
	xold=p1.x
	yold=p1.y
	yvel=0
	xvel=0
	if z_hold then
		if btn(0) then
			--execute dial actions
			--switch_aspects()
		elseif btn(1) then
		elseif btn(2) then
		elseif btn(3) then
		elseif not btn(4) then
			--released, exit hold
			z_hold=false
			return
		end
	end
	if btn(0) then
		xvel=-p1.speed
	end
	if btn(1) then
		xvel=p1.speed
	end
	if btn(2) then
		yvel=-p1.speed
	end
	if btn(3) then
		yvel=p1.speed
	end
	if btn()==0x0010 or --only 🅾️
			dial_display
		then
		--menu (actions)
		dial_display=true
		z_hold=true
		local num=0
		if btn(⬅️) then
			num=1
			dial_display=false
		elseif btn(➡️) then
			num=2
			dial_display=false
		elseif btn(⬆️) then
			num=3
			dial_display=false
		elseif btn(⬇️) then
			num=4
			dial_display=false
		elseif not btn(🅾️) then
			dial_display=false
		end
		if num!=nil and p1.equips[num]!=nil 
			then
			p1.selected_move=p1.moves[num]	
		end
	else
		z_hold=false
		dial_display=false
	end
	if btnp(5) and not btn(4) then
		--primary
		p_swing()
		--if double_press
	end
	
	--compensate diagnol moves
	if abs(xvel)>0 and abs(yvel)>0
		then
		xvel*=0.707
		yvel*=0.707
	end
	c_move_p1(p1.x,p1.y,xvel,yvel)
end

function c_move_p1(old_x,old_y,vel_x,vel_y)
	local x=old_x+vel_x
	local y=old_y+vel_y
	--don't allow out of combat area
	if x<8 or x>120 then
		vel_x=0
	end
	if y<48 or y>92 then
		vel_y=-0
	end
	
	p1.moved=abs(vel_x)>0 or abs(vel_y)>0
	p1.x+=vel_x
	p1.y+=vel_y
end

function switch_aspects()
	old=nil
	new=nil
	if p1.p_type==p1_fight.p_type
		then
		old=p1_fight
		new=p1_react
	elseif
			p1.p_type==p1_react.p_type
		then
		old=p1_react
		new=p1_fight
	else
		assert(false)
	end
	old.moves=p1.moves
	old.eng_rate=p1.eng_rate
	old.clr_rate=p1.clr_rate
	old.selected_move=
		p1.selected_move
	
	--equivalent
	copy_into(old,p1)
	--p1.moves=new.moves
	--p1.eng_rate=new.eng_rate
	--p1.clr_rate=new.clr_rate
	--p1.selected_move=
	--	new.selected_move
end

function eng_full(p)
	m=p1.selected_move
	--assert(m!=nil)
	if m==nil then return false end
	if m.cost>e.eng then
		return false
	end
	return true
end

--only for player
function p_swing()
	m=p1.selected_move
	if m!=nil then
		player_swing(m)
	end
end

function recalc_stats(e)
	e.patk=0
	e.pspd=0
	e.pdef=0
	e.ablt=0
	e.wspd=0
	for t in all(equips) do
		e.patk+=t.patk
		e.pspd+=t.pspd
		e.pdef+=t.pdef
		e.ablt+=t.ablt
		e.wspd+=t.wspd
	end
end


function c_draw_player()
	anim={}
	if p1.moved!=nil and p1.moved
		then
		anim=p1.c_anim
	else
		anim=p1.c_idle_anim
	end
	c=flr(anim_c/3)
	tmp=c%#anim
	tmp+=1
	spr(anim[tmp],p1.x-8,p1.y-8,2,2)
end

function c_draw_entities()
	for e in all(c_entities) do
		c=flr(anim_c/3)
		local anim=e.c_anim
		if e.moved!=nil and e.moved
			then
			anim=e.c_move_anim
		else
			anim=e.c_anim
		end
		if anim==nil then
			anim={38} --chest
		end
		tmp=(c%#anim)+1
		spr(anim[tmp],e.x-8,e.y-8,2,2)
	end
end


function draw_backdrop()
	sz=32
	--draw grid lines
	--horizontal
	for i=0,(48/sz) do
		line(0,i*sz,128,i*sz,5)
	end
	--vertical
	i=0
	for i=0,(64/4) do
		line(i*sz,0,i*sz,48,5)
	end
	
	line(0,48,128,48,5)
end


tix_buffer_sz=10
tix_buffer={}
tiz_buffer_sz=10
tiz_buffer={}
tap_delay_min=1
tap_delay_max=6
--todo this is an awful way
--of doing this, but it works
--for now...
function track_inputs()
	local tmp={}
	tmp[1]=btn(❎)
	for i=1,tix_buffer_sz do
		tmp[i+1]=tix_buffer[i]
	end
	tix_buffer=tmp
	local tmp={}
	tmp[1]=btn(🅾️)
	for i=1,tiz_buffer_sz do
		tmp[i+1]=tiz_buffer[i]
	end
	tiz_buffer=tmp
end

function ti_humps(buf)
	local humps=0
	local prev=false
	local in_h=false
	for i=0,#buf do
		if in_h then
			if not buf[i] then
				in_h=false
			end
		else
			if buf[i] then
				if prev then
					in_h=true
				else
					in_h=true
					humps+=1
				end
			end 
		end --end if not in_h
		prev=buf[h]
	end
end

function x_single_tap()
	
end
function x_held()
end
function x_double_tap()
end

--hud and swings

function draw_hud()
	local col=0
	local m=""
	if p1.p_type==p1_aspect.react then
		m="😐"
		col=14
	elseif p1.p_type==p1_aspect.fight then
		m="🐱"
		col=12
	end

	rectfill(0,0,128,12,col)
	color(7)
	palt(0,true)
	rectfill(14,2,22,11,0)
	rect(14,2,22,11,6)
	
	print(m,2,5,7)
	--if p1.eng >= p1.max_eng then
	--	rectfill(15,3,21,10,3)
	--end
	local m=nil
	local s=nil
	m=p1.selected_move
	if m!=nil then
		s=p1.move_lvls[m].icon
		if p1.move_lvls[m].eng_cost>p1.eng then
			s=m.icon_disabled
		end
		spr(s,15,3)
	end


	palt(0,false)
	
	print("eng:",25,5,7)
	local col=7
	if p1.eng>=p1.max_eng then
		col=11
	end
	meter(p1.eng,p1.max_eng,
		40,4,col)
	print("clr:", 60,5,7)
	col=7
	if p1.clr>=p1.max_clr then
		col=11
	end
	meter(p1.clr,p1.max_clr,75,4,col)
	
	draw_log()
	draw_sanity()
end


function draw_sanity()
	print("self:",98,4,7)
	rect(118,1,127,10,6)
	local s=48
	if sanity<80 then
		s=49
	end
	if sanity<60 then
		s=50
	end
	if sanity<40 then
		s=51
	end
	if sanity<20 then
		s=52
	end
	--palt(0,false)
	palt(7,false)
	spr(s,119,2)
	palt(7,true)
end

function sanity_distortion()
	sanity=50
	if sanity<80 then

	end
	if sanity<60 then
	
	end
	if sanity<40 then
		for i=0,20 do
			local t=rnd(16)
			line(0,t,
				128,t,7)
		end
	end
	if sanity<20 then
		for i=0,20 do
			local t=rnd(128)
			line(0,t,
				128,t,0)
		end
		if sanity<10 then
			for i=0,20 do
				local t=rnd(128)
				line(0,t,128,t,7)
			end
		end
	end
end

function draw_log()
	rect(0,99,127,127,7)
	rectfill(1,100,126,126,0)
end

function meter(v,mx,x,y,col)
	x1=x
	x2=x+16
	y1=y
	y2=y+5
	--black box
	rectfill(x1,y1,x2,y2,5)
	--draw bar
	o=16.0*((v+.0)/mx)
	rectfill(
		x,y,
		x+o,
		y+5,
		col)
end


function draw_dial()
	local c=anim_c%3
	--up
	local a=p1.equips[3]
	local t="[empty]"
	if a!=nil then
		t=a
	end
	local x=40
	local y=25
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(40,x+20,y+12)
	end
	print(t,x+1,y+2,7)
	--left
	a=p1.equips[1]
	t="[empty]"
	if a!=nil then
		t=a
	end
	x=8
 	y=44
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(41,x+43,y+1)
	end
	print(t,x+1,y+2,7)
	--down
	a=p1.equips[4]
	t="[empty]"
	if a!=nil then
		t=a
	end
	x=40
	y=65
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(40,x+20,y-12,1.0,1.0,
			false,true)
	end
	print(t,x+1,y+2,7)
	--right
	a=p1.equips[2]
	t="[empty]"
	if a!=nil then
		t=a
	end
	x=80
 y=44
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(41,x-12,y+1,1.0,1.0,true)
	end
	print(t,x+1,y+2,7)
	
end

function draw_parry_hud()
	
end

swings={}
function add_swing(src,mv)
	local s={
		--dist=xd+yd,
		mv=mv,
		src=src,
		cooldown=src.move_lvls[mv].cooldown,
		hitbox=4,
		lock=mv.lock,
		rotate=true, --todo
		cnt=0,
		done=false,
		hits={},
		state=0,
		ttl=src.move_lvls[mv].ttl,
		delay=src.move_lvls[mv].delay
	}
	if check_costs(s) then
		add(swings,s)
	else
		return nil
	end
	return s
end

function in_hitbox(e,sw)
	m=sw.hitbox/2.0
	local xd=abs(e.x-sw.x)
	local yd=abs(e.y-sw.y)
	if anim_c%8==0
		then
		rect(sw.x-m,sw.y-m,sw.x+m,
			sw.y+m,14)
	end
	if xd<m and yd<m then
		return true
	end
	return false
end

function has_swing(e)
	for s in all(swings) do
		if s.src==e then
			return false
		end
	end
	return true
end

function player_swing(mv)
	p=p1
	if not has_swing(p) then
		return nil
	end
	local s=add_swing(p1,mv)
	if s==nil then return nil end
	s.x=p.x+8
	s.y=p.y
	s.hitbox=16
	return s
end

function enemy_swing(e,mv)
	if not has_swing(e) then
		return nil
	end
	return nil
	--local s=add_swing(e,mv)
	--if s==nil then return nil end
	--s.x=e.x-8
	--s.y=e.y
	--s.hitbox=16
	--return s
end

function swing_hit(e,s)
	if parry_dmg_mul>0 then
		play_anim(
			s.src.move_lvls[s.mv].t_anim,
			e.x,e.y)
	end
	if parry_rdmg_mul>0 then	
		play_anim(
			s.src.move_lvls[mv].r_anim,
			s.src.x,s.src.y)
	end
	apply_dmg(s.src,e,
		calc_dmg(s),calc_rdmg(s))
end

--computes damage for swing
function calc_dmg(s)
	local d=
		s.src.move_lvls[s.mv].dmg
	d*=(s.src.patk/10)+1
	d*=parry_dmg_mul
	--todo apply armor etc
	return d
end
function calc_rdmg(s)
	local d=s.src.move_lvls[s.mv].dmg
	d*=parry_rdmg_mul
	--todo apply armor etc
	return d
end



s_state={
	generate=0,
	begin=1,
	locking=2,
	locked=3,
	parry=4,
	cooldown=5,
	done=6
}


function process_swings_2()
	for sw in all(swings) do
		process_swing(sw)
		if sw.state==s_state.done then
			apply_costs(sw)
			del(swings,sw)
		end
	end	
end

function process_swing(sw)
	sw.ttl-=1
 if sw.state==s_state.generate
 	then
 	if sw.gen_count==nil or 
 			sw.gen_count<=0 then
 		sw.state=s_state.begin
 		return
 	end
 	local s={}
 	copy_into(s,sw)
 	s.gen_count=0
 	sw.gen_count-=1
 	add(swings,s)
 end
 	
	if sw.state==s_state.begin
		then
		if sw.ttl<=0 then
			sw.missed=true
			play_float_text("miss!",
				sw.src.x-6,sw.src.y-4,7)
			sw.state=s_state.done
		else
			sw.missed=false		
			for e in all(c_entities) do
				
				if e.faction!=sw.src.faction
					then
					if in_hitbox(e,sw) then
						if sw.lock==nil then
							sw.lock=
								sw.src.move_lvls[sw.mv].lock
						end
						if sw.lock<=0 then
							sw.state=s_state.locked
						else
							sw.state=s_state.locking
						end
						sw.target=e
						break
					end
				end
			end --end for entities
		end --end if ttl
	elseif sw.state==s_state.locking
		then
		if sw.lock==0 then
			--requires no locking
			
		end
		if (p1==sw.target and
				btn(5) and btn(4))
				--or (p1!=sw.target and 
				--sw.target.luck*10>rnd(1000)) 
			then
			if sw.parry_hold==nil then
				sw.parry_hold=5
			end
			if sw.parry_hold>0 then
				sw.parry_hold-=1
			else
				sw.parried=true
			end
		end
		
		if in_hitbox(sw.target,sw) then
			draw_target(sw.src,
				sw.target,sw.lock)
			sw.lock-=1
		else
			sw.state=s_state.done
			sw.lock=sw.mv.lock
		end
		if sw.lock<=0 then
			sw.state=s_state.locked
		end
	elseif sw.state==s_state.locked
		then
		assert(sw.target!=nil)
		if sw.delay<=0 then
			if sw.parried then
				sw.state=s_state.parry
			else
				swing_hit(sw.target,sw)
				sw.state=s_state.cooldown
			end
		end
		sw.delay-=1
	elseif sw.state==s_state.parry
		then
			if p1==sw.target then
				parry_swing_player(sw)
				sw.state=s_state.cooldown
			else
				parry_swing(sw)
				sw.state=s_state.cooldown
			end
	elseif sw.state==s_state.cooldown
		then
		sw.cooldown-=1
		if sw.cooldown<=0 then
			sw.state=s_state.done
		end
	end
end

function apply_costs(sw)
	local m=
		sw.src.move_lvls[sw.mv]
	local src=sw.src
	if sw.missed then
		src.eng-=m.eng_cost/2
		src.clr-=m.clr_cost/2
	else
		src.eng-=m.eng_cost
		src.clr-=m.clr_cost
	end
end

function check_costs(sw)
	local src=sw.src
	local m=src.move_lvls[sw.mv]
	if src.eng<m.eng_cost then
		return false
	end
	if src.clr<m.clr_cost then
		return false
	end
	return true
end

function parry_swing_player(sw)
	parry_speed=1.5
	parry_e=sw.target
	parry_src=sw.src
	parry_sw=sw
	parry_state=parry.begin
end

function parry_swing(sw)
	if true then
		--disable enemy parry for now
		return 
	end
	parry_speed=1.5
	parry_e=sw.target
	parry_src=sw.src
	parry_sw=sw
	parry_state=parry.begin
end

function is_swinging(e)
	for s in all(swings) do
		if s.src==e then
			return true
		end
	end
	return false
end

function draw_swings()
	for s in all(swings) do

		--spr(s.mv.t_anim[s.t_f],
		--		s.t_x,s.t_y)
			--todo source animation
	end
end

--parry and enemy ai

rainbow_col={
	7,8,9,10,11,12,13,14
}

parry={
	begin=1,
	ready=2,
	sliding=3,
	show=4,
	done=5,
}
parry_state=parry.done
parry_go=false
--cursor
parry_cur=0
--where "lucky" region starts
--(on x-axis)
lucky_parry=0
--order is important!
lucky_len=1
parry_len=1
dodge_len=1
block_len=3
unlucky_len=8
--(end ordered)
show_delay=nil
parry_sim=false
--user variables
parry_speed=1
parry_e=nil
parry_src=nil
parry_sw=nil
--results
parry_dmg_mul=1
parry_rdmg_mul=0
parry_msg="nothing."

function c_parry()
	if parry_sw.target!=p1 then
		parry_sim=true
	end
	local msg="❎"
	local blink=12
	if parry_sim then
		msg="😐"
		blink=8
	end
	rectfill(16,16,112,32,0)
	if anim_c%4<2 or 
			parry_state==parry.show then
		print(msg,18,22,7)
	else
 	print(msg,18,22,blink)
	end
	if parry_state==parry.begin then
		if parry_sim or not btn(5) then
			parry_state=parry.ready
			show_delay=10
			parry_cur=0
		end
		return
	end
	--width of about 70
	rect(30,20,106,28,6)
	
	if parry_state==parry.ready then
		if parry_sim or btnp(5) then
			parry_state=parry.sliding
			lucky_parry=rnd(40)+20
			xd=flr(abs(parry_src.x-parry_e.x))
			yd=flr(abs(parry_src.y-parry_e.y))
			xd=min(xd,35)
			xd=min(yd,35)
			--d=flr(xd+yd)
			--todo unsure why this being
			--dynamic doesn't work
			d=30
			
			--printh("diff: "..d)
			--assert(false)
			lucky_parry=d+20
		end
		return
	end
	if parry_state==parry.sliding or
			parry_state==parry.show
		then
		x1=30+lucky_parry
		x2=x1+lucky_len
		rectfill(x1,21,
				x2,27,
				rainbow_col[anim_c%#rainbow_col+1])
		x1+=lucky_len
		x2+=parry_len
		rectfill(x1,21,x2,27,11)
		x1+=parry_len
		x2+=dodge_len
		rectfill(x1,21,x2,27,3)
		x1+=dodge_len
		x2+=block_len
		rectfill(x1,21,x2,27,10)
		x1+=block_len
		x2+=unlucky_len
		rectfill(x1,21,x2,27,8)
		
		
		line(30+parry_cur,18,
			30+parry_cur,30,blink)
		if parry_state==parry.sliding
			then
			local sim_press=false
			if parry_sim then
				sim_press=
					parry_sw.src.luck*10<
					rnd(1000)
			end
			if (sim_press or btn(5)) and
					parry_cur<106-33
			 then		
				parry_cur+=parry_speed
				return
			else
				parry_state=parry.show
			end
		end
	end
	if parry_state==parry.sliding
		then
		return
	end
	assert(parry_state==parry.show)
	if parry_cur>=106-33 then
		--end of gauge
	end
	parry_msg=""
	if parry_cur<lucky_parry then
		parry_msg="nothing."
		parry_rdmg=0
		parry_dmg_mul=1
	elseif parry_cur<=
			lucky_parry+lucky_len
		then
		parry_msg="lucky!"
		parry_rdmg_mul=3.0
		parry_dmg_mul=0.0
		--stop()
	elseif parry_cur<=
			lucky_parry+parry_len+lucky_len
		then
		parry_msg="parry!"
		parry_rdmg_mul=1.0
		parry_dmg_mul=0.0
	elseif parry_cur<=
			lucky_parry+dodge_len+parry_len+lucky_len
		then
		parry_msg="dodge!"
		parry_dmg_mul=0.0
	elseif parry_cur<=
			lucky_parry+block_len+parry_len+dodge_len+lucky_len
		then
		msg="block!"
		parry_dmg_mul=0.5
	elseif parry_cur<=
		lucky_parry+unlucky_len+parry_len+block_len+dodge_len+lucky_len
		then
		parry_msg="unlucky!"
		dmg_mul=3.0
	else
		parry_msg="nothing."
		dmg_mul=1.0
	end
	print(parry_msg,32,22,7) 
	show_delay-=1
	if show_delay<=0 then
		parry_state=parry.done
		swing_hit(parry_e,parry_sw)
		--m.fn(m,parry_src,parry_e)
	end
end

--src, entity, len
function draw_target(se,e,l)
	if l%6<2 then
		if se.faction<=0 then
			blink=1
		else
			blink=8
		end
		line(se.x,se.y,e.x,e.y,blink)

		circ(e.x,e.y,8,blink)
	end
end


targeting_frames=14
function slime_ai(e)
	if e.eng<e.max_eng then return end
	if e.idle==nil or e.idle<=0 then
		e.idle=100
	else
		e.idle-=1
		return
	end
	av_moves={}
	for mv in all(e.move_lvls) do
		if e.eng>=mv.eng_cost then
			add(av_moves,mv)
		end
	end
	enemy_swing(e,av_moves[1])
	
	
end

--use, swap, status mode

--the different tabs
page_tab={
	status,
	moves,
}

function trigger_swap(g)
	next_state=game_state.swap
	wait_time=20
	wait_msg=
"entering swap, please release keys"
	swap_gear=g
	assert(swap_gear!=nil)
	state=game_state.wait
end


function init_equip()
	eq_line=1
end

eq_prev_state=nil

function trigger_equip_mode()
	eq_prev_state=state
	state=game_state.equip
end

eq_line=1
function equip_mode()
	cls()
	reset()
	local y=16
	for m in all(p1.moves) do
		local col=7
		if contains(p1.equips, m)
			then
			col=11
			print("e",2,y,col)
		end
		print(m,9,y,col)
		y+=8
	end
	if anim_c%2<1 then
		spr(55,0,14+(8*(eq_line-1)))
	else
	end
	if eq_line>#p1.moves then
		eq_line=1
	end
	printh(p1.moves[eq_line])
	local m=
		p1.move_lvls[p1.moves[eq_line]]
	assert(#p1.moves>0)
	assert(m!=nil)
	if m==nil then
		eq_leave()
		return
	end
	--bottom text (description)
	rect(0,96,127,127,7)
	print(m.desc,2,98,7)
	--side text (stats)
	rect(80,10,127,82,7)
	local y=12
	print("costs:",82,y,7)
	y+=8
	print(" eng: "..m.eng_cost,82,y,7)
	y+=8
	print(" clr: "..m.clr_cost,82,y,7)
	y+=8
	print("range:"..m.range,82,y,7)
	y+=8
	print("damage:"..m.dmg,82,y,7)
	y+=8
	print("targets:"..m.targets,82,y,7)
	y+=8
	print("lock-on:"..m.lock,82,y,7)
	eq_mode_ctrl()
end




function eq_mode_ctrl()
	if btnp(⬇️) then
		eq_line+=1
	elseif btnp(⬆️) then
		eq_line-=1
	elseif btnp(❎) then
		--equip/unequip
		local m1=p1.moves[eq_line]
		if contains(p1.equips,m1)
			then
			del(p1.equips,m1)
		elseif #p1.equips<=3 then
			add(p1.equips,m1)
		end
	elseif btnp(🅾️) then
		--leave menu
		eq_leave()
	elseif btnp(⬅️) then
		--?
	elseif btnp(➡️) then
		--?
	end
	
	if eq_line<=0 
		then
		eq_line=#p1.moves
	elseif eq_line>#p1.moves
		then
		eq_line=1
	end
end

function eq_leave()
	init_equip()
	state=eq_prev_state
end


slot_names={
	"intrinsic",
	"helmet",
	"chestpiece",
	"pants",
	"shoes"
}

swap_gear=nil
function swap_mode()
	cls()
	color(7)
	local g1=p1.gear[swap_gear.slot]
	if g1==nil or g1.seed==nil 
		then
		g1={}
		g1.seed=0
		g1.name="[empty]"
		g1.patk=0
		g1.pspd=0
		g1.pdef=0
		g1.ablt=0
		g1.wspd=0
		g1.luck=0
		g1.moves={}
	end
	local g2=swap_gear
	--assert(g1!=nil)
	assert(g2!=nil)
	print(
"old(stat) -> new(stat)")
	local t=slot_names[g2.slot]
	print("slot: "..t)
	if g2.seed==nil then
		g2.seed=0
	end
	assert(g2.seed!=nil)
	print("seed:"..g2.seed.."->"..g2.seed)
	y=18
	print_compare("patk",
		g1.patk,g2.patk,p1.patk,y)
	y+=6
	print_compare("pspd",
		g1.pspd,g2.pspd,p1.pspd,y)
	y+=6
	print_compare("pdef",
		g1.pdef,g2.pdef,p1.pdef,y)
	y+=6
	print_compare("ablt",
		g1.ablt,g2.ablt,p1.ablt,y)
	y+=6
	print_compare("wspd",
		g1.wspd,g2.wspd,p1.wspd,y)
	y+=6
	print_compare("luck",
		g1.luck,g2.luck,p1.luck,y)
	y+=6
	if #g1.moves>0 or #g2.moves>0
		then
			print("moves:",0,y,7)
		else
			print("no moves",0,y,7)
		end
	y+=6
	for i=1,max(#g1.moves,#g2.moves) do
		local m1=g1.moves[i]
		local m2=g2.moves[i]
		if m1==nil then
			m1="empty move"
		end
		if m2==nil then
			m2="empty move"
		end
		local col=7
		if m1==m2 then
			col=8
		end
		local lvl1=move_lvl(p1,m1)
		local lvl2=move_lvl(p1,m2)
		print(""..m1.."v"..lvl1,2,y,col)
		print("->", 50,y,7)
		print(""..m2.."v"..lvl2,60,y,col)
		y+=6
	end
	print(
"❎ to swap,⬅️ to leave behind",
		0,y,7)
		
		if btnp(5) then
			p1.gear[swap_gear.slot]=g2
			del(entities,g2)
			rebuild_player(p1)
			state=game_state.dungeon
		end
		if btnp(0) then
			del(entities,g2)
			state=game_state.dungeon
		end
end
	
function print_compare(lbl,old,
		new,total,y)
	local t_l=""..
		(total)
	local t_r=""..
		(total-old+new)
	if old>new then
		rc=8
		lc=11
	elseif old==new then
		rc=7
		lc=7
	else
		rc=11
		lc=8
	end
	local paren_l="("..
		old..")"
	local paren_r="("..
		new..")"
	print(""..lbl..":",0,y,7)
	print(""..t_l..paren_l,
		20,y,lc)
	print("->",50,y,7)
	print(""..t_r..paren_r,
		60,y,rc)
end

next_state=nil
wait_time=nil
wait_msg=""
function wait_mode()
	cls()
	if wait_time==nil then
		return
	end
	if wait_time<0 then
		wait_time=nil
		state=next_state
		return
	end
	color(7)
	print(wait_msg)
	wait_time-=1
end

--map generation

function gen_room_1()
	
end

map_pool={}

function init_map_pool()
	e_pool={}
	add(e_pool,e_slime)
	add(e_pool,e_splicer)
end
function spawn_rnd_enemy(x,y)
	local s=e_pool[flr(rnd(#e_pool))+1]
	spawn_enemy(s,x,y)
end

function spawn_descend(x,y)
	local e={
		tb_t=tb_type.portal,
		tb_x=x,
		tb_y=y,
	}
	copy_into(e,tb_portal)
	tb_add_entity(e)
end


function spawn_rnd_gear(x,y)
	local g=gen_loot_item(20+tb_depth*2)
	spawn_gear(g,x,y)
end

function gen_room_0()
	entities={}
	local int=int_warrior
	spawn_gear(int,1,3)
	local int=int_rogue
	spawn_gear(int,4,3)
	draw_room_text=true
	spawn_descend(2,5)
end

function trigger_portal()
	if #p1.equips>0
	then
		tb_depth+=1
		gen_room()
	else

	end
end

function gen_room()
	if tb_depth<=0 then
		return gen_room_0()
	end
 entities={}
 add(entities,p1)
	for y=0,8 do
		for x=0,8 do
			if rnd()<(0.1+0.05*tb_depth) then
				spawn_rnd_enemy(x,y)
				if rnd()<0.05 then
					spawn_rnd_enemy(x,y)
					if rnd()<0.05 then
						spawn_rnd_enemy(x,y)
					end
				end
			end
		end
	end
	while true do
		for y=0,5 do
			for x=0,5 do
				if rnd()<0.01 then
					spawn_descend(x,y)
					goto _end_descent
				end
			end
		end
	end
	::_end_descent::
	for y=0,5 do
		for x=0,5 do
			if rnd()<0.3 then
				spawn_rnd_gear(x,y)
				if rnd()<0.1 then
					spawn_rnd_gear(x,y)
				end
			end
		end
	end
end

--loot management

base_item={
	tb_spr_size=1,
	tb_anim={38},
	tb_t=tb_type.gear,
	x=0,
	y=0,
	name="[empty]",
	seed=0,
	moves={},
	cooldown=5
}

function frnd(m)
	return flr(rnd(m))
end


function rnd_move()
	while true do
		for k,v in pairs(all_moves) do
			if rnd()<0.5 then
				return k
			end
		end
	end
end

loot_seed=1
function gen_loot_item(stat_max)
	loot_seed+=1
	local e={
			seed=loot_seed,
			patk=frnd(stat_max),
			pspd=frnd(stat_max),
			pdef=frnd(stat_max),
			ablt=frnd(stat_max),
			wspd=frnd(stat_max),
			luck=frnd(stat_max),
	}
	copy_into(e,base_item)
	e.moves={}
	if true then
		--has move
		add(e.moves,rnd_move())
		if rnd()<0.2 then
				add(e.moves,rnd_move())
		end
	end
	--+2 so that intrinsic does
	--not spawn
	e.slot=flr(rnd(#slot_names-1)+2)
 return e
end

function gen_loot()

end
__gfx__
00000000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000060007777777777777777
00000000772227777722277777222777772227777777777777777777777777777700077777000777770007777700077777777777000660007700077777000777
00700700772227777722277777222777772227777722277777bbbb7777bbbb777700077777000777770007777700077777000777000660007700077777000777
0007700077222777772227777722277777222777772227777bbccb777bbccb777700077777000777770007777700077777000777000660007700077777000777
00077000777177777771777777717777777177777722277777bbbb777bbbbb77777077777770777777707777777077777700077700066000c77077c7cc707cc7
007007007751577777515777775157777751577777717777777bb77777bb7777770007777700077777000777770007777770777700444400c70007c7c70007c7
0000000077575777775757777757577777575777775757777777777777777777770707777707077777070777770707777707077700044000cc070cc77c070c77
00000000775757777777577777777777775777777757577777777777777777777707077777770777777777777707777777070777000440007c070c77c70707c7
7c7777777c17777771c77777777777777777777777777777000000000c100000065000000000000077777777777777777777777777cc77770000000000000000
7cc777777cc17777711c7777977777777779999777777777000000000cc1000006650000000000007777777777777777777777777c77ccc70000000000000000
77cc777777cc17777711c7779777777777799a9777777777000aa00000cc1000006650000000000077c77777771c77777771c7777c77777c0000100000005000
777cc777777cc17777711c77977777777799a9977777777700a99a00000cc1000006650000000000cccc77771cccc77771ccccc777c7cc871111cc0055556600
777cc777777cc17777711c7797777777799a99977777777700a99a00000cc1000006650000000000cccc77771cccc77771ccccc777c7cc87cccccccc66666666
777cc777777cc17777711c779777777779a9977777777777000aa000000cc100000665000000000077c77777771c77777771c7777c77777c1111cc0055556600
77cc777777cc17777711c7779777777779977777999999970000000000cc100000665000000000007777777777777777777777777c777ccc0000100000005000
7cc777777cc17777711c7777977777777777777777777777000000000cc10000066500000000000077777777777777777777777777ccc7770000000000000000
707777077777777777777777707077775577775500006000777777777757777777777777777707770000ccc07777777777777777000000000000000000000000
70700707777777777070777705755757577777570006660070000007777577777770777777700777ccccc6c07777777777777777000000000000000000000000
70700707770777777777757777577777777777770006460070444407577577777700077777000777666666c07000007777777777000000000000000000000000
770000777755577775777557557777575777777700004000700aa007755557777000007770000777555556607080807770000077000000000000000000000000
77077077775557777577757755777775577777750000400070444407777757770000000777000777555556607777707770808077000000000000000000000000
77077077777570777557570755777757777777750000400070444407777755577777777777700777666666c07000007770000077000000000000000000000000
77700777777777777775707775757550577577550000400070000007777775757777777777770777cccc66c07000007770000077000000000000000000000000
77700777777777777777777777757707575775570000400077777777777777557777777777777777000cccc07070707777070777000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa88188888000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa888818880077007008800cc006600660000060000f0f0f0f00000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00ba09aa90a80888808070700000888ccc00666666000006600ff0f0f0f00000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00ba00aa00a1808808877070770008ccc000066660000066660ff0f0f0f00000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa888818887700007000ccc8000066660000066666ffffffff00000000000000000000000000000000000000000000000000000000
c0cccc0cbbbbbbbbaa0909aa10919908700070774ccc88845666666500066660ffffffff00000000000000000000000000000000000000000000000000000000
cc0000ccbbb00bbbaa9090aa800000010077007704c00840056006500000660000ffff0000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa881888887000700040400404505005050000600000ffff0000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777770000000000000000
777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bb77777777777777bb77770000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bb37777777777777bb377770000000000000000
777777777777777777777777777777777777777777777777777777777777777777777777777777777777bbbbbb3777777777bbbbbb3777770000000000000000
77777000007777777777700000777777777777777777777777777000007777777777777777777777777bbbbbbbb77777777bbbbbbbb777770000000000000000
777770c0c0775777777770c0c07777777777700000777777777770c0c07777777777700000777777777bbbbbbbb77777777bbbbbbbb777770000000000000000
77777000007757777777700000757777777770c0c07757777777700000777777777770c0c077777777bb9bbb9bbb777777bb9bbb9bbb77770000000000000000
7777700000775777777770000075777777777000007757777777700000757777777770000075777777bbbbbbbbbb777777bbbbbbbbbb77770000000000000000
7777777077744477777777707775777777777000007757777777777077757777777770000075777777bbbbbbbbbb777777bbbbbbbbbb77770000000000000000
77777770700007777777777077444777777777707774447777777770777577777777777077757777773bbbbeebbb777777bbbeeebbbb77770000000000000000
777700000077477777770000000407777777777077770777777700000044477777777770774447777773beeebbb37777773bbbbeebbb77770000000000000000
7777777077777777777777707774777777770000000047777777777077007777777770000000777777773bbbbb3777777773bbbbbbb377770000000000000000
77777770777777777777777077777777777777707777777777777770777477777777777077747777777777777777777777777777777777770000000000000000
77777707077777777777770700777777777770070077777777770007077777777777777077777777777777777777777777777777777777770000000000000000
77777077707777777777707777077777777707777707777777770777707777777777700700777777777777777777777777777777777777770000000000000000
77777077707777777777707777777777777777777777777777777777707777777777707770777777777777777777777777777777777777770000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
22222777222227772222277722222277777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
222227772222277722222777222222777777077a770777777777077a77077777777777777777777777777777997777777777077a770777777777077a77077777
222244444222277722224444422222777777077a770777777777077a77077777777799007777777777777777997777777777077a770777777777077a77077777
222244444222277722224444422222777777077a770077777777077a77007777777799000777777777777770007777777777077a770077777777077a77007777
222244444222277722224444422222777777077a770777777777077a77077777777777000077777777777770007777777777077a770777777777077a77077777
74444444444447777444444444444777777700000007777777770000000777777777777000777777777777700777777777770000000777777777000000077777
22224444444222222222444444422222777700000000777777770000000077777777777000077777777777700007777777770000000077777777000000007777
22224444444222222222444444422222777707777707777777770777770777777777700000007777777770000000777777770777770777777777077777077777
22224444444222222222444444422222777707070707777777770707070777777777000000000777777700000000077777770707070777777777070707077777
22224444444222222222444444422222777700777007777777770077700777777770000777000777777000077770077777770077700777777777007770077777
22224444444222222222444444422222777770000077777777777000007777777770007777700777777000777777077777777000007777777777700000777777
77774444447777777777444444777777777777700777777777777770077777777770077700000777777000070077077777777770077777777777777007777777
72774444447277777777444444727727777777000077777777777700007777777700070000000777770000000070077777777700007777777777770000777777
77274444447777277277444444772777777777077077777777777707707777777700000000000077770000000000007777777007707777777777770770077777
77774444447777777727444444777777777770077007777777777700007777777700000077700077770077700000007777777777700777777777700777777777
77777777777777777777777777777777777777777777777777777777777777774444444444444444444444444444444400000000000000007777777777777777
77777777777777777777777777777777777777777777777777777777777777774444444444444444444444444444444400000000000000007777777777777777
77777000077777777777700007777777777770000777777777777777777777774455555555555544445555555555554400000000000000007777779ddd977777
77770cccc077777777770cccc077777777770cccc07777777777700007777777445aaaaaaaaaa54444500000000005440000000000000000777777d9d9d77777
77770c00c077777777770c00c077777777770c00c077777777770cccc0777777445a44444444a54444504444444405440000000000000000777777ddddd77777
77777000077777777777700007777777777770000777777777770c00c0777777445a4cccccc4a5444450466666640544000000000000000077ddddd999ddddd7
7700000000007777770000000000777777000000000077777777700007777777445a4cccccc4a5444450466666640544000000000000000077dddd9ddd9dddd7
7000000000000777700000000000077770000000000007777700000000007777445a4cccccc4a5444450466666640544000000000000000077dd7ddddddd7dd7
7007700007700777700770000770077770077000077007777700000000007777445a4cccccc4a5444450466666640544000000000000000077dd7ddddddd7dd7
7007700007700777700770000770077770077000077007777700700007007777445a4cccccc4a5444450466666640544000000000000000077dd7ddddddd7dd7
7007700007700777700770000770077770077000077007777700700007007777445a4cccccc4a5444450466666640544000000000000000077777ddd7ddd7777
7007700007700777700770000777777777777000077007777700700007007777445a44444444a5444450444444440544000000000000000077777dd777dd7777
7777007700777777777700770077777777770077007777777777700007777777445aaaaaaaaaa5444450000000000544000000000000000077777dd777dd7777
777700770077777777770077007777777777007700777777777770000777777744555555555555444455555555555544000000000000000077777dd777dd7777
7777007700777777777700770077777777770077007777777777700007777777444444444444444444444444444444440000000000000000777dddd777dddd77
7777007700777777777777770077777777770077777777777777700007777777444444444444444444444444444444440000000000000000777dddd777dddd77
77777777777777777777777777777777770000000007777777777777777777770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777770808080800777777000000000777770000000000000000000000000000000000000000000000000000000000000000
7777779ddd9777777777779ddd977777770000000000007777080808080000770000000000000000000000000000000000000000000000000000000000000000
777777d9d9d77777777777d9d9d77777777777777000007777000000000000770000000000000000000000000000000000000000000000000000000000000000
777777ddddd77777777777ddddd77777777777777700007777777777000000770000000000000000000000000000000000000000000000000000000000000000
77ddddd999ddddd777ddddd999ddddd7777777777000007777777777700000770000000000000000000000000000000000000000000000000000000000000000
77dddd9ddd9dddd777dddd9ddd9dddd7777777770000007777777777000000770000000000000000000000000000000000000000000000000000000000000000
77dd7ddddddd7dd777dd7ddddddd7dd7777770000000007777777000000000770000000000000000000000000000000000000000000000000000000000000000
77dd7ddddddd7dd777dd7ddddddd7dd7777000000000007777700000000000770000000000000000000000000000000000000000000000000000000000000000
77dd7ddddddd777777777ddddddd7dd7770000000000007777000000000000770000000000000000000000000000000000000000000000000000000000000000
77777ddd7ddd777777777ddd7ddd7777770000000000007777000000000000770000000000000000000000000000000000000000000000000000000000000000
77777dd777dd777777777dd777dd7777770000000000007777000000000000770000000000000000000000000000000000000000000000000000000000000000
77777dd777dd777777777dd777dd7777770000000000077777000000000007770000000000000000000000000000000000000000000000000000000000000000
777dddd777dd777777777dd777dddd77777070707070777777070707070707770000000000000000000000000000000000000000000000000000000000000000
777dddd777dddd77777dddd777dddd77777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
7777777777dddd77777dddd777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a0000061500615006150061500b150001500015000150001500a1500515005150051500b15014050140501505015050150501505016050151500f1500d1500d1500d1500d1500c1500b1500b1500c1500c150
001001010c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500b8500a8500885006850058500ca500ca500ca500ca50000000c0000c000120000000000000000000000000000
__music__
00 01424344

