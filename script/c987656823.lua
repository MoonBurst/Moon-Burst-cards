--Thaumic Lightflare
--Scripted by "Nekro"
local s,id=GetID()
Duel.LoadScript("c987656819.lua")
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	thaux.ThaumLinkProc(c)
	--Special Summon from Grave (2)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--ATK Gain (3)
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(s.val)
    c:RegisterEffect(e3)
	--Effect Indes (4)
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetCountLimit(1)
	e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    c:RegisterEffect(e4)
end
--Filters
function s.matfilter(c,e,tp)
	return (c:IsSetCard(0xc54) and c:IsAttribute(ATTRIBUTE_LIGHT)) or thaux.sfilter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
--Shuffle S/T into Deck (1)
function s.filter(c,e,tp)
    return c:IsSetCard(0xc54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,987656806)>0
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end

--ATK Gain (2)
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)*200
end

--Effect Indes (3)
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.repfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:GetReasonPlayer()~=tp
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
	and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end