--if false then
-- function MYLOG (unit,plogstr)
  -- if unit:GetUnitId()=='ual0309' then
    -- LOG(plogstr)
  -- end
-- end
------------------------------------------
local CRFAoldRemoveBuff=RemoveBuff
function RemoveBuff(unit, buffName, removeAllCounts, instigator)
    local def = Buffs[buffName]
    if def and def.BuffType == 'COMMANDERAURA' then
        --MYLOG(unit,'Rm0 '..repr(def))
        if def.RPReplaced then
            for key, bufftbl in unit.Buffs.BuffTable['REG_INSTEAD_OF_RP'] do
                --MYLOG(unit,'Rm1 remove '..repr(key))
                CRFAoldRemoveBuff(unit, key, true)
            end
        else
            local instBuff=buffName..'_NoRP'
            if HasBuff(unit, instBuff) then
                --MYLOG(unit,'Rm1.5 remove '..repr(instBuff))
                RemoveBuff(unit, instBuff, true)
            end
        end
    end
    CRFAoldRemoveBuff(unit, buffName, removeAllCounts, instigator)
end

local CRFAoldApplyBuff=ApplyBuff
function ApplyBuff(unit, buffName, instigator)
    local def = Buffs[buffName]
    if not(unit:IsDead()) and def and def.BuffType == 'COMMANDERAURA' then
        if def.EntityCategory then
            local cat = ParseEntityCategory(def.EntityCategory)
            if not EntityCategoryContains(cat, unit) then
                return
            end
        end
        local ubt = unit.Buffs.BuffTable
        --MYLOG(unit,'AB 0:'..repr(def))
        if def.Stacks == 'REPLACE' then
            if ubt[def.BuffType] then
                --MYLOG(unit,'AB 1:'..repr(ubt[def.BuffType]))
                local lprior = def.Priority or 0
                for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do
                --MYLOG(unit,'AB 2 Prior:'..repr(Buffs[key].Priority))
                    if (Buffs[key].Priority or 0) <= lprior then
                        --MYLOG(unit,'AB 2.5 Remove:'..repr(key))
                        RemoveBuff(unit, key, true)
                    else
                        return
                    end
                end
            end
            local newbuf,regenbuf = ReplaceRPBuff(buffName, unit)
            --MYLOG(unit,'AB 3 new: '..repr(Buffs[newbuf]))
            --MYLOG(unit,'AB 4 reg: '..repr(Buffs[regenbuf]))
            --MYLOG(unit,'ApB 5 old: '..repr(Buffs[buffName]))
            if regenbuf then CRFAoldApplyBuff(unit, regenbuf, instigator) end
            CRFAoldApplyBuff(unit, newbuf, instigator)
            return
        end    
    end
    CRFAoldApplyBuff(unit, buffName, instigator)
end


#--we replace buff 
#buff{
#Name = 'BlahBlahBlah',
#BuffType = 'COMMANDERAURA',
#...
#Affects={RegenPercent={...},...}
#}
#--with:
#buff{
#Name = 'BlahBlahBlah_NoRP',
#BuffType = 'COMMANDERAURA',
#Stacks = 'REPLACE',
#RPReplaced = true,
#...
#Affects={...}
#}
#--and this
#buff{
#Name = 'INSTEAD_OF_RP_REGxxx',
#BuffType = 'REG_INSTEAD_OF_RP',
#Stacks = 'REPLACE',
#Affects={Regen={Add = xxx}}
#}


function ReplaceRPBuff(buffName, unit)
  local buffDef = Buffs[buffName]
  local buffAffects = buffDef.Affects
  
  for atype, vals in buffAffects do
    if atype == 'RegenPercent' then
        local lreg = unit:GetMaxHealth()*vals.Mult
        lreg = GetQuantedRegen(lreg, vals.Ceil, vals.Floor)
        local newbuffname = buffDef.Name..'_NoRP'
        if not Buffs[newbuffname] then
            local newbuff=deepcopy(buffDef)
            newbuff.Affects.RegenPercent=nil
            newbuff.Name = newbuffname
            newbuff.DisplayName = newbuffname
            newbuff.Stacks = 'REPLACE'
            newbuff.RPReplaced = true
            BuffBlueprint(newbuff)
            --MYLOG(unit,'RepBUF1 '..repr(newbuff))
            newbuff=nil
        end
        local regenbuffname = 'INSTEAD_OF_RP_REG'..lreg        
        if not Buffs[regenbuffname] then
            BuffBlueprint{
                Name = regenbuffname,
                DisplayName = regenbuffname,
                BuffType = 'REG_INSTEAD_OF_RP',
                Stacks = 'REPLACE',
                Affects = {Regen={Add = lreg, Mult = 1.0}},
            }
            --MYLOG(unit,'RepBUF2 '..repr(Buffs[regenbuffname]))
        end
        return newbuffname, regenbuffname
    end
  end
  return buffName, nil
end

--округляем регенерацию до кванта, чтобы уменьшить количество уникальных бафов
function GetQuantedRegen(preg,pceil,pfloor)
    local quantum = 10
    if preg <= 6 then quantum = 1
    elseif preg <= 30 then quantum = 3
    elseif preg <= 60 then quantum = 6
    elseif preg <= 120 then quantum = 12
    elseif preg <= 240 then quantum = 24
    elseif preg <= 490 then quantum = 50
    elseif preg <= 990 then quantum = 100
    else quantum = 150
    end
    preg=math.floor(preg/quantum+0.5)*quantum
    if preg > pceil then preg = pceil end
    if preg < pfloor then preg = pfloor end
    return preg
end

--создает копию таблицы, т.к. простое присваивание просто создает еще одну ссылку на таблицу, а нам нужен новый buff
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-------------------------
--end