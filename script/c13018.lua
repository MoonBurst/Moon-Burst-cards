--Poltergeist Lilith
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
	
	--Select A Card From Your Opponent's Hand To Reveal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.locost)
	e3:SetTarget(s.lotg)
	e3:SetOperation(s.loop)
	c:RegisterEffect(e3)
	
	--Select A Card From Your Opponent's Hand To Banish
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	
	--Add 1 Card From Your Deck To Your Hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+200)
	e5:SetOperation(s.thoperation)
	c:RegisterEffect(e5)
end

function s.locost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() 
	and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end

function s.lotg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
end
function s.loop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(p,nil,p,0,LOCATION_HAND,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		--Duel.ShuffleHand(1-tp)
	end
end

--------------------------------------------------------------------------------------------------------

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetTargetCard(g)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
		local op=Duel.SelectOption(tp,70,71,72)
		Duel.ConfirmCards(tp,tc)
		--Duel.ShuffleHand(1-tp)
		if (op~=0 and tc:IsType(TYPE_MONSTER)) or (op~=1 and tc:IsType(TYPE_SPELL)) or (op~=2 and tc:IsType(TYPE_TRAP)) then
			Duel.Damage(tp,1000,REASON_EFFECT)
		else
		    Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end

------------------------------------------------------------------------------------------------------

function s.thoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local add=g:Select(tp,1,1,nil)
		if add:GetFirst():IsAbleToHand() then
			Duel.SendtoHand(add,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,add)
			Duel.ShuffleHand(tp)
		else
			Duel.SendtoGrave(add,REASON_EFFECT)
		end
		Duel.SortDecktop(tp,tp,2)
	end
end