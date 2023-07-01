--hud and swings

function draw_hud()
	local col=0
	if p1.p_type==p1_aspect.react then
		col=14
	elseif p1.p_type==p1_aspect.fight then
		col=12
	end
	rectfill(0,0,128,12,col)
	color(7)
	print("❎:",2,5,7)
	palt(0,true)
	rect(14,2,22,11,6)
	--if p1.eng >= p1.max_eng then
	--	rectfill(15,3,21,10,3)
	--end
	local m=nil
	m=p1.selected_move
	if m!=nil then
		local s=m.icon
		if m.eng_cost>p1.eng then
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
	local a=p1.efforts[3]
	local t="[empty]"
	if a!=nil then
		t=a.name
	end
	local x=40
	local y=25
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(40,x+20,y+12)
	end
	print(t,x+1,y+2,7)
	--left
	a=p1.efforts[1]
	t="[empty]"
	if a!=nil then
		t=a.name
	end
	x=8
 y=44
	rectfill(x,y,x+40,y+8,0)
	if c==0 then
		spr(41,x+43,y+1)
	end
	print(t,x+1,y+2,7)
	--down
	a=p1.efforts[4]
	t="[empty]"
	if a!=nil then
		t=a.name
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
	a=p1.efforts[2]
	t="[empty]"
	if a!=nil then
		t=a.name
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

