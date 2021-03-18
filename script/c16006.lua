--Light Bringer Rose
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.con)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	--e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
	
function s.filter(c)
	return c:IsFaceup(0x616) and c:IsLocation(LOCATION_MZONE) and not c:IsCode(id) or c:IsCode(21251800) and c:IsLocation(LOCATION_MZONE) --and not c:GetSequence()>4 --extra monster zone c89571015
end
function s.con(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end

--------------------------------------------------------------------
function s.cfilter(c,ft,tp)
	return c:IsRace(RACE_FAIRY) and (ft>0 or (c:GetSequence()<5 and c:IsControler(tp))) and (c:IsFaceup(0x616) or c:IsControler(tp))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local c=e:GetHandler()
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>-1 and c:IsReleasable() and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,c,ft,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,c,ft,tp)
	rg:AddCard(c)
	Duel.Release(rg,REASON_COST)
end
function s.dfilter(c,e,tp)
	return c:IsCode(21251800) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			--e1:SetCode(EFFECT_UPDATE_ATTACK)
			--e1:SetValue(-300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
