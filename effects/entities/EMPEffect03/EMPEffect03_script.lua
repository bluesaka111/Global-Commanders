local EffectTemplate = import('/lua/EffectTemplates.lua')

EMPEffect03 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = EffectTemplate.CProtonArtilleryHit01,
	FxTrailScale = 4,
}
TypeClass = EMPEffect03

