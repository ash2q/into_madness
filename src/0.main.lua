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
	init_tb()
	init_gear_slots(p1)
	init_map_pool()
	--tb_spawn_slime(4,5)
	equip(p1,int_warrior)
	local sword=gen_sword(20)
	equip(p1,sword)
	rebuild_player(p1)
	--sword=gen_sword(20)
	--r=gen_sword(40)
	--tb_spawn_gear(r,4,5)
	--trigger_swap(sword)
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
	turn_over=false
end


function tb_draw_status()
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
	assert(e.tb_spr_size!=nil)
	local tmp=(ac%#e.tb_anim)+1
	spr(e.tb_anim[tmp],
		x+16,y+16,
		e.tb_spr_size,
		e.tb_spr_size)
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
		state=game_state.equip
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
	ent.mcount={}
	for g in all(ent.gear) do
		--assert(g.moves!=nil)
		for m in all(g.moves) do
			if not contains(
					ent.moves,m)
				then
				add(ent.moves,m)
				if ent.mcount[m.name]==nil
					then
					ent.mcount[m.name]=0
				end
				ent.mcount[m.name]+=1
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



