--Light Bringer Fumi-Miko
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	
	--Link Summon once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.con)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.con2)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	
	--Extra Normal Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetTarget(s.extg)
	c:RegisterEffect(e3)
	
	--negate attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
	
	--special summon 2
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1)--,id+1)
	e5:SetCondition(aux.exccon)
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	
end
	
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x616,lc,sumtype,tp)  
end
------------------------------------------------------------------------

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
---------------------------------------------------------------------
function s.filter(c)
	return c:IsFaceup(0x616) and c:IsLocation(LOCATION_MZONE) and not c:IsCode(id) or c:IsCode(21251800) and c:IsLocation(LOCATION_MZONE) --and not c:GetSequence()>4 --extra monster zone c89571015
end
function s.con2(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end


---------------------------------------------------------------------
function s.extg(e,c)
	return c:IsLevelBelow(2) and c:IsSetCard(0x616) or c:IsCode(21251800)
end
--------------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.NegateAttack()
	end
end

----------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x616) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end



