--Princess Witch Kaguya
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Special Summon Condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	
	--Treated as Lady Witch Kaguya
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(15001)
	c:RegisterEffect(e2)
	
	--This card cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	
	--Unaffected by card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	
	--Return ALL cards your opponent controls to their hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1)
	e5:SetCondition(s.thcon)
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtarget)
	e5:SetOperation(s.thoperation)
	c:RegisterEffect(e5)
	
	--Destroy Any cards added to Hand
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetCountLimit(1,id)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.descon)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
	
	--Remove the destroyed cards
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,LOCATION_HAND)
	e7:SetValue(LOCATION_REMOVED)
	e7:SetTarget(s.rmtg)
	c:RegisterEffect(e7)
	
	--Negate any Effects activated in your opponent's Banish zone
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_CHAIN_SOLVING)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.discon)
	e8:SetOperation(s.disop)
	c:RegisterEffect(e8)
	
	--Sort your deck
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1,id+1)
	e9:SetTarget(s.target)
	e9:SetOperation(s.activate)
	c:RegisterEffect(e9)
	
	--Banish face-down
	local e10=Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id,1))
    e10:SetCategory(CATEGORY_REMOVE)
    e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e10:SetRange(LOCATION_MZONE)
    e10:SetCode(EVENT_PHASE+PHASE_END)
    e10:SetCountLimit(1)
    e10:SetTarget(s.byetg)
    e10:SetOperation(s.byeop)
    c:RegisterEffect(e10)
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end

function s.thfilter(c)
	return c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.thoperation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end

---------------------------------------------------------------------------------------------------------

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.desfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsControler(1-tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

---------------------------------------------------------------------------------------------------------

function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()~=tp and Duel.IsPlayerCanRemove(tp,c) and c:IsLocation(LOCATION_HAND)
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) 
end

-----------------------------------------------------------------------------------------------------------

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and loc==LOCATION_REMOVED
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

-----------------------------------------------------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.SortDecktop(tp,tp,5)
end

-----------------------------------------------------------------------------------------------------------


function s.byetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end

function s.byeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end





