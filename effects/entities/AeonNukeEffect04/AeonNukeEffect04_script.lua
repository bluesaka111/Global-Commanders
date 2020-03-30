local GCEffectTemplate = import('/mods/Global Commanders Enhanced/lua/GCEffectTemplates.lua')

AeonNukeEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = GCEffectTemplate.AeonNukePlumeFxTrails03,
	FxTrailScale = 0.5,
}
TypeClass = AeonNukeEffect04
