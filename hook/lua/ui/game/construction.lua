
#*****************************************************************************
#* File: lua/modules/ui/game/construction.lua
#* Author: Chris Blackwell / Ted Snook
#* Summary: Construction management UI
#*
#* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local SpecialGrid = import('/lua/ui/controls/specialgrid.lua').SpecialGrid
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua').Tooltips
local Prefs = import('/lua/user/prefs.lua')
local EnhanceCommon = import('/lua/enhancementcommon.lua')
local Templates = import('/lua/ui/game/build_templates.lua')
local BuildMode = import('/lua/ui/game/buildmode.lua')
local UnitViewDetail = import('/lua/ui/game/unitviewDetail.lua')

local OLDConstruct = import('/lua/ui/game/construction.lua')
local LOGICConstruction = import('/mods/Global Commanders/hook/lua/ui/game/construction.lua')

#LOG(OLDConstruct.CommonLogic())
#LOG(LOGICConstruction.CommonLogic())
#LOG(LOGICConstruction.OnClickHandler())
#LOGICConstruction.CommonLogic()
		

function CreateTabs(type)
		
		local selection = GetSelectedUnits()
    local iscommander = false
	  if selection[1] then
	  	if EntityCategoryContains(categories.COMMAND,selection[1])
          	or EntityCategoryContains(categories.SUBCOMMANDER,selection[1]) then
			iscommander = true
		end
    end
        
		if type == 'enhancement' and iscommander then
			LOGICConstruction.MYCommonLogic()
		else OLDConstruct.CommonLogic()
		end
		BACKUPCreateTabs(type)
end

function OnRolloverHandler(button, state)
		
    local selection = GetSelectedUnits()
    if selection[1] then
    	if EntityCategoryContains(categories.COMMAND,selection[1]) 
	or EntityCategoryContains(categories.SUBCOMMANDER,selection[1]) then
            button.OnClick = LOGICConstruction.MYOnClickHandler
    	end
    end
    
    local item = button.Data
    if state == 'enter' then
        button.Glow:SetNeedsFrameUpdate(true)
        if item.type == 'item' then
            UnitViewDetail.Show(__blueprints[item.id], sortedOptions.selection[1], item.id)
        elseif item.type == 'enhancement' then
            UnitViewDetail.ShowEnhancement(item.enhTable, item.unitID, item.icon, GetEnhancementPrefix(item.unitID, item.icon), sortedOptions.selection[1])
        end
    else
        button.Glow:SetNeedsFrameUpdate(false)
        button.Glow:SetAlpha(0)
        UnitViewDetail.Hide()
    end
end

function MYCommonLogic()
  #LOG('MYCommonLogic()')
  #LOG(OLDConstruct.CommonLogic())
  #LOG(OLDConstruct.controls)
  
  controls = OLDConstruct.controls
  
    controls.choices.SetControlToType = function(control, type)
        
        local selection = GetSelectedUnits()
        local iscommander = false
	if selection[1] then
	    if EntityCategoryContains(categories.COMMAND,selection[1]) 
            or EntityCategoryContains(categories.SUBCOMMANDER,selection[1]) then
		iscommander = true
	    end
        else OLDConstruct.CommonLogic()
        end
        
        if type == 'arrow' then
            control.Count:SetText('')
            control:Disable()
            control:SetSolidColor('00000000')
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_vert_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Depth:Set(function() return control.Depth() + 5 end)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Icon.Width:Set(30)
            control.StratIcon:SetSolidColor('00000000')
            if control.LowFuel then
            	control.LowFuel:SetAlpha(0, true)
            	control.LowFuel:SetNeedsFrameUpdate(false)
            end
            control.BuildKey = nil
        elseif type == 'spacer' then
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_horizontal_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Width:Set(control.Icon.BitmapWidth)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Count:SetText('')
            control:Disable()
            control.StratIcon:SetSolidColor('00000000')
            control:SetSolidColor('00000000')
            if control.LowFuel then
            	control.LowFuel:SetAlpha(0, true)
            	control.LowFuel:SetNeedsFrameUpdate(false)
            end
            control.BuildKey = nil
        elseif type == 'enhancement' and iscommander then
            control.Icon:SetSolidColor('00000000')
            control:SetNewTextures(OLDConstruct.GetEnhancementTextures(control.Data.unitID, control.Data.icon))
            local _,down,over,_,up = OLDConstruct.GetEnhancementTextures(control.Data.unitID, control.Data.icon)
            control:SetUpAltButtons(up,up,up,up)
            control.tooltipID = LOC(control.Data.enhTable.Name) or 'no description'
            
            local existingEnhancements = EnhanceCommon.GetEnhancements(selection[1]:GetEntityId())
            
            if control.Data.enhTable.ID and existingEnhancements[control.Data.enhTable.ID] == control.Data.enhTable.ID
             #or control.Data.enhTable.BlockedBy and control.Data.enhTable.BlockedBy == existingEnhancements[control.Data.enhTable.BlockedBy]
             then
								control.Data.Selected = false
            		control.Data.Disabled = true
            elseif control.Data.enhTable.Prerequisite and existingEnhancements[control.Data.enhTable.Prerequisite] == control.Data.enhTable.Prerequisite then
								control.Data.Disabled = false
						end
						
						control.mAltToggledFlag = control.Data.Selected
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.Count:SetText('')
            control.StratIcon:SetSolidColor('00000000')
            if control.LowFuel then
            	control.LowFuel:SetAlpha(0, true)
            	control.LowFuel:SetNeedsFrameUpdate(false)
            end
            control.BuildKey = nil
            if control.Data.Disabled then
                control:Disable()
               	if not control.Data.Selected then
                   control.Icon:SetSolidColor('aa000000')
                end
            else
                control:Enable()
            end
        end
    end
end


function MYOnClickHandler(button, modifiers)
		#LOG('MYOnClickHandler')
		
    PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
    local item = button.Data
    
    local selection = GetSelectedUnits()
    local iscommander = false
    if EntityCategoryContains(categories.COMMAND,selection[1])
    or EntityCategoryContains(categories.SUBCOMMANDER,selection[1])
    or EntityCategoryContains(categories.SPECUNIT,selection[1])  then
       	iscommander = true
    end
    
    if item.type == 'enhancement' and iscommander then
        local existingEnhancements = EnhanceCommon.GetEnhancements(selection[1]:GetEntityId())
        
       	if item.enhTable.ID then
       				if existingEnhancements[item.enhTable.ID] != item.enhTable.ID then
				       	local orderData = {
               			TaskName = "EnhanceTask",
               			Enhancement = item.id,
           			}
           			IssueCommand("UNITCOMMAND_Script", orderData, true)
           		else 
           			UIUtil.QuickDialog(GetFrame(0), "Can't upgrade twice", "<LOC _Ok>")
	           	end
	      end
    else OLDConstruct.OnClickHandler(button, modifiers)
    end
end

function BACKUPCreateTabs(type)
    local defaultTabOrder = {}
    local desiredTabs = 0
    if type == 'construction' then
        for index, tab in constructionTabs do
            local i = index
            if not controls.tabs[i] then
                controls.tabs[i] = CreateTab(controls.constructionGroup, tab, OnNestedTabCheck)
            end
            controls.tabs[i].ID = tab
            controls.tabs[i].OnRolloverEvent = function(self, event)
            end
            Tooltip.AddControlTooltip(controls.tabs[i], 'construction_tab_'..tab)
            Tooltip.AddControlTooltip(controls.tabs[i].disabledGroup, 'construction_tab_'..tab..'_dis')
        end
        desiredTabs = table.getsize(constructionTabs)
        defaultTabOrder = {t3=1, t2=2, t1=3}
    elseif type == 'enhancement' then
        local selection = sortedOptions.selection
        local enhancements = selection[1]:GetBlueprint().Enhancements 
        local enhCommon = import('/lua/enhancementcommon.lua')
        local enhancementPrefixes = {Back = 'b-', LCH = 'la-', RCH = 'ra-'}
        local newTabs = {}
        if enhancements.Slots then
            local tabIndex = 1
            for slotName, slotInfo in enhancements.Slots do
                if not controls.tabs[tabIndex] then
                    controls.tabs[tabIndex] = CreateTab(controls.constructionGroup, nil, OnNestedTabCheck)
                end
                controls.tabs[tabIndex].tooltipKey = enhancementTooltips[slotName]
                controls.tabs[tabIndex].OnRolloverEvent = function(self, event)
                    if event == 'enter' then
                        local existing = enhCommon.GetEnhancements(selection[1]:GetEntityId())
                        if existing[slotName] then
                            local enhancement = enhancements[existing[slotName]]
                            local icon = enhancements[existing[slotName]].Icon
                            local bpID = selection[1]:GetBlueprint().BlueprintId
                            local enhName = existing[slotName]
                            local texture = "/textures/ui/common"..GetEnhancementPrefix(bpID, enhancementPrefixes[slotName]..icon)
                            UnitViewDetail.ShowEnhancement(enhancement, bpID, icon, texture, sortedOptions.selection[1])
                        end
                    elseif event == 'exit' then
                        if existing[slotName] then
                            UnitViewDetail.Hide()
                        end
                    end
                end
                Tooltip.AddControlTooltip(controls.tabs[tabIndex], enhancementTooltips[slotName])
                controls.tabs[tabIndex].ID = slotName
                newTabs[tabIndex] = controls.tabs[tabIndex]
                tabIndex = tabIndex + 1
                sortedOptions[slotName] = {}
                for enhName, enhTable in enhancements do
                    if enhTable.Slot == slotName then
                        enhTable.ID = enhName
                        enhTable.UnitID = selection[1]:GetBlueprint().BlueprintId
                        table.insert(sortedOptions[slotName], enhTable)
                    end
                end
            end
            desiredTabs = table.getsize(enhancements.Slots)
        end
        defaultTabOrder = {Back=1, LCH=2, RCH=3}
    end
    while table.getsize(controls.tabs) > desiredTabs do
        controls.tabs[table.getsize(controls.tabs)]:Destroy()
        controls.tabs[table.getsize(controls.tabs)] = nil
    end
    import(UIUtil.GetLayoutFilename('construction')).LayoutTabs(controls)
    local defaultTab = false
    local numActive = 0
    for _, tab in controls.tabs do
        if sortedOptions[tab.ID] and table.getn(sortedOptions[tab.ID]) > 0 then
            tab:Enable()
            numActive = numActive + 1
            if defaultTabOrder[tab.ID] then
                if not defaultTab or defaultTabOrder[tab.ID] < defaultTabOrder[defaultTab.ID] then
                    defaultTab = tab
                end
            end
        else
            tab:Disable()
        end
    end
    if previousTabSet != type or previousTabSize != numActive then
        if defaultTab then
            defaultTab:SetCheck(true)
        end
        previousTabSet = type
        previousTabSize = numActive
    elseif activeTab then
        activeTab:SetCheck(true)
    end
end