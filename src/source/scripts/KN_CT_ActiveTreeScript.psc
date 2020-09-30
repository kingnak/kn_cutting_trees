Scriptname KN_CT_ActiveTreeScript extends ReferenceAlias Hidden 

KN_CT_TreeManagementScript Property Manager Auto
Message Property MsgAlreadyHarvested Auto

int Property HitCount = 0 Auto
int Property MaxHitCount = 3 Auto
bool Property WasHarvested = false Auto
bool Property IsFreshHit = false  Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, \
  bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if (akAggressor == Game.GetPlayer())
		if (Manager.IsCuttingAxe(akSource))
			if (WasHarvested)
				if (!IsFreshHit)
					MsgAlreadyHarvested.Show()
				endif
			else
				Harvest()
			endif
		endif
	endif
EndEvent

Function Harvest()
	HitCount += 1
	if (HitCount >= MaxHitCount)
		; Don't show message while dropping
		IsFreshHit = true
		WasHarvested = true
		Manager.CutTree(self.GetReference())
		MiscObject res = Manager.GetDroppedWoodResource()
		; Debug.Notification("Dropping " + res.GetFormID())
		DropAtPlayer(res)
		if (Manager.GetExtraResource())
			; Debug.Notification("Dropping extra")
			res = Manager.GetDroppedWoodResource()
			DropAtPlayer(res)
		endif
		; Now we can show message
		IsFreshHit = false
	endif
EndFunction

Function DropAtPlayer(MiscObject object)
	float fAngZ = Game.GetPlayer().GetAngleZ()
	ObjectReference resRef = Game.GetPlayer().PlaceAtMe(object)
	resRef.MoveTo(Game.GetPlayer(), 95*Math.Sin(fAngZ), 95*Math.Cos(fAngZ), 75, true)
EndFunction

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
