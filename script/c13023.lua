--Poltergeist Axel
--by King Of Justice
--Artist: Ell
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	
	--Must Be Ritual Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	
	--Control Of This Card Cannot Be Switched
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e2)
	
	--Your Face-up "Poltergeist" Spell/Trap Cards And This Card Cannot Be Destroyer By Card Effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0) 
	e3:SetTarget(s.catg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	
	--Destroy All Spell/Trap Cards Your Opponent Controls
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destarget)
	e4:SetOperation(s.desoperation)
	c:RegisterEffect(e4)
    
	--Negate The Summon Of A Monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_SUMMON)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distarget)
	e5:SetOperation(s.disoperation)
	c:RegisterEffect(e5)
	
	--Return A Card Your Opponent Controls To The Hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+200)
	e6:SetTarget(s.rthtarget)
	e6:SetOperation(s.rthoperation)
	c:RegisterEffect(e6)
	
	--Banish A Monster This Card Battles
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_BATTLE_START)
	e7:SetTarget(s.rmtarget)
	e7:SetOperation(s.rmoperation)
	c:RegisterEffect(e7)
	
	--Add 1 "Poltergeist" Card From Your Graveyard or Banish Zone To Your Hand
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCountLimit(1,id+300)
	e8:SetTarget(s.thtarget)
	e8:SetOperation(s.thoperation)
	c:RegisterEffect(e8)
end

function s.catg(e,c)
    local c=e:GetHandler()
	return c:IsFaceup() and c:IsSetCard(0x67C) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:GetHandler()
end

--------------------------------------------------------------------------------------------------------

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end

function s.desoperation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Destroy(sg,REASON_EFFECT)
end

--------------------------------------------------------------------------------------------------------

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentChain()==0
end

function s.distarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end

function s.disoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end

--------------------------------------------------------------------------------------------------------

function s.rthtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.rthoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-------------------------------------------------------------------------------------------------------

function s.rmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk ==0 then	return Duel.GetAttacker()==e:GetHandler() and d~=nil end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,d,1,0,0)
end

function s.rmoperation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() then
		Duel.Remove(d,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------------------------------

function s.thfilter(c)
	return c:IsSetCard(0x67C) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

