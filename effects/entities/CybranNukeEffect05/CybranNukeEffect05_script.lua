local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')

CybranNukeEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = GCEffectTemplate.CybranNukePlumeFxTrails05,
	FxTrailScale = 0.5,
}
TypeClass = CybranNukeEffect05

