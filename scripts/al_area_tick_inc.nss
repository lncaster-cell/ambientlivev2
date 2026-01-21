#include "al_constants_inc"
#include "al_npc_reg_inc"

// Shared Area tick helper: scheduled every 45s while players are present.
// NPC registry synchronization is handled here at the area level only.

const float AL_TICK_PERIOD = 45.0;
const int AL_SYNC_TICK_INTERVAL = 4;

int AL_IsRelevantRouteTag(string sTag)
{
    if (sTag == "AL_WP_PACE")
    {
        return TRUE;
    }

    if (sTag == "AL_WP_WWP")
    {
        return TRUE;
    }

    if (sTag == "AL_WP_S0" || sTag == "AL_WP_S1" || sTag == "AL_WP_S2")
    {
        return TRUE;
    }

    if (sTag == "AL_WP_S3" || sTag == "AL_WP_S4" || sTag == "AL_WP_S5")
    {
        return TRUE;
    }

    return FALSE;
}

void AL_CacheAreaRoutes(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, "al_routes_cached"))
    {
        return;
    }

    object oObj = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT)
        {
            string sTag = GetTag(oObj);
            if (AL_IsRelevantRouteTag(sTag))
            {
                string sAreaPrefix = "al_route_" + sTag + "_";
                int iCount = GetLocalInt(oArea, sAreaPrefix + "n");
                string sIndex = sAreaPrefix + IntToString(iCount);
                SetLocalLocation(oArea, sIndex, GetLocation(oObj));
                int nActivity = GetLocalInt(oObj, "al_activity");
                if (nActivity > 0)
                {
                    SetLocalInt(oArea, sIndex + "_activity", nActivity);
                }
                else
                {
                    DeleteLocalInt(oArea, sIndex + "_activity");
                }

                DeleteLocalLocation(oArea, sIndex + "_jump");
                // Transition setup is pre-seeded via toolset/bootstrap:
                // - Preferred: set a local location on the waypoint: "al_transition_location".
                // - Alternative: set a local object area: "al_transition_area" + x/y/z/facing.
                // Avoid tag lookups in runtime hot paths.
                location lJump = GetLocalLocation(oObj, "al_transition_location");
                object oJumpArea = GetAreaFromLocation(lJump);
                if (GetIsObjectValid(oJumpArea))
                {
                    SetLocalLocation(oArea, sIndex + "_jump", lJump);
                }
                else
                {
                    object oTargetArea = GetLocalObject(oObj, "al_transition_area");
                    if (GetIsObjectValid(oTargetArea))
                    {
                        float fX = GetLocalFloat(oObj, "al_transition_x");
                        float fY = GetLocalFloat(oObj, "al_transition_y");
                        float fZ = GetLocalFloat(oObj, "al_transition_z");
                        float fFacing = GetLocalFloat(oObj, "al_transition_facing");
                        location lResolvedJump = Location(oTargetArea, Vector(fX, fY, fZ), fFacing);
                        SetLocalLocation(oArea, sIndex + "_jump", lResolvedJump);
                    }
                }

                iCount++;
                SetLocalInt(oArea, sAreaPrefix + "n", iCount);
            }
        }

        oObj = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, "al_routes_cached", TRUE);
}

int AL_ComputeTimeSlot()
{
    int iSlot = GetTimeHour() / 4;
    if (iSlot < 0)
    {
        iSlot = 0;
    }
    else if (iSlot > AL_SLOT_MAX)
    {
        iSlot = AL_SLOT_MAX;
    }

    return iSlot;
}

void AreaTick(object oArea, int nToken)
{
    if (GetLocalInt(oArea, "al_player_count") <= 0)
    {
        return;
    }

    if (nToken != GetLocalInt(oArea, "al_tick_token"))
    {
        return;
    }

    int iSyncTick = GetLocalInt(oArea, "al_sync_tick") + 1;
    int bSynced = FALSE;
    if (iSyncTick >= AL_SYNC_TICK_INTERVAL)
    {
        iSyncTick = 0;
        AL_SyncAreaNPCRegistry(oArea);
        bSynced = TRUE;
    }
    SetLocalInt(oArea, "al_sync_tick", iSyncTick);

    int iSlot = AL_ComputeTimeSlot();

    if (iSlot == GetLocalInt(oArea, "al_slot"))
    {
        DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
        return;
    }

    if (!bSynced)
    {
        AL_SyncAreaNPCRegistry(oArea);
    }
    SetLocalInt(oArea, "al_slot", iSlot);
    AL_BroadcastUserEvent(oArea, AL_EVT_SLOT_BASE + iSlot);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
}
