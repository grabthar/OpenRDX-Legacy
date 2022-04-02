--------------------------------------------------
-- Scripted variable type
--------------------------------------------------
RDX.RegisterFeature({
	name = "art_var_script";
	title = i18n("Variable: Scripted");
	category = i18n("Variables");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local md,_,_,ty = RDXDB.GetObjectData(desc.script);
		if (not md) or (ty ~= "Script") or (not md.data) or (not md.data.script) then
			VFL.AddError(errs, i18n("Invalid script pointer.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- Apply the custom code.
		local createCode = [[

]];
		createCode = createCode .. (RDXDB.GetObjectData(desc.script)).data.script;
		createCode = createCode .. [[

]];

		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local scriptsel = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Script")); end);
		scriptsel:SetLabel(i18n("Script object")); scriptsel:Show();
		if desc and desc.script then scriptsel:SetPath(desc.script); end
		ui:InsertFrame(scriptsel);

		function ui:GetDescriptor()
			return { 
				feature = "art_var_script";
				script = scriptsel:GetPath();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "art_var_script", 
		};
	end;
});