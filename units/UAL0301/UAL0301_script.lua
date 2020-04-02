#****************************************************************************
#**
#**  File     :  /cdimage/units/UAL0301/UAL0301_script.lua
#**  Author(s):  Jessica St. Croix
#**
#**  Summary  :  Aeon Sub Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local ADFPhasonLaser = AWeapons.ADFPhasonLaser
local ADFCannonOblivionWeapon = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua').ADFCannonOblivionWeapon02
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon
local ADFCannonQuantumWeapon = AWeapons.ADFCannonQuantumWeapon
local ACruiseMissileWeapon = AWeapons.ACruiseMissileWeapon
local AANChronoTorpedoWeapon = AWeapons.AANChronoTorpedoWeapon

local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

UAL0301 = Class(AWalkingLandUnit) {    
    Weapons = {
        RightOblivionCannon = Class(ADFCannonOblivionWeapon) {},
        LeftOblivionCannon = Class(ADFCannonOblivionWeapon) {},
        RightQuantumCannon = Class(ADFCannonQuantumWeapon) {},
        LeftQuantumCannon = Class(ADFCannonQuantumWeapon) {},
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
        MissileRack01 = Class(AAAZealotMissileWeapon) {},
        MissileRack02 = Class(AAAZealotMissileWeapon) {},
        LaserCannon = Class(ADFPhasonLaser) {},
        CruiseMissile01 = Class(ACruiseMissileWeapon) {},
        CruiseMissile02 = Class(ACruiseMissileWeapon) {},
        Torpedo = Class(AANChronoTorpedoWeapon) {},
    },

    OnCreate = function(self)
        AWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
		self.canTeleport = 'false'
        self:HideBone('Turbine', true)
        self:HideBone('Head_Upgrade', true)
        self:HideBone('Missile_Turret01', true)
        self:HideBone('Missile_Turret02', true)
        self:HideBone('Axe01', true)
        self:HideBone('Axe02', true)
        self:HideBone('LeftQuantumCannon', true)
        self:HideBone('RightQuantumCannon', true)
        self:HideBone('Torpedo_Barrel01', true)
        self:HideBone('Torpedo_Barrel02', true)
        self:HideBone('Laser_Barrel', true)
        self:SetupBuildBones()
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYSUBCOMMANDER) ) 
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        AWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
		self:SetWeaponEnabledByLabel('Torpedo', false)
		self:SetWeaponEnabledByLabel('MissileRack01', false)
		self:SetWeaponEnabledByLabel('MissileRack02', false)
		self:SetWeaponEnabledByLabel('LaserCannon', false)
		self:SetWeaponEnabledByLabel('CruiseMissile01', false)
		self:SetWeaponEnabledByLabel('CruiseMissile02', false)
		self:SetWeaponEnabledByLabel('RightQuantumCannon', false)
		self:SetWeaponEnabledByLabel('LeftQuantumCannon', false)
		self.WeaponsEnabled = true
    end,
    
    OnPrepareArmToBuild = function(self)
        AWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,
        
    OnStopCapture = function(self, target)
        AWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnFailedCapture = function(self, target)
        AWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStopReclaim = function(self, target)
        AWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    
    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnMotionHorzEventChange = function( self, new, old )
        AWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

        if ( new == 'TopSpeed' ) and self.canTeleport == 'true' then
			ForkThread(function()
			#self:HideBone(0, true)
				Pos = self:GetNavigator():GetGoalPos()
				destination = Vector(Pos[1], Pos[2], Pos[3])

				self:PlayTeleportOutEffects()
				self:PlayUnitSound('GateOut')
								
				Warp(self, destination, self:GetOrientation())
				
				self:CreateProjectile( '/mods/Global Commanders Enhanced/effects/entities/SuperTeleport/SuperTeleport_proj.bp', 0, 0.35, 0, nil, nil, nil):SetCollision(false)

				WaitSeconds(.3) --wait at destination
				self:GetNavigator():AbortMove()
				#self:ShowBone(0, true)
            		end)	
		end
	end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,      
    
    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        #Shield
        if enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldHeavy' then
            self:ForkThread(self.CreateHeavyShield, bp)
        #ResourceAllocation              
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        #Engineering Focus Module
        elseif enh == 'EngineeringFocusingModule' then
            if not Buffs['AeonSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate',
                    DisplayName = 'AeonSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUBuildRate')
        #SystemIntegrityCompensator
        elseif enh == 'SystemIntegrityCompensator' then
            if not Buffs['AeonSCUIntegrityCompensator'] then
               BuffBlueprint {
                    Name = 'AeonSCUIntegrityCompensator',
                    DisplayName = 'AeonSCUIntegrityCompensator',
                    BuffType = 'SCUUPGRADEDMG',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            Buff.ApplyBuff(self, 'AeonSCUIntegrityCompensator')
        #Crysalis Beam
        elseif enh == 'CrysalisBeam' then
            local wep1 = self:GetWeaponByLabel('LeftOblivionCannon')
            wep1:ChangeDamage(bp.LeftOblivionCannonNewDamage)
            local wep2 = self:GetWeaponByLabel('RightOblivionCannon')
            wep2:ChangeDamage(bp.RightOblivionCannonNewDamage)
        #Heat Sink Augmentation
        elseif enh == 'HeatSink' then
            local wep1 = self:GetWeaponByLabel('LeftOblivionCannon')
            wep1:ChangeRateOfFire(bp.LeftOblivionCannonNewRateOfFire)
            local wep2 = self:GetWeaponByLabel('RightOblivionCannon')
            wep2:ChangeRateOfFire(bp.RightOblivionCannonNewRateOfFire)
        #StabilitySupressant
        elseif enh =='StabilitySuppressant' then
            local wep1 = self:GetWeaponByLabel('LeftOblivionCannon')
            wep1:ChangeDamageRadius(bp.LeftOblivionCannonNewDamageRadius)
            local wep2 = self:GetWeaponByLabel('RightOblivionCannon')
            wep2:ChangeDamageRadius(bp.RightOblivionCannonNewDamageRadius)
	#Heavy AntiAir Upgrade
	elseif enh =='HeavyAntiAirUpgrade' then
	    self:SetWeaponEnabledByLabel('MissileRack01', true)
	    self:SetWeaponEnabledByLabel('MissileRack02', true)
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius)
            self:SetIntelRadius('Vision', bp.NewVisionRadius)
            self:SetIntelRadius('Omni', bp.NewOmniRadius)
	#Phason Laser
        elseif enh == 'PhasonLaser' then
            self:SetWeaponEnabledByLabel('LaserCannon', true)
        #Cruise Missiles
        elseif enh == 'CruiseMissile' then
            self:SetWeaponEnabledByLabel('CruiseMissile01', true)
            self:SetWeaponEnabledByLabel('CruiseMissile02', true)
        #Quantum Cannon
        elseif enh == 'RightQuantumCannon' then
            self:SetWeaponEnabledByLabel('RightQuantumCannon', true)
        elseif enh == 'LeftQuantumCannon' then
            self:SetWeaponEnabledByLabel('LeftQuantumCannon', true)
        #Torpedo Launcher
        elseif enh == 'TorpedoLauncher' then
            self:SetWeaponEnabledByLabel('Torpedo', true)
	#Teleporter
        elseif enh == 'SuperTeleporter' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
	#SpeedIncrease
	elseif enh == 'SpeedIncrease' then
		self:SetSpeedMult(4.0)
    	elseif enh =='SubComEngineeringT4' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            if not Buffs['AeonSCUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUT4BuildRate',
                    DisplayName = 'AeonSCUT4BuildRate',
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
            Buff.ApplyBuff(self, 'AeonSCUT4BuildRate') 
    	elseif enh =='SubComEngineeringT5' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonSCUT5BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUT5BuildRate',
                    DisplayName = 'AeonSCUT5BuildRate',
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
            Buff.ApplyBuff(self, 'AeonSCUT5BuildRate') 
        end
    end,
    
    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)     
        self:SetMaintenanceConsumptionActive()
    end,    
    
    OnPaused = function(self)
        AWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        AWalkingLandUnit.OnUnpaused(self)
    end,   

    OnScriptBitSet = function(self, bit)
        AWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        AWalkingLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(4.0) 
	    	self.canTeleport = 'false'
        end
    end,      
}

TypeClass = UAL0301
