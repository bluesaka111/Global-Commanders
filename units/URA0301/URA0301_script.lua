#****************************************************************************
#**
#**  File     :  /cdimage/units/URL0301/URL0301_script.lua
#**  Author(s):  David Tomandl, Jessica St. Croix
#**
#**  Summary  :  Cybran Sub Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CAirUnit = import('/lua/cybranunits.lua').CAirUnit
local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CANNaniteTorpedoWeapon = CWeapons.CANNaniteTorpedoWeapon
local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local CIFArtilleryWeapon = CWeapons.CIFArtilleryWeapon
local CDFHvyProtonCannonWeapon = CWeapons.CDFHvyProtonCannonWeapon
local CDFLaserHeavyWeapon = CWeapons.CDFLaserHeavyWeapon
local RedLaserGenerator = import('/mods/Global Commanders/lua/GCweapons.lua').RedLaserGenerator

function printecnhancement(unit)
    if unit.EnhList != nil then
        for k,v in unit.EnhList do
            LOG('*SACU: ',k..' '..v)
        end
        LOG('*****************')
    end
end

function CopyEnhancement(srcUnit, destUnit)
    #printecnhancement(srcUnit)
    if srcUnit.EnhList then
        for k,v in srcUnit.EnhList do
            #LOG('*SACU: ',k..' '..v)
            local bp = destUnit:GetBlueprint().Enhancements[v]
            if not bp then
                error('*ERROR: CopyEnhancement - target unit enhancements list doesnt equal to source.', 2)
                break
            end
            destUnit:CreateEnhancement(v)
        end
    end
end

URA0301 = Class(CAirUnit) {
    LeftFoot = 'Left_Foot02',
    RightFoot = 'Right_Foot02',
    
    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
        LeftRipper = Class(CCannonMolecularWeapon) {
	    CreateProjectileAtMuzzle = function(self, muzzle)
		numProjectiles = 10
		    for i = 0, (numProjectiles -1) do
		    local proj = CCannonMolecularWeapon.CreateProjectileAtMuzzle(self, muzzle)
		end
	    end,
	},
        RightRipper = Class(CCannonMolecularWeapon) {
	    CreateProjectileAtMuzzle = function(self, muzzle)
		numProjectiles = 10
		    for i = 0, (numProjectiles -1) do
		    local proj = CCannonMolecularWeapon.CreateProjectileAtMuzzle(self, muzzle)
		end
	    end,
	},
        MissileRack01 = Class(CAAMissileNaniteWeapon) {},
        MissileRack02 = Class(CAAMissileNaniteWeapon) {},
        Bullseyes = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
        ArtCannon = Class(CIFArtilleryWeapon) {},
        TorpedoLauncher = Class(CANNaniteTorpedoWeapon) {},
        ProtonCannon = Class(CDFHvyProtonCannonWeapon) {},
        StunLaser = Class(RedLaserGenerator) {            
            OnWeaponFired = function(self)
            	RedLaserGenerator.OnWeaponFired(self)
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
        CAirUnit.OnCreate(self)
        self.EnhList = {}
        self:SetCapturable(false)
        self:HideBone('Combat_Horns', true)
        self:HideBone('Power_Pack', true)
        self:HideBone('Axe01', true)
        self:HideBone('Axe02', true)
        self:HideBone('Torpedo_Launcher', true)
        self:HideBone('ProtonCannon', true)
        self:HideBone('Laser_Barrel', true)
        self:HideBone('Artillery', true)
        self:HideBone('Turbine', true)
        self:HideBone('EMP_Barrel', true)
        self:SetupBuildBones()
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYSUBCOMMANDER) ) 
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:BuildManipulatorSetEnabled(false)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
	self:SetWeaponEnabledByLabel('MissileRack01', false)
	self:SetWeaponEnabledByLabel('MissileRack02', false)
	self:SetWeaponEnabledByLabel('Bullseyes', false)
	self:SetWeaponEnabledByLabel('ArtCannon', false)
	self:SetWeaponEnabledByLabel('TorpedoLauncher', false)
	self:SetWeaponEnabledByLabel('ProtonCannon', false)
	self:SetWeaponEnabledByLabel('StunLaser', false)
	self.WeaponsEnabled = true
    end,

    OnPrepareArmToBuild = function(self)
        CAirUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,
    
    OnStopCapture = function(self, target)
        CAirUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedCapture = function(self, target)
        CAirUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStopReclaim = function(self, target)
        CAirUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)    
        CAirUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true   
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        CAirUnit.OnStopBuild(self, unitBeingBuilt)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)   
    end,    
    
    OnFailedToBuild = function(self)
        CAirUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 3, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    SetupIntel = function(self, layer)
        CAirUnit.SetupIntel(self)
        if layer == 'Seabed' or layer == 'Sub' then
            self:EnableIntel('WaterVision')
        else
            self:EnableIntel('Vision')
        end

        self:EnableIntel('Radar')
        self:EnableIntel('Sonar')
    end,



    OnScriptBitSet = function(self, bit)
        #CAirUnit.OnScriptBitSet(self, bit)
        if bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        #CAirUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            self:ForkThread(self.LandMode)
    	elseif bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,


    LandMode = function(self)
        if not self:IsDead() then

            local myOrientation = self:GetOrientation()

            local location = self:GetPosition()

            local health = self:GetHealth()
            local numkills = self:GetStat('KILLS', 0).Value

            local url0301 = CreateUnit('url0301', self:GetArmy(), location[1], location[2], location[3], myOrientation[1], myOrientation[2], myOrientation[3], myOrientation[4], 'Land')

            url0301:AddKills(numkills)
            CopyEnhancement(self, url0301)
            url0301:SetHealth(self,health)
            url0301:SetScriptBit('RULEUTC_CloakToggle', self:GetScriptBit('RULEUTC_CloakToggle'))
            url0301 = nil

            self:Destroy()
        end
    end,

    CreateEnhancement = function(self, enh)
        CAirUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'CloakingGenerator' then
            self.StealthEnh = false
	    self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
            if not Buffs['CybranSCUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranSCUCloakBonus',
                    DisplayName = 'CybranSCUCloakBonus',
                    BuffType = 'SCUCLOAKBONUS',
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
            if Buff.HasBuff( self, 'CybranSCUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCUCloakBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranSCUCloakBonus')                		
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
        elseif enh == 'SensorRangeEnhancer' then
            self:SetIntelRadius('WaterVision', bp.NewWaterVisionRadius or 96)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 96)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 96)        
        elseif enh == 'NaniteMissileSystem' then
            self:SetWeaponEnabledByLabel('MissileRack01', true)
            self:SetWeaponEnabledByLabel('MissileRack02', true)
        elseif enh == 'SelfRepairSystem' then
            if not Buffs['CybranSCUSelfRepairSystem'] then
               BuffBlueprint {
                    Name = 'CybranSCUSelfRepairSystem',
                    DisplayName = 'CybranSCUSelfRepairSystem',
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
            Buff.ApplyBuff(self, 'CybranSCUSelfRepairSystem')
        elseif enh == 'ResourceAllocation' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + self:GetProductionPerSecondEnergy() or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + self:GetProductionPerSecondEnergy() or 0)
        elseif enh =='Switchback' then
            if not Buffs['CybranSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'CybranSCUBuildRate',
                    DisplayName = 'CybranSCUBuildRate',
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
            Buff.ApplyBuff(self, 'CybranSCUBuildRate')
    	elseif enh =='SubComEngineeringT4' then
            if not Buffs['CybranSCUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranSCUT4BuildRate',
                    DisplayName = 'CybranSCUT4BuildRate',
                    BuffType = 'SCUBUILDRATE',
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

            Buff.ApplyBuff(self, 'CybranSCUT4BuildRate') 
    	elseif enh =='SubComEngineeringT5' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranSCUT5BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranSCUT5BuildRate',
                    DisplayName = 'CybranSCUT5BuildRate',
                    BuffType = 'SCUBUILDRATE',
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

            Buff.ApplyBuff(self, 'CybranSCUT5BuildRate') 
        elseif enh == 'EMPCharge' then
            self:SetWeaponEnabledByLabel('StunLaser', true)
	elseif enh =='PowerUp' then
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeDamage(bp.LeftRipperNewDamage)
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeDamage(bp.RightRipperNewDamage)
        elseif enh =='AdvancedCoolingUpgrade' then
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeRateOfFire(bp.LeftRipperNewRateOfFire)
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeRateOfFire(bp.RightRipperNewRateOfFire)
        elseif enh =='HighExplosiveOrdnance' then
            local wep = self:GetWeaponByLabel('LeftRipper')
            wep:ChangeDamageRadius(bp.LeftRipperNewDamageRadius)
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeDamageRadius(bp.RightRipperNewDamageRadius)
	elseif enh == 'Artillery' then
            self:SetWeaponEnabledByLabel('ArtCannon', true)
        elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('Bullseyes', true)
	elseif enh == 'ProtonCannon' then
            self:SetWeaponEnabledByLabel('ProtonCannon', true)
        elseif enh == 'Torpedo' then
            self:SetWeaponEnabledByLabel('TorpedoLauncher', true)
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
        #JetPack
        elseif enh == 'JetPack' then
            self:AddToggleCap('RULEUTC_WeaponToggle')        
        end             
    #LOG('*SACU: Enhancement added - ',enh)
    table.insert(self.EnhList,enh)
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
        CAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
        CAirUnit.OnIntelEnabled(self)
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
        CAirUnit.OnIntelDisabled(self)
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
    
    OnPaused = function(self)
        CAirUnit.OnPaused(self)
        if self.BuildingUnit then
            CAirUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CAirUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CAirUnit.OnUnpaused(self)
    end,        
}

TypeClass = URA0301
