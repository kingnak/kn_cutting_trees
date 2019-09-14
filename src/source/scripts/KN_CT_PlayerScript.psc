Scriptname KN_CT_PlayerScript extends ReferenceAlias Hidden 

KN_CT_TreeManagementScript Property TreeManager Auto

Event OnPlayerLoadGame()
	; Debug.Notification("KN CT Loading")
	TreeManager.Init()
EndEvent
