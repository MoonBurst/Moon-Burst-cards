--Thaumaturge Everly
--by King Of Justice with the help of Moon Burst
--Artist: Chiaki Negishi 
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	
	--You Cannot Negate The Pendulum Summon Of "Thaumaturge" Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	
	--Rolling For Scale Change
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	
	--Special Summon This Card If You Take Damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_BATTLE_DAMAGE) 
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	
	local e4=e3:Clone()
	e4:SetCode(EVENT_DAMAGE)
	c:RegisterEffect(e4)
	
	--Gain 300 LP
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+200)
	e5:SetTarget(s.lptg)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	
	--Return A Card To The Hand And Gain LPs
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+300)
	e6:SetCondition(s.glpcon)
	e6:SetTarget(s.glptarget)
	e6:SetOperation(s.glpoperation)
	c:RegisterEffect(e6)
	
end

function s.target(e,c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSetCard(0x35A) and c:IsType(TYPE_PENDULUM)
end

------------------------------------------------------------------------------------------------------------

s.roll_dice=true
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()<8 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end

function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()>=8 then return end
	local dc=Duel.TossDice(tp,1)
	local sch=math.min(8-c:GetLeftScale(),dc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(sch)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end

-------------------------------------------------------------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end

----------------------------------------------------------------------------------------------------

function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,300)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,300,REASON_EFFECT)
end

---------------------------------------------------------------------------------------------------
function s.glpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

--c:GetAttack()>0
function s.glpfilter(c,e,tp)
    return c:IsSetCard(0x35A) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:IsLevelBelow(4) and not c:IsCode(id)
end

function s.glptarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_EXTRA) and s.glpfilter(chkc) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.glpfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE+LOCATION_EXTRA)
end

function s.glpoperation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.glpfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil,tpe)
    if g:GetCount()>0 then
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(g:GetFirst():GetAttack())
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
    if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then 
    Duel.ConfirmCards(1-tp,g)
    Duel.Recover(tp,g:GetFirst():GetAttack(),REASON_EFFECT)
        end
    end
end

--function s.glpoperation(e,tp,eg,ep,ev,re,r,rp)
    --Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    --local g=Duel.SelectMatchingCard(tp,s.glpfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil,tpe)
    --if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then 
        --Duel.ConfirmCards(1-tp,g)
        --Duel.Recover(tp,g:GetFirst():GetAttack(),REASON_EFFECT)
    --end
--end

------------------------------------------You can't target cards in the Extra Deck

--function s.glptarget(e,tp,eg,ep,ev,re,r,rp,chk)
    --if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_EXTRA) and s.glpfilter(chkc) end
    --if chk==0 then return true end
    --if Duel.IsExistingTarget(s.glpfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil) then
        --Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        --local g=Duel.SelectTarget(tp,s.glpfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil)
        --Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
        --Duel.SetTargetPlayer(tp)
        --Duel.SetTargetParam(g:GetFirst():GetAttack())
        --Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
    --end
--end

--function s.glpoperation(e,tp,eg,ep,ev,re,r,rp)
    --local c=e:GetHandler()
    --local tc=Duel.GetFirstTarget()
    --local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    --if tc and tc:IsRelateToEffect(e) then
        --if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) then
            --Duel.Recover(p,d,REASON_EFFECT)
        --end
    --end
--end

--IsExistingMatchingCard
--SelectMatchingCard

