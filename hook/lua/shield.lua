do
#****************************************************************************
#**
#**  File     :  /lua/shield.lua
#**  Author(s):  John Comes, Gordon Duclos
#**
#**  Summary  : Shield lua module: Do Not Allow Strategic Missiles to Penetrate the shield
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local OldShield = Shield
Shield = Class(OldShield) {

    # Return true to process this collision, false to ignore it.
    OnCollisionCheck = function(self,other)
	local CollideWithShield = OldShield.OnCollisionCheck(self, other)
	if not CollideWithShield and IsEnemy(self:GetArmy(),other:GetArmy()) then 
	    if EntityCategoryContains( categories.STRATEGIC, other ) and EntityCategoryContains( categories.MISSILE, other ) then
		CollideWithShield = true
	    end
	end
        return CollideWithShield
    end,
}
end
