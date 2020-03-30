local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local GetRandomFloat = import('/lua/utilities.lua').GetRandomFloat
local DefaultExplosion = import('/lua/defaultexplosions.lua')
local DepthCharge = import('/lua/defaultantiprojectile.lua').DepthCharge
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Projectile = import('/lua/sim/projectile.lua').Projectile
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local util = import('/lua/utilities.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local MultiCompositeEmitterProjectile = DefaultProjectileFile.MultiCompositeEmitterProjectile
local NullShell = DefaultProjectileFile.NullShell
local MultiBeamProjectile = DefaultProjectileFile.MultiBeamProjectile

local GCEffectTemplate = import('/mods/Global Commanders Enhanced/lua/GCEffectTemplates.lua')

AOblivionCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,

    PolyTrails = {
	'/effects/emitters/aeon_laser_trail_02_emit.bp',
	'/effects/emitters/default_polytrail_03_emit.bp',
    },
    PolyTrailOffset = {0,0},
    PolyTrailScale = 5,

    FxTrails = {
        '/effects/emitters/oblivion_cannon_munition_01_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    FxTrailScale = 5,
	
    FxImpactUnit = GCEffectTemplate.AOblivionCannonEXHit,
    FxImpactProp = GCEffectTemplate.AOblivionCannonEXHit,
    FxImpactLand = GCEffectTemplate.AOblivionCannonEXHit,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

ADFPowerCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
	'/effects/emitters/aeon_laser_trail_02_emit.bp',
	'/effects/emitters/default_polytrail_03_emit.bp',
    },
    PolyTrailOffset = {0,0},
    PolyTrailScale = 3,

    FxTrails = {
        '/effects/emitters/oblivion_cannon_munition_01_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    FxTrailScale = 3,

    FxImpactUnit = GCEffectTemplate.APowerCannonHit01,
    FxImpactProp = GCEffectTemplate.APowerCannonHit01,
    FxImpactLand = GCEffectTemplate.APowerCannonHit01,
    FxImpactWater = GCEffectTemplate.APowerCannonHit01,
    FxImpactShield = GCEffectTemplate.APowerCannonHit01,
    FxImpactUnderWater = {},
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxLandHitScale = 2,
    FxWaterHitScale = 2,
    FxShieldHitScale = 2,
}

AQuantumCannonProjectile = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_01_emit.bp',
        '/effects/emitters/quantum_cannon_munition_02_emit.bp',  
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
        '/effects/emitters/quantum_cannon_munition_05_emit.bp',
        '/effects/emitters/quantum_cannon_munition_06_emit.bp',  
    },
    FxTrailScale = 2.5,
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',
    PolyTrailScale = 2.5,
    FxImpactUnit = EffectTemplate.AQuantumCannonHit01,
    FxImpactProp = EffectTemplate.AQuantumCannonHit01,
    FxImpactLand = EffectTemplate.AQuantumCannonHit01,
    FxLandHitScale = 2.5,
    FxPropHitScale = 2.5,
    FxUnitHitScale = 2.5,
}

ADFSuperCannonProjectile = Class(MultiPolyTrailProjectile) {

    PolyTrails = {
	'/mods/Global Commanders Enhanced/effects/emitters/AeonSuperCannon_polytrails_emit.bp',
    },
    PolyTrailScale = 5,
    FxImpactUnit = GCEffectTemplate.ASuperCannonHit01,
    FxUnitHitScale = 1.25,
    FxImpactProp = GCEffectTemplate.ASuperCannonHit01,
    FxPropHitScale = 1.25,
    FxImpactLand = GCEffectTemplate.ASuperCannonHit01,
    FxLandHitScale = 1.25,
    FxImpactWater = GCEffectTemplate.ASuperCannonHit01,
    FxImpactShield = GCEffectTemplate.ASuperCannonHit01,
    FxWaterHitScale = 1.25,
    FxShieldHitScale = 1.25,
    FxImpactUnderWater = {},
}

AQuantumWarheadProjectile = Class(MultiCompositeEmitterProjectile) {

    Beams = {'/effects/emitters/aeon_nuke_exhaust_beam_01_emit.bp',},
    PolyTrails = {'/effects/emitters/aeon_nuke_trail_emit.bp',},

    FxImpactUnit = EffectTemplate.CProtonArtilleryHit01,
    FxImpactProp = EffectTemplate.CProtonArtilleryHit01,    
    FxImpactLand = EffectTemplate.CProtonArtilleryHit01,

    FxLandHitScale = 5,
    FxPropHitScale = 5,
    FxUnitHitScale = 5,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()

        local blanketSides = 12
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/mods/Global Commanders Enhanced/effects/entities/EMPEffect01/EMPEffect01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
    
}

CDFStunProjectile = Class(NullShell) {

    FxImpactTrajectoryAligned = false,

    FxImpactUnit = EffectTemplate.CProtonArtilleryHit01,
    FxImpactProp = EffectTemplate.CProtonArtilleryHit01,    
    FxImpactLand = EffectTemplate.CProtonArtilleryHit01,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()

        local blanketSides = 12
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/mods/Global Commanders Enhanced/effects/entities/EMPEffect02/EMPEffect02_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
    
}

SDFMegaCannonProjectile = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.SDFSinnutheWeaponFXTrails01,

    FxImpactUnit = GCEffectTemplate.SMegaCannonHit01,
    FxUnitHitScale = 1.6,
    FxImpactProp = GCEffectTemplate.SMegaCannonHit01,
    FxPropHitScale = 1.6,
    FxImpactLand = GCEffectTemplate.SMegaCannonHit01,
    FxLandHitScale = 1.6,
    FxImpactWater = GCEffectTemplate.SMegaCannonHit01,
    FxWaterHitScale = 1.6,
    FxImpactShield = GCEffectTemplate.SMegaCannonHit01,
    FxShieldHitScale = 1.6,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

SDFMultigunProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactNone = GCEffectTemplate.MultiGunWeaponHit01,
    FxImpactUnit = GCEffectTemplate.MultigunWeaponHitUnit,
    FxImpactProp = GCEffectTemplate.MultiGunWeaponHit01,
    FxImpactLand = GCEffectTemplate.MultiGunWeaponHit01,
    FxImpactWater= GCEffectTemplate.MultiGunWeaponHit01,
    RandomPolyTrails = 1,
    
    PolyTrails = GCEffectTemplate.MultiGunWeaponPolytrails01,
    PolyTrailOffset = {0,0,0},
}

SIFBoomProjectile = Class(NullShell) {
    FxImpactTrajectoryAligned = false,

    OnImpact = function(self, TargetType, TargetEntity)
        NullShell.OnImpact(self, TargetType, TargetEntity) 
	local proj = self:CreateProjectile('/effects/entities/SBOOhwalliBombEffectController01/SBOOhwalliBombEffectController01_proj.bp', 0, 0, 0, 0, 0, 0):SetCollision(false)
	proj:PassDamageData(self.DamageData)
	self:Destroy()
    end,
}

SIFNukeProjectile = Class(NullShell) {
    FxImpactTrajectoryAligned = false,

    OnImpact = function(self, TargetType, TargetEntity)
        nukeProjectile = self:CreateProjectile('/effects/entities/InainoEffectController01/InainoEffectController01_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
        nukeProjectile:PassDamageData(self.DamageData)
        nukeProjectile:PassData(self.Data)
        NullShell.OnImpact(self, TargetType, TargetEntity)
    end,
}

THgausCannon = Class(MultiPolyTrailProjectile) {
    FxImpactWater = GCEffectTemplate.THgausCannonUnitHit,
    FxImpactLand = GCEffectTemplate.THgausCannonUnitHit,
    FxImpactNone = GCEffectTemplate.THgausCannonUnitHit,
    FxImpactProp = GCEffectTemplate.THgausCannonUnitHit,    
    FxImpactUnit = GCEffectTemplate.THgausCannonUnitHit,    
    FxTrails = GCEffectTemplate.THgausCannonFxTrails,
    PolyTrails = GCEffectTemplate.THgausCannonPolyTrails,
    PolyTrailOffset = {0,-1.5},
    FxImpactProjectile = {},
    FxImpactUnderWater = {},
    FxTrailScale = 0.85,
    FxUnitHitScale = 0.45,
    FxLandHitScale = 0.45, 
    FxNoneHitScale = 0.45, 
    FxPropHitScale = 0.45, 
    FxWaterHitScale = 0.45,
}

TDFPlasmaGunProjectile = Class(EmitterProjectile) {
    FxTrails = {'/mods/Global Commanders Enhanced/Effects/Emitters/PlasmaTrailFX.bp',},
    FxTrailScale = 0.5,  
  
    FxImpactTrajectoryAligned = false,

    FxImpactUnit = GCEffectTemplate.PlasmaHit01,
    FxImpactProp = GCEffectTemplate.PlasmaHit01,
    FxImpactLand = GCEffectTemplate.PlasmaHit01,     
}

#########################################################################################################################
#
#   Cybran Nuke Effects Projectiles

CybranPlasmaBallProjectile = Class(EmitterProjectile) {
    PolyTrail = GCEffectTemplate.CybranPlasmaBallPolytrail01,
    FxTrails = GCEffectTemplate.CybranPlasmaBallFxtrail01,
	FxTrailScale = 2,

    # Hit Effects
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},

    ChildProjectile = '/mods/Global Commanders Enhanced/projectiles/CybranPlasmaBallChild01/CybranPlasmaBallChild01_proj.bp',

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        self.Impacted = false
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
        EmitterProjectile.DoDamage(self, instigator, damageData, targetEntity)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false and TargetType != 'Air' then
            self.Impacted = true
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,4),Random(1,5),Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),-Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.5,5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),-Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1.5,4.5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),Random(2,4))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,2),Random(1,7),-Random(1,3))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2.5,3.5),Random(2,6),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2,3),Random(2,3),Random(3,5))
            EmitterProjectile.OnImpact(self, TargetType, TargetEntity)
        end
    end,
    
    # Overiding Destruction
    OnImpactDestroy = function( self, TargetType, TargetEntity)
        self:ForkThread( self.DelayedDestroyThread )
    end,

    DelayedDestroyThread = function(self)
        WaitSeconds( 0.5 )
        self:Destroy()
    end,
}

CybranPlasmaBallChildProjectile = Class(EmitterProjectile) {
    PolyTrail = GCEffectTemplate.CybranPlasmaBallPolytrail01,
    FxTrails = GCEffectTemplate.CybranPlasmaBallChildFxtrail01,
	FxTrailScale = 2,
    # Hit Effects
    FxImpactUnit = GCEffectTemplate.CybranPlasmaBallHitLand01,
	FxUnitHitScale = 2,
    FxImpactProp = GCEffectTemplate.CybranPlasmaBallHitLand01,
	FxPropHitScale = 2,
    FxImpactLand = GCEffectTemplate.CybranPlasmaBallHitLand01,
	FxLandHitScale = 2,
    FxImpactWater = GCEffectTemplate.CybranPlasmaBallHitLand01,
	FxWaterHitScale = 2,
    OnCreate = function(self, TargetType, TargetEntity)

    	local projectile = self
		
	SetDamageThread = ForkThread(function(self)
	    projectile.DamageData = {
	    	DamageRadius = 4,
	    	DamageAmount = 100,
	    	DoTPulses = 30,
            	DoTTime = 9,
	    	DamageType = 'Normal',
	    	DamageFriendly = true,
	        MetaImpactAmount = nil,
	        MetaImpactRadius = nil,
	    }
	    KillThread(self)
	end)
	EmitterProjectile.OnCreate(self, TargetType, TargetEntity)
    end,

}

###########################################################################################################################
