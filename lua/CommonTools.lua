
-- Common functions

-- Prints an error message to the screen
function PrintError(msg, destArmy)

	if destArmy and destArmy ~= GetFocusArmy() then return end
	
	PrintText(msg, 20, 'ffff0000', 5, 'center')
end


-- Gets all [unit]'s allied mobile units within the specified radius of the specified position
function GetAlliedMobileUnitsInRadius(unit, position, radius)
	local x1 = position.x - radius
	local z1 = position.z - radius
	local x2 = position.x + radius
	local z2 = position.z + radius
	
	local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	
	-- Check for empty rectangle
	if not UnitsinRec then return false end
	
	local validUnits = { }
	
    	for k, v in UnitsinRec do
		if IsAlly(v:GetArmy(), unit:GetArmy()) and v:GetBlueprint().Physics.MotionType != 'RULEUMT_None' then
		
			local pos = v:GetPosition()
			local dist = math.sqrt( math.pow(pos.x - position.x, 2) + math.pow(pos.z - position.z, 2) )
			
			if dist <= radius then
				table.insert(validUnits, v)
			end
		end
	end

	return validUnits
end


-- Gets all [unit]'s allied gateways within the specified radius of the specified position
function GetAlliedGatesInRadius(unit, position, radius)
	local x1 = position.x - radius
	local z1 = position.z - radius
	local x2 = position.x + radius
	local z2 = position.z + radius
	
	local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	
	-- Check for empty rectangle
	if not UnitsinRec then return false end
	
	local validUnits = { }
	
    	for k, v in UnitsinRec do		
		if IsAlly(v:GetArmy(), unit:GetArmy()) and table.find(v:GetBlueprint().Categories, 'TELEPORTATOR') then
			local pos = v:GetPosition()
			local dist = math.sqrt( math.pow(pos.x - position.x, 2) + math.pow(pos.z - position.z, 2) )
			
			if v.TeleportReady and dist <= radius then
				table.insert(validUnits, v)
			end
		end
	end

	return validUnits
end
