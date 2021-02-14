--Thaumic Crystal Kerbecs
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	 --Use as Material in S/T (0)
    local ex0=Effect.CreateEffect(c)
    ex0:SetType(EFFECT_TYPE_FIELD)
    ex0:SetRange(LOCATION_SZONE)
    ex0:SetCode(EFFECT_EXTRA_MATERIAL)
    ex0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ex0:SetTargetRange(1,0)
    ex0:SetOperation(s.extracon)
    ex0:SetValue(s.extraval)
    c:RegisterEffect(ex0)
    --Use as Material in S/T (ex0)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetTargetRange(LOCATION_SZONE,0)
    e0:SetTarget(s.eftg)
    e0:SetLabelObject(ex0)
    c:RegisterEffect(e0)
	--Attribute Change (2)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id+100)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.atcon)
    e1:SetCost(s.atcost)
    e1:SetOperation(s.atop)
    c:RegisterEffect(e1)
	--race
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetTarget(s.target)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end

function s.eftg(e,c)
	return s.filter(c)
end

--Filters
function s.matfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) or s.filter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
function s.chngcon(c)
	return function(scard,sumtype,tp)
		return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK and scard==c
	end
end

--Use as Material in S/T (0)
function s.filter(c)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL+TYPE_CONTINUOUS)
end

function s.extraval(chk,summon_type,e,...)
    local c=e:GetHandler()
    if chk==0 then
        local tp,sc=...
        if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
            return Group.CreateGroup()
        else
            return Duel.GetMatchingGroup(s.eftg,tp,0,LOCATION_SZONE,nil)
        end
    end
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
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        c:RegisterEffect(e1)
    end
end

-- (2)
function s.target(e,c)
	e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.value(e)
	return e:GetHandler():GetAttribute()
end