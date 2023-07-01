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



