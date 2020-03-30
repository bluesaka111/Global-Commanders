local GCEffectTemplate = import('/mods/Global Commanders Enhanced/lua/GCEffectTemplates.lua')

EMPEffect01 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = GCEffectTemplate.EMPEffect01,
	FxTrailScale = 1.5,
}
TypeClass = EMPEffect01

