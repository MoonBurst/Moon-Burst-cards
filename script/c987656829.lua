--Thaumic Miracle
--Scripted by Nekro
local s,id=GetID()

s.LINK_IDS={"987656819","987656820","987656821","987656822","987656823","987656824","987656825"}
s.THAUMIC_LINKS={}
s.THAUMIC_ATTRIBUTES={}

function s.initial_effect(c)
	--Skill
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0xff)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.listed_series={0xc56}

function s.op(e,tp,eg,ep,ev,re,r,rp)
	for i=1,#s.LINK_IDS,1 do
		s.THAUMIC_LINKS[i]=Duel.CreateToken(tp,s.LINK_IDS[i])
		s.THAUMIC_ATTRIBUTES[i]=s.THAUMIC_LINKS[i]:GetAttribute()
	end
end

function s.filter(c,att)
	return c:IsSetCard(0xc54) and c:IsAttribute(att)
end

function s.stfilter(c,cardtype)
	return c:IsSetCard(0xc54) and c:IsType(cardtype)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--Condition
	for i=1,#s.THAUMIC_LINKS,1 do
		local att=s.THAUMIC_ATTRIBUTES[i]
		--EMPEROR AND CRYSTAL CHECK
		if s.THAUMIC_LINKS[i]:GetCode()==987656825 and Duel.IsExistingMatchingCard(s.emperorfilter,tp,LOCATION_MZONE,0,3,nil) then
			return true
		end
		if s.THAUMIC_LINKS[i]:GetCode()==987656824
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,2,nil,ATTRIBUTE_DARK)
				or (Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_SZONE,0,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)) then
			return true
		end
		
		local mg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,att)
		local mg2=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_CONTINUOUS)
		local mg=#mg1 + #mg2
		if #mg1>0 and mg>2 then
			return true
		end
	end
	
	return false
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--OPD Check; Skill Activation
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Negate Check
	if aux.CheckSkillNegation(e,tp) then return end
	--Get Attribute of "Thaumic" monsters on Field
	local att=0
	for gc in aux.Next(Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0xc54),tp,LOCATION_MZONE,0,nil)) do
		att=att|gc:GetAttribute()
	end
	local mg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,att)
	local mg2=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	--EMPEROR & CRYSTAL Check
	if mg1:IsExists(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_DARK),1,nil) then
		local mg=#mg1 + #mg2
		if #mg1>0 and mg>1 then
			s.announce_filter={TYPE_LINK,OPCODE_ISTYPE,0xc54,OPCODE_ISSETCARD,OPCODE_AND,att,OPCODE_ISATTRIBUTE,OPCODE_AND}
			local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
			local tl=Duel.CreateToken(tp,ac)
			Duel.SendtoHand(tl,tp,REASON_RULE)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			Duel.LinkSummon(tp,tl)
		end
	else
		local mg=#mg1 + #mg2
		if #mg1>0 and mg>2 then
			s.announce_filter={TYPE_LINK,OPCODE_ISTYPE,0xc54,OPCODE_ISSETCARD,OPCODE_AND,att,OPCODE_ISATTRIBUTE,OPCODE_AND}
			local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
			local tl=Duel.CreateToken(tp,ac)
			Duel.SendtoHand(tl,tp,REASON_RULE)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			Duel.LinkSummon(tp,tl)
		end
	end
end
