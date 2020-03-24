local DefaultUnitsFile = import('/lua/defaultunits.lua')
local StructureUnit = DefaultUnitsFile.StructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')
local Toolbox = import('/mods/Global Commanders/lua/CommonTools.lua')

QuantumTeleporterUnit = Class(StructureUnit) {

	-- Base economic costs for starting a teleport
	BaseChargeTime = 30,
	BaseEnergyCost = 1000,
	
	-- Resource costs for various unit tiers
	ResourceCosts = {
		Energy = {
			T1 = 50,
			T2 = 75,
			T3 = 150,
			T4 = 2500,
			COMMAND = 8000,
		},
	},

	-- Sound that plays when a teleport happens
	TeleportSound = Sound {
		Bank = 'UAL',
		Cue = 'UAL0001_Gate_In',
		LodCutoff = 'UnitMove_LodCutoff',
	},

	-- Set of effects that are played when a gate involved with an in-progress teleport is destroyed
	GateExplodeEffect = {
		{
			Scale = 0.6,
			Offset = { x = 0, y = 0, z = 0 },
			Emitters = {
				'/effects/emitters/seraphim_inaino_hit_03_emit.bp',
				'/effects/emitters/seraphim_inaino_hit_08_emit.bp',
				'/effects/emitters/seraphim_inaino_hit_07_emit.bp',
				'/effects/emitters/seraphim_inaino_explode_07_emit.bp',
			},
		},
		{
			Scale = 8,
			Offset = { x = 0, y = 0, z = 0 },
			Emitters = {
				'/mods/Global Commanders/effects/emitters/teleport_explode_effect_01_emit.bp',
				'/mods/Global Commanders/effects/emitters/teleport_explode_effect_02_emit.bp',
			},
		},
		{
			Scale = 4,
			Offset = { x = 0, y = 0, z = 0 },
			Emitters = {
				'/mods/Global Commanders/effects/emitters/teleport_explode_effect_03_emit.bp',
			},
		},
	},
	
	-- Set of effects used when a teleport happens	
	TeleportChargeEffect = {
		{
			Scale = 0.85,
			Offset = { x = 0, y = 1, z = -4.5 },
			Emitters = EffectTemplate.CSoothSayerAmbient,
		},
		{
			Scale = 3,
			Offset = { x = 0, y = 1.5, z = 0 },
			Emitters = {
				'/mods/Global Commanders/effects/emitters/teleport_charge_effect_01_emit.bp',
				'/mods/Global Commanders/effects/emitters/teleport_charge_effect_02_emit.bp',
				'/mods/Global Commanders/effects/emitters/teleport_charge_effect_01_emit.bp',
			},
		},
		{
			Scale = 6,
			Offset = { x = 0, y = 2.5, z = -6 },
			Emitters = {
				'/mods/Global Commanders/effects/emitters/teleport_charge_effect_04_emit.bp',
				'/mods/Global Commanders/effects/emitters/teleport_charge_effect_05_emit.bp',
			},
		},
	},
	

	
	-- Fires when the gateway finishes building. Used to set flags and prepare the gate
	-- for teleport stuff
	OnStopBeingBuilt = function(self, builder, layer)
		self.TeleportReady = true			-- check if the gateway is ready to participate in teleporting
		self.TeleportingUnits = nil			-- table holds the units currently being teleported
		self.DestinationGateway = nil		-- when this gate is sending, the gate we are sending to
		self.TeleportInProgress = false		-- true when a teleport is currently underway

		-- bubble event
		StructureUnit.OnStopBeingBuilt(self, builder, layer)
	end,


	-- Fires when the gateway is destroyed.  This handles killing the remote gateway and units in transit if 
	-- a teleportation is underway. It also fires off special effects
	OnKilled = function(self, instigator, type, overkillRatio)
		LOG('~Gateway destroyed!')

		if self.TeleportThread then
			KillThread(self.TeleportThread)
			self.TeleportThread	= nil
		end

		if self.TeleportInProgress then
		
			self:EndGateChargeEffect()
			self:PlayGateExplodeEffect()
		
			-- if the gate destroyed is linked to a remote (receiving) gateway then kill it
			if self.DestinationGateway and not self.DestinationGateway:IsDead() then
				LOG('~Killing destination gateway')
				self.DestinationGateway:Kill(self, type, 1.0)
			end

			-- if the gate destroyed is linked to a remote (sending) gateway then kill it
			if self.SourceGateway and not self.SourceGateway:IsDead() then
				LOG('~Killing source gateway')
				self.SourceGateway:Kill(self, type, 1.0)
			end

			-- it is the job of the sending gateway to kill any units being teleported
			if self.TeleportingUnits then
				LOG('~Killing units in transit')
				for k, v in self.TeleportingUnits do
					v:CleanupTeleportChargeEffects()
					v:SetImmobile(false)
					v:Kill(self, type, 1.0)
				end
			end
			
			-- cleanup
			self.DestinationGateway = nil
			self.SourceGateway = nil
			self.TeleportInProgress = false
		
		end

		-- bubble event
		StructureUnit.OnKilled(self, instigator, type, overkillRatio)
	end,


	-- This is the "main" function called when the teleport button is clicked
	WarpNearbyUnits	= function(self, radius)
		LOG('~Starting teleport')

		if not self.TeleportReady then
			Toolbox.PrintError("Gateway not ready!", self:GetArmy())
			return
		end
	
		if self.TeleportInProgress then
			Toolbox.PrintError("Teleport already in progress!", self:GetArmy())
			return
		end
		
		local warpLocation = self:GetRallyPoint()
		local possibleGates = Toolbox.GetAlliedGatesInRadius(self, warpLocation, radius)
		
		if not possibleGates or table.getn(possibleGates) == 0 then
			Toolbox.PrintError("No destination gates found at rally point", self:GetArmy())
			return
		end
		
		-- just pick the first gate in the list, more than one gate within the teleport radius == WTF
		local destinationGate = possibleGates[1]
		
		if destinationGate == self then
			Toolbox.PrintError("Must target a remote gateway with rally point", self:GetArmy())
			return 
		end
		
		if destinationGate.TeleportInProgress then
			Toolbox.PrintError("Target gate already teleporting!", self:GetArmy())
			return 
		end
		
		local warpUnits = Toolbox.GetAlliedMobileUnitsInRadius(self, self:GetPosition(), radius)
		
		--if not warpUnits or table.getn(warpUnits) == 0 then
		--	Toolbox.PrintError("No units within teleport radius", self:GetArmy())
		--	return
		--end
		
		LOG('~Number of units to teleport: ' .. table.getn(warpUnits))

		if self.TeleportDrain then
			RemoveEconomyEvent(self, self.TeleportDrain)
			self.TeleportDrain = nil
		end

		LOG('~Starting teleport thread')
		
		-- fire off a new thread to handle the teleport
		self.TeleportThread	= self:ForkThread(self.TeleportUnits, warpUnits, destinationGate)
	end,


	-- Handler for the economy event that will update the teleporter's progress
	UpdateTeleportProgress = function(self,	progress)
		self:SetWorkProgress(progress)
		
		if self.DestinationGateway then
			self.DestinationGateway:SetWorkProgress(progress)
		end
	end,
	

	-- Plays the teleport-in-progress death effect
	PlayGateExplodeEffect = function(self)
		-- fork a thread because of the effects used we need to sleep a few seconds for timing
		ForkThread(self.GateDeathEffectThread, self)
	end,
	
	
	-- Main thread function for playing gate death effects
	GateDeathEffectThread = function(self)
	
		local fx = nil
		local fxBag = { }
		
		for k, v in self.GateExplodeEffect do
			for k, e in v.Emitters do
				fx = CreateEmitterAtEntity(self, self:GetArmy(), e):OffsetEmitter(v.Offset.x, v.Offset.y, v.Offset.z):ScaleEmitter(v.Scale)
				table.insert(fxBag, fx)
			end
		end
	
		WaitSeconds(3)
		
		for k, v in fxBag do
			v:Destroy()
		end
	end,
		

	-- Plays the teleportation effect
	PlayGateTeleportEffect = function(self)

		-- upwards funnel
		for k, v in EffectTemplate.SIFInainoHit02 do
			CreateEmitterAtEntity(self, self:GetArmy(), v):ScaleEmitter(0.7)
			CreateEmitterAtEntity(self.DestinationGateway, self.DestinationGateway:GetArmy(), v):ScaleEmitter(0.7)
		end
		
		self:CreateProjectile('/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 2, 0, nil, nil, nil):SetCollision(false)
		self.DestinationGateway:CreateProjectile('/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 2, 0, nil, nil, nil):SetCollision(false)

		WaitSeconds(2.15)

		-- flash!
		for k, v in EffectTemplate.SIFInainoHit01 do
			CreateEmitterAtEntity(self, self:GetArmy(), v):ScaleEmitter(1.15)
			CreateEmitterAtEntity(self.DestinationGateway, self.DestinationGateway:GetArmy(), v):ScaleEmitter(1)
		end
		
	end,


	-- Initiates the "teleport charging" effect on gateways involved
	StartGateChargeEffect = function(self)
		local army = self:GetArmy()

		self.TeleportChargeBag = { }
		
		for k, v in self.TeleportChargeEffect do
			for k, e in v.Emitters do
				local fx = CreateEmitterAtEntity(self, army, e):OffsetEmitter(v.Offset.x, v.Offset.y, v.Offset.z):ScaleEmitter(v.Scale)
				table.insert(self.TeleportChargeBag, fx)
			end
		end

		-- sending gateway tells remote gateway to charge up
		if self.DestinationGateway then
			self.DestinationGateway:StartGateChargeEffect()
		end
	end,


	-- Terminates the teleport charging effects
	EndGateChargeEffect = function(self)
		
		if self.TeleportChargeBag then
			for k, v in self.TeleportChargeBag do
				v:Destroy()
			end
		end

		self.TeleportChargeBag = nil
		
		-- sending gateway tells remote gateway to stop charging
		if self.DestinationGateway then
			self.DestinationGateway:EndGateChargeEffect()
		end
	end,
	
	
	-- Plays the teleport sound at both gateways
	PlayTeleportSound = function(self)
	
		self:PlaySound(self.TeleportSound)
		
		if self.DestinationGateway then
			-- NOTE: this doesn't work. Only the sending gateway plays a sound
			-- No idea why...
			self.DestinationGateway:PlaySound(self.TeleportSound)
		end
	
	end,


	-- Main teleportation function thread
	TeleportUnits = function(self, warpUnits, destinationGate)

		self.TeleportInProgress = true
		destinationGate.TeleportInProgress = true
	
		self.TeleportingUnits = warpUnits
		self:CreateTeleportLink(destinationGate)
		self:StartGateChargeEffect()

		local massCost = 0
		local energyCost = self.BaseEnergyCost
		local timeCost = self.BaseChargeTime

		-- calculate economic costs for teleport
		for k, v in warpUnits do
			if v.GetPosition then

				IssueStop( { v } )
				IssueClearCommands( { v } )
				v:SetImmobile(true)

				v:PlayScaledTeleportChargeEffects()

				local cats = v:GetBlueprint().Categories
			
				-- COMMAND is first because SCUs have both a COMMAND and a TECH3 category
				if table.find(cats, 'COMMAND') or table.find(cats, 'SUBCOMMANDER') then
					energyCost = energyCost + self.ResourceCosts.Energy.COMMAND

				elseif table.find(cats, 'TECH1') then
					energyCost = energyCost + self.ResourceCosts.Energy.T1
					
				elseif table.find(cats, 'TECH2') then
					energyCost = energyCost + self.ResourceCosts.Energy.T2

				elseif table.find(cats, 'TECH3') then
					energyCost = energyCost + self.ResourceCosts.Energy.T3

				elseif table.find(cats, 'EXPERIMENTAL') then
					energyCost = energyCost + self.ResourceCosts.Energy.T4
				else
					LOG("~Found UNKNOWN unit!")
				end
			end
		end

		LOG("~Calculated time cost: " .. timeCost)
		LOG("~Teleport energy cost (per second): " .. energyCost)

		-- we want cost PER SECOND, so multiply by time
		energyCost = energyCost * timeCost

		LOG("~Energy cost per second (total): " .. energyCost)

		LOG('~Adding econ event')
		self.TeleportDrain = CreateEconomyEvent(self, energyCost, massCost, timeCost, self.UpdateTeleportProgress)

		LOG('~Waiting for econ event')
		WaitFor(self.TeleportDrain)

		LOG('~Starting transport sequence')
		
		if self.TeleportDrain then
			RemoveEconomyEvent(self, self.TeleportDrain)
			self.TeleportDrain = nil
		end

		self:UpdateTeleportProgress(0.0)

		local srcGatePos = self:GetPosition()
		local dstGatePos = self.DestinationGateway:GetPosition()
		LOG(string.format("~Source gateway position: [%f, %f, %f]", srcGatePos.x, srcGatePos.y, srcGatePos.z))
		LOG(string.format("~Destination gateway position: [%f, %f, %f]", dstGatePos.x, dstGatePos.y, dstGatePos.z))

		self:PlayTeleportSound()
		
		self:EndGateChargeEffect()
		self:PlayGateTeleportEffect()
		
		self:PlayScaledTeleportInEffects()
		self.DestinationGateway:PlayScaledTeleportInEffects()

		-- the main teleport loop. Moves all units to the destination gate
		for	k, v in	warpUnits do

			-- no rides for units killed during charge-up
			if v:IsDead() then continue end

			-- figure out the position of the unit relative to the sending gate, and use that relative position
			-- offset by the receiving gate's position to determine the final location to teleport a unit
			if v.GetPosition then
				local curPos = v:GetPosition()

				local xOffset = curPos.x - srcGatePos.x
				local yOffset = curPos.y - srcGatePos.y
				local zOffset = curPos.z - srcGatePos.z
				
				local newPos = { dstGatePos.x + xOffset, dstGatePos.y + yOffset, dstGatePos.z + zOffset }

				v:CleanupTeleportChargeEffects()
				v:PlayScaledTeleportOutEffects()

				Warp(v,	newPos, v:GetOrientation())

				v:PlayScaledTeleportInEffects()
				v:CleanupTeleportChargeEffects()
				v:SetImmobile(false) -- this is important
			end
		end

		self:RemoveTeleportLink()

		-- cleanup
		self.TeleportingUnits = nil
		self.TeleportThread = nil
		self.TeleportDrain = nil
		
		self.TeleportInProgress = false
		destinationGate.TeleportInProgress = false
		
		LOG("~Transport sequence complete!")
	end,

	
	-- Creates a link between this gateway and a destination gateway
	CreateTeleportLink = function(self, dstGate)
		
		self.DestinationGateway = dstGate
		dstGate.SourceGateway = self

	end,


	-- Removes a link between gateways
	RemoveTeleportLink = function(self)

		local otherGate = self.DestinationGateway
	
		self.DestinationGateway = nil
		self.SourceGateway = nil
		
		if otherGate then
			otherGate.DestinationGateway = nil
			otherGate.SourceGateway = nil
		end

	end,

	
	-- Teleport GUI button
	OnScriptBitSet = function(self,	bit)
	    StructureUnit.OnScriptBitSet(self, bit)
	    if bit == 1 then
		ForkThread(self.WarpNearbyUnits, self, 48)
        	ForkThread(function()
    		    self.Rotator = CreateRotator(self, 'Spinner', 'y', nil, 500, 250, 500)
        	    self.Rotator:SetTargetSpeed(500)
        	    WaitSeconds(35)
        	    self.Rotator:SetTargetSpeed(0)
        	end)
	    end
	    self:SetScriptBit('RULEUTC_WeaponToggle', false)
	end,
}
