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
