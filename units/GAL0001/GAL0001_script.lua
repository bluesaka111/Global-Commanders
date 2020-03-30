#****************************************************************************
#**
#**  File     :  /cdimage/units/UAL0001/UAL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  Aeon Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local ADFCannonQuantumWeapon = AWeapons.ADFCannonQuantumWeapon
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon
local ACruiseMissileWeapon = AWeapons.ACruiseMissileWeapon
local AANChronoTorpedoWeapon = AWeapons.AANChronoTorpedoWeapon
local ADFPhasonLaser = AWeapons.ADFPhasonLaser
local AIFQuantumWarhead = AWeapons.AIFQuantumWarhead

local ADFCannonOblivionWeapon = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua').ADFCannonOblivionWeapon
local ADFCannonOblivionWeapon02 = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua').ADFCannonOblivionWeapon02

local target = 0
local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local podteleport,podlocation

local RemoteViewing = import('/mods/Global Commanders Enhanced/lua/RemoteViewing.lua').RemoteViewing
AWalkingLandUnit = RemoteViewing( AWalkingLandUnit ) 

GAL0001 = Class(AWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,

    Weapons = {
    	LeftDisruptor = Class(ADFCannonOblivionWeapon) {
			OnCreate = function(self)
					ADFCannonOblivionWeapon.OnCreate(self)
					if not self.SpinManip then 
						self.SpinManip = CreateRotator(self.unit, 'Left_Rotator', 'z', nil, 150, 150, 150)
						self.unit.Trash:Add(self.SpinManip)
					end
			end,
		},
        RightDisruptor = Class(ADFCannonOblivionWeapon) {
			OnCreate = function(self)
            	ADFCannonOblivionWeapon.OnCreate(self)
            	if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Right_Rotator', 'z', nil, -150, -150, -150)
                    self.unit.Trash:Add(self.SpinManip)
				end
			end,
		},
        Torpedo01 = Class(AANChronoTorpedoWeapon) {},
        Torpedo02 = Class(AANChronoTorpedoWeapon) {},
    	LeftQuantumCannon = Class(ADFCannonQuantumWeapon) {},
    	RightQuantumCannon = Class(ADFCannonQuantumWeapon) {},
    	LeftAntiAir01 = Class(AAAZealotMissileWeapon) {},
    	LeftAntiAir02 = Class(AAAZealotMissileWeapon) {},
    	RightAntiAir01 = Class(AAAZealotMissileWeapon) {},
    	RightAntiAir02 = Class(AAAZealotMissileWeapon) {},
    	MultiMissiles = Class(ACruiseMissileWeapon) {},
        OblivionCannon = Class(ADFCannonOblivionWeapon02) {},
        LaserWeapon = Class(ADFPhasonLaser) {},
        CruiseMissiles = Class(AIFQuantumWarhead) {},
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
    },

    OnCreate = function(self)
        AWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
    	self.canTeleport = 'false'
        self.Sync.Abilities = self:GetBlueprint().Abilities
        self.Sync.Abilities.TargetLocation.Active = false
        self:SetupBuildBones()
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Rotator', true)        
        self:HideBone('Left_Rotator', true) 
    	self:HideBone('AA_UpgradeRight01', true)
    	self:HideBone('AA_UpgradeRight02', true)
    	self:HideBone('AA_UpgradeLeft01', true)
    	self:HideBone('AA_UpgradeLeft02', true)
        self:HideBone('RightQuantumCannon', true)
    	self:HideBone('LeftQuantumCannon', true)
    	self:HideBone('Oblivion_Turret', true)
    	self:HideBone('MultiMissiles_Rack', true)
    	self:HideBone('Torpedo_Launcher01', true)
    	self:HideBone('Torpedo_Launcher02', true)
    	self:HideBone('Laser_Cannon', true)
    	self:HideBone('Missile_Rack', true)
		self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        AWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightDisruptor', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        AWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        AWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        AWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
        --don`t enable real weapon after enhancement in hunker state
        if not(self.hunkerState) then
            AWalkingLandUnit.SetWeaponEnabledByLabel(self, label, enable)
        end
        if self.hunkerwepstate[label] != nil and not(self.hunkerMethodCall) then
            self.hunkerwepstate[label] = enable
        end      
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self.hunkerwepstate = {}
        self.hunkerState = false
        self.hunkerMethodCall = false
        local weplabel
        for i = 1, self:GetWeaponCount() do
            weplabel = self:GetWeapon(i):GetBlueprint().Label
            if (weplabel != 'DeathWeapon') then
                self.hunkerwepstate[weplabel] = true
            end
        end
    	self:SetWeaponEnabledByLabel('RightQuantumCannon', false)
       	self:SetWeaponEnabledByLabel('LeftQuantumCannon', false)
       	self:SetWeaponEnabledByLabel('LeftAntiAir01', false)
       	self:SetWeaponEnabledByLabel('LeftAntiAir02', false)
       	self:SetWeaponEnabledByLabel('RightAntiAir01', false)
       	self:SetWeaponEnabledByLabel('RightAntiAir02', false)
       	self:SetWeaponEnabledByLabel('MultiMissiles', false)
    	self:SetWeaponEnabledByLabel('OblivionCannon', false)
    	self:SetWeaponEnabledByLabel('Torpedo01', false)
    	self:SetWeaponEnabledByLabel('Torpedo02', false)
    	self:SetWeaponEnabledByLabel('LaserWeapon', false)
    	self:SetWeaponEnabledByLabel('CruiseMissiles', false)
    	self:SetWeaponEnabledByLabel('QuantumMissiles', false)
    	self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    PlayCommanderWarpInEffect = function(self)
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:ShowBone(0, true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Rotator', true)        
        self:HideBone('Left_Rotator', true)  
    	self:HideBone('AA_UpgradeRight01', true)
    	self:HideBone('AA_UpgradeRight02', true)
    	self:HideBone('AA_UpgradeLeft01', true)
    	self:HideBone('AA_UpgradeLeft02', true)
    	self:HideBone('RightQuantumCannon', true)
    	self:HideBone('LeftQuantumCannon', true)
    	self:HideBone('Oblivion_Turret', true)
    	self:HideBone('MultiMissiles_Rack', true)
    	self:HideBone('Torpedo_Launcher01', true)
    	self:HideBone('Torpedo_Launcher02', true)
    	self:HideBone('Laser_Cannon', true)
    	self:HideBone('Missile_Rack', true)
        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
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

    OnTeleportUnit = function(self, teleporter, location, orientation)
	AWalkingLandUnit.OnTeleportUnit(self, teleporter, location, orientation)
    	podteleporter = teleporter
    	podlocation = location
    end,

    PlayTeleportInEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplate.GenericTeleportIn01 do
            emit = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, (bp.Physics.MeshExtentsY or 1) / 2, 0)
        end
        
        if self.RightPod and not self.RightPod:IsDead() and not self.RightPod:IsUnitState( 'Attached' ) then
    	    self.RightPod.OnTeleportUnit(self.RightPod, podteleporter, podlocation)
    	    IssueClearCommands({self.RightPod})
    	    IssueGuard( {self.RightPod}, self)
    	end
    			
		if self.LeftPod and not self.LeftPod:IsDead() and not self.LeftPod:IsUnitState( 'Attached' ) then
			self.LeftPod.OnTeleportUnit(self.LeftPod, podteleporter, podlocation)
			IssueClearCommands({self.LeftPod})
			IssueGuard( {self.LeftPod}, self)
		end
    end,    
    		
    NotifyOfPodDeath = function(self, pod, Unit)
        if pod == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GAA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
            self:RequestRefreshUI()
        elseif pod == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GAA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
			pod:PlayTeleportOutEffects()
			self:RequestRefreshUI()
		end       
    end,

    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GAA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = false
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()       		
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GAA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = false
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
        #Resource Allocation
		elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        #SystemIntegrityCompensator
        elseif enh == 'SystemIntegrityCompensator' then
            if not Buffs['AeonACUIntegrityCompensator'] then
               BuffBlueprint {
                    Name = 'AeonACUIntegrityCompensator',
                    DisplayName = 'AeonACUIntegrityCompensator',
                    BuffType = 'ACUUPGRADEDMG',
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
            Buff.ApplyBuff(self, 'AeonACUIntegrityCompensator')
	#Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldHeavy' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:ForkThread(self.CreateHeavyShield, bp)
        elseif enh == 'Hunker' then
            if not Buffs['AeonACUHunkerRegen'] then
               BuffBlueprint {
                    Name = 'AeonACUHunkerRegen',
                    DisplayName = 'AeonACUHunkerRegen',
                    BuffType = 'ACUHUNKREG',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = 2000,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            self:AddToggleCap('RULEUTC_SpecialToggle')
    	elseif enh == 'Health' then
			if not Buffs['VeterancyMegaHealth6'] then
				BuffBlueprint {
				Name = 'VeterancyMegaHealth6',
				DisplayName = 'VeterancyMegaHealth6',
				BuffType = 'VETERANCYHEALTH1',
				Stacks = 'ALWAYS',
				Duration = -1,
				Affects = {
						MaxHealth = {
							Add = bp.NewHealth,
							Mult = 1.0,
						},
					},
				}
			end
			Buff.ApplyBuff(self, 'VeterancyMegaHealth6')
        elseif enh == 'SuperTeleporter' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
        #T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT2BuildRate',
                    DisplayName = 'AeonACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
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

            Buff.ApplyBuff(self, 'AeonACUT2BuildRate')
        #T3 Engineering
        elseif enh =='T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT3BuildRate',
                    DisplayName = 'AeonACUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
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
            Buff.ApplyBuff(self, 'AeonACUT3BuildRate')
	#SpeedIncrease
		elseif enh == 'SpeedIncrease' then
			self:SetSpeedMult(5.0)
        elseif enh == 'PowerUp' then
            local wep1 = self:GetWeaponByLabel('LeftDisruptor')
            wep1:ChangeDamage(bp.LeftDisruptorNewDamage)
            local wep2 = self:GetWeaponByLabel('RightDisruptor')
            wep2:ChangeDamage(bp.RightDisruptorNewDamage)
        #Crysalis Beam
        elseif enh == 'CrysalisBeam' then
            local wep1 = self:GetWeaponByLabel('LeftDisruptor')
            wep1:ChangeMaxRadius(bp.LeftDisruptorNewMaxRadius)
            local wep2 = self:GetWeaponByLabel('RightDisruptor')
            wep2:ChangeMaxRadius(bp.RightDisruptorNewMaxRadius)
        #Heat Sink Augmentation
        elseif enh == 'HeatSink' then
            local wep1 = self:GetWeaponByLabel('LeftDisruptor')
            wep1:ChangeRateOfFire(bp.LeftDisruptorNewRateOfFire)
            local wep2 = self:GetWeaponByLabel('RightDisruptor')
            wep2:ChangeRateOfFire(bp.RightDisruptorNewRateOfFire)
        elseif enh =='StabilitySuppressant' then
            local wep1 = self:GetWeaponByLabel('LeftDisruptor')
            wep1:ChangeDamageRadius(bp.LeftDisruptorNewDamageRadius)
            wep1:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
            local wep2 = self:GetWeaponByLabel('RightDisruptor')
            wep2:ChangeDamageRadius(bp.RightDisruptorNewDamageRadius)
            wep2:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius or 104)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
        elseif enh == 'RightQuantumCannon' then
			self:SetWeaponEnabledByLabel('RightQuantumCannon', true)
        elseif enh == 'LeftQuantumCannon' then
			self:SetWeaponEnabledByLabel('LeftQuantumCannon', true)
        elseif enh == 'LeftAntiair' then
			self:SetWeaponEnabledByLabel('LeftAntiAir01', true)
        elseif enh == 'RightAntiair' then
			self:SetWeaponEnabledByLabel('RightAntiAir01', true)
        elseif enh == 'HeavyLeftAntiair' then
			self:SetWeaponEnabledByLabel('LeftAntiAir02', true)
        elseif enh == 'HeavyRightAntiair' then
			self:SetWeaponEnabledByLabel('RightAntiAir02', true)
        elseif enh == 'MultiMissile' then
			self:SetWeaponEnabledByLabel('MultiMissiles', true)
        elseif enh == 'OblivionCannon' then
			self:SetWeaponEnabledByLabel('OblivionCannon', true)
        elseif enh == 'Laser' then
			self:SetWeaponEnabledByLabel('LaserWeapon', true)
        elseif enh == 'TorpedoLauncher' then
			self:SetWeaponEnabledByLabel('Torpedo01', true)
        elseif enh == 'HeavyTorpedoLauncher' then
			self:SetWeaponEnabledByLabel('Torpedo02', true)
        elseif enh == 'CruiseMissiles' then
			self:SetWeaponEnabledByLabel('CruiseMissiles', true)
        elseif enh == 'QuantumMissiles' then
            local wep = self:GetWeaponByLabel('CruiseMissiles')
            wep:ChangeRateOfFire(bp.CruiseMissilesNewRateOfFire)
        elseif enh == 'RemoteViewing' then
			self.Sync.Abilities = self:GetBlueprint().Abilities
			self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
			self:SetMaintenanceConsumptionInactive()
			self:EnableRemoteViewingButtons()
      	#BUILTBYTIER4COMMANDER
        elseif enh =='T4Engineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            if not Buffs['AeonACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT4BuildRate',
                    DisplayName = 'AeonCUT4BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
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
            Buff.ApplyBuff(self, 'AeonACUT4BuildRate')               
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
        if bit == 7 then 
           	-- Removes all commands
           	IssueClearCommands({self})            
           	-- Forces the commander to stop
           	IssueStop({self})
		self:SetSpeedMult(0)
		self:SetTurnMult(0)
		self:SetImmobile(true)
		-- Remove caps
            	self:RemoveCommandCap('RULEUCC_Attack')
            	self:RemoveCommandCap('RULEUCC_Move')
		-- Add build restriction
            	self:AddBuildRestriction(categories.ALLUNITS)
            	self:RequestRefreshUI()
		-- Setup Animation
		if not self.AnimationManipulator then
		    self.AnimationManipulator = CreateAnimator(self)
		    self.Trash:Add(self.AnimationManipulator)
		    self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationSitDown)
		end
		self.AnimationManipulator:SetRate(1.5)
		-- Destroy Shield
            	self:DestroyShield()
            	self:RemoveToggleCap('RULEUTC_ShieldToggle')
            	--disable all active weapon
            	self.hunkerMethodCall = true
            	for label, state in self.hunkerwepstate do
            	    if state then self:SetWeaponEnabledByLabel(label, false) end
            	end
            	self.hunkerMethodCall = false
            	self.hunkerState = true
            	#LOG(repr(self.hunkerwepstate))
		-- Setup Shield
            	ForkThread(function()
            	    WaitSeconds(10)
            	    self:CreateShield(self:GetBlueprint().Enhancements.HunkerShieldGeneratorField)
            	    self:SetEnergyMaintenanceConsumptionOverride(200000)
            	    self:SetMaintenanceConsumptionActive()
            	end)
            	Buff.ApplyBuff(self, 'AeonACUHunkerRegen')
    	elseif bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        AWalkingLandUnit.OnScriptBitClear(self, bit)
        if bit == 7 then 
           	-- Removes all commands
           	IssueClearCommands({self})            
           	-- Forces the unit to stop
           	IssueStop({self})
		self:SetSpeedMult(1.0)
                self:SetTurnMult(1.0) 
		self:SetImmobile(false)
		-- Add caps 
            	self:AddCommandCap('RULEUCC_Attack')
            	self:AddCommandCap('RULEUCC_Move')
		-- Restore build restriction
            	self:RestoreBuildRestrictions()
            	self:RequestRefreshUI()
		-- Setup Animation
		if self.AnimationManipulator then
		    self.AnimationManipulator:SetRate(-1.5)
		end
		-- Destroy Shield
            	self:DestroyShield()
		-- Setup Shield
            	self:AddToggleCap('RULEUTC_ShieldToggle')
            	ForkThread(function()
            	    WaitTicks(1)
            	    self:CreatePersonalShield(self:GetBlueprint().Enhancements.ShieldHeavy)
            	    self:SetEnergyMaintenanceConsumptionOverride(500)
            	    self:SetMaintenanceConsumptionActive()
            	end)
            	if Buff.HasBuff( self, 'AeonACUHunkerRegen' ) then
            	    Buff.RemoveBuff( self, 'AeonACUHunkerRegen' )
            	end
            	--enable all reserched weapon
            	self.hunkerState = false
            	self.hunkerMethodCall = true
            	for label, state in self.hunkerwepstate do
            	    if state then self:SetWeaponEnabledByLabel(label, true) end
            	end
            	self.hunkerMethodCall = false
            	#LOG(repr(self.hunkerwepstate))
            	ForkThread(function()
		    self:RemoveToggleCap('RULEUTC_SpecialToggle')
            	    WaitSeconds(180)
            	    self:AddToggleCap('RULEUTC_SpecialToggle')
            	end)
    	elseif bit == 1 then 
		self:SetSpeedMult(5.0) 
	    	self.canTeleport = 'false'
        end
    end,
}

TypeClass = GAL0001