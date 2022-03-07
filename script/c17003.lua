--Enchantress Ethel
--by King Of Justice
--Artist: irua
local s,id=GetID()
function s.initial_effect(c)
    --Attack limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	
	--double level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	
end
s.listed_series={0x1B36}

function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x1B36),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end

----------------------------------------------------------------------------------------------------

function s.spfilter(c)
	return c:GetSequence()<5
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

----------------------------------------------------------------------------------------------------
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1B36) and c:IsCanBeEffectTarget(e) and c:HasLevel()
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,2,nil,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,nil,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	for tc in aux.Next(tg) do
		--Double their Levels
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(tc:GetLevel()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end