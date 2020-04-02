#****************************************************************************
#**
#**  File     :  /cdimage/units/URL0001/URL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos, Andres Mendez
#**
#**  Summary  :  Cybran Commander Unit Script
#**
#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local CWeapons = import('/lua/cybranweapons.lua')
local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local BlueLaserGenerator = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua').BlueLaserGenerator
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon
local CIFArtilleryWeapon = CWeapons.CIFArtilleryWeapon
local CDFHvyProtonCannonWeapon = CWeapons.CDFHvyProtonCannonWeapon
local CAMZapperWeapon = CWeapons.CAMZapperWeapon02
local CAMEMPMissileWeapon = CWeapons.CAMEMPMissileWeapon
local CIFMissileLoaTacticalWeapon = CWeapons.CIFMissileLoaTacticalWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local Entity = import('/lua/sim/Entity.lua').Entity
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local RemoteIntel = import('/mods/Global Commanders Enhanced/lua/RemoteIntel.lua').RemoteIntel
CWalkingLandUnit = RemoteIntel( CWalkingLandUnit )

GRL0001 = Class(CWalkingLandUnit) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        RightRipper = Class(CCannonMolecularWeapon) {},
        LeftRipper = Class(CCannonMolecularWeapon) {},
		HeavyRightRipper = Class(CCannonMolecularWeapon) {},
		HeavyLeftRipper = Class(CCannonMolecularWeapon) {}, 
        RightProtonCannon = Class(CDFHvyProtonCannonWeapon) {},
        LeftProtonCannon = Class(CDFHvyProtonCannonWeapon) {},
        RightAAMissile = Class(CAAMissileNaniteWeapon) {},
        LeftAAMissile = Class(CAAMissileNaniteWeapon) {},
        RightTorpedo = Class(CANTorpedoLauncherWeapon) {},
        LeftTorpedo = Class(CANTorpedoLauncherWeapon) {},
		Artillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
        TMD01 = Class(CAMZapperWeapon) {},
        TMD02 = Class(CAMZapperWeapon) {},
        TMD03 = Class(CAMZapperWeapon) {},
        TMD04 = Class(CAMZapperWeapon) {},
        SMD = Class(CAMEMPMissileWeapon) {
        	FxMuzzleFlash = EffectTemplate.CAntiNukeLaunch01,
        },
        MLG = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
            DisabledFiringBones = {'Turret_Muzzle_03'},
            
            SetOnTransport = function(self, transportstate)
                CDFHeavyMicrowaveLaserGeneratorCom.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,          
        },
        MLG02 = Class(BlueLaserGenerator) {
            DisabledFiringBones = {'Turret_Muzzle_03'},
            
            SetOnTransport = function(self, transportstate)
                BlueLaserGenerator.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,          
        },
        CruiseMissile = Class(CIFMissileLoaTacticalWeapon) {},
		EMPWeapon01 = Class(CIFCommanderDeathWeapon) {},
		EMPWeapon02 = Class(CIFCommanderDeathWeapon) {},
		DeathWeapon = Class(CIFCommanderDeathWeapon) {},
    },
	DroneA = nil,
	DroneB = nil,
    # ********
    # Creation
    # ********
    OnCreate = function(self)
        CWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
    	self.canTeleport = 'false'
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Left_Range_Upgrade', true)
        self:HideBone('Right_Range_Upgrade', true)
        self:HideBone('Left_Cooling_Upgrade', true)
        self:HideBone('Right_Cooling_Upgrade', true)
        self:HideBone('Left_Ripper', true)
        self:HideBone('Right_Ripper', true)
		self:HideBone('Left_HeavyProton_Cannon', true)
		self:HideBone('Right_HeavyProton_Cannon', true)
		self:HideBone('Left_Torpedo_Launcher', true)
		self:HideBone('Right_Torpedo_Launcher', true)
		self:HideBone('Left_AA_Rack', true)
		self:HideBone('Right_AA_Rack', true)
		self:HideBone('Artillery', true)
		self:HideBone('Armor01', true)
		self:HideBone('Armor02', true)
		self:HideBone('Speed_Leg01', true)
		self:HideBone('Speed_Leg02', true)
		self:HideBone('TMD_Armor', true)
		self:HideBone('Missile_Rack', true)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
		
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
    end,
	
    OnPrepareArmToBuild = function(self)
        CWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,

    OnStopCapture = function(self, target)
        CWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedCapture = function(self, target)
        CWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnStopReclaim = function(self, target)
        CWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
        --don`t enable real weapon after enhancement in hunker state
        if not(self.hunkerState) then
            CWalkingLandUnit.SetWeaponEnabledByLabel(self, label, enable)
        end
        if self.hunkerwepstate[label] != nil and not(self.hunkerMethodCall) then
            self.hunkerwepstate[label] = enable
        end      
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
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
        self:SetWeaponEnabledByLabel('MLG', false)
        self:SetWeaponEnabledByLabel('MLG02', false)
        self:SetWeaponEnabledByLabel('RightTorpedo', false)
        self:SetWeaponEnabledByLabel('LeftTorpedo', false)
		self:SetWeaponEnabledByLabel('HeavyRightRipper', false)   
		self:SetWeaponEnabledByLabel('HeavyLeftRipper', false)   
		self:SetWeaponEnabledByLabel('Artillery', false)
    	self:SetWeaponEnabledByLabel('TMD01', false)
     	self:SetWeaponEnabledByLabel('TMD02', false)
     	self:SetWeaponEnabledByLabel('TMD03', false)
     	self:SetWeaponEnabledByLabel('TMD04', false)
		self:SetWeaponEnabledByLabel('SMD', false)
		self:SetWeaponEnabledByLabel('RightProtonCannon', false)
		self:SetWeaponEnabledByLabel('LeftProtonCannon', false)
		self:SetWeaponEnabledByLabel('RightAAMissile', false)
		self:SetWeaponEnabledByLabel('LeftAAMissile', false)
		self:SetWeaponEnabledByLabel('CruiseMissile', false)
		self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('Sonar')
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        CWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)    
        CWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        CWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
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
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Left_Range_Upgrade', true)
        self:HideBone('Right_Range_Upgrade', true)
        self:HideBone('Left_Cooling_Upgrade', true)
        self:HideBone('Right_Cooling_Upgrade', true)
        self:HideBone('Left_Ripper', true)
        self:HideBone('Right_Ripper', true)
		self:HideBone('Left_HeavyProton_Cannon', true)
		self:HideBone('Right_HeavyProton_Cannon', true)
		self:HideBone('Left_Torpedo_Launcher', true)
		self:HideBone('Right_Torpedo_Launcher', true)
		self:HideBone('Left_AA_Rack', true)
		self:HideBone('Right_AA_Rack', true)
		self:HideBone('Artillery', true)
		self:HideBone('Armor01', true)
		self:HideBone('Armor02', true)
		self:HideBone('Speed_Leg01', true)
		self:HideBone('Speed_Leg02', true)
		self:HideBone('TMD_Armor', true)
		self:HideBone('Missile_Rack', true)
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

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    OnScriptBitSet = function(self, bit)
        if bit == 7 then 
		-- EMP Weapon Fire
        	self:ForkThread(self.EMP)
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
		-- Disable Cloak
			self:StopUnitAmbientSound( 'ActiveLoop' )
			self:SetMaintenanceConsumptionInactive()
			self:DisableUnitIntel('Cloak')
			self:DisableUnitIntel('RadarStealth')
			self:DisableUnitIntel('SonarStealth')
			self:RemoveToggleCap('RULEUTC_CloakToggle')
		-- Set Hunker mode
			self.hunkerMethodCall = true
			for label, state in self.hunkerwepstate do
				if state then self:SetWeaponEnabledByLabel(label, false) end
			end
			self.hunkerMethodCall = false
			self.hunkerState = true
			#LOG(repr(self.hunkerwepstate))
		-- Add Hunker Charge Button
			self:AddToggleCap('RULEUTC_GenericToggle')
		-- Setup Shield
			ForkThread(function()
				WaitSeconds(10)
				self:CreateShield(self:GetBlueprint().Enhancements.HunkerShieldGeneratorField)
				self:SetEnergyMaintenanceConsumptionOverride(100000)
				self:SetMaintenanceConsumptionActive()
			end)
			Buff.ApplyBuff(self, 'CybranACUHunkerRegen')
    	elseif bit == 8 then # cloak toggle
			self:StopUnitAmbientSound( 'ActiveLoop' )
			self:SetMaintenanceConsumptionInactive()
			self:DisableUnitIntel('Cloak')
			self:DisableUnitIntel('RadarStealth')
			self:DisableUnitIntel('SonarStealth') 
    	elseif bit == 1 then 
			self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
    	elseif bit == 6 then
        	self:ForkThread(self.EMP)
			self:SetScriptBit('RULEUTC_GenericToggle', false)
        end
    end,

    OnScriptBitClear = function(self, bit)
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
		-- Enable Cloak
			self:PlayUnitAmbientSound( 'ActiveLoop' )
			self:SetMaintenanceConsumptionActive()
			self:EnableUnitIntel('Cloak')
			self:EnableUnitIntel('RadarStealth')
			self:EnableUnitIntel('SonarStealth')
			self:AddToggleCap('RULEUTC_CloakToggle')
			if Buff.HasBuff( self, 'CybranACUHunkerRegen' ) then
				Buff.RemoveBuff( self, 'CybranACUHunkerRegen' )
			end
			--enable all reserched weapon
			self.hunkerState = false
			self.hunkerMethodCall = true
			for label, state in self.hunkerwepstate do
				if state then self:SetWeaponEnabledByLabel(label, true) end
			end
			self.hunkerMethodCall = false
			#LOG(repr(self.hunkerwepstate))
	-- Remove Hunker Charge Button
			self:RemoveToggleCap('RULEUTC_GenericToggle')
			ForkThread(function()
				self:RemoveToggleCap('RULEUTC_SpecialToggle')
				WaitSeconds(180)
				self:AddToggleCap('RULEUTC_SpecialToggle')
			end)
    	elseif bit == 8 then # cloak toggle
			self:PlayUnitAmbientSound( 'ActiveLoop' )
			self:SetMaintenanceConsumptionActive()
			self:EnableUnitIntel('Cloak')
			self:EnableUnitIntel('RadarStealth')
			self:EnableUnitIntel('SonarStealth')
    	elseif bit == 1 then 
			self:SetSpeedMult(5.0) 
	    	self.canTeleport = 'false'
        end
    end,

    EMP = function(self)
		if not self:IsDead() then
			self:ForkThread(function()
			self:RemoveToggleCap('RULEUTC_GenericToggle')
					WaitSeconds(0.1)
			local wep1 = self:GetWeaponByLabel('EMPWeapon01')
			wep1:Fire()
					WaitSeconds(1)
			local wep2 = self:GetWeaponByLabel('EMPWeapon02')
			wep2:Fire()
					WaitSeconds(20)
			self:AddToggleCap('RULEUTC_GenericToggle')
				end)
		end
    end,

    OnMotionHorzEventChange = function( self, new, old )
        CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

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

    # *************
    # Build/Upgrade
    # *************
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 5, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    CreateEnhancement = function(self, enh)
        CWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if enh == 'SuperTeleporter' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
	    self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
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
            if Buff.HasBuff( self, 'CybranACUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranACUCloakBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')  
        elseif enh == 'Hunker' then
            if not Buffs['CybranACUHunkerRegen'] then
               BuffBlueprint {
                    Name = 'CybranACUHunkerRegen',
                    DisplayName = 'CybranACUHunkerRegen',
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
        elseif enh == 'RemoteCloaking' then
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionInactive()
            self:EnableRemoteViewingButtons()
        #T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT2BuildRate',
                    DisplayName = 'CybranACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'CybranACUT2BuildRate')
        #T3 Engineering
        elseif enh =='T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT3BuildRate',
                    DisplayName = 'CybranCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'CybranACUT3BuildRate')
		elseif enh =='PowerUp' then
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeDamage(bp.RightRipperNewDamage)
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeDamage(bp.LeftRipperNewDamage)
        elseif enh =='CoolingUpgrade' then
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeRateOfFire(bp.NewRateOfFire)
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeRateOfFire(bp.NewRateOfFire)
        elseif enh =='HighRangeUpgrade' then
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeMaxRadius(bp.RightRipperNewMaxRadius)
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeMaxRadius(bp.LeftRipperNewMaxRadius)
        elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG', true)
        elseif enh == 'BlueMicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG02', true)
            self:SetWeaponEnabledByLabel('MLG', false)
        elseif enh == 'RightNaniteTorpedo' then
            self:SetWeaponEnabledByLabel('RightTorpedo', true)
            self:EnableUnitIntel('Sonar')
        elseif enh == 'LeftNaniteTorpedo' then
            self:SetWeaponEnabledByLabel('LeftTorpedo', true)
             self:EnableUnitIntel('Sonar')
        elseif enh == 'EnhancedSensors' then
	        self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius)
	        self:SetIntelRadius('Vision', bp.NewVisionRadius)
            	self:SetIntelRadius('Omni', bp.NewOmniRadius)
		elseif enh == 'SpeedIncrease' then
			self:SetSpeedMult(5.0) 
		elseif enh == 'Artillery' then
					self:SetWeaponEnabledByLabel('Artillery', true)
		elseif enh == 'RightAntiAir' then
					self:SetWeaponEnabledByLabel('RightAAMissile', true)
		elseif enh == 'LeftAntiAir' then
			self:SetWeaponEnabledByLabel('LeftAAMissile', true)

		elseif enh == 'BigArmor' then
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
						Mult = 1,
			 },
					},
			}
			end
			Buff.ApplyBuff(self, 'VeterancyMegaHealth6')
    
        elseif enh =='DamageStablization' then
            if not Buffs['CybranACUDamageStablization'] then
               BuffBlueprint {
                    Name = 'CybranACUDamageStablization',
                    DisplayName = 'CybranACUDamageStablization',
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
            Buff.ApplyBuff(self, 'CybranACUDamageStablization')
    	elseif enh == 'CruiseMissile' then
    	        self:SetWeaponEnabledByLabel('CruiseMissile', true)
		elseif enh == 'HeavyRightRipper' then
             	self:SetWeaponEnabledByLabel('HeavyRightRipper', true)
    	elseif enh == 'HeavyLeftRipper' then
    	        self:SetWeaponEnabledByLabel('HeavyLeftRipper', true) 
		elseif enh == 'RightProtonCannon' then
             	self:SetWeaponEnabledByLabel('RightProtonCannon', true)
		elseif enh == 'LeftProtonCannon' then
             	self:SetWeaponEnabledByLabel('LeftProtonCannon', true)
		elseif enh == 'TMD' then
         	self:SetWeaponEnabledByLabel('TMD01', true)
         	self:SetWeaponEnabledByLabel('TMD02', true)
         	self:SetWeaponEnabledByLabel('TMD03', true)
         	self:SetWeaponEnabledByLabel('TMD04', true)
        elseif enh == 'SMD' then
           	self:SetWeaponEnabledByLabel('SMD', true)
    	elseif enh =='T4Engineering' then
            if not Buffs['CybranACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT4BuildRate',
                    DisplayName = 'CybranCUT4BuildRate',
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

            Buff.ApplyBuff(self, 'CybranACUT4BuildRate')    
        elseif enh == 'AssaultDrones' then
			self:ForkThread(self.InitialDroneSpawn)
			self:RequestRefreshUI()
			self.UnitComplete = true
			self.Army = self:GetArmy()
			self.DroneA = nil
			self.DroneB = nil
      	end
    end,

    InitialDroneSpawn = function(self)
    	WaitSeconds(2)
    	if not self:IsDead() then
			if not self:IsDead() then 
				self:ForkThread(self.SpawnDrone) 
			end
    	end
    end,

    SpawnDrone = function(self)
    	WaitSeconds(1)
    	if not self:IsDead() then 
            local myOrientation = self:GetOrientation()      
            if self.DroneA == nil or self.DroneA:IsDead() then
            	local location = self:GetPosition('AttachSpecial01')
            	local drone = CreateUnit('GRA0002', self:GetArmy(), location[1], location[2], location[3], myOrientation[1], myOrientation[2], myOrientation[3], myOrientation[4], 'Air') 
				self.DroneA = drone
				drone:SetParent(self, 'GRL0001')
            	drone:SetCreator(self)  
				IssueClearCommands({drone})
            	IssueGuard({drone}, self)
                drone:PlayTeleportOutEffects()
				self.Trash:Add(drone)
			end
            if self.DroneB == nil or self.DroneB:IsDead() then
            	local location = self:GetPosition('AttachSpecial02')
				local drone = CreateUnit('GRA0002', self:GetArmy(), location[1], location[2], location[3], myOrientation[1], myOrientation[2], myOrientation[3], myOrientation[4], 'Air') 
				self.DroneB = drone
				drone:SetParent(self, 'GRL0001')
            	drone:SetCreator(self)
				IssueClearCommands({drone})
            	IssueGuard({drone}, self)
                drone:PlayTeleportOutEffects()
				self.Trash:Add(drone)
            end
    	end
    end,

    NotifyOfDroneDeath = function(self) 
    	if not self:IsDead() then
			self:ForkThread(self.SpawnDrone) 
    	end    
    end,

    OnDamage = function(self, instigator, amount, vector, damagetype) 
    	CWalkingLandUnit.OnDamage(self, instigator, amount, vector, damagetype) 
		if self.DroneA != nil and not self.DroneA:IsDead() then
			IssueStop({self.DroneA})
			IssueClearCommands({self.DroneA})
			IssueAttack({self.DroneA}, instigator)
		end
		if self.DroneB != nil and not self.DroneB:IsDead() then
			IssueStop({self.DroneB})
			IssueClearCommands({self.DroneB})
			IssueAttack({self.DroneB}, instigator)
		end 
    end,
    
    # **********
    # Intel
    # **********    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Turret',
				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Chest',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Turret',
				    'Left_Turret',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Chest',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
        CWalkingLandUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self)
        CWalkingLandUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end          
    end,
        
    # *****
    # Death
    # *****
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end 
        #if we could find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
            #Apply Buff
			self:AddBuff(bp)
        end
        #otherwise, we should finish killing the unit
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
		if self.DroneChecker then
			KillThread(self.DroneChecker)
		end
    	if self.DroneA != nil then
			IssueClearCommands({self.DroneA}) 
			IssueKillSelf({self.DroneA})
    	end
		if self.DroneB != nil then
			IssueClearCommands({self.DroneB}) 
			IssueKillSelf({self.DroneB})
    	end
    end,
    
    OnPaused = function(self)
        CWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            CWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CWalkingLandUnit.OnUnpaused(self)
    end,     
}   
    
TypeClass = GRL0001
