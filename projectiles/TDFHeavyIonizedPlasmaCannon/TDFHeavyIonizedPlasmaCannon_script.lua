local TIonizedPlasmaGatlingCannon = import('/lua/terranprojectiles.lua').TIonizedPlasmaGatlingCannon
local EffectTemplate = import('/lua/EffectTemplates.lua')

TDFHeavyIonizedPlasmaCannon = Class(TIonizedPlasmaGatlingCannon) {

    FxImpactUnit = EffectTemplate.TAntiMatterShellHit02,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit02,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit02,
    FxLandHitScale = 0.33,
    FxPropHitScale = 0.33,
    FxUnitHitScale = 0.33,
}
TypeClass = TDFHeavyIonizedPlasmaCannon