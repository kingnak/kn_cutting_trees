Scriptname KN_CT_TreeManagementScriptSKSE extends KN_CT_TreeManagementScript Hidden

Import StringUtil

FormList Property DroppedWoodList Auto
String Property DropProbabilities = "1" auto

Function RegisterInit()
	;Debug.Notification("KN Cutting Trees SKSE init")
	UpdateDynamicDropProbabilities()
	
	UnregisterForActorAction(7)
	UnregisterForActorAction(9)
	
	RegisterForActorAction(7)
	RegisterForActorAction(9)
EndFunction

Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if (actionType == 7)
		; Draw
		if (IsWoodcuttingEnabled(false))
			GotoWoodcutting()
		else
			GotoIdle()
		endif
	elseif (actionType == 9)
		; Sheath
		GotoIdle()
	endif
EndEvent

Function GotoWoodcutting()
	GotoState("CanCut")
	ClearActiveTrees()
	RegisterForSingleUpdate(0.1)
	; Debug.Notification("now cutting")
EndFunction

Function GotoIdle()
	GotoState("Idle")
	UnregisterForUpdate()
	ClearActiveTrees()
	; Debug.Notification("now idle")
EndFunction

Auto State Idle
	Event OnUpdate()
	EndEvent
EndState

State CanCut
	Event OnUpdate()
		FindTrees()
		RegisterForSingleUpdate(5)
	EndEvent
EndState

int dropProbSum
int[] dropProbs
MiscObject[] dropResources

MiscObject Function GetDroppedWoodResource()
	int max = dropProbSum
	max -= 1
	int rnd = Utility.RandomInt(0, max)
	int i = 0
	while (rnd >= dropProbs[i] && dropProbs[i] > 0 && i < 10)
		rnd -= dropProbs[i]
		i += 1
	endwhile
	return dropResources[i]
EndFunction

Function UpdateDynamicDropProbabilities()
	int i = 0
	dropProbs = new int[10]
	dropResources = new MiscObject[10]
	while (i < 10)
		dropProbs[i] = 0
		dropResources[i] = none
		i += 1
	endwhile

	bool ok = true
	dropProbSum = 0
	i = 0
	String dp = DropProbabilities
	while (i < 10 && i < DroppedWoodList.GetSize() && ok)
		; Get next probabilty (or reminder, of at end)
		String curProbStr = dp
		int pos = Find(dp, ",")
		if (pos >= 0)
			curProbStr = Substring(dp, 0, pos)
			dp = Substring(dp, pos+1)
		endif
		
		int curProbInt = 0
		if (GetLength(curProbStr) > 0)
			; Convert to number
			int j = 0
			while (j < GetLength(curProbStr) && ok)
				String curChar = Substring(curProbStr, j, 1)
				if (IsDigit(curChar))
					curProbInt *= 10
					curProbInt += AsOrd(curChar)
					curProbInt -= 48 ; Simple ASCII calculation
				else
					ok = false
				endif
				j += 1
			endwhile
			
			if (curProbInt == 0)
				curProbInt = 1
			endif
		else
			; Nothing more, rest will be 1
			dp = ""
			curProbInt = 1
		endif
		
		MiscObject resource = DroppedWoodList.GetAt(i) as MiscObject
		if (resource)
			dropProbSum += curProbInt
			dropProbs[i] = curProbInt
			dropResources[i] = resource
			;Debug.Notification("Assigned at " + i + " with prob " + dropProbs[i] + ": " + dropResources[i].GetFormID())
		endif
		i += 1
	endwhile
	
	; Error, go back to default
	if (!ok)
		;Debug.Notification("NOT OK")
		i = 0
		while (i < 10)
			dropProbs[i] = 0
			dropResources[i] = none
			i += 1
		endwhile

		dropProbSum = 1
		dropProbs[0] = 1
		dropResources[0] = DefaultDropResource
	endif
	
	; Debug
	; i = 0
	; while (i < 10)
		; Debug.Notification(i + ": " + dropProbs[i] + " for " + dropResources[i])
		; i += 1
	; endwhile
EndFunction
