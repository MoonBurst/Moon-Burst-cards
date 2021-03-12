--Init

--GLITCHY'S STUFF
--Special Categories
GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP=0x1

--Duel Effects without player target range
DUEL_EFFECT_NOP={EFFECT_DISABLE_FIELD}

--Global Card Effect Table
if not global_card_effect_table_global_check then
	global_card_effect_table_global_check=true
	global_range_effect_table={}
	global_target_range_effect_table={}
	effect_set_range, effect_set_target_range = Effect.SetRange, Effect.SetTargetRange
	function Effect.SetRange(e,r)
		global_range_effect_table[e]=r
		return effect_set_range(e,r)
	end
	function Effect.SetTargetRange(e,s,o)
		global_target_range_effect_table[e]={s,o}
		return effect_set_target_range(e,s,o)
	end
end

function Effect.GLGetRange(e)
	local r=global_range_effect_table[e]
	if not r then r=0 end
	return r
end
function Effect.GLGetTargetRange(e)
	if not global_target_range_effect_table[e] then return 0,0 end
	local s=global_target_range_effect_table[e][1]
	local o=global_target_range_effect_table[e][2]
	return s,o
end

function Auxiliary.SetOperationResultAsLabel(op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local res=op(e,tp,eg,ep,ev,re,r,rp)
				e:SetLabel(res)
				return res
			end
end

--Global Card Effect Table (for Duel.RegisterEffect)
if not global_duel_effect_table_global_check then
	global_duel_effect_table_global_check=true
	Duel.register_global_duel_effect_table,card_reg_eff = Duel.RegisterEffect,Card.RegisterEffect
	Duel.RegisterEffect = function(e,tp)
							local s,o=e:GLGetTargetRange()
							if not e:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) and s==0 and o==0 then
								for i=1,#DUEL_EFFECT_NOP do
									if e:GetCode()==DUEL_EFFECT_NOP[i] then e:SetProperty(e:GetProperty()|EFFECT_FLAG_PLAYER_TARGET) e:SetTargetRange(1,0) end
								end
							end
							return Duel.register_global_duel_effect_table(e,tp)
						  end
							
	Card.RegisterEffect = function(c,e,...)
							local reg={...}
							if e:GetCode()==EFFECT_DISABLE_FIELD and e:GetLabel()==0 and e:GetOperation() then
								local op=e:GetOperation()
								e:SetOperation(Auxiliary.SetOperationResultAsLabel(op))
							end
							return card_reg_eff(c,e,table.unpack(reg))
						   end
end

--Set Special Categories not listed in constant.lua
if not glitchy_effect_table then glitchy_effect_table={} end
function Effect.GLSetCategory(e,cat)
	if not glitchy_effect_table[e] then glitchy_effect_table[e]={0} end
	glitchy_effect_table[e][1]=glitchy_effect_table[e][1]|cat
end

--Creates an effect table that stores informations on what the effect is going to do during the resolution.
--Roughly equivalent to Duel.SetOperationInfo, but for special categories
Auxiliary.GLSpecialInfos={}
function Duel.SetGLOperationInfo(e,ch,cat,g,ct,p,loc,fromloc)
	if not g then
		Auxiliary.GLSpecialInfos[e]={cat,nil,ct,p,loc,fromloc}
	else
		Auxiliary.GLSpecialInfos[e]={cat,g,ct,0,0,fromloc}
	end
end

--Procs through numbers from 0 to ct and assigns a value depending on what number "i" is equal to.
--{...}: For example, if i==0 then the function will assign the value inserted as the 1st {...} param, if i==1 the 2nd {...} param will be assigned and so on
function Auxiliary.GLSetValueDependingOnNumber(i,ct,...)
	local f={...}
	if #f~=ct+1 then return 0 end
	for k=0,ct do
		if i==k then return f[k+1] end
	end
	return 0
end

--Returns all the zones the arrows PRINTED on the card (c) point to, REGARDLESS of the card type (even if it is not an active Link Monster) or of the location it is in (MZONE/SZONE)
--If f is set to true, the function only returns the available zones (usable and unoccupied)
function Auxiliary.GLGetLinkedZoneManually(c,f)
	if c:GetOriginalType()&TYPE_LINK==0 or not c:IsLocation(LOCATION_MZONE+LOCATION_SZONE) then return 0 end
	local seq=c:GetSequence()
	local tlchk,tchk,trchk=false,false,false
	local xct=(seq>4) and true or false
	if c:IsLocation(LOCATION_MZONE) then
		if (seq>4 or seq==2 or seq==4) then tlchk=true end
		if (seq>4 or seq==1 or seq==3) then tchk=true end
		if (seq>4 or seq==0 or seq==2) then trchk=true end
	end
	local lk=c:LinkMarker()
	local zone=0
	local free=(f==true) and function(c,loc,sq,locp) local p=(locp~=nil) and 1-c:GetControler() or c:GetControler() local s=(locp~=nil and sq<5) and 4-sq or sq return Duel.CheckLocation(p,loc,s) end or false
	
	if lk&LINK_MARKER_BOTTOM_LEFT>0 and c:IsLocation(LOCATION_MZONE) and seq>0 then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(seq>4) and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base-1) then
			zone=zone|(0x1<<(base-1+loct))
		end
	end
	if lk&LINK_MARKER_BOTTOM>0 and c:IsLocation(LOCATION_MZONE) then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(type(xct)=="number") and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base) then
			zone=zone|(0x1<<(base+loct))
		end
	end
	if lk&LINK_MARKER_BOTTOM_RIGHT>0 and c:IsLocation(LOCATION_MZONE) and seq~=4 then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(type(xct)=="number") and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base+1) then
			zone=zone|(0x1<<(base+1+loct))
		end
	end
	if lk&LINK_MARKER_LEFT>0 and seq<5 and seq~=0 then
		local loct=(c:IsLocation(LOCATION_MZONE)) and 0 or 8
		local floc=(c:IsLocation(LOCATION_MZONE)) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,seq-1) then
			zone=zone|(0x1<<(seq-1+loct))
		end
	end
	if lk&LINK_MARKER_RIGHT>0 and seq<5 and seq~=4 then
		local loct=(c:IsLocation(LOCATION_MZONE)) and 0 or 8
		local floc=(c:IsLocation(LOCATION_MZONE)) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,seq+1) then
			zone=zone|(0x1<<(seq+1+loct))
		end
	end
	if lk&LINK_MARKER_TOP_LEFT>0 and ((c:IsLocation(LOCATION_SZONE) and seq>0) or tlchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		if not free or free(c,LOCATION_MZONE,base-1,locp) then
			zone=zone|(0x1<<(base-1+loct))
		end
	end
	if lk&LINK_MARKER_TOP>0 and (c:IsLocation(LOCATION_SZONE) or tchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		if not free or free(c,LOCATION_MZONE,base,locp) then
			zone=zone|(0x1<<(base+loct))
		end
	end
	if lk&LINK_MARKER_TOP_RIGHT>0 and ((c:IsLocation(LOCATION_SZONE) and seq~=4) or trchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		if not free or free(c,LOCATION_MZONE,base+1,locp) then
			zone=zone|(0x1<<(base+1+loct))
		end
	end
	return zone
end