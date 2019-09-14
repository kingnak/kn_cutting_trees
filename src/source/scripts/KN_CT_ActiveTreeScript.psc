Scriptname KN_CT_ActiveTreeScript extends ReferenceAlias Hidden 


FormList Property CuttingAxes Auto
KN_CT_TreeManagementScript Property Manager Auto
MiscObject Property WoodResource Auto
Message Property MsgAlreadyHarvested Auto

int Property HitCount = 0 Auto
int Property MaxHitCount = 3 Auto
bool Property WasHarvested = false Auto
bool Property IsFreshHit = false  Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, \
  bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if (akAggressor == Game.GetPlayer())
		if (CuttingAxes.HasForm(akSource))
			if (WasHarvested)
				if (!IsFreshHit)
					MsgAlreadyHarvested.Show()
				endif
			else
				HitCount += 1
				if (HitCount >= MaxHitCount)
					akAggressor.AddItem(WoodResource)
					Manager.CutTree(self.GetReference())
					WasHarvested = true
					IsFreshHit = true
				endif
			endif
		endif
	endif
EndEvent

Function ActivateTree(bool enabled)
	WasHarvested = !enabled
	HitCount = 0
	IsFreshHit = false
EndFunction

bool Function IsIntermediateState()
	return (!WasHarvested && HitCount > 0)
EndFunction

Function ResetFreshState()
	IsFreshHit = false
EndFunction
