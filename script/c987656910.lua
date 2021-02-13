--Solguard Keeper of Tradition
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),2,2)
    --Special Summon Restrict (1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.sumlimit)
    c:RegisterEffect(e1)
	--Add to Hand (2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--Special Summon Restrict (1)
function s.sumlimit(e,c)
    return not c:IsType(TYPE_FUSION) and not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end

--Add to Hand (2)
function s.fusfilter(c)
    local effs={c:GetCardEffect(EVENT_FREE_CHAIN)}
    for _,eff in ipairs(effs) do
      if eff:IsHasCategory(CATEGORY_FUSION_SUMMON) then
        c:RegisterFlagEffect(id,RESET_EVENT+EVENT_ADJUST,0,1)
      end
    end
    return c:IsSetCard(0xc56) and c:IsAbleToHand() and not c:IsPublic() and c:GetType()&TYPE_SPELL==TYPE_SPELL and c:GetFlagEffect(id)~=0
end

function s.ritfilter(c)
	return c:IsRitualSpell() and c:IsAbleToHand() and not c:IsPublic()
end

function s.duofilter(c,e,tp)
	return c:IsSetCard(0xc56) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and (Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_DECK,0,1,nil))
		or (Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_DECK,0,1,nil))
			or (Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.IsExistingMatchingCard(s.duofilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_DECK,0,1,nil))
		or (Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_DECK,0,1,nil))
			or (Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.IsExistingMatchingCard(s.duofilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.duofilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		ops[off]=aux.Stringid(id,3)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Reveal Fusion Spell; Add Ritual Spell
		local rv=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,rv)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
		end
	elseif opval[op]==2 then --Reveal Ritual Spell; Add Fusion Spell
		local rv=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,rv)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
		end
	elseif opval[op]==3 then --Reveal 1 Fusion and Ritual Spell; SS a Solguard
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local rv1=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_HAND,0,1,1,nil)
		local rv2=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND,0,1,1,nil)
		rv1:Merge(rv2)
		Duel.ConfirmCards(1-tp,rv1)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.duofilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end