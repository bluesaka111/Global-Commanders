#****************************************************************************
#**
#**  File     :  /cdimage/units/XSL0001/XSL0001_script.lua
#**  Author(s):  Drew Staltman, Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  Seraphim Commander Script
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SWeapons = import('/lua/seraphimweapons.lua')
local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon
local SAALosaareAutoCannonWeapon = SWeapons.SAALosaareAutoCannonWeapon
local SDFAireauWeapon = SWeapons.SDFAireauWeapon
local SAMElectrumMissileDefense = SWeapons.SAMElectrumMissileDefense
local SIFSuthanusArtilleryCannon = SWeapons.SIFSuthanusArtilleryCannon
local SDFExperimentalPhasonProj = SWeapons.SDFExperimentalPhasonProj
local SANHeavyCavitationTorpedo = SWeapons.SANHeavyCavitationTorpedo
local SDFUltraChromaticBeamGenerator = SWeapons.SDFUltraChromaticBeamGenerator

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local AIUtils = import('/lua/ai/aiutilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local DefaultDamage = import('/lua/sim/defaultdamage.lua')
local podteleport,podlocation

local RemoteTracking = import('/mods/Global Commanders Enhanced/lua/RemoteTracking.lua').RemoteTracking
SWalkingLandUnit = RemoteTracking( SWalkingLandUnit ) 

GSL0001 = Class( SWalkingLandUnit ) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
        TorpedoLauncher01 = Class(SANHeavyCavitationTorpedo) {},
        TorpedoLauncher02 = Class(SANHeavyCavitationTorpedo) {},
        LeftAntiMissile = Class(SAMElectrumMissileDefense) {},
        RightAntiMissile = Class(SAMElectrumMissileDefense) {},
        BigBallCannon = Class(SDFExperimentalPhasonProj) {},
        MultiGun01 = Class(SDFAireauWeapon) {
            OnCreate = function(self)
              	SDFAireauWeapon.OnCreate(self)
            	    if not self.SpinManip then 
              	    self.SpinManip = CreateRotator(self.unit, 'SpinMultiGun01', 'z', nil, 200, 200, 200)
                    self.unit.Trash:Add(self.SpinManip)
              	end
            end,
        },
        MultiGun02 = Class(SDFAireauWeapon) {
            OnCreate = function(self)
              	SDFAireauWeapon.OnCreate(self)
            	    if not self.SpinManip then 
              	    self.SpinManip = CreateRotator(self.unit, 'SpinMultiGun02', 'z', nil, -200, -200, -200)
                    self.unit.Trash:Add(self.SpinManip)
              	end
            end,
        },
        PowerGun = Class(SIFSuthanusArtilleryCannon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = SIFSuthanusArtilleryCannon.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().ShieldDamage
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
            end,
        },
    	AntiAirMissiles01 = Class(SAALosaareAutoCannonWeapon) {
    	    OnCreate = function(self)
              	SAALosaareAutoCannonWeapon.OnCreate(self)
            	    if not self.SpinManip then 
              	    self.SpinManip = CreateRotator(self.unit, 'TurnPoint', 'y', nil, 40, 40, 40)
                    self.unit.Trash:Add(self.SpinManip)
              	end
            end,
        },
        AntiAirMissiles02 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles03 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles04 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles05 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles06 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles07 = Class(SAALosaareAutoCannonWeapon){},
        AntiAirMissiles08 = Class(SAALosaareAutoCannonWeapon){},
        NukeLaser = Class(SDFUltraChromaticBeamGenerator) {            
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
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_TMD_Mount', true)
		self:HideBone('Right_TMD_Mount', true)
		self:HideBone('TurnPoint', true)
		self:HideBone('TurnPoint01', true)
		self:HideBone('SpinMultiGun01', true)
		self:HideBone('SpinMultiGun02', true)
		self:HideBone('Big_Ball_Cannon', true)
		self:HideBone('Torpedo_Launcher', true)
        self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false		     
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        SWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,

    OnStopCapture = function(self, target)
        SWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedCapture = function(self, target)
        SWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnStopReclaim = function(self, target)
        SWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
        --don`t enable real weapon after enhancement in hunker state
        if not(self.hunkerState) then
            SWalkingLandUnit.SetWeaponEnabledByLabel(self, label, enable)
        end
        if self.hunkerwepstate[label] != nil and not(self.hunkerMethodCall) then
            self.hunkerwepstate[label] = enable
        end      
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
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
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles01', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles02', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles03', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles04', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles05', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles06', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles07', false)
		self:SetWeaponEnabledByLabel('AntiAirMissiles08', false)
		self:SetWeaponEnabledByLabel('MultiGun01', false)
		self:SetWeaponEnabledByLabel('MultiGun02', false)
		self:SetWeaponEnabledByLabel('LeftAntiMissile', false)
		self:SetWeaponEnabledByLabel('RightAntiMissile', false)	
		self:SetWeaponEnabledByLabel('PowerGun', false)	
		self:SetWeaponEnabledByLabel('NukeLaser', false)
    	self:SetWeaponEnabledByLabel('Boom', false)
		self:SetWeaponEnabledByLabel('BigBallCannon', false)
		self:SetWeaponEnabledByLabel('TorpedoLauncher01', false)
		self:SetWeaponEnabledByLabel('TorpedoLauncher02', false)
        self:ForkThread(self.GiveInitialResources)
        self.Trash:Add(CreateRotator(self, 'TurnPoint01', 'x', nil, 50))
        self.Trash:Add(CreateRotator(self, 'TurnPoint01', 'y', nil, 50))
        self.Trash:Add(CreateRotator(self, 'TurnPoint01', 'z', nil, 50))
        self.ShieldEffectsBag = {}
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
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
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('TurnPoint', true)
		self:HideBone('TurnPoint01', true)
		self:HideBone('SpinMultiGun01', true)
		self:HideBone('SpinMultiGun02', true)
		self:HideBone('Left_TMD_Mount', true)
		self:HideBone('Right_TMD_Mount', true)
		self:HideBone('Big_Ball_Cannon', true)
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

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    RegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.ALLUNITS, self:GetPosition(), self:GetBlueprint().Enhancements.RegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,
       
    AdvancedRegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.ALLUNITS, self:GetPosition(), self:GetBlueprint().Enhancements.AdvancedRegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura')
            end
            #
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

    DegenAuraThread = function(self)
        local damageData = {
                Instigator = self,
            	DoTPulses = 15,
            	DoTTime = 2.5,
	        DamageType = 'Reclaimed',
	        DamageFriendly = false,
		}
        while not self:IsDead() do
            local units = self:GetAIBrain():GetUnitsAroundPoint(categories.ALLUNITS - categories.SATELLITE - categories.UNTARGETABLE, self:GetPosition(), self:GetBlueprint().Enhancements.AdvancedRegenAura.Radius, 'Enemy')
            local unitbphealth = 0
            local damage = 0
            for k, unit in units do
                if not unit:IsUnitState('BeingBuilt') then
                    unitbphealth = unit:GetBlueprint().Defense.MaxHealth or 1
                    damage = unitbphealth*self.DegenPS
                    if damage > self.DegenCeil then damage = self.DegenCeil end
                    if damage < self.DegenFloor then damage = self.DegenFloor end
                    #LOG(damage)
                    ForkThread(DefaultDamage.UnitDoTThread, damageData.Instigator, unit, damageData.DoTPulses, (damageData.DoTTime / damageData.DoTPulses), damage/damageData.DoTPulses, damageData.DamageType, damageData.DamageFriendly)
                end
            end
            WaitSeconds(1)
        end
    end,

    OnTeleportUnit = function(self, teleporter, location, orientation)
	#LOG('OnTeleportUnit')
		SWalkingLandUnit.OnTeleportUnit(self, teleporter, location, orientation)
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
    
    OnMotionHorzEventChange = function( self, new, old )
        SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)

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

    NotifyOfPodDeath = function(self, pod, Unit)
        if pod == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('XSA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()
        elseif pod == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('XSA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()
        end       
    end,

    CreateEnhancement = function(self, enh)
        SWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        if enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('GSA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('GSA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
            pod:PlayTeleportOutEffects()
        # Regenerative Aura
		elseif enh == 'RegenAura' then
            if not Buffs['SeraphimACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura',
                    DisplayName = 'SeraphimACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Priority = 10000,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end

            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread)
                        
        elseif enh == 'AdvancedRegenAura' then
            if self.RegenThreadHandle then
                if self.ShieldEffectsBag then
                    for k, v in self.ShieldEffectsBag do
                        v:Destroy()
                    end
		            self.ShieldEffectsBag = {}
		        end
                KillThread(self.RegenThreadHandle)
                
            end

            if not Buffs['SeraphimAdvancedACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura',
                    DisplayName = 'SeraphimAdvancedACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Priority = 10001,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                        MaxHealth = {
                            Add = 0,
                            Mult = bp.MaxHealthFactor or 1.0,
                            DoNoFill = true,
                        },                        
                    },
                }
            end
            self.DegenPS = bp.RegenPerSecond
            self.DegenCeil = bp.RegenCeiling
            self.DegenFloor = bp.RegenFloor
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.AdvancedRegenThreadHandle = self:ForkThread(self.AdvancedRegenBuffThread)
            self.DegenAuraThreadHandle = self:ForkThread(self.DegenAuraThread)
        #Resource Allocation
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        #Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimACUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilization',
                    DisplayName = 'SeraphimACUDamageStabilization',
                    BuffType = 'ACUUPGRADEDMG',
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
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilization')    
      	elseif enh == 'DamageStabilizationAdvanced' then
            if not Buffs['SeraphimACUDamageStabilizationAdv'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilizationAdv',
                    DisplayName = 'SeraphimACUDamageStabilizationAdv',
                    BuffType = 'ACUUPGRADEDMG',
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
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilizationAdv') 
	elseif enh == 'SpeedIncrease' then
		self:SetSpeedMult(5.0)  	    
        #Teleporter
        elseif enh == 'SuperTeleport' then
            self:AddToggleCap('RULEUTC_WeaponToggle')
        #Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldHeavy' then
            self:ForkThread(self.CreateHeavyShield, bp)
        elseif enh == 'Hunker' then
            if not Buffs['SeraphimACUHunkerRegen'] then
               BuffBlueprint {
                    Name = 'SeraphimACUHunkerRegen',
                    DisplayName = 'SeraphimACUHunkerRegen',
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
	elseif enh == 'MissileRedirect' then
         local bp = self:GetBlueprint().Defense.AntiMissile
         self.MissileRedirectors = {}
         for i, attbone in bp.AttachBones do
             self.MissileRedirectors[i] = MissileRedirect {
                 Owner = self,
                 Radius = bp.Radius,
                 AttachBone = attbone,
                 RedirectRateOfFire = bp.RedirectRateOfFire
                 }
             self.Trash:Add(self.MissileRedirectors[i])
         end
         self:ForkThread(function()
         #MissileRedirect bag workaround
             while true do
                 WaitSeconds(5)
                 for i, mr in self.MissileRedirectors do
                     if mr then
                         ChangeState(mr, mr.WaitingState)
                     end
                 end
             end
         end)
         self.UnitComplete = true
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius or 104)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
        #T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT2BuildRate',
                    DisplayName = 'SeraphimACUT2BuildRate',
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

            Buff.ApplyBuff(self, 'SeraphimACUT2BuildRate')
            
        #T3 Engineering
        elseif enh =='T3Engineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT3BuildRate',
                    DisplayName = 'SeraphimCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT3BuildRate')
        #Blast Attack
        elseif enh == 'BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeDamage(bp.ChronotronCannonNewDamage)
        elseif enh == 'RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.ChronotronCannonNewRateOfFire) 
        elseif enh == 'CrysalisBeam' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeMaxRadius(bp.ChronotronCannonNewMaxRadius)  
        elseif enh =='StabilitySuppressant' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeDamageRadius(bp.ChronotronCannonNewDamageRadius)   
            wep:ChangeProjectileBlueprint(bp.NewProjectileBlueprint)
	#T4Engineering
        elseif enh =='T4Engineering' then
	    if not Buffs['SeraphimACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT4BuildRate',
                    DisplayName = 'SeraphimCUT4BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT4BuildRate')
        #Double Attack
        elseif enh == 'DoubleAttack' then
            local wep = self:GetWeaponByLabel('PowerGun')
            wep:AddDamageRadiusMod(bp.NewDamageRadius)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'PGRateOfFire' then
            local wep = self:GetWeaponByLabel('PowerGun')
            wep:ChangeRateOfFire(bp.NewRateOfFire)     
      #Antiair
        elseif enh == 'Antiair' then
		self:SetWeaponEnabledByLabel('AntiAirMissiles01', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles02', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles03', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles04', true)	
      #AdvanceAntiair
        elseif enh == 'AdvanceAntiair' then
		self:SetWeaponEnabledByLabel('AntiAirMissiles05', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles06', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles07', true)	
		self:SetWeaponEnabledByLabel('AntiAirMissiles08', true)
      #MultiGun
        elseif enh == 'MultiGun01' then
		self:SetWeaponEnabledByLabel('MultiGun01', true)
        elseif enh == 'MultiGun02' then
		self:SetWeaponEnabledByLabel('MultiGun02', true)
        elseif enh == 'TorpedoLauncher' then
		self:SetWeaponEnabledByLabel('TorpedoLauncher01', true)
        elseif enh == 'AdvancedTorpedoLauncher' then
		self:SetWeaponEnabledByLabel('TorpedoLauncher02', true)
		self:SetWeaponEnabledByLabel('TorpedoLauncher01', false)
        elseif enh == 'PowerGun' then
		self:SetWeaponEnabledByLabel('PowerGun', true)    
        elseif enh == 'BigBallCannon' then
		self:SetWeaponEnabledByLabel('BigBallCannon', true)          
        elseif enh == 'LeftAntiMissile' then
		self:SetWeaponEnabledByLabel('LeftAntiMissile', true)
        elseif enh == 'RightAntiMissile' then
		self:SetWeaponEnabledByLabel('RightAntiMissile', true)     
        elseif enh == 'NukeLaser' then
		self:SetWeaponEnabledByLabel('NukeLaser', true)   
        elseif enh == 'RemoteTracking' then
            	self.Sync.Abilities = self:GetBlueprint().Abilities
            	self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            	self:SetMaintenanceConsumptionInactive()
            	self:EnableRemoteViewingButtons()            
        end
    end,

    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
        self:SetMaintenanceConsumptionActive()
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

    OnScriptBitSet = function(self, bit)
        SWalkingLandUnit.OnScriptBitSet(self, bit)
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
            	    self:SetEnergyMaintenanceConsumptionOverride(100000)
            	    self:SetMaintenanceConsumptionActive()
            	end)
            	Buff.ApplyBuff(self, 'SeraphimACUHunkerRegen') 
    	elseif bit == 1 then 
		self:SetSpeedMult(1.0) 
	    	self.canTeleport = 'true'
        end
    end,

    OnScriptBitClear = function(self, bit)
        SWalkingLandUnit.OnScriptBitClear(self, bit)
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
            	ForkThread(function()
            	    WaitTicks(1)
            	    self:CreatePersonalShield(self:GetBlueprint().Enhancements.ShieldHeavy)
            	    self:SetEnergyMaintenanceConsumptionOverride(500)
            	    self:SetMaintenanceConsumptionActive()
            	end)
            	self:AddToggleCap('RULEUTC_ShieldToggle')
            	if Buff.HasBuff( self, 'SeraphimACUHunkerRegen' ) then
            	    Buff.RemoveBuff( self, 'SeraphimACUHunkerRegen' )
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

TypeClass = GSL0001