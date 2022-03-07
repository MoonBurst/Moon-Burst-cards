--Enchantress Eudora
--by King Of Justice
--Artist: irua
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1B36),5,2,nil,nil,7)
	
	--Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.attval)
	c:RegisterEffect(e1)

	--Cannot Be Destroyed By Battle
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.btindes)
	c:RegisterEffect(e2)
	
	--ATK Change Effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.atkcost)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	
	--Banish a card from your Opponent's Graveyard
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(s.btarget)
	e4:SetOperation(s.boperation)
	c:RegisterEffect(e4)
	
	--Return A Banished card to GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
	
	--Special Summon An Xyz Monster
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	--e6:SetType(EFFECT_TYPE_TRIGGER_O)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCountLimit(1,id+100)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={0x1B36}

function s.attval(e,c)
	local att=0
	local og=e:GetHandler():GetOverlayGroup()
	for tc in aux.Next(og) do
		att=att|tc:GetAttribute()
	end
	return att
end

-------------------------------------------------------------------------------------------------

function s.btindes(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end

-------------------------------------------------------------------------------------------------
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if d and a:GetControler()~=d:GetControler() then
		if a:IsControler(tp) then
			e:SetLabelObject(a)
		else
			e:SetLabelObject(d)
		end
	return true
	else return false end
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tc)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end

-------------------------------------------------------------------------------------------------
function s.btarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end

function s.boperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
end
-------------------------------------------------------------------------------------------------

function s.tgfilter(c,e,tp) 
	return c:IsSetCard(0x1B36) --and c:IsFaceup()  c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) 
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end

-------------------------------------------------------------------------------------------------

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end

function s.mtfilter(c)
	return c:IsSetCard(0x1B36)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingTarget(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,#g1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.mtfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=tg:Filter(s.spfilter,nil,e,tp):GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE)
		and Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		local oc=tg:Filter(s.mtfilter,tc,e,tp):GetFirst()
		if oc and oc:IsControler(tp) and oc:IsRelateToEffect(e) and not oc:IsImmuneToEffect(e) then
			oc:CancelToGrave()
			Duel.Overlay(tc,oc,true)
		end
	end
end
