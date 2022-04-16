--Thaumic Emperor Threefold Kerbecs
--Scripted by Nekro
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.filter,3,3,s.lcheck)
end

function s.lcheck(g,lc,tp)
	return g:GetClassCount(Card.GetAttribute)==#g
end