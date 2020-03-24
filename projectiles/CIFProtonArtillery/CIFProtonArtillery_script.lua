local CArtilleryProtonProjectile = import('/lua/cybranprojectiles.lua').CArtilleryProtonProjectile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

CIFProtonArtillery = Class(CArtilleryProtonProjectile) {

    FxLandHitScale = 0.33,
    FxPropHitScale = 0.33,
    FxUnitHitScale = 0.33,

    OnImpact = function(self, targetType, targetEntity)
        CArtilleryProtonProjectile.OnImpact(self, targetType, targetEntity)
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 8, 4, 'glow_03', 'ramp_red_06' )
        CreateLightParticle( self, -1, army, 3, 7, 'glow_03', 'ramp_antimatter_02' )
        if targetType == 'Terrain' or targetType == 'Prop' then
            CreateDecal( self:GetPosition(), RandomFloat(0.0,6.28), 'scorch_011_albedo', '', 'Albedo', 5, 5, 175, 100, army )  
        end
        ForkThread(self.ForceThread, self, self:GetPosition())       
    end,

    ForceThread = function(self, pos)
        DamageArea(self, pos, 10, 1, 'Force', true)
        WaitTicks(2)
        DamageArea(self, pos, 10, 1, 'Force', true)
        DamageRing(self, pos, 10, 15, 1, 'Fire', true)
    end,
}
TypeClass = CIFProtonArtillery