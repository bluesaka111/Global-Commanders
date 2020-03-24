local TIonizedPlasmaGatlingCannon = import('/lua/terranprojectiles.lua').TIonizedPlasmaGatlingCannon
local EffectTemplate = import('/lua/EffectTemplates.lua')

TDFAntiMatterCannon = Class(TIonizedPlasmaGatlingCannon) {

    FxImpactUnit = EffectTemplate.TAntiMatterShellHit01,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit01,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit01,
    FxLandHitScale = 0.33,
    FxPropHitScale = 0.33,
    FxUnitHitScale = 0.33,
}

TypeClass = TDFAntiMatterCannon