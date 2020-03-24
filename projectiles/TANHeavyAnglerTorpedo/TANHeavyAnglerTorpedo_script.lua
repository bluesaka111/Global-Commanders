local TTorpedoShipProjectile = import('/lua/terranprojectiles.lua').TTorpedoShipProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

TANHeavyAnglerTorpedo = Class(TTorpedoShipProjectile) {

    FxImpactUnit = EffectTemplate.TAntiMatterShellHit02,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit02,
    FxImpactUnderWater = EffectTemplate.TAntiMatterShellHit02,
    FxUnderWaterHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,

    OnEnterWater = function(self)
        TTorpedoShipProjectile.OnEnterWater(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        local army = self:GetArmy()
        for k, v in self.FxEnterWater do #splash
            CreateEmitterAtEntity(self,army,v)
        end
    end,
}

TypeClass = TANHeavyAnglerTorpedo
