--Thaumic Hurricane
--Scripted by "Nekro"
local s,id=GetID()
Duel.LoadScript("c987656819.lua")
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	thaux.ThaumLinkProc(c)
	--If special summoned, return 1 of opponent's monsters to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thacon)
	e2:SetTarget(s.thatg)
	e2:SetOperation(s.thaop)
	c:RegisterEffect(e2)
	--direct atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	--to grave
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end

--Filters
function s.matfilter(c,e,tp)
	return (c:IsSetCard(0xc54) and c:IsAttribute(ATTRIBUTE_WIND)) or thaux.sfilter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end

--Send Opponent's Monster to GY (1)
function s.thacon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,987656806)>0
end
function s.thatg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.thaop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if #tc>0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e2)
end