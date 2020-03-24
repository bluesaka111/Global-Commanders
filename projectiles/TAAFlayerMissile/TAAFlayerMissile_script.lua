local TMissileAAProjectile = import('/lua/terranprojectiles.lua').TMissileAAProjectile

TAAFlayerMissile = Class(TMissileAAProjectile) {

    FxImpactAirUnit = import('/lua/EffectTemplates.lua').TAntiMatterShellHit02,
    FxAirUnitHitScale = 0.33,
}

TypeClass = TAAFlayerMissile

