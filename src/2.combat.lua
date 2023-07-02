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
	p1.selected_move=p1.moves[1]
	
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
		e.ai(e)
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
			switch_aspects()
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
		if btn(⬅️) and 
				p1.moves[1]!=nil then
			p1.selected_move=
				p1.moves[1]
			dial_display=false
		elseif btn(➡️) and
				p1.moves[2]!=nil then
			p1.selected_move=
				p1.moves[2]
			dial_display=false
		elseif btn(⬆️) and
				p1.moves[3]!=nil then
			p1.selected_move=
				p1.moves[3]
			dial_display=false
		elseif btn(⬇️) and
				p1.moves[4]!=nil then
			p1.selected_move=
				p1.moves[4]
			dial_display=false
		elseif not btn(🅾️) then
			dial_display=false
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






