#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0301/UEL0301_script.lua
#**  Author(s):  Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  UEF Sub Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local Shield = import('/lua/shield.lua').Shield
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher
local TIFCarpetBombWeapon = import('/lua/terranweapons.lua').TIFCarpetBombWeapon
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local TDFIonizedPlasmaCannon = import('/lua/terranweapons.lua').TDFIonizedPlasmaCannon
local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon
local TDFHeavyPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFHeavyPlasmaCannonWeapon


UEL0301 = Class(TWalkingLandUnit) {
    
    IntelEffects = {
	{
	    Bones = {
		'Jetpack',
	    },
	    Scale = 0.5,
	    Type = 'Jammer01',
	},
    },    

    Weapons = {
        LeftHeavyShotGun = Class(TDFIonizedPlasmaCannon) {
	    CreateProjectileAtMuzzle = function(self, muzzle)
		numProjectiles = 10
		for i = 0, (numProjectiles -1) do
		    local proj = TDFIonizedPlasmaCannon.CreateProjectileAtMuzzle(self, muzzle)
	    	end
	    end,
	},
        RightHeavyShotGun = Class(TDFIonizedPlasmaCannon) {
	    CreateProjectileAtMuzzle = function(self, muzzle)
		numProjectiles = 10
		for i = 0, (numProjectiles -1) do
		    local proj = TDFIonizedPlasmaCannon.CreateProjectileAtMuzzle(self, muzzle)
	    	end
	    end,
	},
        MissileRack01 = Class(TSAMLauncher) {},
        MissileRack02 = Class(TSAMLauncher) {},
        MissileWeapon = Class(TIFCarpetBombWeapon) {
    		FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchSmoke,
		FxMuzzleFlashScale = 0.5,
	},
        PlasmaWeapon = Class(TDFGaussCannonWeapon) {},
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    	Minigun01 = Class(TDFHeavyPlasmaCannonWeapon) {  
     
           OnCreate = function(self)
            	TDFHeavyPlasmaCannonWeapon.OnCreate(self)
            	if not self.SpinManip then 
                   self.SpinManip = CreateRotator(self.unit, 'Minigun01_Barrel', 'z', nil, 350, 350, 350)
                   self.unit.Trash:Add(self.SpinManip)
            	end
           end,
    	},
    	Minigun02 = Class(TDFHeavyPlasmaCannonWeapon) {       

           OnCreate = function(self)
            	TDFHeavyPlasmaCannonWeapon.OnCreate(self)
            	if not self.SpinManip then 
                   self.SpinManip = CreateRotator(self.unit, 'Minigun02_Barrel', 'z', nil, -350, -350, -350)
                   self.unit.Trash:Add(self.SpinManip)
            	end
           end,
    	},  
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
	self.canTeleport = 'false'
        self.HasLeftPod = false
        self.HasRightPod = false     
        self:HideBone('Jetpack', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Shoulder_Left', true)
        self:HideBone('Shoulder_Right', true)
        self:HideBone('Rack01', true)
        self:HideBone('Rack02', true)
	self:HideBone('Minigun01_Rack', true)
	self:HideBone('Minigun02_Rack', true)
        self:SetupBuildBones()  
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYSUBCOMMANDER) ) 
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        TWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:DisableUnitIntel('Jammer')
	self:SetWeaponEnabledByLabel('MissileRack01', false)
	self:SetWeaponEnabledByLabel('MissileRack02', false)
	self:SetWeaponEnabledByLabel('MissileWeapon', false)
	self:SetWeaponEnabledByLabel('PlasmaWeapon', false)
	self:SetWeaponEnabledByLabel('Minigun01', false)
	self:SetWeaponEnabledByLabel('Minigun02', false)
	self.WeaponsEnabled = true
    end,

    OnMotionHorzEventChange = function( self, new, old )
        TWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

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

    OnPrepareArmToBuild = function(self)
        TWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,
    
    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedCapture = function(self, target)
        TWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStopReclaim = function(self, target)
        TWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)    
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false      
    end,     
    
    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )   
        end           
    end,     

    PlayTeleportInEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplate.GenericTeleportIn01 do
            emit = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, (bp.Physics.MeshExtentsY or 1) / 2, 0)
        end
        
        if self.RightPod 
    		and not self.RightPod:IsDead()
    		and not self.RightPod:IsUnitState( 'Attached' ) then
    		self.RightPod.OnTeleportUnit(self.RightPod, podteleporter, podlocation)
    		IssueClearCommands({self.RightPod})
    		IssueGuard( {self.RightPod}, self)
    	end
    			
	if self.LeftPod 
		and not self.LeftPod:IsDead()
		and not self.LeftPod:IsUnitState( 'Attached' ) then
		self.LeftPod.OnTeleportUnit(self.LeftPod, podteleporter, podlocation)
		IssueClearCommands({self.LeftPod})
		IssueGuard( {self.LeftPod}, self)
	end
    end,
    
    		
    NotifyOfPodDeath = function(self, pod, Unit)
        if pod == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GEA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
            self:RequestRefreshUI()
        elseif pod == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GEA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
	    pod:PlayTeleportOutEffects()
            self:RequestRefreshUI()
        end
        
    end,

		OnTeleportUnit = function(self, teleporter, location, orientation)
    			#LOG('OnTeleportUnit')
    			TWalkingLandUnit.OnTeleportUnit(self, teleporter, location, orientation)
    			
    			podteleporter = teleporter
    			podlocation = location
    			#LOG(podteleporter)
    			#LOG(podlocation)
    end,

    CreateEnhancement = function(self, enh)
        TWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        #Drone
        if enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GEA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()
        		
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GEA0003', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
        #Shield
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldGeneratorField' then
            self:DestroyShield()    
            ForkThread(function()
                WaitTicks(1)   
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        #ResourceAllocation              
        elseif enh =='ResourceAllocation' then
            elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        #SensorRangeEnhancer
        elseif enh == 'SensorRangeEnhancer' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius)
            self:SetIntelRadius('Vision', bp.NewVisionRadius)
            self:SetIntelRadius('Omni', bp.NewOmniRadius)
        #RadarJammer
        elseif enh == 'RadarJammer' then
            self:SetIntelRadius('Jammer', bp.NewJammerRadius or 26)
            self.RadarJammerEnh = true 
	    self:EnableUnitIntel('Jammer')
            self:AddToggleCap('RULEUTC_JammingToggle')   
	elseif enh =='PowerUp' then
            local wep1 = self:GetWeaponByLabel('LeftHeavyShotGun')
            wep1:ChangeDamage(bp.LeftShotGunNewDamage)
            local wep2 = self:GetWeaponByLabel('RightHeavyShotGun')
            wep2:ChangeDamage(bp.RightShotGunNewDamage)
        elseif enh =='DamageStablization' then
            if not Buffs['UEFSCUDamageStablization'] then
               BuffBlueprint {
                    Name = 'UEFSCUDamageStablization',
                    DisplayName = 'UEFSCUDamageStablization',
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
            Buff.ApplyBuff(self, 'UEFSCUDamageStablization')
        #AdvancedCoolingUpgrade
        elseif enh =='AdvancedCoolingUpgrade' then
            local wep1 = self:GetWeaponByLabel('LeftHeavyShotGun')
            wep1:ChangeRateOfFire(bp.LeftShotGunNewRateOfFire)
            local wep2 = self:GetWeaponByLabel('RightHeavyShotGun')
            wep2:ChangeRateOfFire(bp.RightShotGunNewRateOfFire)
        #High Explosive Ordnance
        elseif enh =='HighExplosiveOrdnance' then
            local wep1 = self:GetWeaponByLabel('LeftHeavyShotGun')
            wep1:ChangeDamageRadius(bp.LeftShotGunNewDamageRadius)
            local wep2 = self:GetWeaponByLabel('RightHeavyShotGun')
            wep2:ChangeDamageRadius(bp.RightShotGunNewDamageRadius)
	#Heavy AntiAir Upgrade
	elseif enh =='HeavyAntiAirUpgrade' then
	    self:SetWeaponEnabledByLabel('MissileRack01', true)
	    self:SetWeaponEnabledByLabel('MissileRack02', true)
	#Cruise Missile Upgrade
	elseif enh =='CruiseMissileUpgrade' then
	    self:SetWeaponEnabledByLabel('MissileWeapon', true)
	#Miniguns
	elseif enh =='LeftMinigun' then
	    self:SetWeaponEnabledByLabel('Minigun01', true)
    	elseif enh =='RightMinigun' then
	    self:SetWeaponEnabledByLabel('Minigun02', true)
        elseif enh =='PlasmaGunUpgrade' then
	    self:SetWeaponEnabledByLabel('PlasmaWeapon', true)
	#Teleport
        elseif enh == 'SuperTeleport' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
	#SpeedIncrease
	elseif enh == 'SpeedIncrease' then
		self:SetSpeedMult(4.0)  
    	elseif enh =='SubComEngineeringT4' then
            if not Buffs['UEFSCUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFSCUT4BuildRate',
                    DisplayName = 'UEFSCUT4BuildRate',
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
            Buff.ApplyBuff(self, 'UEFSCUT4BuildRate')
    	elseif enh =='SubComEngineeringT5' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)

            if not Buffs['UEFSCUT5BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFSCUT5BuildRate',
                    DisplayName = 'UEFSCUT5BuildRate',
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
            Buff.ApplyBuff(self, 'UEFSCUT5BuildRate')
        end
    end,

    OnScriptBitSet = function(self, bit)
        TWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        TWalkingLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
		self:SetSpeedMult(4.0) 
	    	self.canTeleport = 'false'
        end
    end,

    OnIntelEnabled = function(self)
        TWalkingLandUnit.OnIntelEnabled(self)
        if self.RadarJammerEnh and self:IsIntelEnabled('Jammer') then 
            if self.IntelEffects then
		        self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
	        end
	        self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['RadarJammer'].MaintenanceConsumptionPerSecondEnergy or 0)        
            self:SetMaintenanceConsumptionActive()
        end    
    end,

    OnIntelDisabled = function(self)
        TWalkingLandUnit.OnIntelDisabled(self)
        if self.RadarJammerEnh and not self:IsIntelEnabled('Jammer') then
            self:SetMaintenanceConsumptionInactive()
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            end
        end       
    end,
    
    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,   
}

TypeClass = UEL0301