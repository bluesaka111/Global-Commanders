local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')

AeonNukeEffect06 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = GCEffectTemplate.AeonNukePlumeFxTrails06,
	FxTrailScale = 0.7,
}
TypeClass = AeonNukeEffect06

