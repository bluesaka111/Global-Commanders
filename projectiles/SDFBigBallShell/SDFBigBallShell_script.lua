local SDFExperimentalPhasonProjectile = import('/lua/seraphimprojectiles.lua').SDFExperimentalPhasonProjectile

SDFBigBallShell = Class(SDFExperimentalPhasonProjectile) {

    FxTrailScale = 2,
    FxLandHitScale = 2,
    FxPropHitScale = 2,
    FxUnitHitScale = 2,
}

TypeClass = SDFBigBallShell

