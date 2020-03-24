do

oldfunc = ModBlueprints
function ModBlueprints(all_bps) 
    oldfunc(all_bps)
    for id,bp in all_bps.Unit do
	if bp.Weapon then
	    for index,weapon in ipairs(bp.Weapon) do
        	if not weapon.FireTargetLayerCapsTable.Air then
		    if weapon.FireTargetLayerCapsTable.Land then
			weapon.FireTargetLayerCapsTable.Air = weapon.FireTargetLayerCapsTable.Land
		    end
        	end
    	    end
	end

        if bp.Transport then
           bp.Transport.CanFireFromTransport = true
        end
    end
end

end