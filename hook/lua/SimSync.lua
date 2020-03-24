cdrenhancementTable = {}
     
function AddUnitEnhancement(unit, enhancement, slot)
    if not slot then return end
    local id = unit:GetEntityId()
    local unitEnh = SimUnitEnhancements[id]
    
    local bp = unit:GetBlueprint()
    local iscommander = false
    if EntityCategoryContains(categories.COMMAND,unit) 
    or EntityCategoryContains(categories.SUBCOMMANDER,unit) then
	iscommander = true
    end
    
    if unitEnh then
        if iscommander then 
        	if not cdrenhancementTable[id] then 
        		cdrenhancementTable[id] = {}
        	end
        	cdrenhancementTable[id][slot] = enhancement
        	cdrenhancementTable[id][enhancement] = enhancement
        	SimUnitEnhancements[id] = cdrenhancementTable[id]
        else         
        	SimUnitEnhancements[id][slot] = enhancement
        end
    else
        SimUnitEnhancements[id] = {}
        if iscommander then 
        	if not cdrenhancementTable[id] then 
        		cdrenhancementTable[id] = {}
        	end
        	cdrenhancementTable[id][slot] = enhancement
        	cdrenhancementTable[id][enhancement] = enhancement
        	SimUnitEnhancements[id] = cdrenhancementTable[id]
        else         
        	SimUnitEnhancements[id][slot] = enhancement
        end
    end
    SyncUnitEnhancements()
end

function RemoveAllUnitEnhancements(unit)
    local id = unit:GetEntityId()
    local bp = unit:GetBlueprint()
    if EntityCategoryContains(categories.COMMAND,unit) 
    or EntityCategoryContains(categories.SUBCOMMANDER,unit) then
	cdrenhancementTable[id] = nil
    end
    SimUnitEnhancements[id] = nil
    SyncUnitEnhancements()
end