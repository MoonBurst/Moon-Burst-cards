--Thaumic Tsunami
--Scripted by "Nekro"
local s,id=GetID()
Duel.LoadScript("c987656819.lua")
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	thaux.ThaumLinkProc(c)
	--Shuffle S/T into Deck (1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Disable SPSummon & Shuffle into Deck (2)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_SPSUMMON)
	e4:SetRange(LOCATION_MZONE)
	--e4:SetProperty(EFFECT_FLAG_DELAY)
	--e4:SetCondition(s.dscon)
	e4:SetCost(s.dscost)
	e4:SetTarget(s.dstg)
	e4:SetOperation(s.dsop)
	c:RegisterEffect(e4)
end
--Summon Filters
function s.matfilter(c,e,tp)
	return (c:IsSetCard(0xc54) and c:IsAttribute(ATTRIBUTE_WATER)) or thaux.sfilter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end

--Shuffle S/T into Deck (1)
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,987656806)>0
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end

--Disable SPSummon & Shuffle into Deck (2)
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return tp==1-ep and Duel.GetCurrentChain()==0
end

function s.dscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xc54),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsSetCard,0xc54),tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
	
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.SendtoDeck(eg,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
end