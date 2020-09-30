Scriptname KN_CT_TreeManagementScriptLite extends KN_CT_TreeManagementScript Hidden

int Property DropProbability_1 auto
int Property DropProbability_2 auto
int Property DropProbability_3 auto
int Property DropProbability_4 auto
FormList Property DroppedWoodList Auto

Function RegisterInit()
	; Debug.Notification("KN Cutting Trees Light init")
	UnregisterForUpdate()
EndFunction

Function UpdateDynamicDropProbabilities()
	ClearDynamicDropItems()

	if (DroppedWoodList.GetSize() <= 0)
		return
	endif
	
	int i = 0
	while (i < DroppedWoodList.GetSize() && i < 10)
		int prob = 0
		if (i == 0)
			prob = DropProbability_1
		elseif (i == 1)
			prob = DropProbability_2
		elseif (i == 2)
			prob = DropProbability_3
		elseif (i == 3)
			prob = DropProbability_4
		endif
		if (prob <= 0)
			prob = 1
		endif
		
		MiscObject resource = DroppedWoodList.GetAt(i) as MiscObject
		AddDynamicDropItem(resource, prob)
		i += 1
	endwhile
	
	DumpDynamicDropItems()
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
