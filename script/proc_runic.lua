if not aux.RuneProcedure then
	aux.RuneProcedure = {}
	Runic = aux.RuneProcedure
end
if not Runic then
	Runic = aux.RuneProcedure
end

if not aux.AltarProcedure then
	aux.AltarProcedure = {}
	Altar = aux.AltarProcedure
end
if not Altar then
	Altar = aux.AltarProcedure
end

--CUSTOM CONSTANTS
TYPE_RUNIC						=0x20000000
REASON_RUNE						=0x21000000
EFFECT_RUNE						=0x22000000
COUNTER_RUNIC					=0xc40

TYPE_ALTAR						=0x40000000 
SUMMON_TYPE_ALTAR				=0x41000000
REASON_ALTAR					=0x42000000
CANNOT_BE_ALTER_MATERIAL		=0x43000000


--Procedure - Runic

--c - default
--cc - counter count (if just 1 counter, put 1)
--cat - category (if none then put 'nil')
--sett - settype (if none then put 'nil')
--setc - setcode
--stopt - settype optional (TRUE/FALSE)
--loc - location (if default then put nil)
--runecon - condition for rune
--runetg - target for rune (if none then put 'nil')
--runeop - operation for rune (if none then put 'nil')
function Runic.AddProcedure(c,sett,setc,runecon)
	--Runic Procedure
	c:EnableCounterPermit(COUNTER_RUNIC)
	local e1,cc=Effect.CreateEffect(c),1
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(sett+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(setc)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(runecon)
	e1:SetTarget(Runic.Target(c,cc))
	e1:SetOperation(Runic.Operation(c,cc))
	e1:SetValue(EFFECT_RUNE)
	c:RegisterEffect(e1)
end

function Runic.AddFunProcedure(c,cc,cat,sett,setc,stopt,loc,runecon,runetg,runeop)
	--Runic Procedure
	c:EnableCounterPermit(COUNTER_RUNIC)
	local e1=Effect.CreateEffect(c)
	if cat then e1:SetCategory(cat+CATEGORY_COUNTER)
	else e1:SetCategory(CATEGORY_COUNTER) end
	if stopt==true then e1:SetType(sett+EFFECT_TYPE_TRIGGER_O)
	else e1:SetType(sett+EFFECT_TYPE_TRIGGER_F) end
	e1:SetCode(setc)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	if not loc then e1:SetRange(LOCATION_MZONE)
	else e1:SetRange(loc) end
	e1:SetCondition(runecon)
	if runetg then e1:SetTarget(aux.AND(runetg,Runic.Target(c,cc)))
	else e1:SetTarget(Runic.Target(c,cc)) end
	if runeop then e1:SetOperation(aux.AND(runeop,Runic.Operation(c,cc)))
	else e1:SetOperation(Runic.Operation(c,cc)) end
	e1:SetValue(EFFECT_RUNE)
	c:RegisterEffect(e1)
end

function Runic.Target(c,cc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,cc,0,COUNTER_RUNIC)
			end
end

function Runic.Operation(c,cc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				e:GetHandler():AddCounter(COUNTER_RUNIC,cc)
			end
end




function Altar.AddProcedure(c,amat,altarcon)
	--Altar Procedure
	c:EnableCounterPermit(COUNTER_RUNIC)
    local lv=c:GetLevel()
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1173)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_DECK)
    if altarcon then e1:SetCondition(aux.AND(altarcon,Altar.Condition(c,lv,amat)))
	else e1:SetCondition(Altar.Condition(c,lv,amat)) end
    e1:SetTarget(Altar.Target(c,lv))
    e1:SetOperation(Altar.Operation(c,lv))
    e1:SetValue(SUMMON_TYPE_ALTAR)
    c:RegisterEffect(e1)
	--When Altar Summoned, Place Runic Counters
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabelObject(e1)
	e2:SetCondition(Altar.Countercon(c))
	e2:SetOperation(Altar.Counterop(c))
	c:RegisterEffect(e2)
end

function Altar.AddFunProcedure(c,loc,altarcon)
	--Altar Procedure
	c:EnableCounterPermit(COUNTER_RUNIC)
    local lv=c:GetLevel()
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1173)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    if not loc then e1:SetRange(LOCATION_DECK)
	else e1:SetRange(loc) end
    if altarcon then e1:SetCondition(aux.AND(altarcon,Altar.Condition(c,lv)))
	else e1:SetCondition(Altar.Condition(c,lv)) end
    e1:SetTarget(Altar.Target(c,lv))
    e1:SetOperation(Altar.Operation(c,lv))
    e1:SetValue(SUMMON_TYPE_ALTAR)
    c:RegisterEffect(e1)
	--When Altar Summoned, Place Runic Counters
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabelObject(e1)
	e2:SetCondition(Altar.Countercon(c))
	e2:SetOperation(Altar.Counterop(c))
	c:RegisterEffect(e2)
end

function Card.IsCanBeAltarMaterial(c,tp,lv)
    return c:IsType(TYPE_RUNIC) and c:IsOnField() and c:IsFaceup() and c:IsCanRemoveCounter(tp,COUNTER_RUNIC,lv,REASON_MATERIAL)
end

function Altar.Condition(ac,lv,amat)
    return    function(e,tp,eg,ep,ev,re,r,rp)
                if ac==nil then return false end
                if (ac:IsType(TYPE_PENDULUM) or ac:IsFaceup()) then return false end
                local tp=ac:GetControler()
                return Duel.IsExistingMatchingCard(aux.AND(Card.IsCanBeAltarMaterial,amat),tp,LOCATION_MZONE,0,1,ac,tp,lv)
            end
end

function Altar.Target(ac,lv,amat)
    return  function(e,tp,eg,ep,ev,re,r,rp)
                if not ac then return false end
                local sg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsCanBeAltarMaterial,amat),tp,LOCATION_MZONE,0,1,1,ac,tp,lv)
                sg:KeepAlive()
                e:SetLabelObject(sg)
                return true
            end
end

function Altar.Operation(ac,lv)
    return    function(e,tp,eg,ep,ev,re,r,rp,c)
                local sg=e:GetLabelObject()
                ac:SetMaterial(sg)
                for tc in aux.Next(sg) do
					local cc=tc:GetCounter(COUNTER_RUNIC)
                    tc:RemoveCounter(tp,COUNTER_RUNIC,lv,REASON_MATERIAL+REASON_ALTAR)
					local ce=cc-lv
					e:SetLabel(ce)
					Duel.SendtoGrave(tc,REASON_MATERIAL+REASON_ALTAR)
                end
				sg:DeleteGroup(e,c)
            end
end

function Altar.Countercon(c)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonType(SUMMON_TYPE_ALTAR)
	end
end

function Altar.Counterop(c)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		local ct=e:GetLabelObject():GetLabel()
		c:AddCounter(COUNTER_RUNIC,ct)
	end
end