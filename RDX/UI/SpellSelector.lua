-- SpellSelector.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE LICENCE.
-- UNLICENSED COPYING IS PROHIBITED.
--
-- A custom control that allows the entry and selection of spells from a list.
RDXUI.SpellSelector = {};

function RDXUI.SpellSelector:new(parent)
	local spellEdit = VFLUI.LabeledEdit:new(parent, 200);
	spellEdit:SetText(i18n("Spell Name")); 

	local btn = VFLUI.Button:new(spellEdit);
	btn:SetHeight(25); 
	btn:SetWidth(25); 
	btn:SetText("...");
	btn:SetPoint("RIGHT", spellEdit.editBox, "LEFT");
	btn:Show();
	btn:SetScript("OnClick", function()
		local qq = { };
		for spell,_ in pairs(RDXSS.GetAllSpells()) do
			local retVal = spell;
			table.insert(qq, { 
				text = retVal, 
				OnClick = function() 
					VFL.poptree:Release();
					spellEdit.editBox:SetText(retVal);
				end
			});
		end
		table.sort(qq, function(x1,x2) return tostring(x1.text) < tostring(x2.text); end);
		VFL.poptree:Begin(200, 12, btn, "CENTER");
		VFL.poptree:Expand(nil, qq, 20);
	end);

	function spellEdit:GetSpell()
		return spellEdit.editBox:GetText();
	end
	function spellEdit:SetSpell(sp)
		spellEdit.editBox:SetText(sp);
	end

	spellEdit.Destroy = VFL.hook(function(s)
		s.GetSpell = nil; s.SetSpell = nil;
		btn:Destroy(); btn = nil;
	end, spellEdit.Destroy);

	return spellEdit;
end
