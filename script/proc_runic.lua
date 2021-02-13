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
--cat - category (if none then put 'nil')
--sett - settype (if none then put 'nil')
--setc - setcode
--stopt - settype optional (true/false)
--runecon - condition for rune
--runetg - target for rune (if none then put 'nil')
--runeop - operation for rune (if none then put 'nil')
function Runic.AddProcedure(c,cat,sett,setc,stopt,runecon,runetg,runeop)
	--Runic Procedure
	c:EnableCounterPermit(COUNTER_RUNIC)
	local e1=Effect.CreateEffect(c)
	if category then e1:SetCategory(cat+CATEGORY_COUNTER)
	else e1:SetCategory(CATEGORY_COUNTER) end
	if stopt==true then e1:SetType(sett+EFFECT_TYPE_TRIGGER_O)
	else e1:SetType(sett+EFFECT_TYPE_TRIGGER_F) end
	e1:SetCode(setc)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(runecon)
	if runetg then e1:SetTarget(aux.AND(runetg,Runic.Target(c)))
	else e1:SetTarget(Runic.Target(c)) end
	if runeop then e1:SetOperation(aux.AND(runeop,Runic.Operation(c)))
	else e1:SetOperation(Runic.Operation(c)) end
	e1:SetValue(EFFECT_RUNE)
	c:RegisterEffect(e1)
end

function Runic.Target(c)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_RUNIC)
			end
end

function Runic.Operation(c)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				e:GetHandler():AddCounter(COUNTER_RUNIC,1)
			end
end

--Procedure - Altar
function Altar.AddProcedure(c,altercon)
    local lv=c:GetLevel()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1173)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_DECK)
    if altarcon then e1:SetCondition(aux.AND(altarcon,Altar.Condition(c,lv)))
	else e1:SetCondition(Altar.Condition(c,lv)) end
    e1:SetTarget(Altar.Target(c,lv))
    e1:SetOperation(Altar.Operation(c,lv))
    e1:SetValue(SUMMON_TYPE_ALTAR)
    c:RegisterEffect(e1)
end

function Card.IsCanBeRunicMaterial(c,tp,lv)
    return c:IsType(TYPE_RUNIC) and c:IsOnField() and c:IsFaceup() and c:IsCanRemoveCounter(tp,COUNTER_RUNIC,lv,REASON_MATERIAL)
end

function Altar.Condition(ac,lv)
    return    function(e,tp,eg,ep,ev,re,r,rp)
                if ac==nil then return false end
                if (ac:IsType(TYPE_PENDULUM) or ac:IsFaceup()) then return false end
                local tp=ac:GetControler()
                return Duel.IsExistingMatchingCard(Card.IsCanBeRunicMaterial,tp,LOCATION_MZONE,0,1,ac,tp,lv)
            end
end

function Altar.Target(ac,lv)
    return  function(e,tp,eg,ep,ev,re,r,rp)
                if not ac then return false end
                local sg=Duel.SelectMatchingCard(tp,Card.IsCanBeRunicMaterial,tp,LOCATION_MZONE,0,1,1,ac,tp,lv)
                sg:KeepAlive()
                e:SetLabelObject(sg)
                Debug.Message("tg")
                return true
            end
end

function Altar.Operation(ac,lv)
    return    function(e,tp,eg,ep,ev,re,r,rp,c)
                local sg=e:GetLabelObject()
                ac:SetMaterial(sg)
                for tc in aux.Next(sg) do
                    tc:RemoveCounter(tp,COUNTER_RUNIC,lv,REASON_MATERIAL)
                    Duel.SendtoGrave(tc,REASON_MATERIAL+REASON_ALTAR)
                end
                sg:DeleteGroup()
            end
end
