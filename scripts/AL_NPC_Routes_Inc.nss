// NPC route helpers: store per-slot route locations in locals and enqueue actions.
// Locals format on NPC:
//   r<slot>_n      (int)    number of points
//   r<slot>_<idx>  (location) route point
// Runtime locals:
//   r_slot         (int)    active slot
//   r_idx          (int)    active index (optional)

#include "AL_Constants_Inc"

string AL_GetRoutePrefix(int nSlot)
{
    return "r" + IntToString(nSlot) + "_";
}

int AL_GetRouteCount(object oNpc, int nSlot)
{
    return GetLocalInt(oNpc, AL_GetRoutePrefix(nSlot) + "n");
}

location AL_GetRoutePoint(object oNpc, int nSlot, int iIndex)
{
    return GetLocalLocation(oNpc, AL_GetRoutePrefix(nSlot) + IntToString(iIndex));
}

void AL_ClearRoute(object oNpc, int nSlot)
{
    string sPrefix = AL_GetRoutePrefix(nSlot);
    int iCount = GetLocalInt(oNpc, sPrefix + "n");
    int i = 0;

    while (i < iCount)
    {
        DeleteLocalLocation(oNpc, sPrefix + IntToString(i));
        i++;
    }

    DeleteLocalInt(oNpc, sPrefix + "n");
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
    int iCount = 0;
    object oObj = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && GetTag(oObj) == sTag)
        {
            SetLocalLocation(oNpc, sPrefix + IntToString(iCount), GetLocation(oObj));
            iCount++;
        }
        oObj = GetNextObjectInArea(oArea);
    }

    if (iCount > 0)
    {
        SetLocalInt(oNpc, sPrefix + "n", iCount);
    }

    return iCount;
}

void AL_QueueRoute(object oNpc, int nSlot, int bClearActions)
{
    int iCount = AL_GetRouteCount(oNpc, nSlot);
    int i = 0;

    if (bClearActions)
    {
        AssignCommand(oNpc, ClearAllActions());
    }

    if (iCount <= 0)
    {
        DeleteLocalInt(oNpc, "r_slot");
        DeleteLocalInt(oNpc, "r_idx");
        return;
    }

    SetLocalInt(oNpc, "r_slot", nSlot);
    SetLocalInt(oNpc, "r_idx", 0);

    while (i < iCount)
    {
        location lPoint = AL_GetRoutePoint(oNpc, nSlot, i);
        AssignCommand(oNpc, ActionMoveToLocation(lPoint));
        i++;
    }

    AssignCommand(oNpc, ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVT_ROUTE_REPEAT))));
}
