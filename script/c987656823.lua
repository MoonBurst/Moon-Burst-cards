--Thaumic Lightflare
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	--Use Material in S/T (1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
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

--Summon Filters
function s.matfilter(c)
	return (c:IsSetCard(0xc54) and c:IsAttribute(ATTRIBUTE_EARTH)) or (c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS))
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end

--Use Material in S/T (1)
s.curgroup=nil
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not s.curgroup or #(sg&s.curgroup)<3
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local c=e:GetHandler()
		local ex=Effect.CreateEffect(c)
		ex:SetType(EFFECT_TYPE_SINGLE)
		ex:SetCode(EFFECT_ADD_TYPE)
		ex:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex:SetReset(RESET_EVENT+RESETS_STANDARD)
		ex:SetOperation(s.chngcon)
		ex:SetValue(TYPE_MONSTER)
		c:RegisterEffect(ex)
		local ex2=Effect.CreateEffect(c)
		ex2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ex2:SetRange(LOCATION_EXTRA)
		ex2:SetTargetRange(LOCATION_SZONE,0)
		ex2:SetTarget(s.eftg)
		ex2:SetLabelObject(ex)
		c:RegisterEffect(ex2)
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end

function s.eftg(e,c)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end

function s.chngcon(scard,sumtype,tp)
    return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK
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