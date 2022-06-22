--Horizon Worshipper
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
	--Spirit Return (3)
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot Special Summon (1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--Add to Hand or Additional Normal Summon (2)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--Add to Hand or Additional Normal Summon (2)
function s.filter(c)
	return aux.IsCodeListed(c,987656958)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		or Duel.IsExistingMatchingCard(aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if (Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if (Duel.IsExistingMatchingCard(aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),tp,LOCATION_HAND,0,1,nil)) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
		if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --ADD CARD THAT LISTS TOKEN
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
	end
	elseif opval[op]==2 then --NORMAL SUMMON SPIRIT
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local gc=Duel.SelectMatchingCard(tp,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),tp,LOCATION_HAND,0,1,1,nil)
		Duel.Summon(tp,gc:GetFirst(),true,nil)
		Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
	end
end