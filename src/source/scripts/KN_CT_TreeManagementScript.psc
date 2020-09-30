Scriptname KN_CT_TreeManagementScript extends Quest Hidden

Message Property MsgAlreadyHarvested Auto
FormList Property WoodCuttingAxes Auto
FormList Property CuttableTrees Auto
MiscObject Property DefaultDropResource Auto
float Property TreeRefreshTime = 72.0 Auto
int Property nextDisabledIdx = 0 Auto

int tryCount = 10
int activeTreeCount = 5
int disabledTreeCount = 10
int activeTreeBase = 40
int disabledTreeBase = 50

int dropProbSum
int[] dropProbs
MiscObject[] dropResources

Event OnInit()
	; Clear all
	int i = 0
	while (i < activeTreeCount)
		GetActiveAlias(i).Clear()
		i += 1
	endwhile
	i = 0
	while (i < disabledTreeCount)
		GetDisabledAlias(i).Clear()
		i += 1
	endwhile
	
	Init()
EndEvent

Function Init()
	UnregisterForUpdateGameTime()
	
	dropProbs = new int[10]
	dropResources = new MiscObject[10]
	ClearDynamicDropItems()
	
	InitializeTrees()
	UpdateDynamicDropProbabilities()
	
	RegisterForSingleUpdateGameTime(1)
	RefreshDisabledTrees()
	
	RegisterInit()
	
	; Start in CanCut State?
	if (IsWoodcuttingEnabled(true))
		GotoWoodcutting()
	else
		GotoIdle()
	endif
EndFunction

Function RegisterInit()
	; Abstract method. Initialize updates for changing states
EndFunction

bool Function IsCuttingAxe(Form akAxe)
	return WoodCuttingAxes.HasForm(akAxe)
EndFunction

bool Function IsWoodcuttingEnabled(bool checkDrawn)
	if (!checkDrawn || Game.GetPlayer().IsWeaponDrawn())
		return (IsCuttingAxe(Game.GetPlayer().GetEquippedWeapon(false)) || IsCuttingAxe(Game.GetPlayer().GetEquippedWeapon(true)))
	endif
	return false
EndFunction

Function GotoWoodcutting()
	; Abstract method. Goto Woodcutting state
EndFunction

Function GotoIdle()
	; Abstract mehtod. Goto Idle state
EndFunction

Event OnUpdateGameTime()
	RefreshDisabledTrees()
	RegisterForSingleUpdateGameTime(1)
EndEvent

Function UpdateDynamicDropProbabilities()
	ClearDynamicDropItems()
EndFunction

Function ClearDynamicDropItems()
	int i = 0
	while (i < 10)
		dropProbs[i] = 0
		dropResources[i] = none
		i += 1
	endwhile
	dropProbSum = 0
EndFunction

Function DumpDynamicDropItems()
	; Debug
	; int i = 0
	; if (dropProbSum == 0)
		; Debug.Notification("No dynamic drop items")
		; return
	; endif
	; Debug.Notification("Probability sum: " + dropProbSum)
	; while (i < 10)
		; Debug.Notification(i + ": " + dropProbs[i] + " for " + dropResources[i])
		; i += 1
	; endwhile
EndFunction

Function AddDynamicDropItem(MiscObject object, int prob)
	; Debug.Notification("Adding :" + prob + ": " + object.GetFormID())
	if (object == none || prob < 1)
		return
	endif
	int i = 0
	int sum = 0
	while (i < 10 && dropResources[i] != none)
		sum += dropProbs[i]
		i += 1
	endwhile
	if (i < 10)
		dropProbs[i] = prob
		dropResources[i] = object
		sum += prob
		dropProbSum = sum
		; Debug.Notification("Assigned at " + i + " with prob " + dropProbs[i] + ": " + dropResources[i].GetFormID())
	endif
EndFunction

Function InitializeTrees()
	int i = 0
	while (i < activeTreeCount)
		GetActiveAlias(i).manager = self
		GetActiveAlias(i).MsgAlreadyHarvested = MsgAlreadyHarvested
		i += 1
	endwhile
EndFunction

Function FindTrees()
	; Debug.Notification("Checking for trees...")
		
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
	; Debug.Notification("Total: " + duration)
EndFunction

Function RefreshDisabledTrees()
	; Debug.Notification("Clearing trees...")
	int i = nextDisabledIdx + 1
	int j = 0
	; int ct = 0
	while (j < disabledTreeCount)
		KN_CT_DisabledTreeScript t = GetDisabledAlias(i)
		if (t.CutTime + TreeRefreshTime/24.0 < Utility.GetCurrentGameTime())
			; if (t.GetRef())
				; ct += 1
			; endif
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

MiscObject Function GetDroppedWoodResource()
	if (dropProbSum <= 0)
		return DefaultDropResource
	endif
	
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

bool Function GetExtraResource()
	return false
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
					cur.ResetFreshState()
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
			; Debug.Notification("Fast assigned tree is same")
			cur.ResetFreshState()
			return
		endif
		if (!cur.IsIntermediateState())
			candidate = i
		endif
		i += 1
	endwhile
	
	KN_CT_ActiveTreeScript c = GetActiveAlias(candidate)
	c.ActivateTree(CheckCandidate(akTree))
	c.ForceRefTo(akTree)
	; Debug.Notification("Fast assigned tree")
EndFunction

KN_CT_DisabledTreeScript Function GetDisabledAlias(int i)
	if (i < 0 || i >= disabledTreeCount)
		return none
	endif
	return (GetAlias(disabledTreeBase+i)) as KN_CT_DisabledTreeScript
EndFunction

KN_CT_ActiveTreeScript Function GetActiveAlias(int i)
	if (i < 0 || i >= activeTreeCount)
		return none
	endif
	return (GetAlias(activeTreeBase+i)) as KN_CT_ActiveTreeScript
EndFunction

Function ClearActiveTrees()
	int i = 0
	while (i < activeTreeCount)
		GetActiveAlias(i).Clear()
		i += 1
	endwhile
EndFunction

