############
###
### Small EMP Effect
###
############

local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')

EMPEffect02 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = GCEffectTemplate.EMPEffect01,
	FxTrailScale = 0.3,
}
TypeClass = EMPEffect02

