-- TODO :)
-- _DBG("======== KvCE START RelationshipDialogs")
-- function GetCampRequiredTalks()
--     local tab1 = Osi.DB_Camp_RequiredTalks:Get(nil)
--     local tab2 = Osi.DB_Camp_RequiredTalks:Get(nil, nil)
-- end
-- IF DB_Camp_RequiredTalks(_Var1, _, _Var1, _Var1, _Var1)
-- THEN
--     PROC_LoopEffect(EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80, _Var1, "GLO_Camp_RequiredTalk", "__ANY__", "Dummy_OverheadFX");
local function GetPendingRelationshipDialogs()
    -- PROC PROC_Test_RelationshipDialog_Queue()
    --     AND DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, _Var4, _Var5, _Var6, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_RelationshipDialog_WorldCategory(_Var4, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_HandlingRelationshipDialog(_Var1, _, _, _, _, _, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_CantTalk(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_InCamp(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_PartyDialogSuppressed_CheckRelationshipDialogAllowed(_Var1, _Var2, _Var3, _Var1, _Var1)
    -- THEN
    --     PROC_LoopEffect(EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80, _Var1, "RelationshipMarker", "__ANY__", "Dummy_OverheadFX");
    --     NOT DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, _Var4, _Var5, _Var6);
    --     DB_HandlingRelationshipDialog(_Var1, _Var2, _Var3, _Var4, _Var5, _Var6);

    -- PROC PROC_Test_RelationshipDialog_Queue()
    --     AND DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, "WORLDORCAMP", _Var4, _Var5, _Var1, _Var1, _Var1, _Var1)
    --     AND DB_InCamp(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_Camp_NightMode(1, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_HandlingRelationshipDialog(_Var1, _, _, _, _, _, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_CantTalk(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_PartyDialogSuppressed_CheckRelationshipDialogAllowed(_Var1, _Var2, _Var3, _Var1, _Var1)
    -- THEN
    --     PROC_LoopEffect(EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80, _Var1, "RelationshipMarker", "__ANY__", "Dummy_OverheadFX");
    --     NOT DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, "WORLDORCAMP", _Var4, _Var5);
    --     DB_HandlingRelationshipDialog(_Var1, _Var2, _Var3, "WORLDORCAMP", _Var4, _Var5);

    -- PROC PROC_Try_CampRelationshipDialog((CHARACTER)_Var1, 1, (CHARACTER)_Var1, (CHARACTER)_Var1, (CHARACTER)_Var1)
    --     AND DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, "CAMP", _Var4, _Var5, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_ValidForCRD(_Var1, _Var1, _Var1, _Var1, _Var1)
    -- THEN
    --     DB_HandlingRelationshipDialog(_Var1, _Var2, _Var3, "CAMP", _Var4, _Var5);
    --     NOT DB_RelationshipDialog_Queue(_Var1, _Var2, _Var3, "CAMP", _Var4, _Var5);
    --     PROC_LoopEffect(EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80, _Var1, "RelationshipMarker", "__ANY__", "Dummy_OverheadFX");

end

-- _DBG("==== KvCE END RelationshipDialogs")
