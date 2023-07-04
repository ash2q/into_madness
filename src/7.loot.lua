--loot management

function gen_loot_item(stat_max)
    local g=nil
    g.slot=flr(rnd(7)+1)
    e.patk=rnd(stat_max)
	e.pspd=rnd(stat_max)
	e.pdef=rnd(stat_max)
	e.ablt=rnd(stat_max)
	e.wspd=rnd(stat_max)
    
    return g
end

function gen_loot()

end



