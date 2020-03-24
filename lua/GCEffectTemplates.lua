TableCat = import('/lua/utilities.lua').TableCat
EmtBpPathAlt = '/mods/Global Commanders/effects/Emitters/'
ModPath = '/mods/Global Commanders/effects/Emitters/'
EmtBpPath = '/effects/emitters/'


UnitHitShrapnel01 = { EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',}

OthuyAmbientEmanation = {
    EmtBpPath .. 'seraphim_othuy_ambient_01_emit.bp',
    EmtBpPath .. 'seraphim_othuy_ambient_02_emit.bp',
    EmtBpPath .. 'seraphim_othuy_ambient_03_emit.bp',
    #EmtBpPath .. 'seraphim_othuy_ambient_04_emit.bp',
    #EmtBpPath .. 'seraphim_othuy_ambient_05_emit.bp',
    #EmtBpPath .. 'seraphim_othuy_ambient_06_emit.bp',
}

#-------------------------------------------
#			NEW AEON NUKE EFFECTS
#-------------------------------------------
AeonNukeHit01 = {
    EmtBpPathAlt .. 'aeon_nuke_hit_01_emit.bp',			## plasma outward
    EmtBpPathAlt .. 'aeon_nuke_hit_02_emit.bp',			## spiky lines
    EmtBpPathAlt .. 'aeon_nuke_hit_03_emit.bp',			## plasma darkening outward
    EmtBpPathAlt .. 'aeon_nuke_hit_04_emit.bp',			## twirling line buildup
    EmtBpPathAlt .. 'aeon_nuke_detonate_03_emit.bp',	## non oriented glow
}
AeonNukePlumeFxTrails03 = {
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_05_emit.bp',		## plasma trail 
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_06_emit.bp',		## plasma trail darkening  
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_10_emit.bp',		## bright tip  
}
AeonNukePlumeFxTrails05 = {
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_07_emit.bp',	## plasma cloud 
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_08_emit.bp',	## plasma cloud 2, ser 07    
}
AeonNukePlumeFxTrails06 = {
    EmtBpPathAlt .. 'aeon_nuke_plume_fxtrails_09_emit.bp',	## line detail in explosion, fingers.
}

AeonNukeDetonate01 = {
    EmtBpPathAlt .. 'aeon_nuke_explode_01_emit.bp',		## glow
    EmtBpPathAlt .. 'aeon_nuke_explode_02_emit.bp',		## upwards plasma tall    
    EmtBpPathAlt .. 'aeon_nuke_explode_03_emit.bp',		## upwards plasma short/wide    
    EmtBpPathAlt .. 'aeon_nuke_explode_04_emit.bp',		## upwards plasma top column, thin/tall
    EmtBpPathAlt .. 'aeon_nuke_explode_05_emit.bp',		## upwards lines
    EmtBpPathAlt .. 'aeon_nuke_concussion_01_emit.bp',	## ring
    EmtBpPathAlt .. 'aeon_nuke_concussion_02_emit.bp',	## smaller/slower ring bursts
    EmtBpPathAlt .. 'aeon_nuke_hit_05_emit.bp',		## fast flash
    EmtBpPathAlt .. 'aeon_nuke_hit_14_emit.bp',		## long glow
    EmtBpPathAlt .. 'aeon_nuke_hit_13_emit.bp',		## faint plasma, ser7    
}

#-----------------------------------------
#				END EFFECTS
#-----------------------------------------

#---------------------------------------------------------
#				NEW CYBRAN NUKE EFFECTS
#---------------------------------------------------------
CybranNukePlumeFxTrails05 = {
    EmtBpPathAlt .. 'cybran_nuke_plume_fxtrails_07_emit.bp',	## plasma cloud 
    EmtBpPathAlt .. 'cybran_nuke_plume_fxtrails_08_emit.bp',	## plasma cloud 2, ser 07    
}

CybranNukeHeadEffects02 = { 
	EmtBpPathAlt .. 'cybran_nuke_head_smoke_03_emit.bp',
	EmtBpPathAlt .. 'cybran_nuke_head_smoke_04_emit.bp',
		
}

CybranNukeHeadEffects03 = { EmtBpPathAlt .. 'cybran_nuke_head_fire_01_emit.bp', }


#-----------------------------------------------------------
#					END EFFECTS
#-----------------------------------------------------------

CybranPlasmaBallPolytrail01 = EmtBpPath .. 'aeon_quantic_cluster_polytrail_01_emit.bp'

CybranPlasmaBallFxtrail01 = {
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrails_01_emit.bp',
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrails_02_emit.bp',
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrail_03_emit.bp',	##after cloud
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrail_06_emit.bp',#air ripple
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrail_08_emit.bp',#ripple
    EmtBpPathAlt .. 'cybran_plasma_ball_fxtrail_09_emit.bp',#ripple

}
CybranPlasmaBallChildFxtrail01 = {
    EmtBpPathAlt .. 'cybran_plasma_ball_child_fxtrails_01_emit.bp',
    EmtBpPathAlt .. 'cybran_plasma_ball_child_fxtrails_02_emit.bp',
}
CybranPlasmaBallHitLand01 = {
    EmtBpPathAlt .. 'blue_napalm_hvy_01_emit.bp',
    EmtBpPathAlt .. 'blue_napalm_hvy_02_emit.bp',
    EmtBpPathAlt .. 'blue_napalm_hvy_03_emit.bp',
}

EMPEffect01 = {
    EmtBpPathAlt .. 'aeon_empeffect_01_emit.bp',
    EmtBpPathAlt .. 'aeon_empeffect_02_emit.bp',
}

MultiGunWeaponPolytrails01 = {
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_polytrail_01_emit.bp', 
}

MultiGunWeaponMuzzleFlash = {
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_muzzle_flash_01_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_muzzle_flash_02_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_muzzle_flash_03_emit.bp',
}

MultiGunWeaponHit01 = {
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hit_01_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hit_02_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hit_03_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hit_04_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hit_05_emit.bp',
}

MultiGunWeaponHit02 = {
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hitunit_04_emit.bp',
    EmtBpPathAlt .. 'seraphim_multigun_autocannon_hitunit_05_emit.bp',
}

MultigunWeaponHitUnit = TableCat( MultiGunWeaponHit01, MultiGunWeaponHit02, UnitHitShrapnel01)

PlasmaHit01 = {
    EmtBpPathAlt .. 'plasma_flash_emit.bp',
    EmtBpPathAlt .. 'plasma_01_emit.bp',
    EmtBpPathAlt .. 'plasma_02_emit.bp',
    EmtBpPathAlt .. 'plasma_03_emit.bp',
}

MicrowaveBlueLaserEndPoint = {
    EmtBpPathAlt .. 'microwave_laser_end_01_emit.bp',
    EmtBpPathAlt .. 'microwave_laser_end_02_emit.bp',
    EmtBpPath .. 'microwave_laser_end_03_emit.bp',
    EmtBpPathAlt .. 'microwave_laser_end_04_emit.bp',
    EmtBpPath .. 'microwave_laser_end_05_emit.bp',
    EmtBpPathAlt .. 'microwave_laser_end_06_emit.bp',
}

MicrowaveBlueLaserMuzzle = { 
    EmtBpPathAlt .. 'microwave_laser_flash_01_emit.bp',
    EmtBpPathAlt .. 'microwave_laser_muzzle_01_emit.bp',
}

AOblivionCannonEXHit = {
    EmtBpPath .. 'quark_bomb_explosion_03_emit.bp',
    EmtBpPath .. 'quark_bomb_explosion_04_emit.bp',
    EmtBpPath .. 'quark_bomb_explosion_05_emit.bp',
    EmtBpPath .. 'quark_bomb_explosion_06_emit.bp',
    EmtBpPath .. 'quark_bomb_explosion_07_emit.bp',
    EmtBpPath .. 'quark_bomb_explosion_08_emit.bp',
    EmtBpPath .. 'aeon_chrono_dampener_01_emit.bp',
    EmtBpPath .. 'aeon_chrono_dampener_02_emit.bp',
    EmtBpPath .. 'aeon_chrono_dampener_03_emit.bp',
    EmtBpPath .. 'aeon_chrono_dampener_04_emit.bp',
}

THgausCannonMuzzleFlash = {
    ModPath .. 'w_u_hvg01_l_01_flash_emit.bp',
    ModPath .. 'w_u_hvg01_l_02_largeflash_emit.bp',
    ModPath .. 'w_u_hvg01_l_03_firecloud_emit.bp',
    ModPath .. 'w_u_hvg01_l_04_shockwave_emit.bp',
    ModPath .. 'w_u_hvg01_l_05_flashline_emit.bp',
    ModPath .. 'w_u_hvg01_l_06_leftoverplasma_emit.bp',
    ModPath .. 'w_u_hvg01_l_07_leftoversmoke_emit.bp',
    ModPath .. 'w_u_hvg01_l_08_inwardfirecloud_emit.bp',
    ModPath .. 'w_u_hvg01_l_09_sparks_emit.bp',
    ModPath .. 'w_u_hvg01_l_10_flashdetail_emit.bp',
    ModPath .. 'w_u_hvg01_l_11_dots_emit.bp',
    ModPath .. 'w_u_hvg01_l_12_flareflash_emit.bp',
    ModPath .. 'w_u_hvg01_l_13_leftoverline_emit.bp',
}

THgausCannonHit = {
    ModPath .. 'w_u_hvg01_i_u_01_flatflash_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_02_flash_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_03_sparks_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_04_halfring_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_05_ring_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_06_firecloud_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_07_fwdsparks_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_08_leftoverglows_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_11_debris_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_12_lines_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
}

THgausCannonUnitHit = {
    ModPath .. 'w_u_hvg01_i_u_01_flatflash_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_02_flash_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_03_sparks_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_04_halfring_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_05_ring_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_06_firecloud_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_07_fwdsparks_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_08_leftoverglows_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_09_leftoverwisps_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_10_fwdsmoke_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_11_debris_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_12_lines_emit.bp',
    ModPath .. 'w_u_hvg01_i_u_13_leftoversmoke_emit.bp',
}

THgausCannonFxTrails = {
    ModPath .. 'w_u_hvg01_p_01_smoke_emit.bp',
    ModPath .. 'w_u_hvg01_p_04_wisps_emit.bp',
    ModPath .. 'w_u_hvg01_p_05_glow_emit.bp',
}

THgausCannonPolyTrails = {
    ModPath .. 'w_u_hvg01_p_02_polytrail_emit.bp',
    ModPath .. 'w_u_hvg01_p_03_polytrail_emit.bp',
}

SMegaCannonHit01 = {
    EmtBpPathAlt .. 'seramegabot_01_emit.bp',
    EmtBpPathAlt .. 'seramegabot_02_emit.bp',
    EmtBpPathAlt .. 'seramegabot_03_emit.bp',
    EmtBpPathAlt .. 'seramegabot_04_emit.bp',
    EmtBpPathAlt .. 'seramegabot_05_emit.bp',
    EmtBpPathAlt .. 'seramegabot_06_emit.bp',
    EmtBpPathAlt .. 'seramegabot_07_emit.bp',
    EmtBpPathAlt .. 'seramegabot_08_emit.bp',
    EmtBpPathAlt .. 'seramegabot_09_emit.bp',
    EmtBpPathAlt .. 'seramegabot_10_emit.bp',
}

APowerCannonHit01 = {
    EmtBpPathAlt .. 'apowercannonhit_01_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_02_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_03_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_04_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_05_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_06_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_07_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_08_emit.bp',
    EmtBpPathAlt .. 'apowercannonhit_09_emit.bp',
}

ASuperCannonHit01 = {
    EmtBpPathAlt .. 'asupercannon_hit_01_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_02_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_03_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_04_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_05_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_06_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_07_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_08_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_09_emit.bp',
    EmtBpPathAlt .. 'asupercannon_hit_10_emit.bp',
}

LambdaRedirector = {
    EmtBpPathAlt .. 'lambda_distortion_01.bp',
    EmtBpPathAlt .. 'lambda_redirect_bright_01.bp',
    EmtBpPathAlt .. 'lambda_redirect_bright_01.bp',
    EmtBpPathAlt .. 'lambda_redirect_bright_02.bp',
    EmtBpPathAlt .. 'lambda_redirect_bright_02.bp',
    EmtBpPathAlt .. 'lambda_redirect_bright_03.bp',
    EmtBpPathAlt .. 'lambda_distortion_01.bp',
}

LambdaDestoyer = {
    EmtBpPathAlt .. 'lambda_distortion_01.bp',
    EmtBpPathAlt .. 'lambda_destroy_dark_01.bp',
    EmtBpPathAlt .. 'lambda_destroy_dark_02.bp',
    EmtBpPathAlt .. 'lambda_destroy_dark_03a.bp',
    EmtBpPathAlt .. 'lambda_destroy_dark_03b.bp',
    EmtBpPathAlt .. 'lambda_destroy_dark_04.bp',
    EmtBpPathAlt .. 'lambda_destroy_bright_01.bp',
    EmtBpPathAlt .. 'lambda_destroy_bright_01.bp',
    EmtBpPathAlt .. 'lambda_distortion_01.bp',
}