--Solguard Shining Down
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
	local params={aux.FilterBoolFunction(Card.IsSetCard,0xc56),nil,nil,s.extrafil}
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.extrafilfus(c,e,tp)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil) and c:IsType(TYPE_MONSTER)
end

function s.extrafilrit(c,e,tp)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
end

function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xc56)
end

function s.ritfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0xc56) and c:IsType(TYPE_MONSTER)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,987656910),tp,LOCATION_ONFIELD,0,1,nil) and
	(Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil)) and
	Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil))
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil) then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=2
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Ritual Summon
		local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		local tc=g:GetFirst()
		local lv=tc:GetLevel()
		local mg=Duel.GetMatchingGroup(s.extrafilrit,tp,LOCATION_DECK,0,nil,tp,c,e)
		local mat=mg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,99)
		Duel.SendtoGrave(mat,REASON_COST)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	elseif opval[op]==2 then --Fusion Summon
		local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		local tc=g:GetFirst()
		local mg=Duel.GetMatchingGroup(s.extrafilfus,tp,LOCATION_DECK,0,nil,c,e)
		local mat=Duel.SelectFusionMaterial(tp,tc,mg)
		Duel.SendtoGrave(mat,REASON_COST)
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
