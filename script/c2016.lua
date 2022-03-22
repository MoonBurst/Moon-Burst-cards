--Synclone The Mechanic Storm Dragon Winder
--Scripted by King Of Justice
--Artist:
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	Synchro.AddProcedure(c,aux.FilterSummonCode(2008),1,1,Synchro.NonTunerEx(Card.IsSetCard,0x8FC),1,1)
	c:EnableReviveLimit()
	
	--Destroy and Inflict Damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.stgcon)
	e1:SetTarget(s.stgtg)
	e1:SetOperation(s.stgop)
	c:RegisterEffect(e1)
	
	--Unaffected by Monster Effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	--e2:SetCondition(s.efilter)
	--e2:SetValue(s.unval)
	c:RegisterEffect(e2)
	
	--Shuffle and Attack again
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	
	--Special summon from the extra deck
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x8FE,0x8FC}
s.material={2008}

function s.stgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.stgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then
			return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),tp)
	end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetChainLimit(s.chlimit)
end

function s.stgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	Duel.SendtoGrave(g,REASON_EFFECT)
end

function s.chlimit(e,ep,tp)
	return tp==ep
end

-----------------------------------------------------------------------------------------------------
function s.efilter(e,re)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and e:GetHandler()~=rc
end

-----------------------------------------------------------------------------------------------------

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:CanChainAttack() and c==Duel.GetAttacker() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetOperation(s.caop)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end

function s.caop(e,tp)
	local c=e:GetHandler()
	if c:CanChainAttack() then
		Duel.ChainAttack()
	end
end

---------------------------------------------------------------------------------------------

function s.filter(c,e,tp)
	return c:IsSetCard(0x8FE) and c:GetLevel()==8 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0  --and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and not c:IsCode(id)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end