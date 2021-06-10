--Night Blaster Girl
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,511963018,511963031)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17377751,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--actlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--remove
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCountLimit(1)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    --Cannot change control
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e4)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetAttacker()==c and c:GetFlagEffect(id)==0
        and c:CanChainAttack()
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChainAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,c) end
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		local og=Duel.GetOperatedGroup()
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:IsExists(s.retfilter,1,nil,e:GetLabel()) then
		return true
	else 
		g:DeleteGroup()
		e:Reset()
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local og=e:GetLabelObject()
	local g=og:Filter(s.retfilter,nil,e:GetLabel())
	og:DeleteGroup()
	if #g<=0 then return end
	local p=g:GetFirst():GetPreviousControler()
	local tg=Group.CreateGroup()
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if #g>ft then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)
		tg:Merge(g:Select(p,ft,ft,nil))
	else
		tg:Merge(g)
	end
	for tc in aux.Next(tg) do
		Duel.ReturnToField(tc)
	end
end
