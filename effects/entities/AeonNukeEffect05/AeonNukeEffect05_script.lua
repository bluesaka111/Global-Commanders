local GCEffectTemplate = import('/mods/Global Commanders Enhanced/lua/GCEffectTemplates.lua')

AeonNukeEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = GCEffectTemplate.AeonNukePlumeFxTrails05,
	FxTrailScale = 0.5,
}
TypeClass = AeonNukeEffect05

