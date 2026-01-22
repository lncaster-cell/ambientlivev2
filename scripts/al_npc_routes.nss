// NPC route helpers: store per-slot route locations in locals and enqueue actions.
// Locals format on NPC:
//   r<slot>_n      (int)    number of points
//   r<slot>_<idx>  (location) route point
// Runtime locals:
//   r_slot         (int)    active slot
//   r_idx          (int)    active index (optional)

#include "al_constants_inc"
#include "al_npc_reg_inc"

string AL_GetRoutePrefix(int nSlot)
{
    return "r" + IntToString(nSlot) + "_";
}

string AL_GetRouteTagKey(int nSlot)
{
    return AL_GetRoutePrefix(nSlot) + "tag";
}

string AL_GetRouteTag(object oNpc, int nSlot)
{
    return GetLocalString(oNpc, AL_GetRouteTagKey(nSlot));
}

string AL_GetDesiredRouteKey(int nSlot)
{
    return "alwp" + IntToString(nSlot);
}

string AL_GetDefaultRouteTag(int nSlot)
{
    return "AL_WP_S" + IntToString(nSlot);
}

string AL_GetDesiredRouteTag(object oNpc, int nSlot)
{
    string sKey = AL_GetDesiredRouteKey(nSlot);
    string sTag = GetLocalString(oNpc, sKey);
    if (sTag != "")
    {
        return sTag;
    }

    return AL_GetDefaultRouteTag(nSlot);
}

int AL_GetRouteCount(object oNpc, int nSlot)
{
    return GetLocalInt(oNpc, AL_GetRoutePrefix(nSlot) + "n");
}

location AL_GetRoutePoint(object oNpc, int nSlot, int iIndex)
{
    return GetLocalLocation(oNpc, AL_GetRoutePrefix(nSlot) + IntToString(iIndex));
}

int AL_GetRoutePointActivity(object oNpc, int nSlot, int iIndex)
{
    return GetLocalInt(oNpc, AL_GetRoutePrefix(nSlot) + IntToString(iIndex) + "_activity");
}

void AL_UpdateRouteIndex(object oNpc, int iIndex)
{
    SetLocalInt(oNpc, "r_idx", iIndex);
}

void AL_ClearActiveRoute(object oNpc, int bClearActions)
{
    if (bClearActions)
    {
        AssignCommand(oNpc, ClearAllActions());
    }

    DeleteLocalInt(oNpc, "r_slot");
    DeleteLocalInt(oNpc, "r_idx");
    DeleteLocalInt(oNpc, "r_active");
}

void AL_ClearRoute(object oNpc, int nSlot)
{
    string sPrefix = AL_GetRoutePrefix(nSlot);
    int iCount = GetLocalInt(oNpc, sPrefix + "n");
    int i = 0;

    while (i < iCount)
    {
        string sIndex = sPrefix + IntToString(i);
        DeleteLocalLocation(oNpc, sIndex);
        DeleteLocalLocation(oNpc, sIndex + "_jump");
        DeleteLocalInt(oNpc, sIndex + "_activity");
        i++;
    }

    DeleteLocalInt(oNpc, sPrefix + "n");
    DeleteLocalString(oNpc, AL_GetRouteTagKey(nSlot));
}

int AL_CacheRouteFromTag(object oNpc, int nSlot, string sTag)
{
    AL_ClearRoute(oNpc, nSlot);

    if (sTag == "")
    {
        return 0;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    string sPrefix = AL_GetRoutePrefix(nSlot);
    string sAreaPrefix = "al_route_" + sTag + "_";
    int iCount = GetLocalInt(oArea, sAreaPrefix + "n");
    int i = 0;

    while (i < iCount)
    {
        string sIndex = sPrefix + IntToString(i);
        string sAreaIndex = sAreaPrefix + IntToString(i);
        SetLocalLocation(oNpc, sIndex, GetLocalLocation(oArea, sAreaIndex));
        int nActivity = GetLocalInt(oArea, sAreaIndex + "_activity");
        if (nActivity > 0)
        {
            SetLocalInt(oNpc, sIndex + "_activity", nActivity);
        }
        else
        {
            DeleteLocalInt(oNpc, sIndex + "_activity");
        }

        DeleteLocalLocation(oNpc, sIndex + "_jump");
        location lJump = GetLocalLocation(oArea, sAreaIndex + "_jump");
        object oJumpArea = GetAreaFromLocation(lJump);
        if (GetIsObjectValid(oJumpArea))
        {
            SetLocalLocation(oNpc, sIndex + "_jump", lJump);
        }

        i++;
    }

    if (iCount > 0)
    {
        SetLocalInt(oNpc, sPrefix + "n", iCount);
        SetLocalString(oNpc, AL_GetRouteTagKey(nSlot), sTag);
    }

    return iCount;
}

void AL_HandleRouteAreaTransition()
{
    object oNpc = OBJECT_SELF;

    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // Instant registry update on explicit route transitions (no per-NPC timers).
    AL_UnregisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        SetLocalObject(oNpc, "al_last_area", oArea);
        int nPlayerCount = GetLocalInt(oArea, "al_player_count");
        if (nPlayerCount <= 0)
        {
            // Protect zero-activity areas without PCs; activation happens via al_area_onenter.
            SetScriptHidden(oNpc, TRUE, TRUE);
            if (GetLocalInt(oNpc, "r_active"))
            {
                AL_ClearActiveRoute(oNpc, TRUE);
            }
            return;
        }

        AL_RegisterNPC(oNpc);
    }

    int nSlot = GetLocalInt(oNpc, "r_slot");
    if (nSlot >= 0 && nSlot <= AL_SLOT_MAX)
    {
        string sDesiredTag = AL_GetDesiredRouteTag(oNpc, nSlot);
        string sCurrentTag = AL_GetRouteTag(oNpc, nSlot);
        if (sCurrentTag != "" && sCurrentTag != sDesiredTag)
        {
            AL_ClearRoute(oNpc, nSlot);
        }
        AL_CacheRouteFromTag(oNpc, nSlot, sDesiredTag);
    }
    SignalEvent(oNpc, EventUserDefined(AL_EVT_RESYNC));
}

void AL_QueueRoute(object oNpc, int nSlot, int bClearActions)
{
    int iCount = AL_GetRouteCount(oNpc, nSlot);
    int i = 0;
    int bTransitionQueued = FALSE;

    if (bClearActions)
    {
        AssignCommand(oNpc, ClearAllActions());
    }

    if (iCount <= 0)
    {
        AL_ClearActiveRoute(oNpc, FALSE);
        return;
    }

    SetLocalInt(oNpc, "r_slot", nSlot);
    SetLocalInt(oNpc, "r_idx", 0);
    SetLocalInt(oNpc, "r_active", TRUE);

    while (i < iCount)
    {
        string sIndex = AL_GetRoutePrefix(nSlot) + IntToString(i);
        location lPoint = AL_GetRoutePoint(oNpc, nSlot, i);
        AssignCommand(oNpc, ActionMoveToLocation(lPoint));
        AssignCommand(oNpc, ActionDoCommand(AL_UpdateRouteIndex(oNpc, i)));
        location lJump = GetLocalLocation(oNpc, sIndex + "_jump");
        object oJumpArea = GetAreaFromLocation(lJump);
        if (GetIsObjectValid(oJumpArea))
        {
            AssignCommand(oNpc, ActionJumpToLocation(lJump));
            AssignCommand(oNpc, ActionDoCommand(AL_HandleRouteAreaTransition()));
            bTransitionQueued = TRUE;
            break;
        }
        i++;
    }

    if (!bTransitionQueued)
    {
        float fRepeatDelay = 5.0 + IntToFloat(Random(8));

        AssignCommand(oNpc, ActionWait(fRepeatDelay));
        AssignCommand(oNpc, ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVT_ROUTE_REPEAT))));
    }
}
