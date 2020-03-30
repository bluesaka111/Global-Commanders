do
	local TriggerFile = import('scenariotriggers.lua')
	local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
	local UnitUpgradeTemplates = import('/lua/upgradeTemplates.lua').UnitUpgradeTemplates
	local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
	local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
	local SimCamera = import('/lua/SimCamera.lua').SimCamera
	local Cinematics = import('/lua/cinematics.lua')
	local SimUIVars = import('/lua/sim/SimUIState.lua')
	local Utilities = import('/lua/Utilities.lua') # enabled so we can hide strat icons during NISs
	local EffectTemplate = import('/lua/EffectTemplates.lua')

	PingGroups = import('/lua/SimPingGroup.lua')
	Objectives = import('/lua/SimObjectives.lua')

	function FakeGateInUnit(unit, callbackFunction)
		local faction
		local bp = unit:GetBlueprint()

		if EntityCategoryContains( categories.COMMAND, unit ) then
			for k,v in bp.Categories do
				if v == 'UEF' then
					faction = 1
					break
				elseif v == 'AEON' then
					faction = 2
					break
				elseif v == 'CYBRAN' then
					faction = 3
					break
				end
			end

			unit:HideBone(0, true)
			unit:SetUnSelectable(true)
			unit:SetBusy(true)
			unit:PlayUnitSound('CommanderArrival')
			unit:CreateProjectile( '/effects/entities/UnitTeleport03/UnitTeleport03_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
			WaitSeconds(0.75)

			LOG('Faction ',faction)
			if faction == 1 then
				unit:SetMesh('/mods/Global Commanders Enhanced/units/GEL0001/GEL0001_PhaseShield_mesh', true)
				unit:ShowBone(0, true)
				unit:HideBone('Back_Upgrade_B01', true) 
				unit:HideBone('Megacannon01', true)
				unit:HideBone('Megacannon02', true)
				unit:HideBone('Megacannon03', true)
				unit:HideBone('Megacannon04', true)
				unit:HideBone('Rack_Over_Mega_Heavy_Canon01', true)
				unit:HideBone('Rack_Over_Mega_Heavy_Canon02', true)
				unit:HideBone('Shoulder_Left_Upgrade_Turret', true)
				unit:HideBone('Shoulder_Right_Upgrade_Turret', true)
				unit:HideBone('Minigun01', true)
				unit:HideBone('Minigun02', true)
				unit:HideBone('Right_Upgrade02', true)
				unit:HideBone('Right_Upgrade03', true)
				unit:HideBone('Cape', true)
				unit:HideBone('Torpedo_Launcher', true)
			elseif faction == 2 then
				unit:SetMesh('/mods/Global Commanders Enhanced/units/GAL0001/GAL0001_PhaseShield_mesh', true)
				unit:ShowBone(0, true)
				unit:HideBone('Back_Upgrade', true)
				unit:HideBone('Right_Rotator', true)        
				unit:HideBone('Left_Rotator', true)  
				unit:HideBone('AA_UpgradeRight01', true)
				unit:HideBone('AA_UpgradeRight02', true)
				unit:HideBone('AA_UpgradeLeft01', true)
				unit:HideBone('AA_UpgradeLeft02', true)
				unit:HideBone('RightQuantumCannon', true)
				unit:HideBone('LeftQuantumCannon', true)
				unit:HideBone('Oblivion_Turret', true)
				unit:HideBone('MultiMissiles_Rack', true)
				unit:HideBone('Torpedo_Launcher01', true)
				unit:HideBone('Torpedo_Launcher02', true)
				unit:HideBone('Laser_Cannon', true)
				unit:HideBone('Missile_Rack', true)
			elseif faction == 3 then
				unit:SetMesh('/mods/Global Commanders Enhanced/units/GRL0001/GRL0001_PhaseShield_mesh', true)
				unit:ShowBone(0, true)
				unit:HideBone('Back_Upgrade', true)
				unit:HideBone('Left_Range_Upgrade', true)
				unit:HideBone('Right_Range_Upgrade', true)
				unit:HideBone('Left_Cooling_Upgrade', true)
				unit:HideBone('Right_Cooling_Upgrade', true)
				unit:HideBone('Left_Ripper', true)
				unit:HideBone('Right_Ripper', true)
				unit:HideBone('Left_HeavyProton_Cannon', true)
				unit:HideBone('Right_HeavyProton_Cannon', true)
				unit:HideBone('Left_Torpedo_Launcher', true)
				unit:HideBone('Right_Torpedo_Launcher', true)
				unit:HideBone('Left_AA_Rack', true)
				unit:HideBone('Right_AA_Rack', true)
				unit:HideBone('Artillery', true)
				unit:HideBone('Armor01', true)
				unit:HideBone('Armor02', true)
				unit:HideBone('Speed_Leg01', true)
				unit:HideBone('Speed_Leg02', true)
				unit:HideBone('TMD_Armor', true)
				unit:HideBone('Missile_Rack', true)
			end

			unit:SetUnSelectable(false)
			unit:SetBusy(false)
			unit:SetBlockCommandQueue(false)

			local totalBones = unit:GetBoneCount() - 1
			local army = unit:GetArmy()
			for k, v in EffectTemplate.UnitTeleportSteam01 do
				for bone = 1, totalBones do
					CreateAttachedEmitter(unit,bone,army, v)
				end
			end

			WaitSeconds(2)
			unit:SetMesh(unit:GetBlueprint().Display.MeshBlueprint, true)
		else
			LOG ('debug:non commander')
			unit:PlayTeleportChargeEffects()
			unit:PlayUnitSound('GateCharge')
			WaitSeconds(2)
			unit:CleanupTeleportChargeEffects()
		end

		if callbackFunction then
			callbackFunction()
		end
	end
end