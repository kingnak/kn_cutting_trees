Scriptname KN_CT_TreeManagementScript extends Quest Hidden

FormList Property WoodCuttingAxes Auto
FormList Property CuttableTrees Auto
KeyWord Property IsActiveTree Auto
KeyWord Property IsDisabledTree Auto
float Property TreeRefreshTime = 72.0 Auto

int tryCount
int activeTreeCount
int disabledTreeCount
int nextDisabledIdx = 0
int[] aIdx
int[] dIdx

Event OnInit()
	activeTreeCount = 5
	tryCount = activeTreeCount * 2
	aIdx = new int[10]
	
	; Initialize indices for active trees
	int i = 0
	while (i < activeTreeCount && i < 10)
		aIdx[i] = i
		i += 1
	endwhile
	
	disabledTreeCount = 10
	int dOff = activeTreeCount
	
	; Initialize indices for disabled trees
	i = 0
	dIdx = new int[10]
	while (i < disabledTreeCount && i < 10)
		dIdx[i] = i + dOff
		i += 1
	endwhile

	; Clear all
	i = 0
	while (i < activeTreeCount)
		GetActiveAlias(i).Clear()
		i += 1
	endwhile
	i = 0
	while (i < disabledTreeCount)
		GetDisabledAlias(i).Clear()
		i += 1
	endwhile

	RegisterForActorAction(7)
	RegisterForActorAction(9)
	RegisterForSingleUpdateGameTime(1)
	RefreshDisabledTrees()
EndEvent

Event OnUpdateGameTime()
	RefreshDisabledTrees()
	RegisterForSingleUpdateGameTime(1)
EndEvent

Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if (actionType == 7)
		; Draw
		if (WoodCuttingAxes.HasForm(source))
			GotoState("CanCut")
			RegisterForSingleUpdate(0.1)
		endif
	elseif (actionType == 9)
		; Sheath
		GotoState("Idle")
		UnregisterForUpdate()
		ClearActiveTrees()
	endif
EndEvent

Auto State Idle
	Event OnUpdate()
	EndEvent
EndState

State CanCut
	Event OnUpdate()
		;Debug.Notification("Checking for trees...")
		
		ObjectReference[] treeCandidates = new ObjectReference[10]
		bool[] isEnbledCandidate = new bool[10]
		int i = 0
		int foundCount = 0
		
		float startF = Utility.GetCurrentRealTime()
		; Check closest first
		ObjectReference foundTree = \
			Game.FindClosestReferenceOfAnyTypeInListFromRef(CuttableTrees, Game.GetPlayer(), 1000)
		if (foundTree)
			treeCandidates[foundCount] = foundTree
			foundCount += 1
			;Debug.Notification("Found a candidate!")
		endif
		
		FastAssignTree(foundTree)
		
		int searchIncrease = 0
		int localFailCount = 0
		; Check random in surrounding
		while (i < tryCount && foundCount < activeTreeCount && searchIncrease <= 1500)
			foundTree = \
				Game.FindRandomReferenceOfAnyTypeInListFromRef(CuttableTrees, Game.GetPlayer(), 1000 + searchIncrease)
			i += 1
			
			if (foundTree)
				int k = 0
				while (k < foundCount && foundTree)
					if (treeCandidates[k] == foundTree)
						foundTree = none
						localFailCount += 1
					endif
					k += 1
				endwhile
				if (foundTree)
					treeCandidates[foundCount] = foundTree
					foundCount += 1
					;Debug.Notification("Found a candidate!")
				endif
			else
				localFailCount = 100
			endif
			if (localFailCount > 1)
				searchIncrease += 500
				localFailCount = 0
			endif
		endwhile
		float duration = Utility.GetCurrentRealTime() - startF
		;Debug.Notification("Tree search: " + duration)
		
		AssignTrees(treeCandidates, foundCount)
		duration = Utility.GetCurrentRealTime() - startF
		;Debug.Notification("Total: " + duration)
		
		RegisterForSingleUpdate(15)
	EndEvent
EndState

Function RefreshDisabledTrees()
	; Debug.Notification("Clearing trees...")
	int i = nextDisabledIdx + 1
	int j = 0
	; int ct = 0
	while (j < disabledTreeCount)
		KN_CT_DisabledTreeScript t = GetDisabledAlias(i)
		if (t.CutTime + TreeRefreshTime/24.0 < Utility.GetCurrentGameTime())
			;if (t.GetRef())
				; ct += 1
			;endif
			t.Clear()
		endif
		i = (i + 1) % disabledTreeCount
		j += 1
	endwhile
	; Debug.Notification("Cleared " + ct + " trees")
EndFunction

Function CutTree(ObjectReference arTree)
	KN_CT_DisabledTreeScript x = GetDisabledAlias(nextDisabledIdx)
	x.ForceRefTo(arTree)
	x.CutTime = Utility.GetCurrentGameTime()
	
	nextDisabledIdx = (nextDisabledIdx + 1) % disabledTreeCount
EndFunction

bool Function CheckCandidate(ObjectReference akTree)
	int j = 0
	if (!akTree)
		return false
	endif
	while (j < disabledTreeCount)
		if (akTree == GetDisabledAlias(j).GetRef())
			;Debug.Notification("Tree is disabled")
			return false
		endif
		j += 1
	endwhile
	
	return true
EndFunction

Function AssignTrees(ObjectReference[] candidates, int numCandidates)
	int i = 0
	
	; float f2 = Utility.GetCurrentRealTime()
	; Find re-assignable trees (and clear them)
	; This also clears candidates that are already assigned
	bool canAssign = true
	i = 0
	while (i < activeTreeCount)
		int j = 0
		canAssign = true
		KN_CT_ActiveTreeScript cur = GetActiveAlias(i)
		if (cur.IsIntermediateState())
			while (j < numCandidates)
				if (candidates[j] && cur.GetRef() == candidates[j])
					;Debug.Notification("Tree " + i + " has candidate " + j + " assigned")
					candidates[j] = none
					canAssign = false
					j = numCandidates
				endif
				j += 1
			endwhile
		endif
		
		if (canAssign)
			;Debug.Notification("Clearing tree "+i)
			cur.Clear()
		endif
		
		i += 1
	endwhile
	
	; float f3 = Utility.GetCurrentRealTime()
	; float d2 = f3 - f2
	; Debug.Notification("Find assignable: " + d2)
	; f3 = Utility.GetCurrentRealTime()
	
	; Assign new trees
	i = 0
	int j = 0
	; int aCt = 0
	; int dCt = 0
	while (i < numCandidates)
		if (candidates[i])
			bool found = false
			while (!found && j < activeTreeCount)
				KN_CT_ActiveTreeScript cur = GetActiveAlias(j)
				if (cur.ForceRefIfEmpty(candidates[i]))
					found = true
					bool isEnabled = CheckCandidate(candidates[i])
					; if (isEnabled)
						; aCt += 1
					; else
						; dCt += 1
					; endif
					cur.ActivateTree(isEnabled)
				endif
				j += 1
			endwhile
		endif
		i += 1
	endwhile
	
	; float f4 = Utility.GetCurrentRealTime()
	; float d3 = f4 - f3
	; Debug.Notification("Assign: " + d3)
	; Debug.Notification("Have " + aCt + " active and " + dCt + " dissabled trees")
	
EndFunction

Function FastAssignTree(ObjectReference akTree)
	if (!akTree) 
		return
	endif
	
	int i = 0
	int candidate = 0
	while (i < activeTreeCount)
		KN_CT_ActiveTreeScript cur = GetActiveAlias(i)
		if (cur.GetRef() == akTree)
			return
		endif
		if (!cur.IsIntermediateState())
			candidate = i
		endif
		i += 1
	endwhile
	
	KN_CT_ActiveTreeScript c = GetActiveAlias(candidate)
	c.ForceRefTo(akTree)
	c.ActivateTree(CheckCandidate(akTree))
	;Debug.Notification("Fast assigned tree")
EndFunction

KN_CT_DisabledTreeScript Function GetDisabledAlias(int i)
	if (i >= disabledTreeCount)
		return none
	endif
	return (GetNthAlias(dIdx[i])) as KN_CT_DisabledTreeScript
EndFunction

KN_CT_ActiveTreeScript Function GetActiveAlias(int i)
	if (i >= activeTreeCount)
		return none
	endif
	return (GetNthAlias(aIdx[i])) as KN_CT_ActiveTreeScript
EndFunction

Function ClearActiveTrees()
	int i = 0
	while (i < activeTreeCount)
		GetActiveAlias(i).Clear()
		i += 1
	endwhile
EndFunction
