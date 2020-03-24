#****************************************************************************
#**
#**  File     :  /cdimage/units/XSL0301/XSL0301_script.lua
#**  Author(s):  Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  Seraphim Sub Commander Script
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SWeapons = import('/lua/seraphimweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SDFExperimentalPhasonProj = SWeapons.SDFExperimentalPhasonProj
local SDFUltraChromaticBeamGenerator = SWeapons.SDFUltraChromaticBeamGenerator
local SDFThauCannon = SWeapons.SDFThauCannon
local SLaanseMissileWeapon = SWeapons.SLaanseMissileWeapon
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon
local SDFHeavyQuarnonCannon = SWeapons.SDFHeavyQuarnonCannon
local SDFUnstablePhasonBeam = SWeapons.SDFUnstablePhasonBeam
local SANHeavyCavitationTorpedo = SWeapons.SANHeavyCavitationTorpedo

local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local RemoteTracking = import('/mods/Global Commanders/lua/RemoteTracking.lua').RemoteTracking
SWalkingLandUnit = RemoteTracking( SWalkingLandUnit )

XSL0301 = Class(SWalkingLandUnit) {
    
    Weapons = {
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
        AireauBolter = Class(SDFThauCannon) {},
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
        OverCharge = Class(SDFExperimentalPhasonProj) {},
        QuarnonCannon = Class(SDFHeavyQuarnonCannon) {},
        AntiAir01 = Class(SDFUnstablePhasonBeam) {},
        AntiAir02 = Class(SDFUnstablePhasonBeam) {},
        Torpedo01 = Class(SANHeavyCavitationTorpedo) {},
        Torpedo02 = Class(SANHeavyCavitationTorpedo) {},
        NukeCruiseMissile = Class(SLaanseMissileWeapon) {},
        Laser = Class(SDFUltraChromaticBeamGenerator) {
            OnWeaponFired = function(self)
            	SDFUltraChromaticBeamGenerator.OnWeaponFired(self)
            	local wep = self.unit:GetWeaponByLabel('Boom')
            	self.targetaquired = self:GetCurrentTargetPos()
            	if self.targetaquired then
					wep:SetTargetGround(self.targetaquired)
					self.unit:SetWeaponEnabledByLabel('Boom', true)
					wep:SetTargetGround(self.targetaquired)
					wep:OnFire()
				end
			end,
        },
        Boom = Class(CDFLaserHeavyWeapon){
            OnWeaponFired = function(self)
            CDFLaserHeavyWeapon.OnWeaponFired(self)
		self:SetWeaponEnabled(false)
            end,
        },
    },

    OnCreate = function(self)
        SWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
	self.canTeleport = 'false'
        self:HideBone('HeavyQuarnonCannon', true)
        self:HideBone('Left_Torpedo_Barrel', true)
        self:HideBone('Right_Torpedo_Barrel', true)
        self:HideBone('OverCharge_Cannon', true)
        self:HideBone('Back_Upgrade01', true)
	self:HideBone('Back_Upgrade02', true)
	self:HideBone('Back_Upgrade03', true)
	self:HideBone('Right_AA_Barrel', true)
	self:HideBone('Left_AA_Barrel', true)
        self:SetupBuildBones()
        self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYSUBCOMMANDER) ) 
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        SWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
	self:SetWeaponEnabledByLabel('OverCharge', false)
	self:SetWeaponEnabledByLabel('QuarnonCannon', false)
	self:SetWeaponEnabledByLabel('AntiAir01', false)
	self:SetWeaponEnabledByLabel('AntiAir02', false)
	self:SetWeaponEnabledByLabel('Laser', false)
    	self:SetWeaponEnabledByLabel('Boom', false)    
	self:SetWeaponEnabledByLabel('Torpedo01', false)
	self:SetWeaponEnabledByLabel('Torpedo02', false)
	self:SetWeaponEnabledByLabel('NukeCruiseMissile', false)
	self.WeaponsEnabled = true
    end,
    
    OnPrepareArmToBuild = function(self)
        SWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,
        
    OnStopCapture = function(self, target)
        SWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnFailedCapture = function(self, target)
        SWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStopReclaim = function(self, target)
        SWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        local bp = self:GetBlueprint()
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            self.Upgrading = true
            self.BuildingUnit = false        
            unitBeingBuilt.DisallowCollisions = true
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        SWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnMotionHorzEventChange = function( self, new, old )
        SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

        if ( new == 'TopSpeed' ) and self.canTeleport == 'true' then
			ForkThread(function()
			#self:HideBone(0, true)
				Pos = self:GetNavigator():GetGoalPos() --Get the destination
				destination = Vector(Pos[1], Pos[2], Pos[3]) --turn the destination into a vector

				self:PlayTeleportOutEffects()
				self:PlayUnitSound('GateOut')
								
				Warp(self, destination, self:GetOrientation()) -- warp us there baby yeah!!!
				
				self:CreateProjectile( '/mods/Global Commanders/effects/entities/SuperTeleport/SuperTeleport_proj.bp', 0, 0.35, 0, nil, nil, nil):SetCollision(false)

				WaitSeconds(.3) --wait at destination
				self:GetNavigator():AbortMove()	--kill the current move order
				#self:ShowBone(0, true)
            			end)	
			end
		end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  
    
    CreateEnhancement = function(self, enh)
        SWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        #Shield
        if enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        #Overcharge
        elseif enh == 'Overcharge' then
      	    self:SetWeaponEnabledByLabel('OverCharge', true)
        #QuarnonCannon
        elseif enh == 'QuarnonCannon' then
      	    self:SetWeaponEnabledByLabel('QuarnonCannon', true)
        #Engineering Throughput Upgrade
        elseif enh =='EngineeringThroughput' then
            if not Buffs['SeraphimSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUBuildRate',
                    DisplayName = 'SeraphimSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')
        #Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimSCUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimSCUDamageStabilization',
                    DisplayName = 'SeraphimSCUDamageStabilization',
                    BuffType = 'SCUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            Buff.ApplyBuff(self, 'SeraphimSCUDamageStabilization')           
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius)
            self:SetIntelRadius('Vision', bp.NewVisionRadius)
            self:SetIntelRadius('Omni', bp.NewOmniRadius)
      	#Antiair
        elseif enh == 'LeftAntiair' then
	    self:SetWeaponEnabledByLabel('AntiAir01', true)	
        elseif enh == 'RightAntiair' then	
	    self:SetWeaponEnabledByLabel('AntiAir02', true)
      	#Torpedo Launcher
        elseif enh == 'LeftTorpedo' then
	    self:SetWeaponEnabledByLabel('Torpedo01', true)	
        elseif enh == 'RightTorpedo' then	
	    self:SetWeaponEnabledByLabel('Torpedo02', true)
        #Blast Attack
        elseif enh == 'BlastAttack' then
            local wep1 = self:GetWeaponByLabel('ChronotronCannon')
            wep1:ChangeDamage(bp.ChronotronCannonNewDamage)
            local wep2 = self:GetWeaponByLabel('AireauBolter')
            wep2:ChangeDamage(bp.AireauBolterNewDamage)
        #Heat Sink Augmentation
        elseif enh == 'RateOfFire' then
            local wep1 = self:GetWeaponByLabel('ChronotronCannon')
            wep1:ChangeRateOfFire(bp.ChronotronCannonNewRateOfFire)
            local wep2 = self:GetWeaponByLabel('AireauBolter')
            wep2:ChangeRateOfFire(bp.AireauBolterNewRateOfFire)
        elseif enh =='StabilitySuppressant' then
            local wep1 = self:GetWeaponByLabel('ChronotronCannon')
            wep1:ChangeDamageRadius(bp.ChronotronCannonNewDamageRadius)  
            local wep2 = self:GetWeaponByLabel('AireauBolter') 
            wep2:ChangeDamageRadius(bp.AireauBolterNewDamageRadius) 
      	#Laser
        elseif enh == 'Laser' then
	    self:SetWeaponEnabledByLabel('Laser', true)	
        #Resource Allocation
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
      	#MultiCruiseMissile
        elseif enh == 'NukeCruiseMissile' then
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
	    self:SetWeaponEnabledByLabel('NukeCruiseMissile', true)
        #Teleporter
        elseif enh == 'SuperTeleport' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
	#SpeedIncrease
	elseif enh == 'SpeedIncrease' then
		self:SetSpeedMult(4.0) 
    	elseif enh =='SubComEngineeringT4' then
            if not Buffs['SeraphimSCUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUT4BuildRate',
                    DisplayName = 'SeraphimSCUT4BuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1.0,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimSCUT4BuildRate')
    	elseif enh =='SubComEngineeringT5' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
	    if not Buffs['SeraphimSCUT5BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUT5BuildRate',
                    DisplayName = 'SeraphimSCUT5BuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1.0,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimSCUT5BuildRate')
        elseif enh == 'RemoteTracking' then
            	self.Sync.Abilities = self:GetBlueprint().Abilities
            	self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            	self:SetMaintenanceConsumptionInactive()
            	self:EnableRemoteViewingButtons() 
        end
    end,

    OnScriptBitSet = function(self, bit)
        SWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        SWalkingLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(4.0) 
	    	self.canTeleport = 'false'
        end
    end,
    
    OnPaused = function(self)
        SWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        SWalkingLandUnit.OnUnpaused(self)
    end,         
}

TypeClass = XSL0301
