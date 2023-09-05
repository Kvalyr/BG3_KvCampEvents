-- print("======== KvCE START Debugging")

local DB = KVS.DB

Debug = {}


local function RegisterPrintOnEvent(proc_event, num_params, before_or_after, post_func)
    if num_params == nil then num_params = 0 end
    if not before_or_after then before_or_after = "before" end
    -- if post_func == nil then do_dump_dbs = false end

    Ext.Osiris.RegisterListener(proc_event, num_params, before_or_after, function (...)
        print("======================================")
        _P(proc_event, "<"..string.upper(before_or_after)..">", "Params:", ...)
        print("=================")

        if type(post_func) == "function" then
            post_func()
        end

    end)
end


function DebugCampNightProcs()

    local campQueuedDBs = {}
    -- campQueuedDBs["DB_CampNight_Camp"] = 2
    -- campQueuedDBs["DB_CampNight"] = 1
    campQueuedDBs["DB_FallbackCamp_InCamp"] = 1
    campQueuedDBs["DB_Camp_BestCampNight"] = 2
    campQueuedDBs["DB_Camp_QueuedNight"] = 1
    campQueuedDBs["DB_Camp_QueuedSoloDream"] = 2
    campQueuedDBs["DB_Camp_QueuedMorningCFM"] = 1
    campQueuedDBs["DB_Camp_QueuedRomanceNight"] = 3
    campQueuedDBs["DB_Camp_QueuedSCO"] = 1
    campQueuedDBs["DB_Camp_QueuedAvatarDream"] = 1
    campQueuedDBs["DB_Camp_QueuedMorningIVB"] = 2
    campQueuedDBs["DB_Camp_QueuedMorningIVB"] = 2
    campQueuedDBs["DB_CampNight_Completed"] = 1
    campQueuedDBs["DB_Camp_RequiredTalks"] = 1
    -- campQueuedDBs["DB_CampNight_SleepIndividualDialogs"] = 2
    -- campQueuedDBs["DB_CampNight_CachedSleepExclusiveDialogs"] = 1
    -- campQueuedDBs["DB_CampNight_Requirement"] = 4

    local function DumpCampQueueDBs()
        print("Active Camp:" .. (GetActiveCamp()or "[UNKNOWN]"))
        for key, num_params in pairs(campQueuedDBs) do
            _P("DB Dump: " .. "'" .. key .. "'")
            DB.Dump(key, num_params)
            -- _D(db:Get())
        end
    end

    RegisterPrintOnEvent("DB_Camp_QueuedNight", 1, "before", function() DB.Dump("DB_Camp_QueuedNight", 1) end)
    RegisterPrintOnEvent("DB_Camp_QueuedNight", 1, "after", function() DB.Dump("DB_Camp_QueuedNight", 1) end)
    RegisterPrintOnEvent("DB_Camp_QueuedAvatarDream", 1, "before", function() DB.Dump("DB_Camp_QueuedAvatarDream", 1) end)
    RegisterPrintOnEvent("DB_Camp_QueuedAvatarDream", 1, "after", function() DB.Dump("DB_Camp_QueuedAvatarDream", 1) end)

    RegisterPrintOnEvent("PROC_Camp_EndEvening", nil, "before", nil)
    RegisterPrintOnEvent("PROC_Camp_EndEvening", nil, "after", nil)

    RegisterPrintOnEvent("PROC_CampNight_DecideCampNight", nil, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_DecideCampNight", nil, "after", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_DecideCampNight_Recursive", nil, "before", nil)
    RegisterPrintOnEvent("PROC_CampNight_DecideCampNight_Recursive", nil, "after", nil)

    RegisterPrintOnEvent("PROC_Camp_PlayCampNight", nil, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_Camp_PlayCampNight", nil, "after", DumpCampQueueDBs)

    RegisterPrintOnEvent("PROC_CampNight_PreSelection_Hook", nil, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_PreSelection_Hook", nil, "after", DumpCampQueueDBs)

    RegisterPrintOnEvent("PROC_CampNight_StartSelected", nil, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_StartSelected", nil, "after", DumpCampQueueDBs)

    RegisterPrintOnEvent("PROC_CampNight_LastDialogPlayed", nil, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_LastDialogPlayed", nil, "after", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_ForceComplete", 1, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_ForceComplete", 1, "after", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_ClearCampNight", 1, "before", DumpCampQueueDBs)
    RegisterPrintOnEvent("PROC_CampNight_ClearCampNight", 1, "after", DumpCampQueueDBs)

    RegisterPrintOnEvent("DB_Camp_RequiredTalks", 1, "before", function() DB.Dump("DB_Camp_RequiredTalks", 1) end)
    RegisterPrintOnEvent("DB_Camp_RequiredTalks", 1, "after", function() DB.Dump("DB_Camp_RequiredTalks", 1) end)
    RegisterPrintOnEvent("DB_Camp_RequiredTalks", 2, "before", function() DB.Dump("DB_Camp_RequiredTalks", 2) end)
    RegisterPrintOnEvent("DB_Camp_RequiredTalks", 2, "after", function() DB.Dump("DB_Camp_RequiredTalks", 2) end)
end
Debug.Enable = DebugCampNightProcs


-- DebugCampNightProcs()

-- print("==== KvCE END Debugging")