#****************************************************************************
#**
#**  Author(s):  Domino
#**
#**  Summary  :  Engineer Unit Teleport in effect entity
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

SuperTeleport = Class(NullShell) {

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self:ForkThread(self.TeleportEffectThread)
    end,

    TeleportEffectThread = function(self)
        local army = self:GetArmy()
        local pos = self:GetPosition()
        pos[2] = GetSurfaceHeight(pos[1], pos[3]) - 2

        # Initial light flashs
		CreateLightParticleIntel( self, -1, army, 9, 2, 'flare_lens_add_02', 'ramp_blue_13' ) --18, 4
        WaitSeconds(0.1)
        CreateLightParticleIntel( self, -1, army, 17, 5, 'flare_lens_add_02', 'ramp_blue_13' ) --35,10
		WaitSeconds(0.2)
		CreateLightParticleIntel( self, -1, army, 17, 5, 'glow_02', 'ramp_blue_13' ) --35,10

		local decalOrient = RandomFloat(0,2*math.pi)
        CreateDecal(self:GetPosition(), decalOrient, 'nuke_scorch_002_albedo', '', 'Albedo', 3, 3, 20, 21, army) 
        CreateDecal(self:GetPosition(), decalOrient, 'Crater05_normals', '', 'Normals', 3, 3, 20, 21, army) 
        CreateDecal(self:GetPosition(), decalOrient, 'Crater05_normals', '', 'Normals', 2, 2, 20, 21, army) 

    end,

}

TypeClass = SuperTeleport

