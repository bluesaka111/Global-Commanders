local TArtilleryAntiMatterProjectile = import('/lua/terranprojectiles.lua').TArtilleryAntiMatterProjectile

TIFClusterMissileChild = Class(TArtilleryAntiMatterProjectile) {

    FxLandHitScale = 0.33,
    FxPropHitScale = 0.33,
    FxUnitHitScale = 0.33,

}

TypeClass = TIFClusterMissileChild