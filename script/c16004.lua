--Light Bringer Green
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	--A link monster using this card cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.lkcon)
	e3:SetOperation(s.lkop)
	c:RegisterEffect(e3)
	
	end
	
function s.thfilter(c)
	return c:IsSetCard(0x616) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand() or 
	c:IsLevel(6) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

	--If sent as a Light Bringer link material
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x616)
end
	--A link monster using this card cannot be destroyed by card effects 
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1558)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) (until the end of the turn)
	rc:RegisterEffect(e1)
	--local e2=e1:Clone()
	--e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	--rc:RegisterEffect(e2)
end