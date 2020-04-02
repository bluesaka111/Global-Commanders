#****************************************************************************
#**
#**  File     :  /cdimage/units/UEA0001/UEA0001_script.lua
#**  Author(s):  John Comes
#**
#**  Summary  :  UEF CDR Pod Script
#**
#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local AAirUnit = import('/lua/aeonunits.lua').AAirUnit
local AIFCommanderDeathWeapon = import('/lua/aeonweapons.lua').AIFCommanderDeathWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local AWeapons = import('/lua/aeonweapons.lua')
local ADFPhasonLaser = AWeapons.ADFPhasonLaser

GAA0003 = Class(AAirUnit) {
    Weapons = {
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
    },

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end, 

    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Parent:NotifyOfPodDeath(self.Pod)
        self.Parent = nil
        AAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
                
}

TypeClass = GAA0003