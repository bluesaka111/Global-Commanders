local TLaserBotProjectile = import('/lua/terranprojectiles.lua').TLaserBotProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

LaserBotTerran01 = Class(TLaserBotProjectile) {

    FxTrails = {},
    PolyTrail = '/mods/Global Commanders Enhanced/effects/Emitters/bluelaser_emit.bp',

    # Hit Effects
    FxImpactUnit = EffectTemplate.TPlasmaCannonHeavyHit01,
    FxImpactProp = EffectTemplate.TPlasmaCannonHeavyHit01,
    FxImpactLand = EffectTemplate.TPlasmaCannonHeavyHit01,

}
TypeClass = LaserBotTerran01

