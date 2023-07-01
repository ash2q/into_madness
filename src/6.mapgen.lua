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


function spawn_rnd_gear(g,x,y)
	local t={
		tb_t=tb_type.gear,
		tb_x=x,
		tb_y=y
	}
	
end

function trigger_portal()
	tb_depth+=1
	gen_room()
end

function gen_room()
 entities={}
 add(entities,p1)
	for y=0,8 do
		for x=0,8 do
			if rnd()<0.3 then
				spawn_rnd_enemy(x,y)
				if rnd()<0.1 then
					spawn_rnd_enemy(x,y)
					if rnd()<0.1 then
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



