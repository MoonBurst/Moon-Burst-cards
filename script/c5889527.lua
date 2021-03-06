--Marmonk Grigia
--Scripted by: XGlitchy30
local s,id=GetID()
Duel.LoadScript("init.lua",false)

function s.initial_effect(c)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--enable zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.zntg)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:GLSetCategory(GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--ATK/DEF
function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=0
	for p=tp,1-tp do
		for i=0,4 do
			local index=(p==tp) and i or 4-i
			if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) then
				ct=ct+1
			end
		end
	end
	return ct*300
end
--ENABLE ZONE
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check=false
		for i=0,4 do
			if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) then
				check=true
				break
			end
		end
		return check
	end
	local zone=0
	local ct=0
	for i=0,4 do
		if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) then
			ct=ct+1
			zone=zone|(0x1<<i)
		end
	end
	if ct>1 then
		local int={}
		for i=1,ct do
			table.insert(int,i)
		end
		ct=Duel.AnnounceNumber(tp,table.unpack(int))
	end
	local en=Duel.SelectFieldZone(tp,ct,LOCATION_MZONE,0,~zone,false)
	Duel.Hint(HINT_ZONE,tp,en)
	e:SetLabel(en)
end
function s.zdisfilter(c)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and not c:IsFaceup() then return end
	local t={c:GetCardEffect(nil)}
	if t and #t>0 then
		local fixct=#t
		for i=1,fixct do
			local ce=t[i]
			if ce:GetCode()==EFFECT_DISABLE_FIELD or ce:GetCode()==EFFECT_USE_EXTRA_MZONE then
				return true
			end
		end
	end
	return false
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	--handle card effect
	local g=Duel.GetMatchingGroup(s.zdisfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			local en=(tc:GetControler()==tp) and e:GetLabel() or e:GetLabel()<<16
			local t={tc:GetCardEffect(nil)}
			if t and #t>0 then
				local fixct=#t
				for i=1,fixct do
					local ce=t[i]
					local reset,rct=ce:GetReset()
					if not rct then rct=1 end
					reset=(reset&(~(RESET_EVENT+RESETS_STANDARD_DISABLE)))|(RESET_EVENT+RESETS_STANDARD_DISABLE)
					if ce:GetCode()==EFFECT_DISABLE_FIELD then
						local zone=ce:GetLabel()
						if zone~=0 and zone&en>0 then
							tc:RegisterFlagEffect(id,reset,0,rct)
							local ne=Effect.CreateEffect(ce:GetOwner())
							ne:SetType(EFFECT_TYPE_FIELD)
							ne:SetRange(ce:GLGetRange())
							ne:SetCode(EFFECT_DISABLE_FIELD)
							ne:SetLabel(zone&(~en))
							if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
							ne:SetOperation(s.disop)
							ne:SetReset(reset,rct)
							tc:RegisterEffect(ne)
							ce:SetCondition(s.zcond)
						elseif zone==0 then
							tc:RegisterFlagEffect(id,reset,0,rct)
							local ne=Effect.CreateEffect(ce:GetOwner())
							ne:SetType(EFFECT_TYPE_FIELD)
							ne:SetRange(ce:GLGetRange())
							ne:SetCode(EFFECT_DISABLE_FIELD)
							ne:SetLabel(~en)
							if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
							ne:SetOperation(s.disop2(ce:GetOperation()))
							ne:SetReset(reset,rct)
							tc:RegisterEffect(ne)
							ce:SetCondition(s.zcond)
						end
					elseif ce:GetCode()==EFFECT_USE_EXTRA_MZONE then
						local val=ce:GetValue()
						local zct=math.fmod(val,0x10)
						local zone=bit.rshift(val-zct,16)
						if zone&en~=0 then
							tc:RegisterFlagEffect(id,reset,0,rct)
							local ne=ce:Clone()
							ne:SetValue(bit.lshift(zone&(~en),16)+zct-1)
							ne:SetReset(reset,rct)
							tc:RegisterEffect(ne)
							ce:SetCondition(s.zcond)
						end
					end
				end
			end
			tc=g:GetNext()
		end
	end
	--handle duel effect
	for p=tp,1-tp do
		local en=(p==tp) and e:GetLabel() or e:GetLabel()<<16
		local t={Duel.GetPlayerEffect(p,nil)}
		if t and #t>0 then
			local fixct=#t
			for i=1,fixct do
				local ce=t[i]
				if ce and ce:GetCode()==EFFECT_DISABLE_FIELD then
					local reset,rct=ce:GetReset()
					if not rct then rct=1 end
					local zone=ce:GetLabel()
					if zone~=0 and zone&en>0 then
						ce:GetOwner():RegisterFlagEffect(id,reset,0,rct)
						local ne=Effect.CreateEffect(ce:GetOwner())
						ne:SetType(EFFECT_TYPE_FIELD)
						ne:SetCode(EFFECT_DISABLE_FIELD)
						ne:SetLabel(zone&(~en))
						if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
						ne:SetOperation(s.disop)
						ne:SetReset(reset,rct)
						Duel.RegisterEffect(ne,p)
						ce:SetCondition(s.zcond2)
					elseif zone==0 then
						ce:GetOwner():RegisterFlagEffect(id,reset,0,rct)
						local ne=Effect.CreateEffect(ce:GetOwner())
						ne:SetType(EFFECT_TYPE_FIELD)
						ne:SetCode(EFFECT_DISABLE_FIELD)
						ne:SetLabel(~en)
						if ce:GetLabelObject() then ne:SetLabelObject(ce:GetLabelObject()) end
						ne:SetOperation(s.disop2(ce:GetOperation()))
						ne:SetReset(reset,rct)
						Duel.RegisterEffect(ne,p)
						ce:SetCondition(s.zcond2)
					end
				end
			end
		end
	end
	Duel.Readjust()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.spfilter(c,e,tp)
	if c:IsCode(id) or not c:IsType(TYPE_MONSTER) or not c:IsRace(RACE_BEAST) or not c:IsLevelBelow(4) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local egroup={c:GetCardEffect(nil)}
	for i=1,#egroup do
		local ce=egroup[i]
		if glitchy_effect_table[ce] and glitchy_effect_table[ce][1]&GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP==GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP then
			return true
		end
	end
	return false
end
function s.zcond(e)
	return e:GetHandler():GetFlagEffect(id)<=0
end
function s.zcond2(e)
	return e:GetOwner():GetFlagEffect(id)<=0
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.disop2(op)
	return	function(e,tp)
				local zone=op(e,tp)
				return zone&e:GetLabel()
	end
end

--DRAW
function s.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACE_BEAST==RACE_BEAST
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not e:GetHandler():IsForbidden() and ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetGLOperationInfo(e,0,GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,ct-1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		local ct=Duel.GetMatchingGroupCount(s.tfilter,tp,LOCATION_SZONE,0,nil)
		if ct>0 and Duel.Draw(p,ct,REASON_EFFECT)==ct then
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
			if #g==0 then return end
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg=g:Select(p,ct-1,ct-1,nil)
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		end
	end
end