local AZealot02AAMissileProjectile = import('/lua/aeonprojectiles.lua').AZealot02AAMissileProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

AAAOblivionMissile = Class(AZealot02AAMissileProjectile) {

    PolyTrail = EffectTemplate.AMercyGuidedMissilePolyTrail,
    PolyTrailScale = 5,
    FxImpactUnit = EffectTemplate.AOblivionCannonHit01,
    FxImpactProp = EffectTemplate.AOblivionCannonHit01,
    FxImpactLand = EffectTemplate.AOblivionCannonHit01,
    FxImpactWater = EffectTemplate.AOblivionCannonHit01,
}

TypeClass = AAAOblivionMissile

