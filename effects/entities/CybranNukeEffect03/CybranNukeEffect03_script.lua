#****************************************************************************
#**
#**  File     :  /effects/Entities/UEFNukeEffect03/UEFNukeEffect03_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Nuclear explosion script
#**
#**  Copyright � 2005,2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')

UEFNukeEffect03 = Class(NullShell) {
    
    OnCreate = function(self)
		NullShell.OnCreate(self)
		self:ForkThread(self.EffectThread)
    end,
    
    EffectThread = function(self)
		local army = self:GetArmy()
		for k, v in GCEffectTemplate.CybranNukeHeadEffects03 do
			CreateAttachedEmitter(self, -1, army, v ) 
		end			
	
		WaitSeconds(6)
		for k, v in GCEffectTemplate.CybranNukeHeadEffects02 do
			CreateAttachedEmitter(self, -1, army, v ) 
		end	
    end,      
}

TypeClass = UEFNukeEffect03

