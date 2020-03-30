#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  UEF Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local TDFZephyrCannonWeapon = WeaponsFile.TDFZephyrCannonWeapon
local TDFIonizedPlasmaCannon = WeaponsFile.TDFIonizedPlasmaCannon
local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon
local TSAMLauncher = WeaponsFile.TSAMLauncher
local TANTorpedoAngler = WeaponsFile.TANTorpedoAngler
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TIFStrategicMissileWeapon = WeaponsFile.TIFStrategicMissileWeapon
local BigGaussCannonWeapon = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua').BigGaussCannonWeapon
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local RepairField = import('/mods/Global Commanders Enhanced/lua/RepairField.lua').RepairField
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local Shield = import('/lua/shield.lua').Shield
local podteleport,podlocation

local RemoteViewingRegen = import('/mods/Global Commanders Enhanced/lua/RemoteRepair.lua').RemoteViewingRegen
TWalkingLandUnit = RemoteViewingRegen( TWalkingLandUnit ) 

GEL0001 = Class(TWalkingLandUnit) {    
    DeathThreadDestructionWaitTime = 2,

    Emitters = {
        '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
    },

    RepairFieldEffect = {
		{
			Bones = {
			'Torso',
			},
			Offset = {
			0,
			0,
			0,
			},
			Scale = 1.6,
			Type = 'Cloak01',
		},
    },

    IntelEffects = {
		{
			Bones = {
			'AttachSpecial01',
			'AttachSpecial02',
			},
			Scale = 0.5,
			Type = 'Jammer01',
		},
    },    

    Weapons = {
        RightZephyr = Class(TDFZephyrCannonWeapon) {},
        LeftZephyr = Class(TDFZephyrCannonWeapon) {},
        NukeMissiles = Class(TIFStrategicMissileWeapon) {},
        ClusterMissiles = Class(TIFStrategicMissileWeapon) {},
        TorpedoLauncher = Class(TANTorpedoAngler) {},
		HeavyPlasma01 = Class(TDFIonizedPlasmaCannon) {},
		HeavyPlasma02 = Class(TDFIonizedPlasmaCannon) {},
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
		Megacannon01 = Class(BigGaussCannonWeapon) {},
		Megacannon02 = Class(BigGaussCannonWeapon) {},	
		Megacannon03 = Class(BigGaussCannonWeapon) {},
		Megacannon04 = Class(BigGaussCannonWeapon) {},	
		MissileRack01 = Class(TSAMLauncher) {},		
		MissileRack02 = Class(TSAMLauncher) {},	
        FrontTurret01 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
                '/effects/emitters/gauss_cannon_muzzle_flash_02_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_04_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_05_emit.bp',
                '/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
            },
            FxMuzzleFlashScale = 0.8,
        },
        FrontTurret02 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
                '/effects/emitters/gauss_cannon_muzzle_flash_02_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_04_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_05_emit.bp',
                '/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
            },
            FxMuzzleFlashScale = 0.8,
        },
    	Minigun01 = Class(TDFGaussCannonWeapon) { 
	    OnCreate = function(self)
            	TDFGaussCannonWeapon.OnCreate(self)
            	if not self.SpinManip then 
                   self.SpinManip = CreateRotator(self.unit, 'Minigun01_Barrel', 'z', nil, 350, 350, 350)
                   self.unit.Trash:Add(self.SpinManip)
            	end
            end,
    	},
    	Minigun02 = Class(TDFGaussCannonWeapon) {      
	    OnCreate = function(self)
            	TDFGaussCannonWeapon.OnCreate(self)
            	if not self.SpinManip then 
                   self.SpinManip = CreateRotator(self.unit, 'Minigun02_Barrel', 'z', nil, 350, 350, 350)
                   self.unit.Trash:Add(self.SpinManip)
            	end
            end,
    	},  
        OrbitalBombardment = Class(CDFLaserHeavyWeapon){
			CreateProjectileForWeapon = function(self, bone)
				local numProjectiles = 20
				local defpos = self:GetCurrentTargetPos()
				defpos.y = (GetSurfaceHeight(defpos.x,defpos.z) + 200) or 200
				for i = 0, (numProjectiles -1) do
					WaitTicks(Random(5,10))
					local pos = defpos
					ranX = Random(-4,4)
					ranZ = Random(-4,4)
					pos.x = pos.x + ranX
					pos.z = pos.z + ranZ
					local proj = CDFLaserHeavyWeapon.CreateProjectileForWeapon(self, bone)
					Warp(proj,pos)
					self.unit:PlayUnitSound('WarpingProjectile')
					CreateLightParticle(self.unit, 'OrbitalBombardment_Muzzle', self.unit:GetArmy(), 5, 2, 'beam_white_01', 'ramp_white_07' )
					CreateAttachedEmitter(self.unit, 'OrbitalBombardment_Muzzle', self.unit:GetArmy(), '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.08)
				end
			end,
        },
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
		self.canTeleport = 'false'
        self.Sync.Abilities = self:GetBlueprint().Abilities
        self.Sync.Abilities.TargetLocation.Active = false
        self:HideBone('Back_Upgrade_B01', true) 
		self:HideBone('Megacannon01', true)
		self:HideBone('Megacannon02', true)
		self:HideBone('Megacannon03', true)
		self:HideBone('Megacannon04', true)
		self:HideBone('Rack_Over_Mega_Heavy_Canon01', true)
		self:HideBone('Rack_Over_Mega_Heavy_Canon02', true)
		self:HideBone('Shoulder_Left_Upgrade_Turret', true)
		self:HideBone('Shoulder_Right_Upgrade_Turret', true)
		self:HideBone('Minigun01', true)
		self:HideBone('Minigun02', true)
		self:HideBone('Right_Upgrade02', true)
		self:HideBone('Right_Upgrade03', true)
		self:HideBone('Cape', true)
		self:HideBone('Torpedo_Launcher', true)
		self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnMotionHorzEventChange = function( self, new, old )
        TWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

        if ( new == 'TopSpeed' ) and self.canTeleport == 'true' then
	    ForkThread(function()
		Pos = self:GetNavigator():GetGoalPos() 
		destination = Vector(Pos[1], Pos[2], Pos[3]) 

		self:PlayTeleportOutEffects()
		self:PlayUnitSound('GateOut')
								
		Warp(self, destination, self:GetOrientation()) 
				
		self:CreateProjectile( '/mods/Global Commanders Enhanced/effects/entities/SuperTeleport/SuperTeleport_proj.bp', 0, 0.35, 0, nil, nil, nil):SetCollision(false)

		WaitSeconds(.3) 
		self:GetNavigator():AbortMove()	
	    end)	
	end
    end,

    OnPrepareArmToBuild = function(self)
        TWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,

    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
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
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
        --don`t enable real weapon after enhancement in hunker state
        if not(self.hunkerState) then
            TWalkingLandUnit.SetWeaponEnabledByLabel(self, label, enable)
        end
        if self.hunkerwepstate[label] != nil and not(self.hunkerMethodCall) then
            self.hunkerwepstate[label] = enable
        end      
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
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
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:DisableUnitIntel('Jammer')
        self:BuildManipulatorSetEnabled(false)
        self:SetWeaponEnabledByLabel('NukeMissiles', false)
        self:SetWeaponEnabledByLabel('ClusterMissiles', false)
        self:SetWeaponEnabledByLabel('TorpedoLauncher', false)
		self:SetWeaponEnabledByLabel('HeavyPlasma01', false)
		self:SetWeaponEnabledByLabel('HeavyPlasma02', false)
		self:SetWeaponEnabledByLabel('Megacannon01', false)
		self:SetWeaponEnabledByLabel('Megacannon02', false)
		self:SetWeaponEnabledByLabel('Megacannon03', false)
		self:SetWeaponEnabledByLabel('Megacannon04', false)
		self:SetWeaponEnabledByLabel('MissileRack01', false)
		self:SetWeaponEnabledByLabel('MissileRack02', false)
		self:SetWeaponEnabledByLabel('FrontTurret01', false)
		self:SetWeaponEnabledByLabel('FrontTurret02', false)
    	self:SetWeaponEnabledByLabel('Minigun01', false)
    	self:SetWeaponEnabledByLabel('Minigun02', false)
    	self:SetWeaponEnabledByLabel('OrbitalBombardment', false)
        self:ForkThread(self.GiveInitialResources)
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
        self:HideBone('Back_Upgrade_B01', true) 
		self:HideBone('Megacannon01', true)
		self:HideBone('Megacannon02', true)
		self:HideBone('Megacannon03', true)
		self:HideBone('Megacannon04', true)
		self:HideBone('Rack_Over_Mega_Heavy_Canon01', true)
		self:HideBone('Rack_Over_Mega_Heavy_Canon02', true)
		self:HideBone('Shoulder_Left_Upgrade_Turret', true)
		self:HideBone('Shoulder_Right_Upgrade_Turret', true)
		self:HideBone('Minigun01', true)
		self:HideBone('Minigun02', true)
		self:HideBone('Right_Upgrade02', true)
		self:HideBone('Right_Upgrade03', true)
		self:HideBone('Cape', true)
		self:HideBone('Torpedo_Launcher', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)

        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end
        WaitSeconds(6)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
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

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnTeleportUnit = function(self, teleporter, location, orientation)
	#LOG('OnTeleportUnit')
	TWalkingLandUnit.OnTeleportUnit(self, teleporter, location, orientation)
    	podteleporter = teleporter
    	podlocation = location
    	#LOG(podteleporter)
    	#LOG(podlocation)
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
            local pod = CreateUnitHPR('GEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
            self:RequestRefreshUI()
        elseif pod == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
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
        TWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()      		
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
            pod:PlayTeleportOutEffects()
		elseif enh == 'SpeedIncrease' then
			self:SetSpeedMult(5.0)
        elseif enh == 'SuperTeleporter' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
        elseif enh == 'RepairField' then
            self:AddToggleCap('RULEUTC_GenericToggle')
            ForkThread(function()
            	WaitTicks(1)
        	self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 10)
            	self:SetMaintenanceConsumptionActive()
            	self:CreateRepairField()
            	self.ShieldEffectsBag = {}
            end)
        elseif enh == 'RemoteRepairing' then
            self:RemoveToggleCap('RULEUTC_GenericToggle')
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:EnableRemoteViewingButtons()
        elseif enh =='TacticalNukeMissile' then
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
            self:SetWeaponEnabledByLabel('NukeMissiles', true)
        elseif enh =='ClusterMissile' then
            self:SetWeaponEnabledByLabel('ClusterMissiles', true)
        elseif enh =='OrbitalBombardment' then
            self:SetWeaponEnabledByLabel('OrbitalBombardment', true)
        elseif enh == 'Shield1' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        elseif enh == 'Shield2' then
            self:DestroyShield()
            ForkThread(function()
                self:CreatePersonalShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'Shield3' then
            self:DestroyShield()
            ForkThread(function()
                self:CreatePersonalShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'Shield4' then
            self:DestroyShield()
            ForkThread(function()
                self:CreatePersonalShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'ShieldGeneratorField' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'Hunker' then
            if not Buffs['UEFACUHunkerRegen'] then
               BuffBlueprint {
                    Name = 'UEFACUHunkerRegen',
                    DisplayName = 'UEFACUHunkerRegen',
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
        elseif enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT2BuildRate',
                    DisplayName = 'UEFACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT2BuildRate')
        elseif enh =='T3Engineering' then
            if Buff.HasBuff( self, 'UEFACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'UEFACUT2BuildRate' )
            end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT3BuildRate'] then
            BuffBlueprint {
                Name = 'UEFACUT3BuildRate',
                DisplayName = 'UEFCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT3BuildRate')
        elseif enh =='DamageStablization' then
            if not Buffs['UEFACUDamageStablization'] then
               BuffBlueprint {
                    Name = 'UEFACUDamageStablization',
                    DisplayName = 'UEFACUDamageStablization',
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
            Buff.ApplyBuff(self, 'UEFACUDamageStablization')
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius or 104)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104) 
        elseif enh == 'RadarJammer' then
            self:SetIntelRadius('Jammer', bp.NewJammerRadius or 64)
            self.RadarJammerEnh = true 
	    self:EnableUnitIntel('Jammer')  
            self:AddToggleCap('RULEUTC_JammingToggle')           
        #ResourceAllocation              
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh =='HeavyAntiMatterCannon' then
            local wep1 = self:GetWeaponByLabel('RightZephyr') 
            wep1:ChangeMaxRadius(bp.RightZephyrNewMaxRadius)      
            local wep2 = self:GetWeaponByLabel('LeftZephyr')  
            wep2:ChangeMaxRadius(bp.LeftZephyrNewMaxRadius)     
        elseif enh =='AdvancedCoolingUpgrade' then
            local wep1 = self:GetWeaponByLabel('RightZephyr')       
            wep1:ChangeRateOfFire(bp.RightZephyrNewRateOfFire)
            local wep2 = self:GetWeaponByLabel('LeftZephyr')       
            wep2:ChangeRateOfFire(bp.LeftZephyrNewRateOfFire)
        elseif enh =='PowerUp' then
            local wep1 = self:GetWeaponByLabel('RightZephyr')       
            wep1:ChangeDamage(bp.RightZephyrNewDamage)
            local wep2 = self:GetWeaponByLabel('LeftZephyr')       
            wep2:ChangeDamage(bp.LeftZephyrNewDamage)
        elseif enh =='HighExplosiveOrdnance' then
            local wep1 = self:GetWeaponByLabel('RightZephyr')       
            wep1:AddDamageRadiusMod(bp.RightZephyrNewDamageRadius)
            wep1:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
            local wep2 = self:GetWeaponByLabel('LeftZephyr')       
            wep2:AddDamageRadiusMod(bp.LeftZephyrNewDamageRadius)
            wep2:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
        elseif enh =='HeavyPlasma01' then
	    self:SetWeaponEnabledByLabel('HeavyPlasma01', true)
        elseif enh =='HeavyPlasma02' then
	    self:SetWeaponEnabledByLabel('HeavyPlasma02', true)
    	elseif enh =='HeavyOverMegaCanonRUpgrade' then
	    self:SetWeaponEnabledByLabel('Megacannon02', true)
    	elseif enh =='HeavyOverMegaCanonLUpgrade' then
	    self:SetWeaponEnabledByLabel('Megacannon01', true)
    	elseif enh =='HeavyOverMegaCanonRUpgrade2' then
	    self:SetWeaponEnabledByLabel('Megacannon04', true)
    	elseif enh =='HeavyOverMegaCanonLUpgrade2' then
	    self:SetWeaponEnabledByLabel('Megacannon03', true)
    	elseif enh =='HeavyAntiAirRUpgrade' then
	    self:SetWeaponEnabledByLabel('MissileRack01', true)	
    	elseif enh =='HeavyAntiAirLUpgrade' then
	    self:SetWeaponEnabledByLabel('MissileRack02', true)	
    	elseif enh =='HeavyCannon01' then
	    self:SetWeaponEnabledByLabel('FrontTurret01', true)	
    	elseif enh =='HeavyCannon02' then
	    self:SetWeaponEnabledByLabel('FrontTurret02', true)	
    	elseif enh =='TorpedoLauncher' then
	    self:SetWeaponEnabledByLabel('TorpedoLauncher', true)	
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
    	elseif enh =='LeftMinigun' then
			self:SetWeaponEnabledByLabel('Minigun01', true)
    	elseif enh =='RightMinigun' then
			self:SetWeaponEnabledByLabel('Minigun02', true)
    	elseif enh =='T4Engineering' then
            if not Buffs['UEFACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT4BuildRate',
                    DisplayName = 'UEFACUT4BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT4BuildRate')
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

    OnScriptBitSet = function(self, bit)
        TWalkingLandUnit.OnScriptBitSet(self, bit)
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
		-- Setup Hunker Shield
            	ForkThread(function()
            	    WaitSeconds(10)
            	    self:CreateShield(self:GetBlueprint().Enhancements.HunkerShieldGeneratorField)
            	    self:SetEnergyMaintenanceConsumptionOverride(100000)
            	    self:SetMaintenanceConsumptionActive()
            	end)
                Buff.ApplyBuff(self, 'UEFACUHunkerRegen') 
    	elseif bit == 6 then 
		self.MyRepairField:TurnOff()
        	self:SetMaintenanceConsumptionInactive()
    	elseif bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        TWalkingLandUnit.OnScriptBitClear(self, bit)
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
		-- Destroy Hunker Shield
            	self:DestroyShield()
		-- Setup Shield
            	ForkThread(function()
            	    WaitTicks(1)
            	    self:CreateShield(self:GetBlueprint().Enhancements.ShieldGeneratorField)
            	    self:SetEnergyMaintenanceConsumptionOverride(500)
            	    self:SetMaintenanceConsumptionActive()
            	end)
            	self:AddToggleCap('RULEUTC_ShieldToggle')
                if Buff.HasBuff( self, 'UEFACUHunkerRegen' ) then
                   Buff.RemoveBuff( self, 'UEFACUHunkerRegen' )
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
    	elseif bit == 6 then 
        	self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements.RepairField.MaintenanceConsumptionPerSecondEnergy or 10)
        	self:SetMaintenanceConsumptionActive()
		self.MyRepairField:TurnOn()
    	elseif bit == 1 then 
		self:SetSpeedMult(5.0) 
	    	self.canTeleport = 'false'
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        TWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
	if self.MyRepairField then
	    self.MyRepairField:OnDestroy()
	end
    end,

    CreateRepairField = function(self, repairfieldSpec)
	self.MyRepairField = RepairField {
	    Owner = self,
	    Size = self:GetBlueprint().Enhancements.RepairField.MaxRadius
	}
    end,
}

TypeClass = GEL0001