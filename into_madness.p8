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
	parry=3,
	inventory=4,
	shop=5
}
anim_c=0
state=game_state.dungeon


slot_num={
	intrinsic=1,
	primary=2,
	secondary=3,
	helmet=4,
	chestplate=5,
	pants=6,
	boots=7,
	necklace=8
}
slot_names={  --slots:
	"intrinsic", --1
	"primary",   --2
	"secondary", --3
	"helmet",    --4
	"chestplate",--5
	"pants",     --6
	"boots",     --7
	"necklace"   --8
}

sanity=100.0

--animation helpers
shorts={}
atexts={}

function copy_into(dest,source)
	for k,v in pairs(source) do
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
	init_tb_enemies()
	init_gear_slots(p1)
	tb_spawn_slime(4*16,6*16)
	sword=gen_sword(20)
	equip(p1,sword)
	rebuild_player(p1)
end

function _update()
	anim_c+=1
	if state==game_state.dungeon
		then
		dungeon_mode()
	elseif state==game_state.combat
		then
		combat_mode()
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
	cls(6)
	palt(0,false)
	palt(7,true)

	
	tb_controls()
	if turn_over then
		move_entities()
		turn_over=false
	end
	
	draw_grid()
	tb_draw_player()
	tb_draw_entities()
	turn_over=false
end


function tb_add_entity(e)
	add(entities, e)
end

function tb_draw_entities()
	for e in all(entities) do
		tb_draw_entity(e)
	end
end

function tb_trace_still(e)
	--do nothing
	turn_over=true
end

function move_entities()
	for e in all(entities) do
		e.tb_move(e)
		assert(turn_over==true)
	end
end

function tb_draw_player()
	tb_draw_entity(p1)
end

function tb_draw_entity(e)
	c=flr(anim_c/3)
	--if e.tb_moving
	--then
		--anim=e.tb_mv_anim
	--else
	--anim=e.tb_anim
	--end
	tmp=(c%#e.tb_anim)+1
	spr(e.tb_anim[tmp],
		e.tb_x,e.tb_y,
		e.tb_spr_size,
		e.tb_spr_size)
end

function draw_grid()
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
		--inventory
	elseif btnp(5) then
		--use item?
	end
		
end

function tb_mv_left(e)
	e.moved=true
	e.tb_x-=16
	turn_over=true
end
function tb_mv_right(e)
	e.moved=true
	e.tb_x+=16
	turn_over=true
end
function tb_mv_up(e)
	e.moved=true
	e.tb_y-=16
	turn_over=true
end
function tb_mv_down(e)
	e.moved=true
	e.tb_y+=16
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
	
	if tb_same_pos(p1,e)
	then
		trigger_combat(e)
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
	s=g.slot
	assert(s!=nil)
	assert(s<=#slot_names)
	--unequip(ent,s)
	assert(g!=nil)
	ent.gear[s]=g
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
	for g in all(ent.gear) do
		ent.patk+=g.patk
		ent.pspd+=g.pspd
		ent.pdef+=g.pdef
		ent.ablt+=g.ablt
		ent.wspd+=g.wspd
		ent.luck+=g.luck
	end
end

function rebuild_lists(ent)
	ent.moves={}
	ent.actions={}
	for g in all(ent.gear) do
		assert(g.moves!=nil)
		for m in all(g.moves) do
			if not contains(
					ent.moves,m)
				then
				add(ent.moves,m)
			end
		end --for m
		for a in all(g.actions) do
			if not contains(
					ent.actions,a)
				then
				add(ent.actions,a)
			end
		end --for a
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
	if e.x_move_atk!=nil and
			not contains(
				e.moves,e.x_move_atk) 
		then
		--if #e.moves==0
		e.x_move_atk=nil --e.m0ves[0]
	end
	if e.x_move_act!=nil and
			not contains(
				e.moves,e.x_move_act) 
		then
		e.x_move_act=nil --e.moves[0]
	end
	if e.z_action!=nil and
			not contains(
				e.moves,e.z_action) 
		then
		e.z_action=nil
	end
end

function init_gear_slots(e)
	while #e.gear<8 do
		add(e.gear,empty_gear)
	end
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
-->8
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
	

p1={
	faction=0,
	tb_anim={64,64,72,72},
	tb_spr_size=2,
	--tb_mv_anim={64,66,68,70},
	tb_x=16*3,
	tb_y=16,
	
	c_move_anim={64,64,72,72},
	c_anim={64,64,72,72},
	c_sz=2,
	health=50,
	--energy and clarity
	eng=0,
	max_eng=50,
	eng_rate=0.5,
	clr=0,
	max_clr=50,
	clr_rate=0.5,
	sanity=100,
	--invincibility
	inv_max=60,
	inv_count=0,
	--populated by equips
	moves={},
	actions={},
	gear={},
	--mapped to ❎ in atk mode
	x_move_atk={},
	--mapped to ❎ in act mode
	x_move_act={},
	--mapped to 🅾️ in act mode
	z_action={},
	atk_mode=true,
	idle=20
}

int_warrior={
	slot=slot_num.intrinsic,
	patk=10,
	pspd=1,
	pdef=1,
	ablt=1,
	wspd=5,
	luck=1,
}

empty_gear={
	slot=nil, --on purpose
	patk=0,
	pspd=0,
	pdef=0,
	ablt=0,
	wspd=0,
	luck=0,
	moves={},
	actions={}
}

e_slime={}

function init_tb_enemies()
	e_slime={
		etype=1, --todo
		faction=1,
		tb_anim={6,6,7,7},
		tb_spr_size=0.75,
		c_anim={74,76},
		health=10,
		moves={bash_move},
		actions={bounce_act},
		tb_move=tb_move_square,
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
		actions={},
		gear={},
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
pri_sword=nil

function init_gear()
	init_moves()
	int_slime={
		slot=slot_num.intrinsic,
		patk=10,
		pspd=5,
		pdef=1,
		ablt=5,
		wspd=1,
		luck=1,
		moves={slash_move},
		actions={}
	}
	pri_sword={
		icon=13,
		slot=slot_num.primary,
		name="sword",
		desc=
"a modern sword. nothing\n"..
"special honestly, but feels good\n"..
"in your hand",
		moves={slash_move},
		actions={}
	}
end


function tb_spawn_slime(x,y)
	e={
		tb_x=x,
		tb_y=y,
		--tb_anim={6,7}
	}
	copy_into(e,e_slime)
	init_gear_slots(e)
	equip(e,int_slime)
	printh("before rebuild")
	rebuild_entity(e)
	printh("after rebuild")
	tb_add_entity(e)
end


roll_num=0
function roll_stats(s,total)
	roll_num+=1
	s.aim_total=total
	s.seed=time()+roll_num
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
	name="slash",
	eng_cost=40,
	clr_cost=10,
	range=10,
	dmg=2,
	splash=false,
	spin=false,
	lock=30,
	cooldown=20,
	targets=4,
	ttl=20,
	delay=2
}
bash_move={
	icon=30,
	icon_disabled=31,
	t_anim={26,27,28,29},
	r_anim={33,33,34,34,35,35,36,36},
	s_anim=nil, --optional
	sound=0,
	name="bash",
	eng_cost=20,
	clr_cost=0,
	range=10,
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
			src.x-4,src.y-8,9)
		src.health-=rdmg
	end
	play_float_text("-"..flr(dmg),e.x-4,
		e.y-8,9)
	e.health-=dmg
end

function calc_attributes(e)
	e.eng_rate=0.5+(e.pspd*0.05)
	e.clr_rate=0.5+(e.pdef*0.05)
	e.max_eng=50+(e.wspd*2)
	e.clr_max=50+(e.ablt*2)
	e.speed=0.5+(e.wspd/10)
end

-->8
--combat

--all enemies within the same
--grid position
c_entities={}

function trigger_combat(e)
	setup_combat()
	state=game_state.combat
end

function setup_combat()
	p1.x=8
	p1.y=70
	p1.moved=false
	--p1.moves={slash_move}
	p1.x_move_atk=p1.moves[1]
	p1.x_move_act=p1.moves[1]
	
	--print_table("-----player 1-----"
	--	,p1)
	c_entities={}
	add(c_entities,p1)
	
	for e in all(entities) do
		if tb_same_pos(p1,e)
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
end

function combat_mode()
	cls(6)
	palt(0,false)
	palt(7,true)
	--draw_backdrop()
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
	c_player_control()
	for e in all(entities) do
		c_enemy_control(e)
	end
	draw_swings()
	sanity_distortion()

	
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
	if p1!=e then
		e.ai(e)
	end
end


function c_player_control()
	x_used=false
	xold=p1.x
	yold=p1.y
	yvel=0
	xvel=0
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
	if btnp(4) then
		--menu (actions)
		
	end
	if btnp(5) then
		--primary
		p_x_move()
	end
	
	--compensate diagnol moves
	if abs(xvel)>0 and abs(yvel)>0
		then
		xvel*=0.707
		yvel*=0.707
	end
	p1.moved=
		abs(xvel)>0 or abs(yvel)>0
		
	p1.x+=xvel
	p1.y+=yvel
end

function p_x_filled(p)
	m=p.x_move_act
	assert(m!=nil)
	if p.atk_mode then
		m=p.x_move_atk
	end
	if m==nil then return false end
	if m.cost>e.eng then
		return false
	end
	return true
end



--only for player
function p_x_move()
	m=p1.x_move_act
	if p1.atk_mode then
		m=p1.x_move_atk
	end
	player_swing(m)
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


--last edge colliding on 
--1st set of coordinates
last_edge_top=nil
last_edge_bottom=nil
last_edge_right=nil
last_edge_left=nil
function check_col(x1,y1,w1,h1,
										x2,y2,w2,h2)
	x_col=false
	right=
		x1<=x2+w2 and x1>x2
	if right then
		x_col=true
	end
 left=
		x1+w1>=x2 and x1<=x2+w2
	if left then
		x_col=true
	end
	y_col=false
	top=
		y1<=y2+h2 and y1>y2
	if top then
		y_col=true
	end
	bottom=
		y1+h1>=y2 and y1<=y2+h2
	if bottom then
		y_col=true
	end
	
	if x_col and y_col then
		last_edge_right=right
		last_edge_left=left
		last_edge_top=top
		last_edge_bottom=bottom
		return true
	else
		last_edge_right=false
		last_edge_top=false
		last_edge_bottom=false
		last_edge_left=false
		return false
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
		tmp=(c%#anim)+1
		spr(anim[tmp],e.x-8,e.y-8,2,2)
	end
end

bullets={}
--produces a circular array
--of bullets
function do_bounce_act()
	for ang=0,1.0,0.1 do
		b.x-=b.speed*cos(ang)
		b.y-=b.speed*sin(ang)
	end
end

--follows a fixed line 
--toward end position
function step_line(b)
	if b.xstart==nil then
		b.xstart=b.x
	end
	if b.ystart==nil then
		b.ystart=b.y
	end
	xd=b.xstart-b.xend
	yd=b.ystart-b.yend
	
	ang=atan2(xd,yd)
	b.x-=b.speed*cos(ang)
	b.y-=b.speed*sin(ang)	
	return b	
end

function c_bullets_control()
	--ang=atan2(xd,yd)
	b.x-=b.speed*cos(ang)
	b.y-=b.speed*sin(ang)	
	return b	
end

function draw_backdrop()
	sz=32
	--draw grid lines
	--horizontal
	for i=0,(64/sz) do
		line(0,i*sz,128,i*sz,5)
	end
	--vertical
	i=0
	for i=0,(64/4) do
		line(i*sz,0,i*sz,64,5)
	end
	
	line(0,68,128,68,5)
end
-->8
--hud and swings

function draw_hud()
	rectfill(0,0,128,12,0)
	color(7)
	print("❎:",2,5,7)
	palt(0,true)
	rect(14,2,22,11,6)
	if p1.eng >= p1.max_eng then
		rectfill(15,3,21,10,3)
	end
	m=nil
	if p1.atk_mode then
		m=p1.x_move_atk
	else
		m=p1.x_move_act
	end
	if m!=nil then
		local s=m.icon
		if m.eng_cost>p1.eng then
			s=m.icon_disabled
		end
		spr(s,15,3)
	end

	palt(0,false)
	print("🅾️:",40,4,7)
	
	--p1.strat=true
	if p1.atk_mode then
		rectfill(109,3,121,9,0)
		print("atk",110,4,11)
	else
		rectfill(109,3,121,9,12)
		print("act",110,4,10)
	end
	
	draw_log()
	draw_sanity()
end

function draw_sanity()
	print("self:",78,4,7)
	rect(98,1,107,10,6)
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
	spr(s,99,2)
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
	x2=x+12
	y1=y
	y2=y+5
	--black box
	rectfill(x1,y1,x2,y2,5)
	--draw bar
	o=12.0*((v+.0)/mx)
	rectfill(
		x,y,
		x+o,
		y+5,
		col)
end

--this meter is used on
--moves and action icons
--todo!
function icn_meter(v,mx,x,y,col)
	x1=x
	x2=x+12
	y1=y
	y2=y+5
	--black box
	--rectfill(x1,y1,x2,y2,5)
	--draw bar
	o=12.0*((v+.0)/mx)
	rectfill(
		x,y,
		x+o,
		y+5,
		col)
end


function draw_parry_hud()
	
end

swings={}
function add_swing(src,mv)
	local s={
		--dist=xd+yd,
		mv=mv,
		src=src,
		cooldown=mv.cooldown,
		hitbox=4,
		lock=mv.lock,
		rotate=true, --todo
		cnt=0,
		done=false,
		hits={},
		state=0,
		ttl=mv.ttl,
		delay=mv.delay
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
	if anim_c%3==0
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
	local s=add_swing(e,mv)
	if s==nil then return nil end
	s.x=e.x-8
	s.y=e.y
	s.hitbox=16
	return s
end

function swing_hit(e,s)
	if parry_dmg_mul>0 then
		play_anim(s.mv.t_anim,
			e.x,e.y)
	end
	if parry_rdmg_mul>0 then	
		play_anim(s.mv.r_anim,
			s.src.x,s.src.y)
	end
	apply_dmg(s.src,e,
		calc_dmg(s),calc_rdmg(s))
end

--computes damage for swing
function calc_dmg(s)
	local d=s.mv.dmg
	d*=(s.src.patk/10)+1
	d*=parry_dmg_mul
	--todo apply armor etc
	return d
end
function calc_rdmg(s)
	local d=s.mv.dmg
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
				btn(4) and not btn(5))
				--or (p1!=sw.target and 
				--sw.target.luck*10>rnd(1000)) 
			then
			if sw.parry_hold==nil then
				sw.parry_hold=15
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
	local src=sw.src
	if sw.missed then
		src.eng-=sw.mv.eng_cost/2
		src.clr-=sw.mv.clr_cost/2
	else
		src.eng-=sw.mv.eng_cost
		src.clr-=sw.mv.clr_cost
	end
end

function check_costs(sw)
	local src=sw.src
	if src.eng<sw.mv.eng_cost then
		return false
	end
	if src.clr<sw.mv.clr_cost then
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

-->8
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
	for mv in all(e.moves) do
		if e.eng>=mv.eng_cost then
			add(av_moves,mv)
		end
	end
	enemy_swing(e,av_moves[1])
	
	
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
70777707777777777777777770707777557777550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700707777777777070777705755757577777570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700707770777777777757777577777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000077775557777577755755777757577777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77077077775557777577757755777775577777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77077077777570777557570755777757777777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700777777777777775707775757550577577550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700777777777777777777777757707575775570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa88188888000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa88881888007700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00ba09aa90a80888808070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00ba00aa00a18088088770707700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa88881888770000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0cccc0cbbbbbbbbaa0909aa10919908700070770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc0000ccbbb00bbbaa9090aa80000001007700770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccbbbbbbbbaaaaaaaa88188888700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
22222777222227772222277722222277777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
222227772222277722222777222222777777077a770777777777077a770777770000000000000000000000000000000000000000000000000000000000000000
222244444222277722224444422222777777077a770777777777077a770777770000000000000000000000000000000000000000000000000000000000000000
222244444222277722224444422222777777077a770077777777077a770077770000000000000000000000000000000000000000000000000000000000000000
222244444222277722224444422222777777077a770777777777077a770777770000000000000000000000000000000000000000000000000000000000000000
74444444444447777444444444444777777700000007777777770000000777770000000000000000000000000000000000000000000000000000000000000000
22224444444222222222444444422222777700000000777777770000000077770000000000000000000000000000000000000000000000000000000000000000
22224444444222222222444444422222777707777707777777770777770777770000000000000000000000000000000000000000000000000000000000000000
22224444444222222222444444422222777707070707777777770707070777770000000000000000000000000000000000000000000000000000000000000000
22224444444222222222444444422222777700777007777777770077700777770000000000000000000000000000000000000000000000000000000000000000
22224444444222222222444444422222777770000077777777777000007777770000000000000000000000000000000000000000000000000000000000000000
77774444447777777777444444777777777777700777777777777770077777770000000000000000000000000000000000000000000000000000000000000000
72774444447277777777444444727727777777000077777777777700007777770000000000000000000000000000000000000000000000000000000000000000
77274444447777277277444444772777777777077077777777777707707777770000000000000000000000000000000000000000000000000000000000000000
77774444447777777727444444777777777770077007777777777700007777770000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a0000061500615006150061500b150001500015000150001500a1500515005150051500b15014050140501505015050150501505016050151500f1500d1500d1500d1500d1500c1500b1500b1500c1500c150
001001010c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500c8500b8500a8500885006850058500ca500ca500ca500ca50000000c0000c000120000000000000000000000000000
__music__
00 01424344

