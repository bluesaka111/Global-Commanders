local TDFGaussCannonProjectile = import('/lua/terranprojectiles.lua').TDFLandGaussCannonProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

TDFHeavyGaussCannon = Class(TDFGaussCannonProjectile) {

    FxImpactUnit = EffectTemplate.TLandGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TLandGaussCannonHit01,
    FxImpactLand = EffectTemplate.TLandGaussCannonHit01,

    FxLandHitScale = 2.5,
    FxPropHitScale = 2.5,
    FxUnitHitScale = 2.5,

    OnCreate = function(self, inWater)
        TDFGaussCannonProjectile.OnCreate(self, inWater)
        if not inWater then
            self:SetDestroyOnWater(true)
        else
            self:ForkThread(self.DestroyOnWaterThread)
        end
    end,
    
    DestroyOnWaterThread = function(self)
        WaitSeconds(0.2)
        self:SetDestroyOnWater(true)
    end,
}

TypeClass = TDFHeavyGaussCannon