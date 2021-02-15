--Thaumic Crystal Kerbecs
--Scripted by "Nekro"
local s,id=GetID()
Duel.LoadScript("c987656819.lua")
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	thaux.ThaumLinkProc(c)
	--Attribute Change (2)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.atcon)
    e2:SetCost(s.atcost)
    e2:SetOperation(s.atop)
    c:RegisterEffect(e2)
	--race
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetTarget(s.target)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
end

--Filters
function s.matfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) or thaux.sfilter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end

--Attribute Change (2)
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetHandler())
    Duel.ConfirmCards(1-tp,g)
    e:SetLabelObject(g:GetFirst())
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local att=tc:GetAttribute()
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(att)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        c:RegisterEffect(e2)
    end
end

-- (2)
function s.target(e,c)
	e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.value(e)
	return e:GetHandler():GetAttribute()
end