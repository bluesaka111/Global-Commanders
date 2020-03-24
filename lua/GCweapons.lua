local WeaponFile = import('/lua/sim/defaultweapons.lua') 
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')

local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')
local GCCollisionBeamFile = import('/mods/Global Commanders/lua/GCdefaultcollisionbeams.lua')

ADFCannonOblivionWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
	'/effects/emitters/oblivion_cannon_flash_04_emit.bp',
	'/effects/emitters/oblivion_cannon_flash_05_emit.bp',
	'/effects/emitters/oblivion_cannon_flash_06_emit.bp',
    },  
    FxChargeMuzzleFlash = {
	'/effects/emitters/oblivion_cannon_flash_01_emit.bp',
        '/effects/emitters/oblivion_cannon_flash_02_emit.bp',
        '/effects/emitters/oblivion_cannon_flash_03_emit.bp',
    },
}

ADFCannonOblivionWeapon02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.AOblivionCannonMuzzleFlash02,
    FxMuzzleFlashScale = 0.33,
    FxChargeMuzzleFlash = EffectTemplate.AOblivionCannonChargeMuzzleFlash02,
    FxChargeMuzzleFlashScale = 0.33,
}

BigGaussCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = GCEffectTemplate.THgausCannonMuzzleFlash,
	FxMuzzleFlashScale = 0.25,
}

RedLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = GCCollisionBeamFile.RedLaserBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

BlueLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = GCCollisionBeamFile.BlueLaserBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}