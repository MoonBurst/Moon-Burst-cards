--Thaumaturge Olivia
--by King Of Justice
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
	e2:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
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
	
	--Battle Protection
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetCountLimit(1)     --,id+200)
	e5:SetValue(s.valcon)
	c:RegisterEffect(e5)
	
	--Roll a Dice to Gain Half Or Double Your ATK points
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	--e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e6:SetCountLimit(1,id+300)
	e6:SetCondition(s.condition)
	e6:SetTarget(s.target2)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
end

function s.target(e,c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSetCard(0x35A) and c:IsType(TYPE_PENDULUM)
end

----------------------------------------------------------------------------------------------------------

s.roll_dice=true
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()>1 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()<=1 then return end
	local dc=Duel.TossDice(tp,1)
	local sch=math.min(c:GetLeftScale()-1,dc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(-sch)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end

---------------------------------------------------------------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Damage(1-tp,ev,REASON_EFFECT)
	end
end

----------------------------------------------------------------------------------------------------

function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end

----------------------------------------------------------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

function s.filter(c)
	return c:IsSetCard(0x35A) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
	    e1:SetDescription(aux.Stringid(id,1))
	    e1:SetCategory(CATEGORY_DICE)
	    e1:SetType(EFFECT_TYPE_IGNITION)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	    e1:SetCountLimit(1,id+960)
	    e1:SetTarget(s.atktg)
	    e1:SetOperation(s.atkop)
	    tc:RegisterEffect(e1)
	end
end


function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
	    local dc=Duel.TossDice(tp,1)
	    local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
		--e1:SetCode(EFFECT_UPDATE_ATTACK)
		--e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		--e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	    e1:SetCode(EFFECT_SET_ATTACK_FINAL) --Her attack states forever
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	    if dc==1 or dc==3 or dc==5 then
	        e1:SetValue(c:GetAttack()/2)
	    elseif dc==2 or dc==4 or dc==6 then
		    e1:SetValue(c:GetAttack()*2)
	    end
		c:RegisterEffect(e1)
    end
end


