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
	primary=1,
	secondary=2,
	helmet=3,
	chestplate=4,
	pants=5,
	boots=6,
	necklace=7,
	intrinsic=8
}
slot_names={  --slots:
	"primary",   --1
	"secondary", --2
	"helmet",    --3
	"chestplate",--4
	"pants",     --5
	"boots",     --6
	"necklace",   --7
	"intrinsic"  --8
}

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
	init_tb_enemies()
	tb_spawn_slime(4*16,6*16)
	sword=gen_sword(20)
	equip(p1,sword)
	rebuild_entity(p1)
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
		col=col
	}
	add(atexts,text)
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
	print(s.t,s.x,s.y,s.col)
	s.l-=1
	spr(s.anim,s.x,s.y,s.w,s.h)
end

function trigger_dungeon()
	state=game_state.dungeon
end


function equip(ent,g)
	s=g.slot
	assert(s<=#slot_names)
	unequip(ent,s)
	ent.gear[s]=g
end

function unequip(ent,slot)
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

function print_table(msg,g)
	printh(msg)
	for k,v in pairs(g) do
		if type(v) == "table" then
			print_table(""..k..":{",v)
			printh("}")
		elseif type(v)=="boolean" then
				if v then
					printh(""..k.."=true")
				else
					printh(""..k.."=false")
				end
		else
			if type(v)=="function" then
				v="["..type(v).."]"
			end
			printh(""..k.."="..v)
		end
	end
end

-->8
--specs,defs,spawns

entities={}



p1={
	enemy=false,
	tb_anim={64,64,72,72},
	tb_spr_size=2,
	--tb_mv_anim={64,66,68,70},
	tb_x=0,
	tb_y=0,
	
	c_anim={8,9,10,11},
	c_idle_anim={8,8,12,12},
	c_sz=0.75,
	--energy and clarity
	eng=0,
	max_eng=0,
	eng_rate=0.5,
	clr=0,
	clr_rate=0,
	max_clr=0,
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
	atk_mode=true
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



--moves is what can be done
--without "clarity"
m_punch={}

--actions is what can be done
--with charges of clarity
a_fireball={}

e_slime={}



function init_tb_enemies()
	e_slime={
		etype=1, --todo
		tb_anim={6,6,7,7},
		tb_spr_size=1,
		c_anim={6,7},
		health=10,
		moves={slash_move},
		actions={bounce_act},
		tb_move=tb_move_square,
		--energy(moves)
		eng=0,
		max_eng=0,
		eng_rate=1,
		--clarity(actions)
		clr=0,
		max_clr=0,
		clr_rate=0
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



function tb_spawn_slime(x,y)
	e={
		tb_x=x,
		tb_y=y,
		--tb_anim={6,7}
	}
	copy_into(e,e_slime)
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
	copy_into(s,sword_wpn)
	roll_stats(s,total)
	return s
end




slash_move={
	icon=23,
	icon_disabled=24,
	name="slash",
	cost=40,
	--gear,enemy
	fn=
	--source entity,enemy
function(se,e)
--	play_anim({19,19,19,20,20,21,21},
	play_anim({16,16,17,17,18},
		e.x,e.y)
		apply_dmg(e,
			2*(se.patk/5))
end,
	range=10,
	--target count
	t_cnt=1
}

sword_wpn={
	icon=13,
	slot=slot_num.primary,
	name="sword",
	desc="a modern sword. nothing\n"..
	"special honestly, but feels good\n"..
	"in your hand",
	moves={slash_move},
	actions={}
}


function apply_dmg(e,d)
	play_text("-"..flr(d),10,e.x-4,
		e.y-8,9)
	e.health-=d
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
enemies={}

function trigger_combat(e)
	setup_combat()
	state=game_state.combat
end

function setup_combat()
	p1.x=8
	p1.y=72
	p1.moved=false
	--p1.moves={slash_move}
	p1.x_move_atk=p1.moves[1]
	p1.x_move_act=p1.moves[1]
	
	--print_table("-----player 1-----"
	--	,p1)
	
	for e in all(entities) do
		if tb_same_pos(p1,e)
		then
			add(enemies,e)
		end
	end
	y=24
	for e in all(enemies) do
		e.x=80
		e.y=y
		e.moved=false
		y+=12
	end
end

function combat_mode()
	cls(6)
	palt(0,false)
	palt(7,true)
	draw_hud()
	c_draw_player()
	c_draw_enemies()
	
	c_player_control()
	for e in all(enemies) do
		c_enemy_control(e)
	end
	c_clean_enemies()
	if #enemies==0 then
		--battle done!
		trigger_dungeon()
	end
	track_charging(p1)
	for e in all(enemies) do
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
	for e in all(enemies) do
		if e.health<=0 then
			del(enemies,e)
			del(entities,e)
		end
	end
end

function c_enemy_control(e)

end

function c_player_control()
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
		p1_x_move()
		--play_text("miss!",10,
		--	p1.x-2,p1.y-8,0)
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

--only for player
function p1_x_move()
	m=p1.x_move_act
	if p1.atk_mode then
		m=p1.x_move_atk
	end
	return use_move(p1,m)
end

function use_move(ent,move)
	p=move
	if p==nil then return end
	if p.cost>ent.eng then
		return
	end
	cnt=p.t_cnt
	assert(cnt>0)
	for e in all(enemies) do
		if cnt<=0 then
			break
		end
		xd=abs(e.x-ent.x)
		yd=abs(e.y-ent.y)
		if xd<p.range and
				yd<p.range then
			cnt+=1
			--source is entity using the
			--move
			p.fn(ent,e)
		end
	end
	ent.eng-=p.cost
end

function use_act(ent,act)
	p=act
	if p==nil then return end
	if p.cost>e.clr then
		return
	end
	cnt=p.t_cnt
	for e in all(enemies) do
		if cnt<=0 then
			return
		end
		xd=abs(e.x-ent.x)
		yd=abs(e.y-ent.y)
		if xd<p.range and
				yd<p.range then
			cnt+=1
			p.fn(e,ent)
		end
	end
	ent.eng-=p.cost
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
	spr(anim[tmp],p1.x-3,p1.y-3)
end

function c_draw_enemies()
	for e in all(enemies) do
		c=flr(anim_c/3)
		anim=e.c_anim
		tmp=(c%#anim)+1
		spr(anim[tmp],e.x-4,e.y-4)
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
-->8
--hud and parry

function draw_hud()
	rectfill(0,0,128,12,0)
	color(7)
	print("❎:",2,5,7)
	palt(0,true)
	rect(13,2,22,11,6)
	if p1.eng >= p1.max_eng then
		rectfill(14,3,21,10,3)
	end
	m=nil
	if p1.atk_mode then
		m=p1.x_move_atk
	else
		m=p1.x_move_act
	end
	if m!=nil then
		s=m.icon
		if m.cost>p1.eng then
			s=m.icon_disabled
		end
		spr(s,14,3)
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



function do_parry()
end

function draw_parry_hud()
	
end
__gfx__
00000000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000060000000000000000000
00000000772227777722277777222777772227777777777777777777777777777700077777000777770007777700077777777777000660000000000000000000
00700700772227777722277777222777772227777722277777bbbb7777bbbb777700077777000777770007777700077777000777000660000000000000000000
0007700077222777772227777722277777222777772227777bbccb777bbccb777700077777000777770007777700077777000777000660000000000000000000
00077000777177777771777777717777777177777722277777bbbb777bbbbb777770777777707777777077777770777777000777000660000000000000000000
007007007751577777515777775157777751577777717777777bb77777bb77777700077777000777770007777700077777707777004444000000000000000000
00000000775757777757577777575777775757777757577777777777777777777707077777070777770707777707077777070777000440000000000000000000
00000000775757777777577777777777775777777757577777777777777777777707077777770777777777777707777777070777000440000000000000000000
7c7777777c17777771c77777777777777777777777777777000000000c1000000650000000000000000000000000000000000000000000000000000000000000
7cc777777cc17777711c7777977777777779999777777777000000000cc100000665000000000000000000000000000000000000000000000000000000000000
77cc777777cc17777711c7779777777777799a9777777777000aa00000cc10000066500000000000000000000000000000000000000000000000000000000000
777cc777777cc17777711c77977777777799a9977777777700a99a00000cc1000006650000000000000000000000000000000000000000000000000000000000
777cc777777cc17777711c7797777777799a99977777777700a99a00000cc1000006650000000000000000000000000000000000000000000000000000000000
777cc777777cc17777711c779777777779a9977777777777000aa000000cc1000006650000000000000000000000000000000000000000000000000000000000
77cc777777cc17777711c7779777777779977777999999970000000000cc10000066500000000000000000000000000000000000000000000000000000000000
7cc777777cc17777711c7777977777777777777777777777000000000cc100000665000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777770000000000000000
777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bb77777777777777bb77770000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bb37777777777777bb377770000000000000000
777777777777777777777777777777777777777777777777777777777777777777777777777777777777bbbbbb3777777777bbbbbb3777770000000000000000
77777000007777777777700000777777777777777777777777777000007777777777777777777777777bbbbbbbb77777777bbbbbbbb777770000000000000000
777770e0e0775777777770e0e07777777777700000777777777770e0e07777777777700000777777777bbbbbbbb77777777bbbbbbbb777770000000000000000
77777000007757777777700000757777777770e0e07757777777700000777777777770e0e077777777bbcbbbcbbb777777bbcbbbcbbb77770000000000000000
7777700000775777777770000075777777777000007757777777700000757777777770000075777777bbbbbbbbbb777777bbbbbbbbbb77770000000000000000
7777777077744477777777707775777777777000007757777777777077757777777770000075777777bbbbbbbbbb777777bbbbbbbbbb77770000000000000000
77777770700007777777777077444777777777707774447777777770777577777777777077757777773bbbbeebbb777777bbbeeebbbb77770000000000000000
777700000077477777770000000407777777777077770777777700000044477777777770774447777773beeebbb37777773bbbbeebbb77770000000000000000
7777777077777777777777707774777777770000000047777777777077007777777770000000777777773bbbbb3777777773bbbbbbb377770000000000000000
77777770777777777777777077777777777777707777777777777770777477777777777077747777777777777777777777777777777777770000000000000000
77777707077777777777770700777777777770070077777777770007077777777777777077777777777777777777777777777777777777770000000000000000
77777077707777777777707777077777777707777707777777770777707777777777700700777777777777777777777777777777777777770000000000000000
77777077707777777777707777777777777777777777777777777777707777777777707770777777777777777777777777777777777777770000000000000000
