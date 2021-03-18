--Light Bringer Blue
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--special summon from hand if control no monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
	--special summon to a "Light Bringer" link zone
end
s.listed_series={0x616}
s.listed_names={id}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0) ==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_EXTRA)>=0
end

function s.filter(c)
	return c:IsSetCard(0x616) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and not c:IsCode(id) and c:IsAbleToHand() --or c:IsLevel(6) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end

--function da.filter(c)
	--return c:IsLevel(6) and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
--end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
------------------------------------------------------------------------------





