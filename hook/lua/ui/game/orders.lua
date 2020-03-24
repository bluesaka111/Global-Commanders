#*****************************************************************************
#* File: lua/modules/ui/game/orders.lua
#* Author: Chris Blackwell
#* Summary: Unit orders UI
#*
#* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#*****************************************************************************


local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Grid = import('/lua/maui/grid.lua').Grid
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua')
local Prefs = import('/lua/user/prefs.lua')
local Keymapping = import('/lua/keymap/defaultKeyMap.lua').defaultKeyMap
local CM = import('/lua/ui/game/commandmode.lua')
local UIMain = import('/lua/ui/uimain.lua')

ModUnitOrders = {}

Grid_Params = {
	Grid = { 
		numSlots = 24,
		firstAltSlot = 7,
		vertRows = 6,
		horzRows = 4,
		
		---------------------
		--colums & rows
		vertCols = 4,
		horzCols = 6,
		
		---------------------
		--icon size
		iconsize = { 
			height = 48,
			width = 48,
		},
			
		---------------------
		--panel size
		panelsize = { 
			width = 315,
			height = 120,
		},
	},
	
	Order_Slots = {
		numSlots = 12,
		firstAltSlot = 7,
		vertRows = 6,
		horzRows = 2,
		
		---------------------
		--colums & rows
		vertCols = 2,
		horzCols = 6,
		
		---------------------
		--icon size
		iconsize = { 
			height = 48,
			width = 48,
		},
			
		---------------------
		--panel size
		panelsize = { 
			width = 315,
			height = 120,
		},
	}
}

local InitCapStateDone = false
local OrderNum = 0

local function OrderLayout_Params2(key)
	local Params = UIUtil.OrderLayout_Params(key)
	
	if Params then 
		return Params
	else
		return false
	end
end

local function ExraToggleInit(control, unitList)
	local result = nil
    local mixed = false
	
	if control._data.pulse then 
		result = false
	else
		for i, v in unitList do
			local unitdata = UnitData[v:GetEntityId()]
			local thisUnitStatus = unitdata[control._data.toggle_name .. '_state']
		
			if result == nil then
				result = thisUnitStatus
			else
				if thisUnitStatus != result then
					mixed = true
					result = true
					break
				end
			end
		end
	end
	
    if mixed then
        control._mixedIcon = Bitmap(control, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        LayoutHelpers.AtRightTopIn(control._mixedIcon, control, -2, 2)
    end
    control:SetCheck(result)
end

local function ExtraToggleButtonOrderBehavior(self, modifiers)
	if self._mixedIcon then
        self._mixedIcon:Destroy()
        self._mixedIcon = nil
    end
	
	if self._data.toggle_name then 
		
		local state
		local checkstate = self:IsChecked()
		
		if self._data.pulse then
			state = false
			checkstate = true
		else
		
			if table.getsize(currentSelection) > 1 then 
				if checkstate then
					state = true
				else 
					state = false
				end
			else
				local Data = UnitData[currentSelection[1]:GetEntityId()]
				if Data[self._data.toggle_name] then 
					if Data[self._data.toggle_name ..'_state'] then 
						state = false
					else
						state = true
					end
				end
			end
		end
		
		if state != checkstate then 
			local Params = {}
			Params.Units = {}
			Params.ToggleState = state
			Params.BitName = self._data.toggle_name
	
			for i, u in currentSelection do
				local Data = UnitData[u:GetEntityId()]
				if Data[self._data.toggle_name] then 
					table.insert(Params.Units, u:GetEntityId())
				end
			end
	
			local TTB = { Func = 'ToggleTheBit', Args = { Params = Params } }
			SimCallback(TTB, true)
		
			if controls.mouseoverDisplay.text then
				controls.mouseoverDisplay.text:SetText(self._curHelpText)
			end
		
			if not self._data.pulse then 
				Checkbox.OnClick(self)
			end
		end
	end
end

local function ExtraAbilityButtonBehavior(self, modifiers)
    if self:IsChecked() then
        CM.EndCommandMode(true)
    else
        local modeData = {
            name="RULEUCC_Script", 
            AbilityName = self._data.abilityname or self._script,
            TaskName = self._script,
			cursor = self._data.cursor,
			OrderIcon = self._data.OrderIcon,
			ExtraInfo = self._data.ExtraInfo,
			MouseDecal = self._data.MouseDecal,
			Usage = self._data.usage,
			SelectedUnits = GetSelectedUnits(),
        }
				
        CM.StartCommandMode("order", modeData)
    end
end

function AddUnitOrder(data)
	local unit = GetUnitById(data.Entity)
	local params = data.Params	
	
	ModUnitOrders[data.Entity] = { Params = params, }
end

function RemoveUnitOrder(data)
	if ModUnitOrders[data.Entity] then 
		ModUnitOrders[data.Entity] = nil
	end
end

numSlots = Grid_Params.Grid.numSlots
firstAltSlot = Grid_Params.Grid.firstAltSlot
vertRows = Grid_Params.Grid.vertRows
horzRows = Grid_Params.Grid.horzRows

vertCols = Grid_Params.Grid.vertCols
horzCols = Grid_Params.Grid.horzCols

do

--overriden function because i cant figure out how to hook it correctly
function CreateOrderGlow(parent)
    controls.orderGlow = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.orderGlow, parent)
    controls.orderGlow:SetAlpha(0.0)
    controls.orderGlow:DisableHitTest()
    controls.orderGlow:SetNeedsFrameUpdate(true)
    local alpha = 0.0
    local incriment = true
    controls.orderGlow.OnFrame = function(self, deltaTime)
        if incriment then
		--1.2
            alpha = alpha + (deltaTime * 0.20)
        else
            alpha = alpha - (deltaTime * 0.20)
        end
        if alpha < 0 then
            alpha =  0.0
            incriment = true
        end
		--.4
        if alpha > .0300 then
            alpha = .0300
            incriment = false
        end
        controls.orderGlow:SetAlpha(alpha)
    end     
end

--overridden function to facilitate ability icons and decals.
--new cursors can be added to your skins table, have a look a skins.lua for the format.
--ability button behaviour
function AbilityButtonBehavior(self, modifiers)
    if self:IsChecked() then
        CM.EndCommandMode(true)
    else
		--anything in the modeData is passed to userscriptcommand.lua from commandmode.lua
        local modeData = {
            name="RULEUCC_Script", 
            AbilityName = self._data.abilityname or self._script,
            TaskName = self._script,
			cursor = self._data.cursor,
			OrderIcon = self._data.OrderIcon,
			ExtraInfo = self._data.ExtraInfo,
			MouseDecal = self._data.MouseDecal,
			Usage = self._data.usage,
			SelectedUnits = GetSelectedUnits(),
        }
		
		CM.StartCommandMode("order", modeData)
    end
end

--override, i needed to create the buttons off the bat with the correct size.
local oldCreateOrderButtonGrid = CreateOrderButtonGrid
function CreateOrderButtonGrid()
	controls.orderButtonGrid = Grid(controls.bg, Grid_Params.Grid.iconsize.width, Grid_Params.Grid.iconsize.height)
	controls.orderButtonGrid:SetName("Orders Grid")
	controls.orderButtonGrid:DeleteAll()		
end

local oldCreateFirestatePopup = CreateFirestatePopup
function CreateFirestatePopup(parent, selected)
	local bg = oldCreateFirestatePopup(parent, selected)
	
	--resize the popup icons
	for _, btn in bg.buttons do
		btn.Width:Set(Grid_Params.Order_Slots.iconsize.width)
		btn.Height:Set(Grid_Params.Order_Slots.iconsize.height)
	end
	
	return bg
end

local oldAddOrder = AddOrder
function AddOrder(orderInfo, slot, batchMode)
	checkbox = oldAddOrder(orderInfo, slot, batchMode)
	
	--resize our icons
	checkbox.Width:Set(Grid_Params.Order_Slots.iconsize.width)
	checkbox.Height:Set(Grid_Params.Order_Slots.iconsize.height)
	
	return checkbox

end


local oldSelection = {}
-- called by gamemain when new orders are available, 
local OldSetAvailableOrders = SetAvailableOrders
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
	
	--reset our grid. important.
	ResetGrid()
	
	--only show the the orders panel IF we have some selected units.. 
	--this saves us some ui show time, as it only fires now if we have selected units. 
	if table.getn(newSelection) > 0 then 
		currentSelection = newSelection
		
		for index, unit in currentSelection do
			local tempBP = UnitData[unit:GetEntityId()]
			
			if tempBP then
				for ToggleName, Param in tempBP do	
					if defaultOrdersTable[ToggleName] and Param then 
						table.insert(availableToggles, ToggleName)
					end	
				end
			end
		end	
		
		-- :( override... sorry i need to count order slots before we add the toggles.. 
		SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
	else
		if controls.bg.Mini then
			controls.bg.Mini(true)
		end
	end
end

--had to override this function
function SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
	
	# save new selection
	currentSelection = newSelection
	
	local TotalSlotsNeeded = 0
	local numValidOrders = 0
	local HighestSlot = 12
		
	local AddedAbilities = {}
	if currentSelection then
        for index, unit in currentSelection do
            local tempBP = UnitData[unit:GetEntityId()]			
            if tempBP and tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
                    if ability.Active != false and not AddedAbilities[abilityIndex] then
					
						--LOG('adding ability ' .. repr(ability))
						AddedAbilities[abilityIndex] = true
                        TotalSlotsNeeded = TotalSlotsNeeded + 1
						
						if ability.preferredSlot > HighestSlot then 
							HighestSlot = ability.preferredSlot
						end

                    end
                end
            end
        end
    end
	
	
	
	--clear ALL existing orders
    orderCheckboxMap = {}
    controls.orderButtonGrid:DestroyAllItems(true)
	
    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)
    
    -- look in blueprints for any icon or tooltip overrides
    -- note that if multiple overrides are found for the same order, then the default is used
    -- the syntax of the override in the blueprint is as follows (the overrides use same naming as in the default table above):
    -- In General table
    -- OrderOverrides = {
    --     RULEUTC_IntelToggle = {
    --         bitmapId = 'custom',
    --         helpText = 'toggle_custom',
    --     },
    --  },
    -- 
    local orderDiffs
    
    for index, unit in newSelection do
        local overrideTable = unit:GetBlueprint().General.OrderOverrides
        if overrideTable then
            for orderKey, override in overrideTable do
                if orderDiffs == nil then
                    orderDiffs = {}
                end
                if orderDiffs[orderKey] != nil and (orderDiffs[orderKey].bitmapId != override.bitmapId or orderDiffs[orderKey].helpText != override.helpText) then
                    -- found order diff already, so mark it false so it gets ignored when applying to table
                    orderDiffs[orderKey] = false
                else
                    orderDiffs[orderKey] = override
                end
            end
        end
    end
    
    -- apply overrides
    if orderDiffs != nil then
        for orderKey, override in orderDiffs do
            if override and override != false then
                if override.bitmapId then
                    standardOrdersTable[orderKey].bitmapId = override.bitmapId
                end
                if override.helpText then
                    standardOrdersTable[orderKey].helpText = override.helpText
                end
            end
        end
    end
        
	--Lets see how many orders we have, and create our orders panel accordingly.
	
	for i, v in availableOrders do
		if standardOrdersTable[v] then
			numValidOrders = numValidOrders + 1
			
			if standardOrdersTable[v].preferredSlot and standardOrdersTable[v].preferredSlot > HighestSlot then 
				HighestSlot = standardOrdersTable[v].preferredSlot
			end
			
		end
	end
	
	for i, v in availableToggles do
		if standardOrdersTable[v] then
			numValidOrders = numValidOrders + 1
			
			if standardOrdersTable[v].preferredSlot and standardOrdersTable[v].preferredSlot > HighestSlot then 
				HighestSlot = standardOrdersTable[v].preferredSlot
			end
		end
	end
		
	local assitingUnitList = {}
    local podUnits = {}
    if table.getn(currentSelection) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection) or EntityCategoryFilterDown(categories.POD, currentSelection)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection)
        local Pods = EntityCategoryFilterDown(categories.POD, currentSelection)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
             TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
        if assistingUnits[2] then
             TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
    end
	
	---------------------------------------------------------------------------------------
	--count our disabled buttons.
    local common = table.getsize(commonOrders)
	local sub = 0
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end   # skip any orders we don't have in our table
        if commonOrders[availOrder] then
            sub = sub + 1
        end
    end
	local commonsub = common - sub

	---------------------------------------------------------------------------------------
	TotalSlots = (numValidOrders + TotalSlotsNeeded + commonsub)
	
	--setup our grid params
	--SetGridParams(TotalSlots, true)
	--SetGridParams(HighestSlot, true)
	
	if HighestSlot > TotalSlots then 
		SetGridParams(HighestSlot, true)
	else
		SetGridParams(TotalSlots, true)
	end
	
	--LOG('TotalSlots ' .. repr(TotalSlots))
	
	--Changed this, if there is enough slots for all orders show the orders else LOG a warning and just show an empty panel.
	--Were only going to populate the orders panel IF there is enough slots.
	if TotalSlots <= Grid_Params.Grid.numSlots then		
		CreateCommonOrders(availableOrders)
		CreateAltOrders(availableOrders, availableToggles, currentSelection)
		controls.orderButtonGrid:EndBatch()
	else
		WARN('ORDERS --> NOT ENOUGH SLOTS, REQUESTED:> ' .. repr(TotalSlots) .. ' MAX:> ' .. repr(Grid_Params.Grid.numSlots))
	end
    
	--not needed but kept in til the end. as i hide the panel in the SetAvailableOrders function if there is no selection
	if table.getn(currentSelection) == 0 and controls.bg.Mini then
		controls.bg.Mini(true)
	elseif controls.bg.Mini then
		controls.bg.Mini(false)
	end
end


--overridden function.. 	
function CreateAltOrders(availableOrders, availableToggles, units)

    --Look for units in the selection that have abilities
    --If any are found, add the ability information to the standard order table
	--re-written script part.
	 if units then
        for index, unit in units do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP and tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
					-- needed to add this table.find into this loop, so that all the orders slots are NOT filled with custom abilities
					--also we dont want to add duplicate orders.
					--we also merge the ability table with the units sync table incase any values have changed.
                    if ability.Active != false and not table.find(availableOrders, abilityIndex) then
												
                        table.insert(availableOrders, abilityIndex)
                        standardOrdersTable[abilityIndex] = table.merged(import('/lua/abilitydefinition.lua').abilities[abilityIndex], ability)						
                        standardOrdersTable[abilityIndex].behavior = AbilityButtonBehavior
                    end
                end
            end
        end
    end
	
    local assitingUnitList = {}
    local podUnits = {}
    if table.getn(units) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units) or EntityCategoryFilterDown(categories.POD, units)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units)
        local Pods = EntityCategoryFilterDown(categories.POD, units)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
            table.insert(availableOrders, 'DroneL')
            assitingUnitList['DroneL'] = assistingUnits[1]
        end
        if assistingUnits[2] then
            table.insert(availableOrders, 'DroneR')
            assitingUnitList['DroneR'] = assistingUnits[2]
        end
    end
    
    # determine what slots to put alt orders
    # we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    local usedSpecials = {}
    for index, availOrder in availableOrders do
        if standardOrdersTable[availOrder] then 
            local preferredSlot = standardOrdersTable[availOrder].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availOrder)
        else
            if specialOrdersTable[availOrder] != nil then
                specialOrdersTable[availOrder].behavior()
                usedSpecials[availOrder] = true
            end
        end
    end

    for index, availToggle in availableToggles do
        if standardOrdersTable[availToggle] then 
            local preferredSlot = standardOrdersTable[availToggle].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availToggle)
        else
            if specialOrdersTable[availToggle] != nil then
                specialOrdersTable[availToggle].behavior()
                usedSpecials[availToggle] = true
            end
        end
    end

    for i, specialOrder in specialOrdersTable do
        if not usedSpecials[i] and specialOrder.notAvailableBehavior then
            specialOrder.notAvailableBehavior()
        end
    end

    # now go through that table and determine what doesn't fit and look for slots that are empty
    # since this is only alt orders, just deal with slots 7-12
    local orderInSlot = {}
    
    # go through first time and add all the first entries to their preferred slot
    for slot = Grid_Params.Grid.firstAltSlot,Grid_Params.Grid.numSlots do
        if desiredSlot[slot] then
            orderInSlot[slot] = desiredSlot[slot][1]
        end
    end

    # now put any additional entries wherever they will fit
    for slot = Grid_Params.Grid.firstAltSlot,Grid_Params.Grid.numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = Grid_Params.Grid.firstAltSlot, Grid_Params.Grid.numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        WARN("No free slot for order: " .. item)
                        # could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end

    # now map it the other direction so it's order to slot
    local slotForOrder = {}
    for slot, order in orderInSlot do
        slotForOrder[order] = slot
    end
	
   -- LOG('available orders ' .. repr(availableOrders) .. ' Order in slot ' .. repr(orderInSlot) .. ' order for slot ' .. repr(slotForOrder))
    
    # create the alt order buttons
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end   # skip any orders we don't have in our table
        if not commonOrders[availOrder] then
            local orderInfo = standardOrdersTable[availOrder] or AbilityInformation[availOrder]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availOrder], true)

            orderCheckbox._order = availOrder
            
            if standardOrdersTable[availOrder].script then
                orderCheckbox._script = standardOrdersTable[availOrder].script
            end
            
            if assitingUnitList[availOrder] then
                orderCheckbox._unit = assitingUnitList[availOrder]
            end
            
            if podUnits[availOrder] then
                orderCheckbox._pod = podUnits[availOrder]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availOrder] = orderCheckbox
        end
    end

    for index, availToggle in availableToggles do
        if not standardOrdersTable[availToggle] then continue end   # skip any orders we don't have in our table
        if not commonOrders[availToggle] then
            local orderInfo = standardOrdersTable[availToggle] or AbilityInformation[availToggle]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availToggle], true)

            orderCheckbox._order = availToggle
            
            if standardOrdersTable[availToggle].script then
                orderCheckbox._script = standardOrdersTable[availToggle].script
            end
            
            if assitingUnitList[availToggle] then
                orderCheckbox._unit = assitingUnitList[availToggle]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availToggle] = orderCheckbox
        end
    end
end

function Get_Grid_Params()
	return Grid_Params
end

--important function, it sets the icons and panel to the correct size for the amount of orders on the panel.
--ive added support for upto 24 order icons, i dont think we will ever need more than this.
function SetGridParams(NumOrders, update)
	OrderNum = NumOrders
	local params = {}
		
	if NumOrders <= 12 then 
		--WARN('SETTING SLOTS TO 12 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
		Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['12Slots'] or SlotIconsTable['bottom']['12Slots']
		params = SlotIconsTable[layoutVar]['12Slots'] or SlotIconsTable['bottom']['12Slots']
	elseif NumOrders > 12 and NumOrders <= 18 then 
		--WARN('SETTING SLOTS TO 18 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
		Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['18Slots'] or SlotIconsTable['bottom']['18Slots']
		params = SlotIconsTable[layoutVar]['18Slots'] or SlotIconsTable['bottom']['18Slots']
	elseif NumOrders > 18 and NumOrders <= 24 then 
		--WARN('SETTING SLOTS TO 24 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
		Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
		params = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
	else
		--WARN('SETTING SLOTS TO 24 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
		Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
		params = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
	end
	
	Grid_Params.Order_Slots.layout = layoutVar
	Grid_Params.Order_Slots.NumOrders = NumOrders
		
	if update then 
		--Lets resize the buttons and order panel.
		
		--buttons
		controls.orderButtonGrid._itemWidth = params.iconsize.width
		controls.orderButtonGrid._itemHeight = params.iconsize.height
		
		--panel
		controls.bg.Width:Set(params.panelsize.width)
		controls.bg.Height:Set(params.panelsize.height)
		
		controls.orderButtonGrid:_CalculateVisible()
	end
end

local oldSetLayout = SetLayout
function SetLayout(layout)	
	oldSetLayout(layout)
end

function ResetGrid()
	OrderNum = 0
	Grid_Params = {
		Grid = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 48,
				width = 48,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 315,
				height = 120,
			},
		},
	
		Order_Slots = {
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 48,
				width = 48,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 315,
				height = 120,
			},
		}
	}
end

SlotIconsTable = {
	bottom = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 40,
				width = 40,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 265,
				height = 100,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 40,
				width = 40,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 265,
				height = 145,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 200,
				height = 145,
			},
		},
	},
	
	left = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 70,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 95,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 116, -- when this value is > 116 the construction bar doesnt close correctly in left layout.
			},
		},
	},
	
	right = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 48,
				width = 48,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 315,
				height = 120,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 37,
				width = 37,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 245,
				height = 145,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 200,
				height = 145,
			},
		},
	},
	
	dom_bottom = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 80,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 110,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 140,
			},
		},
	},
}

--move this table to the initialize file and merge it.. with other mods icons tables.. 
--so they can add there own layouts to this table to show the correct icon/panel sizes
--remove the things that are not needed.. 
SlotIconsTable1 = {
	bottom = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 48,
				width = 48,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 315,
				height = 120,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 37,
				width = 37,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 245,
				height = 145,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 200,
				height = 145,
			},
		},
	},
	
	left = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 70,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 95,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 185,
				height = 116, -- when this value is > 116 the construction bar doesnt close correctly in left layout.
			},
		},
	},
	
	right = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 48,
				width = 48,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 315,
				height = 120,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 37,
				width = 37,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 245,
				height = 145,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 200,
				height = 145,
			},
		},
	},
	
	dom_bottom = { 
		['12Slots'] = { 
			numSlots = 12,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 80,
			},
		},
	
		['18Slots'] = { 
			numSlots = 18,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 110,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 7,
			vertRows = 6,
			horzRows = 4,
		
			---------------------
			--colums & rows
			vertCols = 4,
			horzCols = 6,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 140,
			},
		},
	},
}




end