Scriptname KN_CT_TreeManagementScriptLite extends KN_CT_TreeManagementScript Hidden

Function RegisterInit()
	; Debug.Notification("KN Cutting Trees Light init")
	UnregisterForUpdate()
EndFunction

Function GotoWoodcutting()
	UnregisterForUpdate()
	GotoState("CanCut")
	ClearActiveTrees()
	RegisterForSingleUpdate(0.1)
	; Debug.Notification("now cutting")
EndFunction

Function GotoIdle()
	UnregisterForUpdate()
	GotoState("Idle")
	ClearActiveTrees()
	RegisterForUpdate(1)
	; Debug.Notification("now idle")
EndFunction

Auto State Idle
	Event OnUpdate()
		; float s = Utility.GetCurrentRealTime()
		if (IsWoodcuttingEnabled(true))
			GotoWoodcutting()
		else
			RegisterForSingleUpdate(1)
		endif
		; float d = Utility.GetCurrentRealTime() - s
		; Debug.Notification("Idle Check " + d)
	EndEvent
EndState

State CanCut
	Event OnUpdate()
		if (IsWoodcuttingEnabled(true))		
			FindTrees()
			RegisterForSingleUpdate(5)
		else
			GotoIdle()
		endif
	EndEvent
EndState
