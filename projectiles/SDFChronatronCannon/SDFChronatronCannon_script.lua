local SChronatronCannonOverCharge = import('/lua/seraphimprojectiles.lua').SChronatronCannonOverCharge

SDFChronatronCannon = Class(SChronatronCannonOverCharge) {

    FxTrailScale = 2,
    PolyTrailScale = 2,
    FxLandHitScale = 3,
    FxPropHitScale = 3,
    FxUnitHitScale = 3,
}
TypeClass = SDFChronatronCannon