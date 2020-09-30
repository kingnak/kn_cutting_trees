Scriptname KN_CT_TreeManagementSKSE_Campfire extends KN_CT_TreeManagementScriptSKSE Hidden

GlobalVariable Property ResourceFull_Level Auto
GlobalVariable Property ResourceFull_Max Auto

bool Function GetExtraResource()
	float level = ResourceFull_Level.GetValue()
	float max = ResourceFull_Max.GetValue()
	if (max > 0)
		float compare = level/max
		compare /= 2 ; Maximum 50%
		float rnd = Utility.RandomFloat(0, 1)
		return rnd < compare
	endif
	return false
EndFunction
