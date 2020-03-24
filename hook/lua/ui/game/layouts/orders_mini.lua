
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Grid_Params = import('/lua/ui/game/orders.lua').Get_Grid_Params()

numSlots = Grid_Params.Grid.numSlots
firstAltSlot = Grid_Params.Grid.firstAltSlot
vertRows = Grid_Params.Grid.vertRows
horzRows = Grid_Params.Grid.horzRows
vertCols = Grid_Params.Grid.vertCols
horzCols = Grid_Params.Grid.horzCols

function SetLayout()
    local controls = import('/lua/ui/game/orders.lua').controls
		
	controls.bg:SetTexture(UIUtil.SkinnableFile('/game/orders-panel/order-panel_bmp.dds'))
	
	LayoutHelpers.AtLeftIn(controls.bg, controls.controlClusterGroup, 17)
	LayoutHelpers.AtBottomIn(controls.bg, controls.controlClusterGroup, 3)

    LayoutHelpers.ResetRight(controls.bg)
    LayoutHelpers.ResetTop(controls.bg)
    
    controls.bracket:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_t.dds'))
    LayoutHelpers.AtLeftIn(controls.bracket, controls.bg, -17)
    LayoutHelpers.AtTopIn(controls.bracket, controls.bg, -2)
    LayoutHelpers.ResetBottom(controls.bracket)
    LayoutHelpers.ResetRight(controls.bracket)
    
    controls.bracketMax:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_b.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMax, controls.bracket)
    LayoutHelpers.AtBottomIn(controls.bracketMax, controls.bg, -2)
    
    controls.bracketMid:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_m.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMid, controls.bracket, 7)
    controls.bracketMid.Top:Set(controls.bracket.Bottom)
    controls.bracketMid.Bottom:Set(controls.bracketMax.Top)
    
    if controls.bracketRightMin then
        controls.bracketRightMin:Destroy()
        controls.bracketRightMax:Destroy()
        controls.bracketRightMid:Destroy()
        
        controls.bracketRightMin = nil
        controls.bracketRightMax = nil
        controls.bracketRightMid = nil
    end
	
	controls.bg.Width:Set(Grid_Params.Order_Slots.panelsize.width)
	controls.bg.Height:Set(Grid_Params.Order_Slots.panelsize.height)
	controls.orderButtonGrid.Width:Set(Grid_Params.Order_Slots.iconsize.width * Grid_Params.Grid.horzCols)
	controls.orderButtonGrid.Height:Set(Grid_Params.Order_Slots.iconsize.height * Grid_Params.Grid.horzRows)
	LayoutHelpers.AtLeftTopIn(controls.orderButtonGrid, controls.bg, 5, 9)
    
	
    controls.orderButtonGrid:AppendRows(Grid_Params.Grid.horzRows)
    controls.orderButtonGrid:AppendCols(Grid_Params.Grid.horzCols)
    
    controls.bg.Mini = function(state)
        controls.bg:SetHidden(state)
        controls.orderButtonGrid:SetHidden(state)
    end
end