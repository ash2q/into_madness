pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--into madness
--a turn based rogue like with
--a sanity mechanic

--the "crawl" state is turn
--based, while the "combat"
--state is real time

game_state={
	dungeon=1,
	combat=2,
	inventory=3,
	shop=4
}
anim_c=0
state=game_state.dungeon

p1={
	tb_anim={64,64,72,72},
	tb_mv_anim={64,66,68,70},
	tb_x=0,
	tb_y=0,
	tb_moving=false
}


function _init()
	printh("--init--")
end

function _update()
	anim_c+=1
	if state==game_state.dungeon
		then
		dungeon_mode()
	end
end

apply_fns={}
function dungeon_mode()
	cls(7)
	palt(0,false)
	palt(7,true)
	
	move_entities()
	
	tb_controls()
	
	
	draw_grid()
	draw_player()
	

end

entities={}
function move_entities()
	for e in all(entities) do
		if e.moving then
			m=e.moving%16
		end
	end
end

function draw_player()
	tb_draw_entity(p1)
end

function tb_draw_entity(e)
	c=flr(anim_c/3)
	if e.tb_moving
	then
		anim=e.tb_mv_anim
	else
		anim=e.tb_anim
	end
	tmp=(c%#anim)+1
	printh("tmp: "..tmp)
	spr(anim[tmp],
		e.tb_x,e.tb_y,2,2)
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
human_reset=false
function tb_controls()
	if btn()==0 then
		human_reset=true
	elseif btn(0)
		 and human_reset then
		tb_mv_left(p1)
		human_reset=false
	elseif btn(1) 
			and human_reset then
		tb_mv_right(p1)
		human_reset=false
	elseif btn(2)
			and human_reset then
		tb_mv_up(p1)
		human_reset=false
	elseif btn(3)
			and human_reset then
		tb_mv_down(p1)
		human_reset=false
	elseif btn(4) 
			and human_reset then
		--inventory
		human_reset=false
	elseif btn(5)
			and human_reset then
		--use item?
		human_reset=false
	end
		
end

function tb_mv_left(e)
	e.moving=true
	e.tb_x-=16
end
function tb_mv_right(e)
	e.moving=true
	e.tb_x+=16
end
function tb_mv_up(e)
	e.moving=true
	e.tb_y-=16
end
function tb_mv_down(e)
	e.moving=true
	e.tb_y+=16
end
__gfx__
00000000777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
00000000770007777700077777000777770007777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
00700700770007777700077777000777770007777700077777777777777777770000000000000000000000000000000000000000000000000000000000000000
00077000770007777700077777000777770007777700077777777777777777770000000000000000000000000000000000000000000000000000000000000000
00077000777077777770777777707777777077777700077777777000007777770000000000000000000000000000000000000000000000000000000000000000
00700700770007777700077777000777770007777770777777777000007767770000000000000000000000000000000000000000000000000000000000000000
00000000770707777707077777070777770707777707077777777000007767770000000000000000000000000000000000000000000000000000000000000000
00000000770707777777077777777777770777777707077777777000007767770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777770777444770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777770700007770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077770000007747770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777770777777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777770777777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777707077777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777077707777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077777077707777770000000000000000000000000000000000000000000000000000000000000000
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
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
77777000007777777777700000777777777777777777777777777000007777777777777777777777000000000000000000000000000000000000000000000000
777770e0e0776777777770e0e07777777777700000777777777770e0e07777777777700000777777000000000000000000000000000000000000000000000000
77777000007767777777700000767777777770e0e07767777777700000777777777770e0e0777777000000000000000000000000000000000000000000000000
77777000007767777777700000767777777770000077677777777000007677777777700000767777000000000000000000000000000000000000000000000000
77777770777444777777777077767777777770000077677777777770777677777777700000767777000000000000000000000000000000000000000000000000
77777770700007777777777077444777777777707774447777777770777677777777777077767777000000000000000000000000000000000000000000000000
77770000007747777777000000040777777777707777077777770000004447777777777077444777000000000000000000000000000000000000000000000000
77777770777777777777777077747777777700000000477777777770770077777777700000007777000000000000000000000000000000000000000000000000
77777770777777777777777077777777777777707777777777777770777477777777777077747777000000000000000000000000000000000000000000000000
77777707077777777777770700777777777770070077777777770007077777777777777077777777000000000000000000000000000000000000000000000000
77777077707777777777707777077777777707777707777777770777707777777777700700777777000000000000000000000000000000000000000000000000
77777077707777777777707777777777777777777777777777777777707777777777707770777777000000000000000000000000000000000000000000000000
