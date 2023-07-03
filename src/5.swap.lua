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
"enter swap, please release keys"
	swap_gear=g
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
		local c=0
		c=p1.mcount[m.name]
		msg=m.name.." x"..c
		local col=7
		if contains(p1.equips, m)
			then
			col=11
			print("e",8,y,col)
		end
		print(msg,16,y,col)
		y+=8
	end
	if anim_c%2<1 then
		spr(55,6,14+(8*(eq_line-1)))
	else
		
	end
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
		if contains(p1.equips,p1.moves[eq_line])
			then
			del(p1.equips, m1)
		elseif #p1.equips<=3 then
			add(p1.equips, m1)
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




swap_gear=nil
function swap_mode()
	cls()
	color(7)
	g1=p1.gear[swap_gear.slot]
	g2=swap_gear
	assert(g1!=nil)
	assert(g2!=nil)
	print(
"old(stat) -> new(stat)")
	print("slot: "..
		slot_names[g2.slot])
	if g2.seed==nil then
		g2.seed="nil"
	end
	print("seed:"..g1.seed.."->"..g2.seed)
	y=18
	print("name:",0,y,7)
	print(""..g1.name,20,y,7)
	print("->",50,y,7)
	print(""..g2.name,60,y,7)
	y+=6
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
	end
	y+=6
	for i=1,max(#g1.moves,#g2.moves) do
		local m1=g1.moves[i]
		local m2=g2.moves[i]
		if m1==nil then
			m1={name="empty move"}
		end
		if m2==nil then
			m2={name="empty move"}
		end
		local col=7
		if m1.name==m2.name then
			col=8
		end
		print(""..m1.name,2,y,col)
		print("->", 50,y,7)
		print(""..m2.name,60,y,col)
		y+=6
	end
	print(
"❎ to swap,⬅️ to leave behind",
		0,y,7)
		
		if btnp(5) then
			p1.gear[g2.slot]=g2
			del(entities,g2)
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
		(total-old)+new
	local t_r=""..
		(total-old)+new
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
