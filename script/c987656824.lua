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

function s.extrafilter(c,tp)
    return c:IsSetCard(0xc54) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end

function s.matfilter(c,e,tp)
    return c:IsSetCard(0xc54)
end

function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.matfilter2,1,nil,lc,sumtype,tp)
end

function s.matfilter2(c,e,tp)
    return c:IsSetCard(0xc54)
end

function s.atfilter(c,tc)
    return c:IsSetCard(0xc54) and c:IsType(TYPE_MONSTER)
end

--Use as Material in S/T (0)
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
    return (sg+mg):FilterCount(s.extrafilter,nil,tp)>0
end

function s.extraval(chk,summon_type,e,...)
    local c=e:GetHandler()
    if chk==0 then
        local tp,sc=...
        if not summon_type==SUMMON_TYPE_LINK or not sc:IsCode(id) then
            return Group.CreateGroup()
        else
            return Group.FromCards(c)
        end
    elseif chk==1 then
        local sg,sc,tp=...
        if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
            for tc in aux.Next(sg) do
                if tc:GetFlagEffect(id)==0 then
                Duel.Hint(HINT_CARD,tp,id)
                tc:RegisterFlagEffect(id,RESET_EVENT+EVENT_BE_MATERIAL,0,1)
                end
            end
        end
    end
end

function s.eftg(e,c)
    local g=e:GetHandler()
    return c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL+TYPE_CONTINUOUS) and c:IsOriginalType(TYPE_MONSTER)
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