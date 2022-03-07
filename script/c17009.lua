--Enchantress Ballroom
--by King Of Justice
-- BIG THANKS TO MOON BURST :3 
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK && DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1B36))
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	c:RegisterEffect(e2)
	
	--Cannot be destroyed by battle
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(s.battlecon)
    e3:SetTarget(s.tg1)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
	
    --Cannot Be Targeted By Card Effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.condition)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	
	--Change Level
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,id)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(s.lvtg)
	e5:SetOperation(s.lvop)
	c:RegisterEffect(e5)
	
	--When you leave the field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,id+100)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	
	--Activation
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_ACTIVATE)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1,id+200)
	c:RegisterEffect(e7)
end
s.listed_series={0x1B36}

function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return d~=nil and d:IsFaceup() and ((a:GetControler()==tp and a:IsSetCard(0x1B36) and a:IsRelateToBattle() and a:GetLevel()<d:GetLevel())
        or (d:GetControler()==tp and d:IsSetCard(0x1B36) and d:IsRelateToBattle() and d:GetLevel()<a:GetLevel()))
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local tc=Duel.GetAttacker()
    local bc=Duel.GetAttackTarget()
    if not bc then return false end
    if bc:IsControler(1-tp) then bc=tc end
    e:SetLabelObject(bc)
    return bc:IsFaceup() and bc:IsSetCard(0x1B36)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not a:IsRelateToBattle() or a:IsFacedown() or not d:IsRelateToBattle() or d:IsFacedown() then return end
    if a:IsControler(1-tp) then a,d=d,a end
   local dif=d:GetLevel()-a:GetLevel()
   if dif<0 or dif==0 then
    dif=-dif
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetValue(1)
    a:RegisterEffect(e1)

end
--------------------------------------------------------------------------------------------------------

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ)
end

function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
--------------------------------------------------------------------------------------------------------

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1B36) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,7,g:GetFirst():GetLevel())
	Duel.SetTargetParam(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

-----------------------------------------------------------------------------------------------------

function s.thfilter(c)
	return c:IsSetCard(0x1B36) and c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

