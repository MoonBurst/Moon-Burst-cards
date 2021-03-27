--Fusion of Light and Dark
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.fusfilter,matfilter=s.matfilter,extrafil=s.fextra,extraop=s.extraop,extratg=s.fustg})
	c:RegisterEffect(e1)
end

function s.fusfilter(c)
	return c:IsSetCard(0x400)
end

function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end

function s.tgfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToGrave()
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_DARK) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ATTRIBUTE_LIGHT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,tg1,ATTRIBUTE_DARK)
		Duel.SendtoGrave(tg1+tg2,REASON_EFFECT)
		e:SetLabelObject(tg1+tg2)
		(tg1+tg2):KeepAlive()
	end
end

function s.extrafilter(c)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToRemove()
end

function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.extrafilter),tp,LOCATION_GRAVE,0,e:GetLabelObject())
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_DARK) and #eg>0 then
		return eg
	end
	return nil
end

function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end