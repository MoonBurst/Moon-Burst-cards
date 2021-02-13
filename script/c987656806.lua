--Thaumic Catalyst Kerbecs
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Place from Banished or GY (1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
	--Attribute Change (2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1000000)
	e3:SetCost(s.atcost)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	--Place Attack Target (3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_BATTLE_CONFIRM)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(TIMING_BATTLE_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1000001)
	e4:SetTarget(s.asttg)
	e4:SetOperation(s.astop)
	c:RegisterEffect(e4)
end

--Special Summon
function s.spfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSetCard(0xc54) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE,0,nil,ft)
	return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE,0,nil,Duel.GetLocationCount(tp,LOCATION_SZONE))
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

--Place from Banished or GY (1)
function s.atfilter(c,tc)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_MONSTER)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.GetFirstTarget()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local ex1=Effect.CreateEffect(c)
			ex1:SetCode(EFFECT_CHANGE_TYPE)
			ex1:SetType(EFFECT_TYPE_SINGLE)
			ex1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			ex1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			ex1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(ex1)
		end
	end
end

--Attribute Change (2)
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
		local ex2=Effect.CreateEffect(c)
		ex2:SetType(EFFECT_TYPE_SINGLE)
		ex2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		ex2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex2:SetValue(att)
		ex2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(ex2)
	end
end

--Place Attack Target (3)
function s.asttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local bc=Duel.GetAttackTarget()
	if chk==0 then return bc and bc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(bc)
end
function s.astop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local ex3=Effect.CreateEffect(tc)
		ex3:SetCode(EFFECT_CHANGE_TYPE)
		ex3:SetType(EFFECT_TYPE_SINGLE)
		ex3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		ex3:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(ex3)
		local ex4=Effect.CreateEffect(c)
		ex4:SetType(EFFECT_TYPE_SINGLE)
		ex4:SetCode(EFFECT_ADD_SETCODE)
		ex4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex4:SetValue(0xc54)
		ex4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ex4)
	end
end